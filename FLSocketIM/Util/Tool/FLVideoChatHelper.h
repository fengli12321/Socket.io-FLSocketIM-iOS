//
//  FLVideoChatHelp.h
//  FLSocketIM
//
//  Created by 冯里 on 29/08/2017.
//  Copyright © 2017 冯里. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RTCMediaStream.h"
#import "RTCPeerConnectionFactory.h"
#import "RTCPeerConnection.h"
#import "RTCPair.h"
#import "RTCMediaConstraints.h"
#import "RTCAudioTrack.h"
#import "RTCVideoTrack.h"
#import "RTCVideoCapturer.h"
#import "RTCSessionDescription.h"
#import "RTCSessionDescriptionDelegate.h"
#import "RTCEAGLVideoView.h"
#import "RTCICEServer.h"
#import "RTCVideoSource.h"
#import "RTCAVFoundationVideoSource.h"
#import "RTCICECandidate.h"

@protocol FLVideoChatHelperDelegate;

@interface FLVideoChatHelper : NSObject

@property (nonatomic, weak) id<FLVideoChatHelperDelegate>delegate;

+ (instancetype)sharedInstance;
/**
 连接到房间

 @param room 房间号
 */
- (void)connectRoom:(NSString *)room;

/**
 *  退出房间
 */
- (void)exitRoom;

@end


@protocol FLVideoChatHelperDelegate <NSObject>

@optional
- (void)videoChatHelper:(FLVideoChatHelper *)videoChatHelper setLocalStream:(RTCMediaStream *)stream userId:(NSString *)userId;
- (void)videoChatHelper:(FLVideoChatHelper *)videoChatHelper addRemoteStream:(RTCMediaStream *)stream userId:(NSString *)userId;
- (void)videoChatHelper:(FLVideoChatHelper *)videoChatHelper closeWithUserId:(NSString *)userId;
- (void)closeRoomWithVideoChatHelper:(FLVideoChatHelper *)videoChatHelper;
@end

//
//@interface FLPeer : NSObject
//
//@end
