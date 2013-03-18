//
//  FileManager.m
//  MyKeePass
//
//  Created by Qiang Yu on 3/3/10.
//  Copyright 2010 Qiang Yu. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>

//Keepass2 utils
#import <Utils.h>  

#import "FileManager.h"
#import "ASIHTTPRequest.h"
#import "ActivityView.h"

@interface FileManager(PrivateMethods)
- (id<KdbTree>)readFileHelp:(NSString *) fileName withPassword:(NSString *)password keyFile:(NSString *)keyFile;
@end


@implementation FileManager
@synthesize kdbReader = _kdbReader;
@synthesize editable = _editable;
@synthesize filename = _filename;
@synthesize password = _password;
@synthesize keyFilename = _keyFilename;
@synthesize dirty = _dirty;
@synthesize remoteFiles = _remoteFiles;
@synthesize listAllFiles;

//#define KDB_PATH "Passwords"
#define KDB_PATH ""
#define DOWNLOAD_PATH "Download"

#define KDB1_SUFFIX ".kdb"
#define KDB2_SUFFIX ".kdbx"

static NSString * DATA_DIR;
static NSString * DOWNLOAD_DIR;
static NSString * DOWNLOAD_CONFIG;

+ (void)initialize
{
    if ( self == [FileManager class] )
    {
#if TARGET_IPHONE_SIMULATOR		
		DATA_DIR = @"/Users/nike/Desktop/";		
		DOWNLOAD_DIR = DATA_DIR;
#else
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		DATA_DIR = [(NSString *)[paths objectAtIndex:0] stringByAppendingPathComponent:@KDB_PATH];
		DOWNLOAD_DIR = [(NSString *)[paths objectAtIndex:0] stringByAppendingPathComponent:@DOWNLOAD_PATH];
		NSFileManager * fileManager = [NSFileManager defaultManager];
		if (![fileManager fileExistsAtPath:DATA_DIR])
        {
			[fileManager createDirectoryAtPath:DATA_DIR withIntermediateDirectories:YES attributes:nil error:nil];
		}		
		if (![fileManager fileExistsAtPath:DOWNLOAD_DIR])
        {
			[fileManager createDirectoryAtPath:DOWNLOAD_DIR withIntermediateDirectories:YES attributes:nil error:nil];
		}				
#endif
		DOWNLOAD_CONFIG = [DOWNLOAD_DIR stringByAppendingPathComponent:@".download"];
		if (![[NSFileManager defaultManager] fileExistsAtPath:DOWNLOAD_CONFIG])
        {
			NSDictionary *dic = [[NSDictionary alloc] init];
			[dic writeToFile:DOWNLOAD_CONFIG atomically:YES];
		}
	}
}

+ (NSString *)dataDir
{
	return DATA_DIR;
}

- (id)init
{
	if ((self = [super init]))
    {
		self.remoteFiles = [NSMutableDictionary dictionaryWithContentsOfFile:DOWNLOAD_CONFIG];
        self.listAllFiles = NO;
	}	
	return self;
}

- (id<KdbTree>)readFile:(NSString *) fileName withPassword:(NSString *)password keyFile:(NSString *)keyFile
{
	self.filename = fileName;
	return [self readFileHelp:[FileManager getFullFileName:fileName] withPassword:password keyFile:keyFile];
}

- (id<KdbTree>)readFileHelp:(NSString *) fileName withPassword:(NSString *)password keyFile:(NSString *)keyFile
{
	self.password = password;
	self.dirty = NO;

	WrapperNSData *source = [[WrapperNSData alloc] initWithContentsOfMappedFile:fileName];
	self.kdbReader = [KdbReaderFactory kdbReader:source];
	//
	// only kdb3 file is editable so far
	//
	_editable = [_kdbReader isKindOfClass:[Kdb3Reader class]];
	[_kdbReader load:source withPassword:password keyFile:keyFile];
	return [_kdbReader getKdbTree];
}

