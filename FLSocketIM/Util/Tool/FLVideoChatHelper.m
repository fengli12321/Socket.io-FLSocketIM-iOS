//
//  FLVideoChatHelp.m
//  FLSocketIM
//
//  Created by 冯里 on 29/08/2017.
//  Copyright © 2017 冯里. All rights reserved.
//

#import "FLVideoChatHelper.h"
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

//google提供的
static NSString *const RTCSTUNServerURL = @"stun:stun.l.google.com:19302";
static NSString *const RTCSTUNServerURL2 = @"stun:23.21.150.121";
typedef enum : NSUInteger {
    //发送者
    RoleCaller,
    //被发送者
    RoleCallee,
} Role;
@interface FLVideoChatHelper () <RTCPeerConnectionDelegate, RTCSessionDescriptionDelegate>

@property (nonatomic, weak) SocketIOClient *client;

@end
@implementation FLVideoChatHelper
{
    
    NSString *_room;
    
    RTCPeerConnectionFactory *_factory;
    RTCMediaStream *_localStream;
    
    NSString *_myId;
    NSMutableDictionary *_connectionDic;
    NSMutableArray *_connectionIdArray;
    
    Role _role;
    
    NSMutableArray *ICEServers;
    
}

static FLVideoChatHelper *instance = nil;

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
        [instance initData];
        
    });
    return instance;
}
- (void)initData
{
    _connectionDic = [NSMutableDictionary dictionary];
    _connectionIdArray = [NSMutableArray array];
    
}

- (void)connectRoom:(NSString *)room {
    _room = room;
    self.client = [FLSocketManager shareManager].client;
    [self addSocketHandles];
    [self joinRoom:room];
    
}

