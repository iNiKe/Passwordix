//
//  PasswordGenerator.h
//  ruPassword
//
//  Created by Nikita Galayko on 14.02.13.
//  Copyright (c) 2013 Galayko.ru. All rights reserved.
//

#import <Foundation/Foundation.h>

#define PASSWORD_LOCASE_CHARS   @"qwertyuiopasdfghjklzxcvbnm"
#define PASSWORD_UPCASE_CHARS   @"QWERTYUIOPASDFGHJKLZXCVBNM"
#define PASSWORD_SPECIAL_CHARS  @"!@#$%^&*(){}[];:'\"\\<>,./?`~"
#define PASSWORD_MAX_LENGTH     128

@interface PasswordGenerator : NSObject
{
    NSMutableString *passwordChars;
    int _maxLength;
}

@property (nonatomic, assign) NSUInteger passwordLength, passwordVariableMaximum;
@property (nonatomic, assign) BOOL useLocaseChars, useUpcaseChars, useNumbers, useSpecialChars, useOnlyUniqueChars, useCustomChars;
@property (nonatomic, strong) NSString *customChars;

+ (id)generator;
- (void)initializeRandomGenerator;
- (NSString *)generate;
- (NSUInteger)maximumLength;
- (void)saveSettings;
- (void)loadSettings;
- (void)defaultSettings;

@end