+ (NSDictionary *)getKDBInfoFromFile:(NSString *)fileName
{
    NSMutableDictionary *dict = nil;
    
	WrapperNSData *input = [[WrapperNSData alloc]initWithContentsOfMappedFile:fileName];

	uint32_t signature1 = [Utils readInt32LE:input];
	uint32_t signature2 = [Utils readInt32LE:input];
	
    if (signature1 == KEEPASS_SIG)
    {
        dict = [NSMutableDictionary dictionary];
        [dict setObject:[NSNumber numberWithUnsignedInteger:signature2] forKey:@"signature2"];
        uint32_t flags, version = 0, minor_ver, major_ver;
        [dict setValue:@"Unknown" forKey:@"Cipher"];
        if (signature2 == KDB3_SIG2)
        {
            [dict setObject:@"KeePass 1" forKey:@"KeePassVersion"];
            
            flags = [Utils readInt32LE:input];
            version = [Utils readInt32LE:input];
            [dict setObject:[NSNumber numberWithUnsignedInteger:flags] forKey:@"Flags"];
            
            // TODO: TwoFish encription support
            if (flags & FLAG_RIJNDAEL)
                [dict setValue:@"AES" forKey:@"Cipher"];
            else if (flags & FLAG_TWOFISH)
                [dict setValue:@"TwoFish" forKey:@"Cipher"];
        }
        else if (signature2 == KDB4_SIG2 || signature2 == KDB4_PRE_SIG2)
        {
            if (signature2 == KDB4_PRE_SIG2)
                [dict setObject:@"KeePass 2a" forKey:@"KeePassVersion"];
            else
                [dict setObject:@"KeePass 2" forKey:@"KeePassVersion"];
            Kdb4Reader *reader = [[Kdb4Reader alloc] init];
            NSException *ex = [reader readHeader:input stop:NO];
            version = reader.fileVersion;
            if (ex)
            {
                [dict setObject:ex forKey:@"Exception"];
                [dict setValue:@"Unknown" forKey:@"Cipher"];
            }
            else
            {
                [dict setValue:@"AES" forKey:@"Cipher"];
            }
        }
        else
        {
            [dict setObject:@"KeePass ?" forKey:@"KeePassVersion"];
        }
        major_ver = (version & FILE_VERSION_CRITICAL_MASK) >> 16; minor_ver = (version & 0x0000FFFF);
        [dict setValue:[NSString stringWithFormat:@"%i.%02i",major_ver,minor_ver] forKey:@"FileVersion"];
    }
    input = nil;
    return (dict) ? [NSDictionary dictionaryWithDictionary:dict] : nil;
}

+ (NSString *)getTempFileNameFromURL:(NSString *)url
{
	ByteBuffer * buffer = [Utils createByteBufferForString:url coding:NSUTF8StringEncoding];
	uint8_t hash[20];
	CC_SHA1(buffer._bytes, buffer._size, hash);
	NSString * filename = [NSString  stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
						   hash[0], hash[1], hash[2], hash[3], hash[4], hash[5], hash[6], hash[7], hash[8], hash[9],
						   hash[10], hash[11], hash[12], hash[13], hash[14], hash[15], hash[16], hash[17], hash[18], hash[19], nil];
	
	return [DOWNLOAD_DIR stringByAppendingPathComponent:filename];
}

- (id<KdbTree>)readRemoteFile:(NSString *)filename withPassword:(NSString *)password useCached:(BOOL)useCached username:(NSString *)username userpass:(NSString *)userpass domain:(NSString *)domain
{
	self.filename = filename;
	
	NSString * url = [self getURLForRemoteFile:filename];
		
	if(!url) @throw [NSException exceptionWithName:@"DownloadError" reason:@"DownloadError" userInfo:nil];
	
	NSString * cacheFileName = [FileManager getTempFileNameFromURL:url];
	NSString * tmp = [cacheFileName stringByAppendingString:@".tmp"];
	
	NSFileManager * fileManager = [NSFileManager defaultManager];
	
	if([fileManager fileExistsAtPath:cacheFileName]&&useCached){
		id<KdbTree> tree = [self readFileHelp:cacheFileName withPassword:password keyFile:nil];
		_editable = NO;
		return tree;
	}
	 
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
	[request setDownloadDestinationPath:tmp];

	if([username length])
		[request setUsername:username];
	if([userpass length])
		[request setPassword:userpass];
	if([domain length])
		[request setDomain:domain];
	
	[request startSynchronous];
	
	int statusCode = [request responseStatusCode];	
	
	if(statusCode!=200){		
		if(statusCode==401){
			@throw [NSException exceptionWithName:@"RemoteAuthenticationError" reason:@"RemoteAuthenticationError" userInfo:nil];
		}else{			
			@throw [NSException exceptionWithName:@"DownloadError" reason:@"DownloadError" userInfo:nil];
		}
	}
	
	[[NSFileManager defaultManager] removeItemAtPath:cacheFileName error:nil];
	[[NSFileManager defaultManager] moveItemAtPath:tmp toPath:cacheFileName error:nil];	
	id<KdbTree> tree = [self readFileHelp:cacheFileName withPassword:password keyFile:nil];
	//remote file is not editable, yet
	_editable = NO;
	return tree;
}

