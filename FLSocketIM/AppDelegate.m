//
//  AppDelegate.m
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/6.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import "AppDelegate.h"
#import "FLLoginViewController.h"
#import "FLChatViewController.h"
#import <UserNotifications/UserNotifications.h>
@interface AppDelegate () <UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _window.backgroundColor = [UIColor whiteColor];
    
    _window.rootViewController = [[FLLoginViewController alloc] init];
//    _window.rootViewController = [[FLChatViewController alloc] initWithToUser:@"3"];
    
    [_window makeKeyAndVisible];
    
    
    
    [self commonSetting];
    [self remotePushSetting];
    return YES;
}

- (void)remotePushSetting {
//    [[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert];
    
    
    // iOS8系统以上
    if ([UIDevice currentDevice].systemVersion.doubleValue >= 8.0) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    // iOS8系统以下
    else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert];
    }
    
 
    
//    UIRemoteNotificationType types =
//    (UIRemoteNotificationTypeBadge
//     |UIRemoteNotificationTypeSound
//     |UIRemoteNotificationTypeAlert);
//    
//    //注册消息推送
//    [[UIApplication sharedApplication]registerForRemoteNotificationTypes:types];
//    
//    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
//    
//    center.delegate = self;
//    
//    [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
//        
//        if (!error) {
//            
//            FLLog(@"request authorization succeeded!");
//            
//        }
//        
//    }];


}

- (void)commonSetting {
    
    [UINavigationBar appearance].barTintColor = [UIColor blackColor];
    [UINavigationBar appearance].tintColor = [UIColor whiteColor];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
}


- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    // 检查当前用户是否允许通知,如果允许就调用 registerForRemoteNotifications
    if (notificationSettings.types != UIUserNotificationTypeNone) {
        [application registerForRemoteNotifications];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    NSLog(@"deviceToken=%@", token);
    

}

// 注册远程通知失败后，会调用这个方法
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"注册远程通知失败----%@", error.localizedDescription);
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"收到远程通知----%@", userInfo);
}

// 当接收到远程通知（实现了这个方法，则上面的方法不再执行）
// 前台（会调用）
// 从后台进入到前台（会调用）
// 完全退出再进入APP （也会调用这个方法）
//
// 如果要实现：只要接收到通知，不管当前应用在前台、后台、还是锁屏，都执行这个方法
//    > 必须勾选后台模式 Remote Notification
//    > 告诉系统是否有新的内容更新（执行完成代码块）
//    > 设置发送通知的格式 {"content-available" : "随便传"} （在 aps 键里面设置）
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"收到远程通知2----%@", userInfo);
    
    // 调用系统回调代码块的作用
    //  > 系统会估量app消耗的电量，并根据传递的 `UIBackgroundFetchResult` 参数记录新数据是否可用
    //  > 调用完成的处理代码时，应用的界面缩略图会更新
    completionHandler(UIBackgroundFetchResultNewData);
}




- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
