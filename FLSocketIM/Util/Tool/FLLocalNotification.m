//
//  FLLocalNotification.m
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/21.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import "FLLocalNotification.h"
#import "FLConversationModel.h"
#import <UserNotifications/UserNotifications.h>
@implementation FLLocalNotification

+ (void)pushLocalNotificationWithMessage:(FLMessageModel *)message {

    
    if ([UIDevice currentDevice].systemVersion.floatValue >= 10.0) {
        
        [self iOS10PushMessage:message];
    }
    else {
        [self iOS8PushMessage:message];
    }
}

+ (void)iOS10PushMessage:(FLMessageModel *)message {
    
    
    // 使用 UNUserNotificationCenter 来管理通知
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    
    //需创建一个包含待通知内容的 UNMutableNotificationContent 对象，注意不是 UNNotificationContent ,此对象为不可变对象。
    UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
    content.title = [NSString localizedUserNotificationStringForKey:message.from arguments:nil];
    content.body = [NSString localizedUserNotificationStringForKey:[FLConversationModel getMessageStrWithMessage:message] arguments:nil];
    content.sound = [UNNotificationSound defaultSound];
    content.badge = @1;
    
    // 在 alertTime 后推送本地推送
    UNTimeIntervalNotificationTrigger* trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:0.1 repeats:NO];
    
    UNNotificationRequest* request = [UNNotificationRequest requestWithIdentifier:@"MessageNew" content:content trigger:trigger];
    
    //添加推送成功后的处理！
    [center addNotificationRequest:request withCompletionHandler:nil];
}

+ (void)iOS8PushMessage:(FLMessageModel *)message {
    
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    // 时区
    notification.timeZone = [NSTimeZone defaultTimeZone];
    // 设置重复的间隔
    notification.repeatInterval = kCFCalendarUnitSecond;
    // 通知内容
    notification.alertBody = [NSString stringWithFormat:@"%@\n%@", message.from, [FLConversationModel getMessageStrWithMessage:message]];
    notification.applicationIconBadgeNumber = 1;
    // 通知被触发时播放的声音
    notification.soundName = UILocalNotificationDefaultSoundName;
    // 通知参数
    NSDictionary *userDict = @{@"fklsa":@"safdsadf"};
    notification.userInfo = userDict;
    
    
    // 执行通知注册
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

@end
