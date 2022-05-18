//
//  NSString+Check.m
//  MeetingTestDemo_MAC
//
//  Created by YunWu01 on 2021/10/14.
//

#import "NSString+Check.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Check)

#pragma mark - public methods
+ (BOOL)stringCheckEmptyOrNil:(NSString *)aString
{
    return aString == nil ? YES : [aString checkEmptyOrNil];
}

+ (BOOL)stringCheckEmptyWhiteSpaceOrNil:(NSString *)aString
{
    return aString == nil ? YES : [aString checkEmptyWhiteSpaceOrNil];
}

#pragma mark - private methods
- (BOOL)checkEmptyOrNil
{
    return [self length] <= 0 ? YES : NO;
}

- (BOOL)checkEmptyWhiteSpaceOrNil
{
    NSString *trimedString = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return [trimedString length] <= 0 ? YES : NO;
}


+ (NSString *)md5:(NSString *)inStr
{
    const char *cStr = [inStr UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)inStr.length, digest);
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02x", digest[i]];
    }
    
    return result;
    
    
}

+ (NSString *)MD5:(NSString *)inStr
{
    const char *cStr = [inStr UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    NSMutableString *str = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
    
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [str appendFormat:@"%02X", result[i]];
    }
    
    return str;
}

@end