- (void)addSocketHandles {
    
    //1.发送加入房间后的反馈
    [self.client on:@"_peers" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
        
        //得到data
        NSDictionary *dataDic = data.firstObject;
        //得到所有的连接
        NSArray *connections = dataDic[@"connections"];
        //加到连接数组中去
        [_connectionIdArray addObjectsFromArray:connections];
        
        //拿到给自己分配的ID
        _myId = dataDic[@"you"];
        
        //如果为空，则创建点对点工厂
        if (!_factory)
        {
            //设置SSL传输
            [RTCPeerConnectionFactory initializeSSL];
            _factory = [[RTCPeerConnectionFactory alloc] init];
        }
        //如果本地视频流为空
        if (!_localStream)
        {
            //创建本地流
            [self createLocalStream];
        }
        //创建连接
        [self createPeerConnections];
        
        //添加
        [self addStreams];
        [self createOffers];
    }];
    
    //4.接收到新加入的人发了ICE候选，（即经过ICEServer而获取到的地址）
    [self.client on:@"_ice_candidate" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
        
        //得到data
        NSDictionary *dataDic = data.firstObject;
        NSString *socketId = dataDic[@"socketId"];
        NSString *sdpMid = dataDic[@"id"];
        NSInteger sdpMLineIndex = [dataDic[@"label"] integerValue];
        NSString *sdp = dataDic[@"candidate"];
        //生成远端网络地址对象
        RTCICECandidate *candidate = [[RTCICECandidate alloc] initWithMid:sdpMid index:sdpMLineIndex sdp:sdp];
        //拿到当前对应的点对点连接
        RTCPeerConnection *peerConnection = [_connectionDic objectForKey:socketId];
        //添加到点对点连接中
        [peerConnection addICECandidate:candidate];
    }];
    //2.其他新人加入房间的信息
    [self.client on:@"_new_peer" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
        
        //得到data
        NSDictionary *dataDic = data.firstObject;
        //拿到新人的ID
        NSString *socketId = dataDic[@"socketId"];
        //再去创建一个连接
        RTCPeerConnection *peerConnection = [self createPeerConnection:socketId];
        if (!_localStream)
        {
            [self createLocalStream];
        }
        //把本地流加到连接中去
        [peerConnection addStream:_localStream];
        //连接ID新加一个
        [_connectionIdArray addObject:socketId];
        //并且设置到Dic中去
        [_connectionDic setObject:peerConnection forKey:socketId];
    }];
    //有人离开房间的事件(暂时处理为单聊，对象离开房间就关闭)
    [self.client on:@"_remove_peer" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
        
        //得到data
        NSDictionary *dataDic = data.firstObject;
        NSString *socketId = dataDic[@"socketId"];
        [self closePeerConnection:socketId];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(closeRoomWithVideoChatHelper:)]) {
            [self.delegate closeRoomWithVideoChatHelper:self];
        }
    }];
    //这个新加入的人发了个offer
    [self.client on:@"_offer" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
        
        //得到data
        NSDictionary *dataDic = data.firstObject;
        NSDictionary *sdpDic = dataDic[@"sdp"];
        //拿到SDP
        NSString *sdp = sdpDic[@"sdp"];
        NSString *type = sdpDic[@"type"];
        NSString *socketId = dataDic[@"socketId"];
        
     
        
        //拿到这个点对点的连接
        RTCPeerConnection *peerConnection = [_connectionDic objectForKey:socketId];
        //根据类型和SDP 生成SDP描述对象
        RTCSessionDescription *remoteSdp = [[RTCSessionDescription alloc] initWithType:type sdp:sdp];
        //设置给这个点对点连接
        [peerConnection setRemoteDescriptionWithDelegate:self sessionDescription:remoteSdp];
        
        //设置当前角色状态为被呼叫，（被发offer）
        _role = RoleCallee;
    }];
    //回应offer
    [self.client on:@"_answer" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
        
        //得到data
        NSDictionary *dataDic = data.firstObject;
        FLLog(@"_answer\n%@", dataDic);
        NSDictionary *sdpDic = dataDic[@"sdp"];
        NSString *sdp = sdpDic[@"sdp"];
        NSString *type = sdpDic[@"type"];
        NSString *socketId = dataDic[@"socketId"];
        RTCPeerConnection *peerConnection = [_connectionDic objectForKey:socketId];
        RTCSessionDescription *remoteSdp = [[RTCSessionDescription alloc] initWithType:type sdp:sdp];
        [peerConnection setRemoteDescriptionWithDelegate:self sessionDescription:remoteSdp];
    }];
    
    // 对方拒接了通话
    [self.client on:@"cancelVideoChat" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(closeRoomWithVideoChatHelper:)]) {
            [self.delegate closeRoomWithVideoChatHelper:self];
        }
    }];
}

/**
 *  加入房间
 *
 *  @param room 房间号
 */
- (void)joinRoom:(NSString *)room{
    
    // 如果是在线连接状态
    if (self.client.status == SocketIOClientStatusConnected) {
        
        [self.client emit:@"__join" with:@[@{@"room" : room}]];
    }
}
/**
 *  退出房间
 */
- (void)exitRoom {
    _localStream = nil;
    [_connectionIdArray enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self closePeerConnection:obj];
    }];
    [self.client emit:@"closeRoom" with:@[]];
    
    _localStream = nil;
    _factory = nil;
}

/**
 *  关闭peerConnection
 *
 *  @param connectionId 连接id
 */
- (void)closePeerConnection:(NSString *)connectionId
{
    RTCPeerConnection *peerConnection = [_connectionDic objectForKey:connectionId];
    if (peerConnection)
    {
        [peerConnection close];
    }
    [_connectionIdArray removeObject:connectionId];
    [_connectionDic removeObjectForKey:connectionId];
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_delegate respondsToSelector:@selector(videoChatHelper:closeWithUserId:)]) {
            [_delegate videoChatHelper:self closeWithUserId:connectionId];
        }
    });
}

/**
 *  创建本地流，并且把本地流回调出去
 */
