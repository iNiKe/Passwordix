//
//  FileManagerOperation.m
//  MyKeePass
//
//  Created by Qiang Yu on 3/24/10.
//  Copyright 2010 Qiang Yu. All rights reserved.
//

#import "FileManagerOperation.h"
#import "FileManager.h"

@implementation FileManagerOperation

@synthesize _filename;
@synthesize _password;
@synthesize _keyFile;
@synthesize _username;
@synthesize _userpass;
@synthesize _domain;
@synthesize _useCache;
@synthesize delegate = _delegate;

- (id)initWithDelegate:(id<FileManagerOperationDelegate>)delegate
{
	if ((self = [super init]))
    {
		_delegate = delegate;
	}
	return self;
}

- (void)openLocalFile
{
	@try
    {
		[MyAppDelegate.fileManager readFile:_filename withPassword:_password keyFile:_keyFile];
		[((NSObject *)_delegate) performSelectorOnMainThread:@selector(fileOperationSuccess) withObject:nil waitUntilDone:NO];
	}
    @catch(NSException * exception)
    {
		[((NSObject *)_delegate) performSelectorOnMainThread:@selector(fileOperationFailureWithException:) withObject:exception waitUntilDone:NO];
	}
    @finally { }
}

- (void)openRemoteFile
{
	@try
    {
		[MyAppDelegate.fileManager readRemoteFile:_filename withPassword:_password useCached:_useCache username:_username userpass:_userpass domain:_domain];
		[((NSObject *)_delegate) performSelectorOnMainThread:@selector(fileOperationSuccess) withObject:nil waitUntilDone:NO];
	}
    @catch(NSException * exception)
    {
		[((NSObject *)_delegate) performSelectorOnMainThread:@selector(fileOperationFailureWithException:) withObject:exception waitUntilDone:NO];
	}
    @finally { }
	
}

- (void)save
{
	@try
    {
		[MyAppDelegate.fileManager save];
		[((NSObject *)_delegate) performSelectorOnMainThread:@selector(fileOperationSuccess) withObject:nil waitUntilDone:NO];
	}
    @catch(NSException * exception)
    {
		[((NSObject *)_delegate) performSelectorOnMainThread:@selector(fileOperationFailureWithException:) withObject:exception waitUntilDone:NO];
	}
    @finally { }	
}

@end
