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
#import "FLMeViewController.h"
#import "FLTabBarView.h"

@interface FLTabBarController () <FLTabBarViewDelegate>

@end

@implementation FLTabBarController


- (instancetype)init {
    if (self = [super init]) {
        
        
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        
        
    }
    return self;
}

- (void)commonInit {
    
    FLChatListViewController *chatList = [[FLChatListViewController alloc] init];

    FLFriendsAndGroupsViewController *friends = [[FLFriendsAndGroupsViewController alloc] init];
 
    FLMeViewController *me = [[FLMeViewController alloc] init];

    

    [self setupChildVc:chatList title:@"消息" image:@"manu_news" selectedImage:@"manu_news_on"];
    [self setupChildVc:friends title:@"联系人" image:@"menu_navigation" selectedImage:@"menu_navigation_on"];
    [self setupChildVc:me title:@"我的" image:@"" selectedImage:@""];
    
    FLTabBarView *tabBarView = [[FLTabBarView alloc] initWithFrame:self.tabBar.bounds];
    tabBarView.backgroundColor = [UIColor whiteColor];
    [self.tabBar addSubview:tabBarView];
    tabBarView.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
 
    [self commonInit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupChildVc:(UIViewController *)vc title:(NSString *)title image:(NSString *)image selectedImage:(NSString *) selectedImage {
    
    
//    vc.tabBarItem.title = title;
//    vc.tabBarItem.image = [[UIImage imageNamed:image] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    vc.tabBarItem.selectedImage = [[UIImage imageNamed:selectedImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    FLNavigationController *nav = [[FLNavigationController alloc] initWithRootViewController:vc];
    
    [self addChildViewController:nav];
}
#pragma mark - FLTabBarViewDelegate
- (void)fl_tabBarView:(FLTabBarView *)tabBarView didSelectItemAtIndex:(NSInteger)index {
    [self setSelectedIndex:index];
}

- (BOOL)fl_tabBarView:(FLTabBarView *)tabBarView shoulSelectItemAtIndex:(NSInteger)index {
    return YES;
}

@end
