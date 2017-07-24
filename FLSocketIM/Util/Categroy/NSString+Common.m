//
//  NSString+Common.m
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/17.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import "NSString+Common.h"

@implementation NSString (Common)

- (NSDictionary *)stringToJsonDictionary {
    
    if (!self.length) {
        return nil;
    }
    
    NSData *jsonData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        FLLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

+ (NSString *)creatUUIDString {
    return [[NSUUID UUID] UUIDString];
}

@end
