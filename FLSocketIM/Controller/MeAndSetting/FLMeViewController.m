//
//  FLMeViewController.m
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/25.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import "FLMeViewController.h"
#import "GPUImage.h"
#import "FLLoginViewController.h"

@interface FLMeViewController () <FLClientManagerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *backgoundImage;
@property (weak, nonatomic) IBOutlet UIButton *connectBtn;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentUserLabel;
@property (weak, nonatomic) IBOutlet UIButton *existLogin;

@end

@implementation FLMeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
    
    [[FLClientManager shareManager] addDelegate:self];
}

- (void)dealloc {
    [[FLClientManager shareManager] removeDelegate:self];
}
#pragma mark - UI
- (void)setupUI {
    self.navigationItem.title = @"我的";
    
    self.connectBtn.layer.cornerRadius = 8;
    self.existLogin.layer.cornerRadius = 8;
    self.currentUserLabel.text = [NSString stringWithFormat:@"登录用户：%@",[FLClientManager shareManager].currentUserID];
    
    self.statusLabel.text = [self getStatusDescWithStatus:[FLSocketManager shareManager].client.status];
    
    self.connectBtn.selected = [FLSocketManager shareManager].client.status == SocketIOClientStatusDisconnected;
}

- (NSString *)getStatusDescWithStatus:(SocketIOClientStatus)status {
    
    NSString *statusDesc;
    switch (status) {
        case SocketIOClientStatusNotConnected:
            statusDesc = @"没有连接";
            break;
        case SocketIOClientStatusConnected:
            statusDesc = @"已连接";
            break;
        case SocketIOClientStatusConnecting:
            statusDesc = @"连接中";
            break;
        case SocketIOClientStatusDisconnected:
            statusDesc = @"连接断开";
            break;
        default:
            break;
    }
    return [NSString stringWithFormat:@"连接状态：%@", statusDesc];
}

- (IBAction)connectOrDisconnect:(UIButton *)sender {
    
    if (sender.selected) {
        [[FLSocketManager shareManager].client connect];
        
        FLLog(@"=======开启连接");
    }
    else {
        [[FLSocketManager shareManager].client disconnect];
        FLLog(@"=======关闭连接");
    }
}
- (IBAction)existLoginAction:(id)sender {
    
    [FLAlertView showWithTitle:@"确定退出当前账号吗?" message:@"确定以继续" cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] andAction:^(NSInteger buttonIndex) {
        
        if (buttonIndex == 1) {
            [[FLSocketManager shareManager].client disconnect];
            [UIApplication sharedApplication].keyWindow.rootViewController = [[FLLoginViewController alloc] init];
        }
    } andParentView:nil];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - FLClientManagerDelegate
- (void)clientManager:(FLClientManager *)manager didChangeStatus:(SocketIOClientStatus)status {
    self.statusLabel.text = [self getStatusDescWithStatus:status];
    
    self.connectBtn.selected = [FLSocketManager shareManager].client.status == SocketIOClientStatusDisconnected;
}


@end
