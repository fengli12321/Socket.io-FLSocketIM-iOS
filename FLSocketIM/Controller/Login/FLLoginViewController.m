//
//  FLLoginViewController.m
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/6.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import "FLLoginViewController.h"
#import "FLTabBarController.h"
#import "FLSocketManager.h"

@interface FLLoginViewController ()

// 账号输入
@property (weak, nonatomic) IBOutlet UITextField *userNameField;
// 密码输入
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
// 登录按钮
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
// 注册按钮
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;

@end

@implementation FLLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupUI];
}
#pragma mark - UI
- (void)setupUI {
    
    _loginBtn.layer.cornerRadius = 15;
    _registerBtn.layer.cornerRadius = 15;
}

#pragma mark - Private
- (BOOL)checkInput {
    if (!_userNameField.hasText) {
        [FLAlertView showWithTitle:@"请输入用户名" message:@"用户名为空" cancelButtonTitle:@"确定" otherButtonTitles:nil andAction:nil andParentView:nil];
        return NO;
    }
    else if (!_passwordField.hasText) {
        [FLAlertView showWithTitle:@"请输入密码" message:@"密码为空" cancelButtonTitle:@"确定" otherButtonTitles:nil andAction:nil andParentView:nil];
        return NO;
    }
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (IBAction)login:(id)sender {
    if ([self checkInput]) {
        
        [self showMessage:@"登录中"];
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        parameters[@"userName"] = _userNameField.text;
        parameters[@"password"] = _passwordField.text;
        __weak typeof(self) weakSelf = self;
        [FLNetWorkManager ba_requestWithType:Get withUrlString:Login_Url withParameters:parameters withSuccessBlock:^(id response) {
            
            [weakSelf hideHud];
            if ([response[@"code"] integerValue] < 0) {
                
                [FLAlertView showWithTitle:@"账户或者密码错误" message:nil cancelButtonTitle:@"确定" otherButtonTitles:nil andAction:nil andParentView:nil];
            }
            else {
                
                [weakSelf socketConnectWithToken:response[@"data"][@"auth_token"]];
            }
        } withFailureBlock:^(NSError *error) {
            
            [weakSelf hideHud];
            [weakSelf showError:@"登录失败"];
        }];
    }
}

- (void)socketConnectWithToken:(NSString *)token {
    
    [self showMessage:@"连接中"];
    [[FLSocketManager shareManager] connectWithToken:token success:^{
        
        [self hideHud];
        [UIApplication sharedApplication].keyWindow.rootViewController = [[FLTabBarController alloc] init];
    } fail:^{
        
        [self hideHud];
        [self showHint:@"连接失败"];
    }];
}
- (IBAction)register:(id)sender {
    
    if([self checkInput]) {
        
        [self showMessage:@"正在注册中"];
        __weak typeof(self) weakSelf = self;
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        parameters[@"userName"] = _userNameField.text;
        parameters[@"password"] = _passwordField.text;
        [FLNetWorkManager ba_requestWithType:Get withUrlString:Register_Url withParameters:parameters withSuccessBlock:^(id response) {
            
            [weakSelf hideHud];
            if([response[@"code"] integerValue] < 0) {
                [FLAlertView showWithTitle:@"注册失败" message:@"该账号已注册" cancelButtonTitle:@"确定" otherButtonTitles:nil andAction:nil andParentView:nil];
            }else {
                [FLAlertView showWithTitle:@"🎉注册成功" message:nil cancelButtonTitle:@"确定" otherButtonTitles:nil andAction:nil andParentView:nil];
            }
            
        } withFailureBlock:^(NSError *error) {
            
            [weakSelf hideHud];
            [weakSelf showError:@"注册失败"];
        }];
    }
}

@end
