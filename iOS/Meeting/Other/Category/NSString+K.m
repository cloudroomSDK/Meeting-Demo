//
//  NSString+K.m
//  SearchContacts
//
//  Created by apple on 14/11/11.
//  Copyright (c) 2014年 TJF. All rights reserved.
//

#import "NSString+K.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (K)
#pragma mark - public methods
+ (BOOL)stringCheckEmptyOrNil:(NSString *)aString
{
    return aString == nil ? YES : [aString checkEmptyOrNil];
}

+ (BOOL)stringCheckEmptyWhiteSpaceOrNil:(NSString *)aString
{
    return aString == nil ? YES : [aString checkEmptyWhiteSpaceOrNil];
}

/**
 *  是否以数字或其他字符(A~Z或者a~z以外的字符)开头
 *
 *  @param aString 字符串
 *
 *  @return TRUE/FALSE
 */
+ (BOOL)StartWithNumberOrOther:(NSString *)aString
{
    if ([NSString stringCheckEmptyOrNil:aString] == NO)
    {
        unichar ch = [aString characterAtIndex:0];
        
        if ((ch >= 'A' && ch <= 'Z') || (ch >= 'a' && ch <= 'z'))
        {
            return FALSE;
        }
        else
        {
            return TRUE;
        }
    }
    
    return FALSE;
}

/**
 *  是否以数字或其他字符(A~Z或者a~z以外的字符)开头
 *
 *  @param aString 字符串
 *
 *  @return TRUE/FALSE
 */
+ (BOOL)startWithoutHanYuAndAlpha:(NSString *)aString
{
    if ([aString length] > 0)
    {
        unichar ch = [aString characterAtIndex:0];
        
        if ((ch >= 'A' && ch <= 'Z') || (ch >= 'a' && ch <= 'z'))
        {
            return FALSE;
        }
        else
        {
            return TRUE;
        }
    }
    
    return FALSE;
}

/**
 *  字符串转数组
 *
 *  @param aString 待转字符串
 *
 *  @return 数组
 */
+ (NSArray *)translateToArrayFromString:(NSString *)aString
{
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    
    NSInteger stringLength = aString.length;
    
    for (NSInteger i = 0; i < stringLength; i++)
    {
        // one:
//        unichar ch = [string characterAtIndex:i];
//        [tempArray addObject:[NSString stringWithFormat:@"%c",ch]];
        
        // two:
        [tempArray addObject:[aString substringWithRange:NSMakeRange(i, 1)]];
    }
    
    return [NSArray arrayWithArray:tempArray];
}

/**
 *  判断是否包含子串
 *
 *  @param aString 子串
 *
 *  @return YES/NO
 */
- (BOOL)containsWithString:(NSString *)aString
{
    if ([[[UIDevice currentDevice] systemName] floatValue] >= 8.0)
    {
        if ([self containsString:aString] == YES)
        {
            return TRUE;
        }
    }
    else
    {
        if ([self rangeOfString:aString].length > 0)
        {
            return TRUE;
        }
    }
    
    return FALSE;
}

/**
 *  计算文字的高度
 *
 *  @param font  字体(默认为系统字体)
 *  @param width 约束宽度
 *
 *  @return 文字高度
 */
- (CGFloat)heightWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width
{
    UIFont *textFont = font ? font : [UIFont systemFontOfSize:[UIFont systemFontSize]];
    
    CGSize textSize;
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)] == YES)
    {
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        
        paragraph.lineBreakMode = NSLineBreakByWordWrapping;
        
        NSDictionary *attributes = @{
                                     NSFontAttributeName : textFont,
                                     NSParagraphStyleAttributeName : paragraph
                                     };
        
        textSize = [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                      options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine)
                                   attributes:attributes
                                      context:nil].size;
    }
    else
    {
        textSize = [self sizeWithFont:textFont
                    constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                        lineBreakMode:NSLineBreakByWordWrapping];
    }
#else
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName : textFont,
                                 NSParagraphStyleAttributeName : paragraph
                                 };
    
    textSize = [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                  options:(NSStringDrawingUsesLineFragmentOrigin |
                                           NSStringDrawingTruncatesLastVisibleLine)
                               attributes:attributes
                                  context:nil].size;
#endif
    
    return ceil(textSize.height);
}

/**
 *  计算文字的宽度
 *
 *  @param font   字体(默认为系统字体)
 *  @param height 约束高度
 *
 *  @return 文字宽度
 */
