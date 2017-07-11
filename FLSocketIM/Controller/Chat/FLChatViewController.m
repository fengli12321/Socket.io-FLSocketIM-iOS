//
//  FLChatViewController.m
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/6.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import "FLChatViewController.h"
#import "FLMessageCell.h"
#import "FLMessageModel.h"
#import "FLChatManager.h"
#import "FLMessageInputView.h"

@interface FLChatViewController () <UITableViewDelegate, UITableViewDataSource, FLChatManagerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) FLMessageInputView *messageInputView;

@end

@implementation FLChatViewController

#pragma mark - Lazy
- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}
#pragma mark - LifeCircle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[FLChatManager shareManager] addDelegate:self];
    [self creatUI];
}

- (void)dealloc {
    [[FLChatManager shareManager] removeDelegate:self];
}

#pragma mark - UI
- (void)creatUI {
    
    self.title = @"YY";

    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    _tableView.backgroundColor = FLBackGroundColor;
    
    _messageInputView = [[FLMessageInputView alloc] init];
    [self.view addSubview:_messageInputView];
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0, 0, _messageInputView.height, 0);
    _tableView.contentInset = contentInsets;
    _tableView.scrollIndicatorInsets = contentInsets;
    
//    FLMessageModel *model1 = [[FLMessageModel alloc] init];
//    model1.from = @"fox";
//    model1.to = @"yy";
//    model1.bodies = [[FLMessageBody alloc] init];
//    model1.bodies.msg = @"看见爱上了副科级阿拉山口地方了拉上的飞机离开";
//    
//    FLMessageModel *model2 = [[FLMessageModel alloc] init];
//    model2.from = @"yy";
//    model2.to = @"fox";
//    model2.bodies = [[FLMessageBody alloc] init];
//    model2.bodies.msg = @"看见爱上了副sadfkl了解萨拉克服";
//    
//    FLMessageModel *model3 = [[FLMessageModel alloc] init];
//    model3.from = @"fox";
//    model3.to = @"yy";
//    model3.bodies = [[FLMessageBody alloc] init];
//    model3.bodies.msg = @"看见爱上了副科级阿拉山口地方了拉上的飞机离开爱看楼上的房间卡上的李开复";
//    
//    
//    FLMessageModel *model4 = [[FLMessageModel alloc] init];
//    model4.from = @"fox";
//    model4.to = @"yy";
//    model4.bodies = [[FLMessageBody alloc] init];
//    model4.bodies.msg = @"看见爱上了副科级阿拉山口地方了拉上的飞机离开阿喀琉斯打飞机快乐撒娇的法律";
//    
//    FLMessageModel *model5 = [[FLMessageModel alloc] init];
//    model5.from = @"yy";
//    model5.to = @"fox";
//    model5.bodies = [[FLMessageBody alloc] init];
//    model5.bodies.msg = @"看见爱上了副科级阿拉山口地方了拉上的飞机离开阿斯蒂芬克拉数据看到房价来看撒娇放得开拉就是考虑到附近萨克了解到疯狂拉升阶段考虑房价";
//    
//    [self.dataSource addObject:model1];
//    [self.dataSource addObject:model2];
//    [self.dataSource addObject:model3];
//    [self.dataSource addObject:model4];
//    [self.dataSource addObject:model5];
//    
//    [self.tableView reloadData];
}

#pragma mark - UITableViewDatasource 
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    FLMessageModel *model = self.dataSource[indexPath.row];
    BOOL isSender = [model.to isEqualToString:@"fox"];
    NSString *cellIndentifier = [FLMessageCell cellReuseIndetifierWithIsSender:isSender];
    FLMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    
    if (!cell) {
        cell = [[FLMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier isSender:isSender];
    }
    cell.message = model;
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FLMessageModel *model = self.dataSource[indexPath.row];
    return model.messageCellHeight;
}

#pragma mark - 
- (void)chatManager:(id)manager didReceivedMessage:(FLMessageModel *)message {
    
    [self.dataSource addObject:message];
    [self.tableView reloadData];
}
@end
