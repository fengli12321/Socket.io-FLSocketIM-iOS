//
//  FLFriendsAndGroupsViewController.m
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/6.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import "FLFriendsAndGroupsViewController.h"
#import "FLChatViewController.h"
#import "FLFriendsListCell.h"

@interface FLFriendsAndGroupsViewController () <UITableViewDelegate, UITableViewDataSource, FLChatManagerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation FLFriendsAndGroupsViewController

#pragma mark - Lazy
- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}
#pragma mark - lifeCircle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[FLChatManager shareManager] addDelegate:self];
    [self creatUI];
    [self requestData];
}
- (void)dealloc {
    [[FLChatManager shareManager] removeDelegate:self];
}
#pragma mark - UI
- (void)creatUI {
    
    self.title = @"联系人";
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 70;
    [_tableView registerClass:[FLFriendsListCell class] forCellReuseIdentifier:@"FLFriendsListCell"];
    _tableView.tableFooterView = [[UIView alloc] init];
}
#pragma mark - Request
- (void)requestData {
    
    __weak typeof(self) weakSelf = self;
    [FLNetWorkManager ba_requestWithType:Get withUrlString:OnlineUser_Url withParameters:nil withSuccessBlock:^(id response) {
        
        NSArray *onlineUserArr = response[@"data"];
        [weakSelf.dataSource addObjectsFromArray:onlineUserArr];
        if (weakSelf.dataSource.count) {
            [weakSelf.tableView reloadData];
        }
    } withFailureBlock:^(NSError *error) {
        
        [weakSelf showError:@"加载好友失败"];
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FLFriendsListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FLFriendsListCell" forIndexPath:indexPath];
    cell.nameLabel.text = self.dataSource[indexPath.row];
    cell.iconImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"Fruit-%ld", indexPath.row%12]];
    return cell;
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FLChatViewController *chatVC = [[FLChatViewController alloc] initWithToUser:self.dataSource[indexPath.row]];
    chatVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatVC animated:YES];
}

#pragma mark - FLChatManagerDelegate
- (void)chatManager:(FLChatManager *)manager userOnline:(NSString *)userName {
    
    bool isExist = NO;
    for (NSString *str in self.dataSource) {
        if ([str isEqualToString:userName]) {
            isExist = YES;
            break;
        }
    }
    if (isExist) {
        return;
    }
    [self showHint:[NSString stringWithFormat:@"%@上线了", userName]];
    [self.dataSource insertObject:userName atIndex:0];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
}
- (void)chatManager:(FLChatManager *)manager userOffline:(NSString *)userName {
    
    NSInteger index = 0;
    for (NSString *str in self.dataSource) {
        
        if ([str isEqualToString:userName]) {
            
            [self showHint:[NSString stringWithFormat:@"%@下线了", userName]];
            [self.dataSource removeObject:str];
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        index++;
    }
}
@end
