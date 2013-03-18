//
//  PasswordGenerator.m
//  ruPassword
//
//  Created by Nikita Galayko on 14.02.13.
//  Copyright (c) 2013 Galayko.ru. All rights reserved.
//

#import "PasswordGenerator.h"

// Для NSUserDefaults
#define kPasswordLengthKey      @"PswLen"
#define kUseUpcaseCharsKey      @"upcaseSw"
#define kUseLocaseCharsKey      @"locaseSw"
#define kUseNumbersKey          @"numbersSw"
#define kUseOnlyUniqueCharsKey  @"uniqSw"
#define kUseSpecialCharsKey     @"specialSw"
#define kUseCustomCharsKey      @"charsSw"
#define kCustomCharsKey         @"useChars"

@implementation PasswordGenerator
@synthesize passwordLength, passwordVariableMaximum;
@synthesize useLocaseChars, useUpcaseChars, useNumbers, useSpecialChars, useOnlyUniqueChars, useCustomChars;
@synthesize customChars;

+ (id)generator
{
    PasswordGenerator *generator = [[PasswordGenerator alloc] init];
    return generator;
}

- (id)init
{
    if ((self = [super init]))
    {
        [self loadSettings];
        [self initializeRandomGenerator];
        [self updatePasswordChars];
    }
    return self;
}

- (void)initializeRandomGenerator
{
    srandom(time(NULL));
}

- (NSUInteger)maximumLength
{
    return _maxLength;
}

- (void)updatePasswordChars
{
    passwordChars = [NSMutableString string];
    if ( useLocaseChars ) [passwordChars appendString: PASSWORD_LOCASE_CHARS];
    if ( useUpcaseChars ) [passwordChars appendString: PASSWORD_UPCASE_CHARS];
    if ( useNumbers ) [passwordChars appendString: @"0123456789"];
    if ( useSpecialChars ) [passwordChars appendString: PASSWORD_SPECIAL_CHARS];
    if ( useCustomChars && ([customChars length] > 0) ) [passwordChars appendString: customChars];
}

- (NSString *)generate
{
    [self updatePasswordChars];
    _maxLength = PASSWORD_MAX_LENGTH;
    NSMutableString *pass = [[NSMutableString alloc] init];
    int passwordCharsLength = passwordChars.length;
    if ( passwordCharsLength > 0 )
    {
        if ( useOnlyUniqueChars )
        {
            // TODO: check passwordChars for unique chars
            if ( passwordLength > passwordCharsLength ) passwordLength = passwordCharsLength;
            if ( passwordCharsLength < _maxLength ) _maxLength = passwordCharsLength;
        }
        int pswLen = passwordLength;
        if (passwordVariableMaximum > pswLen)
        {
            pswLen += arc4random() % (passwordVariableMaximum - pswLen);
            if (pswLen > _maxLength) pswLen = _maxLength;
        }
        NSMutableString *passChars = [NSMutableString stringWithString:passwordChars];
        for (int i = 0; i < pswLen; i++)
        {
            int r = arc4random() % passChars.length;
            unichar uc = [passChars characterAtIndex:r];
            if (useOnlyUniqueChars) [passChars deleteCharactersInRange:NSMakeRange(r, 1)];
            [pass appendString:[NSString stringWithCharacters:&uc length:1]];
        }
    }
    return [NSString stringWithString:pass];
}

- (void)saveSettings
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:passwordLength forKey:kPasswordLengthKey];
    [userDefaults setBool:useUpcaseChars forKey:kUseUpcaseCharsKey];
    [userDefaults setBool:useLocaseChars forKey:kUseLocaseCharsKey];
    [userDefaults setBool:useNumbers forKey:kUseNumbersKey];
    [userDefaults setBool:useOnlyUniqueChars forKey:kUseOnlyUniqueCharsKey];
    [userDefaults setBool:useSpecialChars forKey:kUseSpecialCharsKey];
    [userDefaults setBool:useCustomChars forKey:kUseCustomCharsKey];
    if (customChars && [customChars isKindOfClass:[NSString class]])
        [userDefaults setObject:customChars forKey:kCustomCharsKey];
    else
        [userDefaults removeObjectForKey:kCustomCharsKey];
    [userDefaults synchronize];
}

- (void)defaultSettings
{
    useLocaseChars = YES; useUpcaseChars = YES; useNumbers = YES; useSpecialChars = NO; useOnlyUniqueChars = NO;
    customChars = @""; useCustomChars = NO; passwordLength = 8; passwordVariableMaximum = 0;
    _maxLength = PASSWORD_MAX_LENGTH;
}

- (void)loadSettings
{
    [self defaultSettings];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *defs = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:passwordLength], kPasswordLengthKey, [NSNumber numberWithBool:useUpcaseChars], kUseUpcaseCharsKey, [NSNumber numberWithBool:useLocaseChars], kUseLocaseCharsKey, [NSNumber numberWithBool:useNumbers], kUseNumbersKey, [NSNumber numberWithBool:useOnlyUniqueChars], kUseOnlyUniqueCharsKey, [NSNumber numberWithBool:useSpecialChars], kUseSpecialCharsKey, [NSNumber numberWithBool:useCustomChars], kUseCustomCharsKey, customChars, kCustomCharsKey, nil];
    [userDefaults registerDefaults:defs];
    
    passwordLength = [userDefaults integerForKey:kPasswordLengthKey];
    useUpcaseChars = [userDefaults boolForKey:kUseUpcaseCharsKey];
    useLocaseChars = [userDefaults boolForKey:kUseLocaseCharsKey];
    useNumbers = [userDefaults boolForKey:kUseNumbersKey];
    useOnlyUniqueChars = [userDefaults boolForKey:kUseOnlyUniqueCharsKey];
    useSpecialChars = [userDefaults boolForKey:kUseSpecialCharsKey];
    useCustomChars = [userDefaults boolForKey:kUseCustomCharsKey];
    customChars = [userDefaults stringForKey:kCustomCharsKey];
}

@end
