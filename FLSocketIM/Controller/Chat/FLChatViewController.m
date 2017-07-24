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
#import "TZImagePickerController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "FLChatListViewController.h"
#import "FLConversationModel.h"


@interface FLChatViewController () <UITableViewDelegate, UITableViewDataSource, FLClientManagerDelegate, FLMessageInputViewDelegate, UIScrollViewDelegate, TZImagePickerControllerDelegate, FLMessageCellDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) FLMessageInputView *messageInputView;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) BOOL loadAllMessage;
@property (nonatomic, assign) BOOL isFirstLoad;

@end

@implementation FLChatViewController

#pragma mark - Lazy
- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

#pragma mark - Init
- (instancetype)initWithToUser:(NSString *)toUser {
    if (self = [super init]) {
        
        self.toUser = toUser;
    }
    return self;
}
#pragma mark - LifeCircle


- (void)viewDidLoad {
    [super viewDidLoad];
    _isFirstLoad = YES;
    [FLClientManager shareManager].chattingConversation = self;
    [[FLClientManager shareManager] addDelegate:self];
    [self creatUI];
    [self queryDataFromDB];
    
    [self updateUnreadMessageRedIconForListAndDB];
    
}

- (void)dealloc {
    [[FLClientManager shareManager] removeDelegate:self];
    
    // 关闭时向消息列表添加当前会话(更新会话列表UI)
    [self addCurrentConversationToChatList];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.messageInputView endEditing:YES];
}

#pragma mark - UI
- (void)creatUI {
    
    self.title = self.toUser;

    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    _tableView.backgroundColor = FLBackGroundColor;
    
    _messageInputView = [[FLMessageInputView alloc] init];
    _messageInputView.delegate = self;
    [self.view addSubview:_messageInputView];
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0, 0, _messageInputView.height, 0);
    _tableView.contentInset = contentInsets;
    _tableView.scrollIndicatorInsets = contentInsets;

    __weak typeof(self) weakSelf = self;
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        [weakSelf queryDataFromDB];
    }];
    header.stateLabel.hidden = YES;
    header.lastUpdatedTimeLabel.hidden = YES;
    _tableView.mj_header = header;
}

#pragma mark - Data
- (void)queryDataFromDB {
    
    
    if (self.loadAllMessage) {
        
        [self showHint:@"没有更多消息记录"];
        [_tableView.mj_header endRefreshing];
        
        [_tableView.mj_header setHidden:YES];
        return;
    }
    NSInteger limit = 10;
    NSArray *dataArray = [[FLChatDBManager shareManager] queryMessagesWithUser:self.toUser limit:limit page:_currentPage];
    [_tableView.mj_header endRefreshing];
    _currentPage ++;
    if (dataArray.count < limit) {
        
        self.loadAllMessage = YES;
    }
    [self.dataSource insertObjects:dataArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, dataArray.count)]];
    

    [self.tableView reloadData];
    if (_isFirstLoad) {    // 第一次加载，滚动到底部
        _isFirstLoad = NO;
        
        if (_dataSource.count) {
            [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_dataSource.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
        
    }
    else {
        
        CGFloat addHeight = 0.0f;
        for (FLMessageModel *message in dataArray) {
            
            addHeight += message.messageCellHeight;
        }
        
        CGPoint tableOffset = _tableView.contentOffset;
        tableOffset.y += addHeight;//(addHeight - _tableView.height/2);
        [_tableView setContentOffset:tableOffset animated:NO];
    }
    
}

#pragma mark - Pravite



/**
 刷新消息的发送状态

 @param message 消息
 */
- (void)updateSendStatusUIWithMessage:(FLMessageModel *)message {
    
    NSInteger index = [_dataSource indexOfObject:message];
    if (index >= 0) {
        
        FLMessageCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        [cell updateSendStatus:message.sendStatus];
    }
}

/**
 将当前会话添加到消息列表中
 */
- (void)addCurrentConversationToChatList {
    
    if (self.dataSource.count) { // 当前会话中有消息记录
        
        FLMessageModel *message = [self.dataSource lastObject];
        if ([message.from isEqualToString:[FLClientManager shareManager].currentUserID]) { // 消息是自己发送的，则更新消息列表最新消息UI（接收到别人的消息, chatListVC会更新UI,这里不做处理）
            [[FLClientManager shareManager].chatListVC addOrUpdateConversation:message.to latestMessage:message isRead:YES];
        }
    }
}


/**
 发送文本消息

 @param text 文本
 */
- (void)sendTextMessageWithText:(NSString *)text {
    __weak typeof(self) weakSelf = self;
    FLMessageModel *message = [[FLChatManager shareManager] sendTextMessage:text toUser:_toUser sendStatus:^(FLMessageModel *newMessage) {
        
        [weakSelf updateSendStatusUIWithMessage:newMessage];
    }];
    [self clientManager:nil didReceivedMessage:message];
}




// 发送图片消息
- (void)sendImgMessageWithImage:(UIImage *)image asset:(id)asset isOriginalPhoto:(BOOL)isOriginalPhoto {
    
    
    if (isOriginalPhoto) {
        __weak typeof(self) weakSelf = self;
        if (iOS8Later) {    // 系统版本
            
            
            PHImageRequestOptions *request = [[PHImageRequestOptions alloc] init];
            request.resizeMode = UIScrollViewDecelerationRateFast;
            request.synchronous = YES;
            [[PHImageManager defaultManager] requestImageDataForAsset:asset options: request resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                
                BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
                if (downloadFinined && imageData) {// 图片数据不为空才传递
                    
                    [weakSelf sendImageMessageWithImgData:imageData];
                }

            }];
        }
        else {  // iOS8之前
            
            dispatch_async(dispatch_get_global_queue(0,0), ^{
                ALAsset *alsset = asset;
                UIImage *image = [UIImage imageWithCGImage:[alsset thumbnail]];
                NSData *imgData = UIImageJPEGRepresentation(image, 1);
                [weakSelf sendImageMessageWithImgData:imgData];
            });
            
        }
        
    }
    else {
        @autoreleasepool {
            NSData *imageData = UIImageJPEGRepresentation(image, 1);
            [self sendImageMessageWithImgData:imageData];
        }
        
    }
}


