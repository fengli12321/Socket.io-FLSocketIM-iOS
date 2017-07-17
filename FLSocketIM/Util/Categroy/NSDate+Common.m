//
//  NSDate+Common.m
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/17.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import "NSDate+Common.h"

@implementation NSDate (Common)

- (long long)timeStamp {
    
    return [self timeIntervalSince1970];
}

@end