- (void)createLocalStream{
    _localStream = [_factory mediaStreamWithLabel:@"ARDAMS"];
    //音频
    RTCAudioTrack *audioTrack = [_factory audioTrackWithID:@"ARDAMSa0"];
    [_localStream addAudioTrack:audioTrack];
    //视频
    
    NSArray *deviceArray = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *device = [deviceArray lastObject];
    //检测摄像头权限
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied)
    {
        FLLog(@"相机访问受限");
        if ([_delegate respondsToSelector:@selector(videoChatHelper:setLocalStream:userId:)])
        {
            
            [_delegate videoChatHelper:self setLocalStream:nil userId:_myId];
        }
    }
    else
    {
        if (device)
        {
            RTCVideoCapturer *capturer = [RTCVideoCapturer capturerWithDeviceName:device.localizedName];
            RTCVideoSource *videoSource = [_factory videoSourceWithCapturer:capturer constraints:[self localVideoConstraints]];
            RTCVideoTrack *videoTrack = [_factory videoTrackWithID:@"ARDAMSv0" source:videoSource];
            
            [_localStream addVideoTrack:videoTrack];
            if ([_delegate respondsToSelector:@selector(videoChatHelper:setLocalStream:userId:)])
            {
                [_delegate videoChatHelper:self setLocalStream:_localStream userId:_myId];
            }
        }
        else
        {
            FLLog(@"该设备不能打开摄像头");
            if ([_delegate respondsToSelector:@selector(videoChatHelper:setLocalStream:userId:)])
            {
                [_delegate videoChatHelper:self setLocalStream:nil userId:_myId];
            }
        }
    }
}

/**
 *  视频的相关约束
 */
- (RTCMediaConstraints *)localVideoConstraints
{
    RTCPair *maxWidth = [[RTCPair alloc] initWithKey:@"maxWidth" value:@"640"];
    RTCPair *minWidth = [[RTCPair alloc] initWithKey:@"minWidth" value:@"640"];
    
    RTCPair *maxHeight = [[RTCPair alloc] initWithKey:@"maxHeight" value:@"480"];
    RTCPair *minHeight = [[RTCPair alloc] initWithKey:@"minHeight" value:@"480"];
    
    RTCPair *minFrameRate = [[RTCPair alloc] initWithKey:@"minFrameRate" value:@"15"];
    
    NSArray *mandatory = @[maxWidth, minWidth, maxHeight, minHeight, minFrameRate];
    RTCMediaConstraints *constraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:mandatory optionalConstraints:nil];
    return constraints;
}



/**
 *  为所有连接创建offer
 */
- (void)createOffers{
    //给每一个点对点连接，都去创建offer
    [_connectionDic enumerateKeysAndObjectsUsingBlock:^(NSString *key, RTCPeerConnection *obj, BOOL * _Nonnull stop) {
        _role = RoleCaller;
        [obj createOfferWithDelegate:self constraints:[self offerOranswerConstraint]];
    }];
}

/**
 *  为所有连接添加流
 */
- (void)addStreams{
    //给每一个点对点连接，都加上本地流
    [_connectionDic enumerateKeysAndObjectsUsingBlock:^(NSString *key, RTCPeerConnection *obj, BOOL * _Nonnull stop) {
        if (!_localStream)
        {
            [self createLocalStream];
        }
        [obj addStream:_localStream];
    }];
}

/**
 *  创建所有连接
 */
- (void)createPeerConnections
{
    //从我们的连接数组里快速遍历
    [_connectionIdArray enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        //根据连接ID去初始化 RTCPeerConnection 连接对象
        RTCPeerConnection *connection = [self createPeerConnection:obj];
        
        //设置这个ID对应的 RTCPeerConnection对象
        [_connectionDic setObject:connection forKey:obj];
    }];
}

/**
 *  创建点对点连接
 *
 *  @param connectionId <#connectionId description#>
 *
 *  @return <#return value description#>
 */
