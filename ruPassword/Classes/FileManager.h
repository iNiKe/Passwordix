//
//  FileManager.h
//  MyKeePass
//
//  Created by Qiang Yu on 3/3/10.
//  Copyright 2010 Qiang Yu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KdbLib.h>

#define KDB_VERSION1 1
#define KDB_VERSION2 2

@interface FileManager : NSObject {
	//e.g. test.kdb; directory information is not included;
	//if it is a remote file remote<->http://www.exaple.com, _filename=remote
}

@property(nonatomic, strong) id<KdbReader> kdbReader;
@property(nonatomic, assign) BOOL editable, dirty;
@property(nonatomic, strong) NSString *filename, *password, *keyFilename;
@property(nonatomic, strong) NSMutableDictionary *remoteFiles;
@property (nonatomic, assign) BOOL listAllFiles;

- (void)getKDBFiles:(NSMutableArray *)list;
- (id<KdbTree>)readFile:(NSString *)fileName withPassword:(NSString *)password keyFile:(NSString *)keyFile;
- (id<KdbTree>)readRemoteFile:(NSString *)filename withPassword:(NSString *)password useCached:(BOOL)useCached username:(NSString *)username userpass:(NSString *)userpass domain:(NSString *)domain;
+ (NSDictionary *)getKDBInfoFromFile:(NSString *)fileName;
- (void)deleteLocalFile:(NSString *)filename;

//get the KDB version of the current opened file
- (NSUInteger) getKDBVersion;

//manage remote files
- (void)getRemoteFiles:(NSMutableArray *)list;
- (void)addRemoteFile:(NSString *)name Url:(NSString *)url;
- (void)deleteRemoteFile:(NSString *)name;
- (NSString *)getURLForRemoteFile:(NSString *)name;

- (void)save;

//
+ (void)newKdb3File:(NSString *)filename withPassword:(NSString *)password keyFile:(NSString *)keyFile;
+ (NSString *)getTempFileNameFromURL:(NSString *)url;
+ (NSString *)getFullFileName:(NSString *)filename;

+ (NSString *)dataDir;

@end
