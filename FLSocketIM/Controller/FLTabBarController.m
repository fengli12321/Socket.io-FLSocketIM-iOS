//
//  FLTabBarController.m
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/6.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import "FLTabBarController.h"
#import "FLNavigationController.h"
#import "FLChatListViewController.h"
#import "FLFriendsAndGroupsViewController.h"

@interface FLTabBarController ()

@end

@implementation FLTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    FLChatListViewController *chatList = [[FLChatListViewController alloc] init];
    FLFriendsAndGroupsViewController *friends = [[FLFriendsAndGroupsViewController alloc] init];
    
    [self setupChildVc:chatList title:@"消息" image:@"manu_news" selectedImage:@"manu_news_on"];
    [self setupChildVc:friends title:@"联系人" image:@"menu_navigation" selectedImage:@"menu_navigation_on"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupChildVc:(UIViewController *)vc title:(NSString *)title image:(NSString *)image selectedImage:(NSString *) selectedImage {
    
    
    vc.tabBarItem.title = title;
    vc.tabBarItem.image = [[UIImage imageNamed:image] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    vc.tabBarItem.selectedImage = [[UIImage imageNamed:selectedImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    FLNavigationController *nav = [[FLNavigationController alloc] initWithRootViewController:vc];
    
    [self addChildViewController:nav];
}


@end