/**
 发送图片消息

 @param imgData 图片文件
 */
- (void)sendImageMessageWithImgData:(NSData *)imgData {
    
    __weak typeof(self) weakSelf = self;
    FLMessageModel *message = [[FLChatManager shareManager] sendImgMessage:imgData toUser:self.toUser sendStatus:^(FLMessageModel *newMessage) {
        
        [weakSelf updateSendStatusUIWithMessage:newMessage];
    }];
    [self clientManager:nil didReceivedMessage:message];
}



// 更新消息列表未读消息数量, 更新数据库
- (void)updateUnreadMessageRedIconForListAndDB {
    
    [[FLClientManager shareManager].chatListVC updateRedPointForUnreadWithConveration:self.toUser];
    [[FLChatDBManager shareManager] updateUnreadCountOfConversation:self.toUser unreadCount:0];
}
#pragma mark - UITableViewDatasource 
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    FLMessageModel *model = self.dataSource[indexPath.row];
    NSString *cellIndentifier = [FLMessageCell cellReuseIndetifierWithMessageModel:model];
    FLMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    
    if (!cell) {
        cell = [[FLMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier messageModel:model];
    }
    cell.delegate = self;
    cell.message = model;
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FLMessageModel *model = self.dataSource[indexPath.row];
    return model.messageCellHeight;
}

#pragma mark - FLClientManagerDelegate
- (void)clientManager:(FLClientManager *)manager didReceivedMessage:(FLMessageModel *)message  {
    
    
    if (manager) { // 接收到的消息
        if ([message.from isEqualToString:message.to]) { // 自己发送给自己的消息
            // 不展示UI
            return;
        }
    }
    
    if (![message.from isEqualToString:self.toUser] && ![message.to isEqualToString:self.toUser]) { // 不是该会话的消息
        
        // 不展示UI
        return;
    }

    [self.dataSource addObject:message];
    [self.tableView reloadData];
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_dataSource.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}
#pragma mark - FLMessageInputViewDelegate
- (void)messageInputView:(FLMessageInputView *)inputView heightToBottomChange:(CGFloat)heightToBottom {
    
    
    FLLog(@"\n\n=========%lf=======%ld\n=====\n====%@====\n======%lf\n\n\n", heightToBottom, self.dataSource.count, _tableView, _tableView.contentInset.top);
    CGFloat insetsTop = _tableView.contentInset.top;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(insetsTop, 0, MAX(inputView.height, heightToBottom), 0);
    _tableView.contentInset = contentInsets;
    _tableView.scrollIndicatorInsets = contentInsets;
    
    static BOOL keyBoardIsDown = YES;
    static CGPoint keyboard_down_ContenOffset;
    static CGFloat keyboard_down_InputViewHeight;
    if (heightToBottom > inputView.height) {
        if (keyBoardIsDown) {
            keyboard_down_ContenOffset = self.tableView.contentOffset;
            keyboard_down_InputViewHeight = inputView.height;
        }
        keyBoardIsDown = NO;
        CGPoint contentOffset = keyboard_down_ContenOffset;
        CGFloat spaceHeight = MAX(0, self.tableView.height - _tableView.contentSize.height - keyboard_down_InputViewHeight);
        contentOffset.y += MAX(0, heightToBottom - keyboard_down_InputViewHeight - spaceHeight);
        _tableView.contentOffset = contentOffset;
    }
    else {
        keyBoardIsDown = YES;
    }
}

- (void)messageInputView:(FLMessageInputView *)inputView sendText:(NSString *)text {
    
    [self sendTextMessageWithText:text];
    
    
}

- (void)messageInputViewSendImage {
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:100 columnNumber:3 delegate:self pushPhotoPickerVc:YES];
    
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.allowPickingImage = YES;
    imagePickerVc.allowPickingOriginalPhoto = YES;
    imagePickerVc.maxImagesCount = 5;
    //    imagePickerVc.photoWidth = 500;
    __weak typeof(self) weakSelf = self;
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        
        NSInteger index = 0;
        if (isSelectOriginalPhoto) {
            for (UIImage *image in photos) {
                
                
                [weakSelf sendImgMessageWithImage:image asset:assets[index] isOriginalPhoto:isSelectOriginalPhoto];
                index++;
            }
        }
        else {
            for (UIImage *image in photos) {
                
                [weakSelf sendImgMessageWithImage:image asset:nil isOriginalPhoto:isSelectOriginalPhoto];
                index++;
            }
        }
        
    }];
    
    [self presentViewController:imagePickerVc animated:YES completion:nil];


}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.messageInputView endEditing:YES];
}

#pragma mark - FLMessageCellDelegate
- (void)resendMessage:(FLMessageModel *)message {
    
    message.sendStatus = FLMessageSending;
    [self updateSendStatusUIWithMessage:message];
    __weak typeof(self) weakSelf = self;
    [[FLChatManager shareManager] resendMessage:message sendStatus:^(FLMessageModel *message) {
        
        [self updateSendStatusUIWithMessage:message];
    }];
}
@end
