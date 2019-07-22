//
//  NSString+Ext.m
//  BjAiSports
//
//  Created by 吴林丰 on 2018/12/18.
//  Copyright © 2018 吴林丰. All rights reserved.
//

#import "NSString+Ext.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

@implementation NSString (Ext)


- (NSString *)emojizedString
{
    return [NSString emojizedStringWithString:self];
}

+ (NSString *)emojizedStringWithString:(NSString *)text
{
    __block NSString *filterStr = [NSString stringWithString:text];
    [text enumerateSubstringsInRange:NSMakeRange(0, [text length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         
         const unichar hs = [substring characterAtIndex:0];
         // surrogate pair
         if (0xd800 <= hs && hs <= 0xdbff) {
             if (substring.length > 1) {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1F9FF) {
                     filterStr = [text stringByReplacingOccurrencesOfString:substring withString:@""];
                 }
             }
         } else if ((0x2100 <= hs && hs <= 0x27ff) || (0x2B05 <= hs && hs <= 0x2b07)||(0x2934 <= hs && hs <= 0x2935)|| (0x3297 <= hs && hs <= 0x3299) || hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
             filterStr = [text stringByReplacingOccurrencesOfString:substring withString:@""];
         }else if (substring.length > 1) {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3) {
                 filterStr = [text stringByReplacingOccurrencesOfString:substring withString:@""];
             }
         }
     }];
    
    return filterStr;
}

#pragma mark ---- 禁止表情
+ (BOOL)stringContainsEmoji:(NSString *)string {
    __block BOOL returnValue = NO;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         const unichar hs = [substring characterAtIndex:0];
         // surrogate pair
         if (0xd800 <= hs && hs <= 0xdbff) {
             if (substring.length > 1) {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f77f) {
                     returnValue = YES;
                 }
             }
             if (substring.length > 1) {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1F9FF) {
                     returnValue = YES;
                 }
             }
         } else if (substring.length > 1) {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3) {
                 returnValue = YES;
             }
             if (0x2100 <= hs && hs <= 0x27ff) {
                 returnValue = YES;
             } else if (0x2B05 <= hs && hs <= 0x2b07) {
                 returnValue = YES;
             } else if (0x2934 <= hs && hs <= 0x2935) {
                 returnValue = YES;
             } else if (0x3297 <= hs && hs <= 0x3299) {
                 returnValue = YES;
             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                 returnValue = YES;
             }
             
         } else {
             // non surrogate
             if (0x2100 <= hs && hs <= 0x27ff) {
                 returnValue = YES;
             } else if (0x2B05 <= hs && hs <= 0x2b07) {
                 returnValue = YES;
             } else if (0x2934 <= hs && hs <= 0x2935) {
                 returnValue = YES;
             } else if (0x3297 <= hs && hs <= 0x3299) {
                 returnValue = YES;
             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                 returnValue = YES;
             }
         }
     }];
    return returnValue;
}

+ (NSString *)disable_emoji:(NSString *)text
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]" options:NSRegularExpressionCaseInsensitive error:nil];
    NSString *modifiedString = [regex stringByReplacingMatchesInString:text
                                                               options:0
                                                                 range:NSMakeRange(0, [text length])
                                                          withTemplate:@""];
    return modifiedString;
}