- (void)getKDBFiles:(NSMutableArray *)list
{
	[list removeAllObjects];
    // TODO: Опция - показывать только KDB/KDBX файлы
	//kdb/kdbx files
	NSFileManager * fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
	NSArray *contents = [fileManager contentsOfDirectoryAtPath:DATA_DIR error:&error];
	for(NSString * fileName in contents){
		if(![fileName hasPrefix:@"."])
        {
//            if (self.listAllFiles || ([[fileName pathExtension]  caseInsensitiveCompare:@"kdb"] == NSOrderedSame)||([[fileName pathExtension]  caseInsensitiveCompare:@"kdbx"] == NSOrderedSame))
                NSDictionary *info = [FileManager getKDBInfoFromFile:[FileManager getFullFileName:fileName]];
                if (info)
                    [list addObject:fileName];
		}
	}
	[list sortUsingSelector:@selector(caseInsensitiveCompare:)];
}

- (void)getRemoteFiles:(NSMutableArray *)list
{
	[list removeAllObjects];
	[list addObjectsFromArray:[_remoteFiles keysSortedByValueUsingSelector:@selector(caseInsensitiveCompare:)]];
	[list sortUsingSelector:@selector(compare:)];
}

- (void)addRemoteFile:(NSString *)name Url:(NSString *)url
{
	[_remoteFiles setObject:url forKey:name];
	[_remoteFiles writeToFile:DOWNLOAD_CONFIG atomically:YES];	
}

- (NSString *)getURLForRemoteFile:(NSString *)name
{
	return [_remoteFiles objectForKey:name];
}

- (void)deleteLocalFile:(NSString *)filename
{
	[[NSFileManager defaultManager] removeItemAtPath:[FileManager getFullFileName:filename] error:nil];
}

- (void)deleteRemoteFile:(NSString *)name
{
	[_remoteFiles removeObjectForKey:name];
	[_remoteFiles writeToFile:DOWNLOAD_CONFIG atomically:YES];	
}

- (NSUInteger) getKDBVersion
{
	if([_kdbReader isKindOfClass:[Kdb3Reader class]]){
		return KDB_VERSION1;
	}else{
		return KDB_VERSION2;
	}
}

- (void)save
{
	if(!_dirty) return;
	if([_kdbReader isKindOfClass:[Kdb3Reader class]])
    {
		Kdb3Writer * writer = nil;
		@try{
			writer = [[Kdb3Writer alloc] init];
			[writer persist:[_kdbReader getKdbTree] file:[FileManager getFullFileName:_filename] withPassword:_password keyFile:_keyFilename];
			_dirty = NO;
		}@finally {
		}
	}
}

+ (NSString *)getFullFileName:(NSString *)filename
{
	return [DATA_DIR stringByAppendingPathComponent:filename];
}

+ (void)newKdb3File:(NSString *)filename withPassword:(NSString *)password keyFile:(NSString *)keyFile
{
	Kdb3Writer * writer = nil;
	@try{
		writer = [[Kdb3Writer alloc]init];
		[writer newFile:[FileManager getFullFileName:filename] withPassword:password keyFile:keyFile];
	}@finally {
	}
}

@end