- (CGFloat)widthWithFont:(UIFont *)font constrainedToHeight:(CGFloat)height
{
    UIFont *textFont = font ? font : [UIFont systemFontOfSize:[UIFont systemFontSize]];
    
    CGSize textSize;
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)] == YES)
    {
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        
        paragraph.lineBreakMode = NSLineBreakByWordWrapping;
        
        NSDictionary *attributes = @{
                                     NSFontAttributeName: textFont,
                                     NSParagraphStyleAttributeName: paragraph
                                     };
        
        textSize = [self boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height)
                                      options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine)
                                   attributes:attributes
                                      context:nil].size;
    }
    else
    {
        textSize = [self sizeWithFont:textFont
                    constrainedToSize:CGSizeMake(CGFLOAT_MAX, height)
                        lineBreakMode:NSLineBreakByWordWrapping];
    }
#else
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName: textFont,
                                 NSParagraphStyleAttributeName: paragraph
                                 };
    
    textSize = [self boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height)
                                  options:(NSStringDrawingUsesLineFragmentOrigin |
                                           NSStringDrawingTruncatesLastVisibleLine)
                               attributes:attributes
                                  context:nil].size;
#endif
    
    return ceil(textSize.width);
}

/**
 *  计算文字的大小
 *
 *  @param font  字体(默认为系统字体)
 *  @param width 约束宽度
 *
 *  @return 文字大小
 */
- (CGSize)sizeWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width
{
    UIFont *textFont = font ? font : [UIFont systemFontOfSize:[UIFont systemFontSize]];
    
    CGSize textSize;
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)] == YES)
    {
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        
        paragraph.lineBreakMode = NSLineBreakByWordWrapping;
        
        NSDictionary *attributes = @{
                                     NSFontAttributeName: textFont,
                                     NSParagraphStyleAttributeName: paragraph
                                     };
        
        textSize = [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                      options:(NSStringDrawingUsesLineFragmentOrigin |
                                               NSStringDrawingTruncatesLastVisibleLine)
                                   attributes:attributes
                                      context:nil].size;
    }
    else
    {
        textSize = [self sizeWithFont:textFont
                    constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                        lineBreakMode:NSLineBreakByWordWrapping];
    }
#else
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName: textFont,
                                 NSParagraphStyleAttributeName: paragraph
                                 };
    
    textSize = [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                  options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine)
                               attributes:attributes
                                  context:nil].size;
#endif
    
    return CGSizeMake(ceil(textSize.width), ceil(textSize.height));
}

/**
 *  计算文字的大小
 *
 *  @param font   字体(默认为系统字体)
 *  @param height 约束高度
 *
 *  @return 文字大小
 */
- (CGSize)sizeWithFont:(UIFont *)font constrainedToHeight:(CGFloat)height
{
    UIFont *textFont = font ? font : [UIFont systemFontOfSize:[UIFont systemFontSize]];
    
    CGSize textSize;
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)] == YES)
    {
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        
        paragraph.lineBreakMode = NSLineBreakByWordWrapping;
        
        NSDictionary *attributes = @{
                                     NSFontAttributeName: textFont,
                                     NSParagraphStyleAttributeName: paragraph
                                     };
        
        textSize = [self boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height)
                                      options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine)
                                   attributes:attributes
                                      context:nil].size;
    }
    else
    {
        textSize = [self sizeWithFont:textFont
                    constrainedToSize:CGSizeMake(CGFLOAT_MAX, height)
                        lineBreakMode:NSLineBreakByWordWrapping];
    }
#else
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName: textFont,
                                 NSParagraphStyleAttributeName: paragraph
                                 };
    
    textSize = [self boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height)
                                  options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine)
                               attributes:attributes
                                  context:nil].size;
#endif
    
    return CGSizeMake(ceil(textSize.width), ceil(textSize.height));
}

// 十六进制转换为普通字符串
+ (NSString *)stringFromHexString:(NSString *)hexString
{
    char *myBuffer = (char *)malloc((int)[hexString length] / 2 + 1);
    bzero(myBuffer, [hexString length] / 2 + 1);
    
    for (int i = 0; i < [hexString length] - 1; i += 2) {
        unsigned int anInt;
        NSString * hexCharStr = [hexString substringWithRange:NSMakeRange(i, 2)];
        NSScanner * scanner = [[NSScanner alloc] initWithString:hexCharStr];
        [scanner scanHexInt:&anInt];
        myBuffer[i / 2] = (char)anInt;
    }
    
    NSString *unicodeString = [NSString stringWithCString:myBuffer encoding:NSUTF8StringEncoding];
    NSLog(@"------字符串=======%@",unicodeString);
    return unicodeString;
}

// 普通字符串转换为十六进制
+ (NSString *)hexStringFromString:(NSString *)string
{
    NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    // 下面是Byte 转换为16进制
    NSString *hexStr = @"";
    
    for(int i = 0;i < [myD length]; i++) {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff]; // 16进制数
        
        if([newHexStr length] == 1) {
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        }
        else {
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
        }
    }
    return hexStr;
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

@end
