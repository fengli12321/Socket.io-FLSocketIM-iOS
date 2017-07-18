//
//  NSDate+Common.m
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/17.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import "NSDate+Common.h"
#import "NSDate+Helper.h"
@implementation NSDate (Common)

- (long long)timeStamp {
    
    return [self timeIntervalSince1970] * 1000;
}

+ (NSDate *)timeStampToDate:(long long)timeStamp {
    
    return [NSDate dateWithTimeIntervalSince1970:timeStamp];
}

- (BOOL)isSameDay:(NSDate *)anotherDate {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents* components1 = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:self];
    NSDateComponents* components2 = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)  fromDate:anotherDate];
    return ([components1 year] == [components2 year] && [components1 month] == [components2 month] && [components1 day] == [components2 day]);
}

- (NSInteger)secondsAgo {
    NSCalendar *calendar = [[self class] sharedCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitSecond fromDate:self toDate:[NSDate date] options:0];
    return components.second;
}

- (NSInteger)minutesAgo {
    NSCalendar *calendar = [[self class] sharedCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitMinute fromDate:self toDate:[NSDate date] options:0];
    return components.minute;
}

- (NSInteger)hoursAgo {
    NSCalendar *calendar = [[self class] sharedCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitHour fromDate:self toDate:[NSDate date] options:0];
    return components.hour;
}

- (NSInteger)monthsAgo {
    NSCalendar *calendar = [[self class] sharedCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitMonth fromDate:self toDate:[NSDate date] options:0];
    return components.month;
}

- (NSInteger)yearsAgo{
    NSCalendar *calendar = [[self class] sharedCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear fromDate:self toDate:[NSDate date] options:0];
    return components.year;
}

- (NSInteger)leftDayCount {
    NSDate *today = [NSDate dateFromString:[[NSDate date] stringWithFormat:@"yyyy-MM-dd"] withFormat:@"yyyy-MM-dd"];//时分清零
    NSDate *selfCopy = [NSDate dateFromString:[self stringWithFormat:@"yyyy-MM-dd"] withFormat:@"yyyy-MM-dd"];//时分清零
    
    NSCalendar *calendar = [[self class] sharedCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitDay)
                                               fromDate:today
                                                 toDate:selfCopy
                                                options:0];
    return [components day];
}

- (NSString *)stringTimesAgo{
    if ([self compare:[NSDate date]] == NSOrderedDescending) {
        return @"刚刚";
    }
    
    NSString *text = nil;
    
    NSInteger agoCount = [self yearsAgo];
    if (agoCount > 0) {
        text = [NSString stringWithFormat:@"%ld年前", (long)agoCount];
    }else{
        agoCount = [self monthsAgo];
        if (agoCount > 0) {
            text = [NSString stringWithFormat:@"%ld个月前", (long)agoCount];
        }else{
            agoCount = [self daysAgoAgainstMidnight];
            if (agoCount > 0) {
                text = [NSString stringWithFormat:@"%ld天前", (long)agoCount];
            }else{
                agoCount = [self hoursAgo];
                if (agoCount > 0) {
                    text = [NSString stringWithFormat:@"%ld小时前", (long)agoCount];
                }else{
                    agoCount = [self minutesAgo];
                    if (agoCount > 0) {
                        text = [NSString stringWithFormat:@"%ld分钟前", (long)agoCount];
                    }else{
                        agoCount = [self secondsAgo];
                        if (agoCount > 15) {
                            text = [NSString stringWithFormat:@"%ld秒前", (long)agoCount];
                        }else{
                            text = @"刚刚";
                        }
                    }
                }
            }
        }
    }
    return text;
}

- (NSString *)string_yyyy_MM_dd_EEE{
    NSString *text = [self stringWithFormat:@"yyyy-MM-dd EEE"];
    NSInteger daysAgo = [self daysAgoAgainstMidnight];
    switch (daysAgo) {
        case 0:
            text = [text stringByAppendingString:@"（今天）"];
            break;
        case 1:
            text = [text stringByAppendingString:@"（昨天）"];
            break;
        default:
            break;
    }
    return text;
}

- (NSString *)string_yyyy_MM_dd{
    return [self stringWithFormat:@"yyyy-MM-dd"];
}

+ (NSString *)convertStr_yyyy_MM_ddToDisplay:(NSString *)str_yyyy_MM_dd{
    if (str_yyyy_MM_dd.length <= 0) {
        return nil;
    }
    NSDate *date = [NSDate dateFromString:str_yyyy_MM_dd withFormat:@"yyyy-MM-dd"];
    if (!date) {
        return nil;
    }
    NSString *displayStr = @"";
    if ([date year] != [[NSDate date] year]) {
        displayStr = [date stringWithFormat:@"yyyy年MM月dd日"];
    }else{
        switch ([date leftDayCount]) {
            case 2:
                displayStr = @"后天";
                break;
            case 1:
                displayStr = @"明天";
                break;
            case 0:
                displayStr = @"今天";
                break;
            case -1:
                displayStr = @"昨天";
                break;
            case -2:
                displayStr = @"前天";
                break;
            default:
                displayStr = [date stringWithFormat:@"MM月dd日"];
                break;
        }
    }
    return displayStr;
}

- (NSString *)stringDisplay_HHmm{
    NSString *displayStr = @"";
    if ([self year] != [[NSDate date] year]) {
        displayStr = [self stringWithFormat:@"yy/MM/dd HH:mm"];
    }else if ([self leftDayCount] != 0){
        displayStr = [self stringWithFormat:@"MM/dd HH:mm"];
    }else if ([self hoursAgo] > 0){
        displayStr = [self stringWithFormat:@"今天 HH:mm"];
    }else if ([self minutesAgo] > 0){
        displayStr = [NSString stringWithFormat:@"%ld 分钟前", (long)[self minutesAgo]];
    }else if ([self secondsAgo] > 10){
        displayStr = [NSString stringWithFormat:@"%ld 秒前", (long)[self secondsAgo]];
    }else{
        displayStr = @"刚刚";
    }
    return displayStr;
}

- (NSString *)stringDisplay_MMdd{
    NSString *displayStr = @"";
    if ([self year] != [[NSDate date] year]) {
        displayStr = [self stringWithFormat:@"yy/MM/dd"];
    }else if ([self leftDayCount] != 0){
        displayStr = [self stringWithFormat:@"MM/dd"];
    }else if ([self hoursAgo] > 0){
        displayStr = [self stringWithFormat:@"今天"];
    }else if ([self minutesAgo] > 0){
        displayStr = [NSString stringWithFormat:@"%ld 分钟前", (long)[self minutesAgo]];
    }else if ([self secondsAgo] > 10){
        displayStr = [NSString stringWithFormat:@"%ld 秒前", (long)[self secondsAgo]];
    }else{
        displayStr = @"刚刚";
    }
    return displayStr;
}



@end
