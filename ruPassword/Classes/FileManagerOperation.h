//
//  FileManagerOperation.h
//  MyKeePass
//
//  Created by Qiang Yu on 3/24/10.
//  Copyright 2010 Qiang Yu. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 * a help class to make open/save KDB file in the background easier
 */
 
@protocol FileManagerOperationDelegate <NSObject>
- (void)fileOperationSuccess;
- (void)fileOperationFailureWithException:(NSException *)exception;
@end

@interface FileManagerOperation : NSOperation
{
	NSString * _filename;
	NSString * _password;
    NSString * _keyFile;
	NSString * _username;
	NSString * _userpass;
	NSString * _domain;
	
	BOOL _useCache;
}

@property(nonatomic, unsafe_unretained) id<FileManagerOperationDelegate> delegate;
@property(nonatomic, strong) NSString * _filename;
@property(nonatomic, strong) NSString * _password;
@property(nonatomic, strong) NSString * _keyFile;
@property(nonatomic, strong) NSString * _username;
@property(nonatomic, strong) NSString * _userpass;
@property(nonatomic, strong) NSString * _domain;
@property(nonatomic, assign) BOOL _useCache;

- (id)initWithDelegate:(id<FileManagerOperationDelegate>)delegate;
- (void)openLocalFile;
- (void)openRemoteFile;
- (void)save;

@end
