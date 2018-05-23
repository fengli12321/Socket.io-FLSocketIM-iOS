//
//  FLVideoChatViewController.m
//  FLSocketIM
//
//  Created by 冯里 on 29/08/2017.
//  Copyright © 2017 冯里. All rights reserved.
//

#import "FLVideoChatViewController.h"
#import "FLVideoChatHelper.h"

@interface FLVideoChatViewController ()<FLVideoChatHelperDelegate>
{
    //本地摄像头追踪
    RTCVideoTrack *_localVideoTrack;
    //远程的视频追踪
    NSMutableDictionary *_remoteVideoTracks;
    
}


@property (nonatomic, copy) NSString *toUser;
@property (nonatomic, copy) NSString *fromUser;
@property (weak, nonatomic) IBOutlet UIButton *disconnectBtn;
@property (weak, nonatomic) IBOutlet UIView *userVideoBackView;
@property (weak, nonatomic) IBOutlet UIView *meVideoBackView;
@property (weak, nonatomic) IBOutlet UIButton *connectBtn;
@property (nonatomic, assign) FLVideoChatType type;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *connectBtnCenterX;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *disconnectBtnCenterX;


/**
 当被发起视频通话后，是否接听了通话
 */
@property (nonatomic, assign) BOOL isAnswer;

@end

@implementation FLVideoChatViewController

- (instancetype)initWithFromUser:(NSString *)fromUser toUser:(NSString *)toUser type:(FLVideoChatType)type{
    if (self = [super init]) {
        self.fromUser = fromUser;
        self.toUser = toUser;
        self.type = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.type == FLVideoChatCaller) { // 主动发起通话
        
        self.connectBtn.hidden = YES;
        [self requestServerCreatRoom];
        
    }
    else { // 被发起通话
        
        self.isAnswer = NO;
        [UIView animateWithDuration:0.4 animations:^{
            
            self.connectBtnCenterX.constant -= kScreenWidth/4.0;
            self.disconnectBtnCenterX.constant += kScreenWidth/4.0;
        }];
        
    }
    _remoteVideoTracks = [NSMutableDictionary dictionary];
    [FLVideoChatHelper sharedInstance].delegate = self;
}

- (void)requestServerCreatRoom {
    SocketIOClient *client = [FLSocketManager shareManager].client;
    // 首先请求服务器创建一个房间
    __weak typeof(self) weakSelf = self;
    [[client emitWithAck:@"videoChat" with:@[@{@"from_user":[FLClientManager shareManager].currentUserID, @"to_user":self.toUser, @"chat_type":@(self.chatType)}]] timingOutAfter:10 callback:^(NSArray * _Nonnull data) {
        
        if ([data.firstObject isKindOfClass:[NSString class]] && [data.firstObject isEqualToString:@"NO ACK"]) {  // 服务器没有应答
            
            FLLog(@"房间创建失败");
        }
        else {  // 服务器应答
            
            FLLog(@"房间创建成功");
            [weakSelf connectRoom:data.firstObject];
        }
    }];
    FLLog(@"准备进入视频聊天");
}

- (void)connectRoom:(NSString *)room {
    
    [[FLVideoChatHelper sharedInstance] connectRoom:room];
}
// 挂断通话
- (IBAction)disconnet:(id)sender {
    
    if (_localVideoTrack) {
        _localVideoTrack = nil;
    }
    if (_remoteVideoTracks.count) {
        [_remoteVideoTracks removeAllObjects];
    }
    [self dismissViewControllerAnimated:YES completion:^{
        
        if (self.isAnswer == false && self.type == FLVideoChatCallee) { // 被请求通话,未接听通话
            
            // 发送拒绝接听消息
            SocketIOClient *client = [FLSocketManager shareManager].client;
            [client emit:@"cancelVideoChat" with:@[@{@"room" : self.room}]];
            
        }
        else {
            
            [[FLVideoChatHelper sharedInstance] exitRoom];
        }
    }];
    
    
}
// 接听通话
- (IBAction)connect:(id)sender {
    
    self.isAnswer = YES;
    [UIView animateWithDuration:0.4 animations:^{
        
        self.connectBtnCenterX.constant += kScreenWidth/4.0;
        self.disconnectBtnCenterX.constant -= kScreenWidth/4.0;
    } completion:^(BOOL finished) {
        
        self.connectBtn.hidden = YES;
    }];
    [self connectRoom:self.room];
}

#pragma mark - FLVideoChatHelperDelegate
- (void)videoChatHelper:(FLVideoChatHelper *)videoChatHelper setLocalStream:(RTCMediaStream *)stream userId:(NSString *)userId {
    
    RTCEAGLVideoView *localVideoView = [[RTCEAGLVideoView alloc] initWithFrame:self.meVideoBackView.bounds];
    //标记本地的摄像头
    localVideoView.tag = 100;
    _localVideoTrack = [stream.videoTracks lastObject];
    [_localVideoTrack addRenderer:localVideoView];
    
    [self.meVideoBackView addSubview:localVideoView];
}

- (void)videoChatHelper:(FLVideoChatHelper *)videoChatHelper addRemoteStream:(RTCMediaStream *)stream userId:(NSString *)userId {
    //缓存起来
    [_remoteVideoTracks setObject:[stream.videoTracks lastObject] forKey:userId];
    [self _refreshRemoteView];
    FLLog(@"addRemoteStream");
}

- (void)videoChatHelper:(FLVideoChatHelper *)webRTChelper closeWithUserId:(NSString *)userId
{
    //移除对方视频追踪
    [_remoteVideoTracks removeObjectForKey:userId];
    [self _refreshRemoteView];
    FLLog(@"closeWithUserId");
}


- (void)closeRoomWithVideoChatHelper:(FLVideoChatHelper *)videoChatHelper {
    
    [self disconnet:self.disconnectBtn];
}

- (void)_refreshRemoteView
{
    
    for (RTCEAGLVideoView *videoView in self.userVideoBackView.subviews) {
//        //本地的视频View和关闭按钮不做处理
//        if (videoView.tag == 100) {
//            continue;
//        }
        //其他的移除
        [videoView removeFromSuperview];
    }
    //再去添加
    __block NSInteger index = 0;
    CGFloat scale = 320.0/240.0;
    CGFloat startY = 150 *scale;
    CGFloat width = kScreenWidth/4.0;
    CGFloat height = width * scale;
    

    [_remoteVideoTracks enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, RTCVideoTrack *remoteTrack, BOOL * _Nonnull stop) {
        
        NSInteger count = self.userVideoBackView.subviews.count;
        if (index < count) {
            RTCEAGLVideoView *videoView = self.userVideoBackView.subviews[index];
            [remoteTrack removeRenderer:videoView];
        }
        if (self.chatType == 0) {
            
            RTCEAGLVideoView *remoteVideoView = [[RTCEAGLVideoView alloc] initWithFrame:self.view.bounds];
            [remoteTrack addRenderer:remoteVideoView];
            [self.userVideoBackView addSubview:remoteVideoView];
        }
        else {
            
            RTCEAGLVideoView *remoteVideoView = [[RTCEAGLVideoView alloc] initWithFrame:CGRectMake(index*width, startY + index*height, width, height)];
            [remoteTrack addRenderer:remoteVideoView];
            [self.userVideoBackView addSubview:remoteVideoView];
        }
        index++;
    }];
}
@end
