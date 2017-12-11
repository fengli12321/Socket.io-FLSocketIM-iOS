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
#import "FLTabBar.h"

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

    

    [self setupChildVc:chatList];
    [self setupChildVc:friends];
    [self setupChildVc:me];
    
    FLTabBarView *tabBarView = [[FLTabBarView alloc] initWithFrame:self.tabBar.bounds];
    tabBarView.backgroundColor = [UIColor whiteColor];
    [self.tabBar addSubview:tabBarView];
    tabBarView.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setValue:[[FLTabBar alloc] init] forKey:@"tabBar"];
    
    [self commonInit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupChildVc:(UIViewController *)vc {
    
    
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
