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

@interface FLChatViewController () <UITableViewDelegate, UITableViewDataSource, FLChatManagerDelegate, FLMessageInputViewDelegate, UIScrollViewDelegate, TZImagePickerControllerDelegate>

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
    
    [FLClientManager shareManager].chattingConversation = self;
    [[FLChatManager shareManager] addDelegate:self];
    [self creatUI];
    
    [self queryDataFromDB];
}

- (void)dealloc {
    [[FLChatManager shareManager] removeDelegate:self];
    
    // 关闭时向消息列表添加当前会话
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

    
}

#pragma mark - Data
- (void)queryDataFromDB {
    
    NSArray *dataArray = [[FLChatDBManager shareManager] queryMessagesWithUser:self.toUser];
    [self.dataSource addObjectsFromArray:dataArray];
    [self.tableView reloadData];
}

#pragma mark - Pravite

/**
 将当前会话添加到消息列表中
 */
- (void)addCurrentConversationToChatList {
    
    if (self.dataSource.count) { // 当前会话中有消息记录
        
        // 判断消息列表中是否已经有该会话
        FLChatListViewController *chatListVC = [FLClientManager shareManager].chatListVC;
        FLConversationModel *conversation = [chatListVC isExistConversationWithToUser:self.toUser];
        if (!conversation) { // 如果会话不存在，添加该会话
            
            FLMessageModel *latestModel = self.dataSource.lastObject;
            [chatListVC addConversationWithMessage:latestModel isReaded:YES];
        }
    }
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
//    [FLChatManager shareManager] sendImgMessage:<#(NSData *)#> toUser:<#(NSString *)#>
}

- (void)sendImageMessageWithImgData:(NSData *)imgData {
    
    FLMessageModel *message = [[FLChatManager shareManager] sendImgMessage:imgData toUser:self.toUser];
    [self chatManager:nil didReceivedMessage:message];
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
    cell.message = model;
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FLMessageModel *model = self.dataSource[indexPath.row];
    return model.messageCellHeight;
}

#pragma mark - FLChatManagerDelegate
- (void)chatManager:(id)manager didReceivedMessage:(FLMessageModel *)message {
    
    if (!([message.from isEqualToString:self.toUser] || [message.to isEqualToString:self.toUser])) {
        return;
    }
    [self.dataSource addObject:message];
    [self.tableView reloadData];
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_dataSource.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}
#pragma mark - FLMessageInputViewDelegate
- (void)messageInputView:(FLMessageInputView *)inputView heightToBottomChange:(CGFloat)heightToBottom {
    
    
    FLLog(@"最新高度=========%lf", heightToBottom);
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
        contentOffset.y += MAX(0, heightToBottom - keyboard_down_InputViewHeight - spaceHeight + insetsTop);
        _tableView.contentOffset = contentOffset;
    }
    else {
        keyBoardIsDown = YES;
    }
}

- (void)messageInputView:(FLMessageInputView *)inputView sendText:(NSString *)text {
    
    
    FLMessageModel *message = [[FLChatManager shareManager] sendTextMessage:text toUser:_toUser];
    [self chatManager:nil didReceivedMessage:message];
    
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
@end
