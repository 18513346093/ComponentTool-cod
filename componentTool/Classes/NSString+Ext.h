//
//  NSString+Ext.h
//  BjAiSports
//
//  Created by 吴林丰 on 2018/12/18.
//  Copyright © 2018 吴林丰. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Ext)
//过滤表情
- (NSString *)emojizedString;
+ (NSString *)emojizedStringWithString:(NSString *)text;
+ (BOOL)stringContainsEmoji:(NSString *)string;
+ (NSString *)disable_emoji:(NSString *)text;

/**
 * 获取设备名称
 */
+ (NSString *)getDeviceName;
+(CGFloat) heightForString:(NSString *)value fontSize:(CGFloat)fontSize andWidth:(CGFloat)width;
-(CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize;
-(BOOL)hasString:(NSString *)str;
+ (BOOL)isSIMInstalled;//能否打电话
//model解析为json串
- (NSString *)returnSaveModelJsonString:(id)model;
@end

NS_ASSUME_NONNULL_END