- (RTCPeerConnection *)createPeerConnection:(NSString *)connectionId
{
    //如果点对点工厂为空
    if (!_factory)
    {
        //先初始化工厂
        [RTCPeerConnectionFactory initializeSSL];
        _factory = [[RTCPeerConnectionFactory alloc] init];
    }
    
    //得到ICEServer
    if (!ICEServers) {
        ICEServers = [NSMutableArray array];
        
        //        NSArray *stunServer = @[@"stun.l.google.com:19302",@"stun1.l.google.com:19302",@"stun2.l.google.com:19302",@"stun3.l.google.com:19302",@"stun3.l.google.com:19302",@"stun01.sipphone.com",@"stun.ekiga.net",@"stun.fwdnet.net",@"stun.fwdnet.net",@"stun.fwdnet.net",@"stun.ideasip.com",@"stun.iptel.org",@"stun.rixtelecom.se",@"stun.schlund.de",@"",@"stunserver.org",@"stun.softjoys.com",@"stun.voiparound.com",@"stun.voipbuster.com",@"stun.voipstunt.com",@"stun.voxgratia.org",@"stun.xten.com"];
        
        [ICEServers addObject:[self defaultSTUNServer:RTCSTUNServerURL ]];
        [ICEServers addObject:[self defaultSTUNServer:RTCSTUNServerURL2]];
        
        //        for (NSString *url  in stunServer) {
        //            [ICEServers addObject:[self defaultSTUNServer:url]];
        //
        //        }
        
    }
    
    //用工厂来创建连接
    RTCPeerConnection *connection = [_factory peerConnectionWithICEServers:ICEServers constraints:[self peerConnectionConstraints] delegate:self];
    return connection;
}

//初始化STUN Server （ICE Server）
- (RTCICEServer *)defaultSTUNServer {
    
    
    NSURL *defaultSTUNServerURL = [NSURL URLWithString:RTCSTUNServerURL];
    return [[RTCICEServer alloc] initWithURI:defaultSTUNServerURL
                                    username:@""
                                    password:@""];
}

- (RTCICEServer *)defaultSTUNServer:(NSString *)stunURL {
    NSURL *defaultSTUNServerURL = [NSURL URLWithString:stunURL];
    return [[RTCICEServer alloc] initWithURI:defaultSTUNServerURL
                                    username:@""
                                    password:@""];
}

/**
 *  peerConnection约束
 *
 *  @return <#return value description#>
 */
- (RTCMediaConstraints *)peerConnectionConstraints
{
    RTCMediaConstraints *constraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:nil optionalConstraints:@[[[RTCPair alloc] initWithKey:@"DtlsSrtpKeyAgreement" value:@"true"]]];
    return constraints;
}
/**
 *  设置offer/answer的约束
 */
- (RTCMediaConstraints *)offerOranswerConstraint
{
    NSMutableArray *array = [NSMutableArray array];
    RTCPair *receiveAudio = [[RTCPair alloc] initWithKey:@"OfferToReceiveAudio" value:@"true"];
    [array addObject:receiveAudio];
    
    NSString *video = @"true";
    RTCPair *receiveVideo = [[RTCPair alloc] initWithKey:@"OfferToReceiveVideo" value:video];
    [array addObject:receiveVideo];
    RTCMediaConstraints *constraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:array optionalConstraints:nil];
    return constraints;
}



- (NSString *)getKeyFromConnectionDic:(RTCPeerConnection *)peerConnection
{
    //find socketid by pc
    static NSString *socketId;
    [_connectionDic enumerateKeysAndObjectsUsingBlock:^(NSString *key, RTCPeerConnection *obj, BOOL * _Nonnull stop) {
        if ([obj isEqual:peerConnection])
        {
            NSLog(@"%@",key);
            socketId = key;
        }
    }];
    return socketId;
}
#pragma mark--RTCSessionDescriptionDelegate
// Called when creating a session.
//创建了一个SDP就会被调用，（只能创建本地的）
- (void)peerConnection:(RTCPeerConnection *)peerConnection
didCreateSessionDescription:(RTCSessionDescription *)sdp
                 error:(NSError *)error
{
    NSLog(@"%s",__func__);
    NSLog(@"%@",sdp.type);
    //设置本地的SDP
    [peerConnection setLocalDescriptionWithDelegate:self sessionDescription:sdp];
    
}

