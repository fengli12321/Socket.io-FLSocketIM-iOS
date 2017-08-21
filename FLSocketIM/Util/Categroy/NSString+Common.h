//
//  NSString+Common.h
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/17.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Common)

/** 字符串转字典 */
- (NSDictionary *)stringToJsonDictionary;
/** 生成唯一编码 */
+ (NSString *)creatUUIDString;

/** 获取文件保存路径 */
+ (NSString *)getFielSavePath;
/** md5编码 */
- (NSString *)md5Str;

- (NSString *)emotionSpecailName;
@end