+ (NSString *)getDeviceName{
    
    size_t size;
    // get the length of machine name
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    // get machine name
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *correspondVersion = [NSString stringWithFormat:@"%s", machine];
    free(machine);
    //------------------------------iTouch------------------------
    if ([correspondVersion isEqualToString:@"iPod1,1"]) return @"iTouch";
    if ([correspondVersion isEqualToString:@"iPod2,1"]) return @"iTouch2";
    if ([correspondVersion isEqualToString:@"iPod3,1"]) return @"iTouch3";
    if ([correspondVersion isEqualToString:@"iPod4,1"]) return @"iTouch4";
    if ([correspondVersion isEqualToString:@"iPod5,1"]) return @"iTouch5";
    if ([correspondVersion isEqualToString:@"iPod7,1"]) return @"iTouch6";
    //------------------------------Samulitor------------------------
    if ([@"i386" isEqualToString:correspondVersion])        return@"Simulator";
    if ([@"x86_64" isEqualToString:correspondVersion])       return @"Simulator";
    //------------------------------IPhone------------------------
    if ([@"iPhone1,1" isEqualToString:correspondVersion])   return@"iPhone 1";
    if ([@"iPhone1,2" isEqualToString:correspondVersion])   return@"iPhone 3";
    if ([@"iPhone2,1" isEqualToString:correspondVersion])   return@"iPhone 3S";
    if ([@"iPhone3,1" isEqualToString:correspondVersion] || [@"iPhone3,2" isEqualToString:correspondVersion])   return@"iPhone 4";
    if ([@"iPhone4,1" isEqualToString:correspondVersion])   return@"iPhone 4S";
    if ([@"iPhone5,1" isEqualToString:correspondVersion] || [@"iPhone5,2" isEqualToString:correspondVersion])   return @"iPhone 5";
    if ([@"iPhone5,3" isEqualToString:correspondVersion] || [@"iPhone5,4" isEqualToString:correspondVersion])   return @"iPhone 5C";
    if ([@"iPhone6,1" isEqualToString:correspondVersion] || [@"iPhone6,2" isEqualToString:correspondVersion])   return @"iPhone 5S";
    
    if ([@"iPhone7,2" isEqualToString:correspondVersion]) return @"iPhone 6";
    if ([@"iPhone7,1" isEqualToString:correspondVersion]) return @"iPhone 6 Plus";
    if ([@"iPhone8,1" isEqualToString:correspondVersion]) return @"iPhone 6s";
    if ([@"iPhone8,2" isEqualToString:correspondVersion]) return @"iPhone 6s Plus";
    if ([@"iPhone8,4" isEqualToString:correspondVersion]) return @"iPhone SE";
    if ([@"iPhone9,1" isEqualToString:correspondVersion]) return @"iPhone 7";
    if ([@"iPhone9,2" isEqualToString:correspondVersion]) return @"iPhone 7 plus";
    if ([@"iPhone10,1" isEqualToString:correspondVersion]) return @"iPhone 8";
    if ([@"iPhone10,4" isEqualToString:correspondVersion]) return @"iPhone 8";
    if ([@"iPhone10,2" isEqualToString:correspondVersion]) return @"iPhone 8 plus";
    if ([@"iPhone10,5" isEqualToString:correspondVersion]) return @"iPhone 8 plus";
    if ([@"iPhone10,3" isEqualToString:correspondVersion]) return @"iPhone X";
    if ([@"iPhone10,6" isEqualToString:correspondVersion]) return @"iPhone X";
    if ([@"iPod1,1" isEqualToString:correspondVersion])     return@"iPod Touch 1";
    if ([@"iPod2,1" isEqualToString:correspondVersion])     return@"iPod Touch 2";
    if ([@"iPod3,1" isEqualToString:correspondVersion])     return@"iPod Touch 3";
    if ([@"iPod4,1" isEqualToString:correspondVersion])     return@"iPod Touch 4";
    if ([@"iPod5,1" isEqualToString:correspondVersion])     return@"iPod Touch 5";
    if ([@"iPhone11,8" isEqualToString:correspondVersion]) return @"iPhone XR";
    if ([@"iPhone11,2" isEqualToString:correspondVersion]) return @"iPhone XS";
    if ([@"iPhone11,4" isEqualToString:correspondVersion] ||
        [@"iPhone11,6" isEqualToString:correspondVersion]) return @"iPhone XS Max";
    
    
    
    //------------------------------IPad------------------------
    if ([@"iPad6,7" isEqualToString:correspondVersion])   return@"iPad pro";
    if ([@"iPad1,1" isEqualToString:correspondVersion])     return@"iPad 1";
    if ([@"iPad2,1" isEqualToString:correspondVersion] || [@"iPad2,2" isEqualToString:correspondVersion] || [@"iPad2,3" isEqualToString:correspondVersion] || [@"iPad2,4" isEqualToString:correspondVersion])     return@"iPad 2";
    if ([@"iPad2,5" isEqualToString:correspondVersion] || [@"iPad2,6" isEqualToString:correspondVersion] || [@"iPad2,7" isEqualToString:correspondVersion] )      return @"iPad Mini";
    if ([@"iPad3,1" isEqualToString:correspondVersion] || [@"iPad3,2" isEqualToString:correspondVersion] || [@"iPad3,3" isEqualToString:correspondVersion] || [@"iPad3,4" isEqualToString:correspondVersion] || [@"iPad3,5" isEqualToString:correspondVersion] || [@"iPad3,6" isEqualToString:correspondVersion])      return @"iPad 3";
    
    
    return @"iphone";
    
}
+(CGFloat) heightForString:(NSString *)value fontSize:(CGFloat)fontSize andWidth:(CGFloat)width{
    CGSize picSize =[value boundingRectWithSize:CGSizeMake(width,CGFLOAT_MAX)
                        options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                          attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]}
                                             context:nil].size;
    return picSize.height;
}

//返回字符串所占用的尺寸.
-(CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize
{
    NSDictionary *attrs;
    if(nil == font){
        attrs = @{NSFontAttributeName : [UIFont systemFontOfSize:19]};
    }else{
        attrs = @{NSFontAttributeName : font};
    }
    return [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}
-(BOOL)hasString:(NSString *)str{
    if([self rangeOfString:str].location != NSNotFound){
        return NO;
    }else{
        return YES;
    }
}

+ (BOOL)isSIMInstalled
{
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [networkInfo subscriberCellularProvider];
    
    if (!carrier.isoCountryCode) {
        return NO;
    }
    return YES;
}

@end