// Called when setting a local or remote description.
//当一个远程或者本地的SDP被设置就会调用
- (void)peerConnection:(RTCPeerConnection *)peerConnection
didSetSessionDescriptionWithError:(NSError *)error
{
    NSLog(@"%s",__func__);
    
    NSString *currentId = [self getKeyFromConnectionDic : peerConnection];
    
    //判断，当前连接状态为，收到了远程点发来的offer，这个是进入房间的时候，尚且没人，来人就调到这里
    if (peerConnection.signalingState == RTCSignalingHaveRemoteOffer)
    {
        //创建一个answer,会把自己的SDP信息返回出去
        [peerConnection createAnswerWithDelegate:self constraints:[self offerOranswerConstraint]];
    }
    //判断连接状态为本地发送offer
    else if (peerConnection.signalingState == RTCSignalingHaveLocalOffer)
    {
        if (_role == RoleCallee)
        {
            [self.client emit:@"__answer" with:@[@{@"sdp": @{@"type": @"answer", @"sdp": peerConnection.localDescription.description}, @"socketId": currentId}]];
     
        }
        //发送者,发送自己的offer
        else if(_role == RoleCaller)
        {
            [self.client emit:@"__offer" with:@[@{@"sdp": @{@"type": @"offer", @"sdp": peerConnection.localDescription.description}, @"socketId": currentId}]];
        }
    }
    else if (peerConnection.signalingState == RTCSignalingStable)
    {
        if (_role == RoleCallee)
        {
            [self.client emit:@"__answer" with:@[@{@"sdp": @{@"type": @"answer", @"sdp": peerConnection.localDescription.description}, @"socketId": currentId}]];
            
        }
    }
}

#pragma mark--RTCPeerConnectionDelegate
// Triggered when the SignalingState changed.
- (void)peerConnection:(RTCPeerConnection *)peerConnection
 signalingStateChanged:(RTCSignalingState)stateChanged
{
    NSLog(@"%s",__func__);
    NSLog(@"%d", stateChanged);
}

// Triggered when media is received on a new stream from remote peer.
- (void)peerConnection:(RTCPeerConnection *)peerConnection
           addedStream:(RTCMediaStream *)stream
{
    NSLog(@"%s",__func__);
    
    NSString *uid = [self getKeyFromConnectionDic : peerConnection];
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_delegate respondsToSelector:@selector(videoChatHelper:addRemoteStream:userId:)])
        {
            //[_delegate webRTCHelper:self addRemoteStream:stream userId:_currentId];
            [_delegate videoChatHelper:self addRemoteStream:stream userId:uid];
        }
    });
}

// Triggered when a remote peer close a stream.
- (void)peerConnection:(RTCPeerConnection *)peerConnection
         removedStream:(RTCMediaStream *)stream
{
    NSLog(@"%s",__func__);
}

// Triggered when renegotiation is needed, for example the ICE has restarted.
- (void)peerConnectionOnRenegotiationNeeded:(RTCPeerConnection *)peerConnection
{
    NSLog(@"%s",__func__);
}

// Called any time the ICEConnectionState changes.
- (void)peerConnection:(RTCPeerConnection *)peerConnection
  iceConnectionChanged:(RTCICEConnectionState)newState
{
    NSLog(@"%s",__func__);
    NSLog(@"%d", newState);
}

// Called any time the ICEGatheringState changes.
- (void)peerConnection:(RTCPeerConnection *)peerConnection
   iceGatheringChanged:(RTCICEGatheringState)newState
{
    NSLog(@"%s",__func__);
    NSLog(@"%d", newState);
}

// New Ice candidate have been found.
//创建peerConnection之后，从server得到响应后调用，得到ICE 候选地址
- (void)peerConnection:(RTCPeerConnection *)peerConnection
       gotICECandidate:(RTCICECandidate *)candidate
{
    NSLog(@"%s",__func__);
    
    NSString *currentId = [self getKeyFromConnectionDic : peerConnection];
    
    [self.client emit:@"__ice_candidate" with:@[@{@"id":candidate.sdpMid,@"label": [NSNumber numberWithInteger:candidate.sdpMLineIndex], @"candidate": candidate.sdp, @"socketId": currentId}]];
}

// New data channel has been opened.
- (void)peerConnection:(RTCPeerConnection*)peerConnection didOpenDataChannel:(RTCDataChannel*)dataChannel

{
    NSLog(@"%s",__func__);
}

@end
