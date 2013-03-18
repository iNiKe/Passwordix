//
//  KdbDocument.m
//  ruPassword
//
//  Created by Nikita Galayko on 21.02.13.
//  Copyright (c) 2013 Galayko.ru. All rights reserved.
//

#import "KdbDocument.h"

@implementation KdbDocument

// Called whenever the application reads data from the file system
- (BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError **)outError
{
    _dataContent = [[NSData alloc] initWithBytes:[contents bytes] length:[contents length]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"dataModified" object:self];
    return YES;
}

// Called whenever the application (auto)saves the content of a note
- (id)contentsForType:(NSString *)typeName error:(NSError **)outError
{
    return _dataContent;
}

@end
