//
//  FLChatManager.h
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/10.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLMessageModel.h"
#import <CoreLocation/CoreLocation.h>

@class FLChatManager;


@interface FLChatManager : NSObject

+ (instancetype)shareManager;



/**
 发送文字消息
 
 @param text 图片数据
 @param toUser 发送目标
 @param sendStatus 状态改变返回消息模型
 @return 消息模型
 */
- (FLMessageModel *)sendTextMessage:(NSString *)text toUser:(NSString *)toUser sendStatus:(void(^)(FLMessageModel *message))sendStatus;



/**
 发送图片消息

 @param imgData 图片数据
 @param toUser 发送目标
 @param sendStatus 状态改变返回消息模型
 @return 消息模型
 */
- (FLMessageModel *)sendImgMessage:(NSData *)imgData toUser:(NSString *)toUser sendStatus:(void(^)(FLMessageModel *message))sendStatus;


/**
 发送语音

 @param audioDataPath 语音数据
 @param duration 语音时长
 @param toUser 发送目标
 @param sendStatus 状态改变返回消息模型
 @return 消息模型
 */
- (FLMessageModel *)sendAudioMessage:(NSString *)audioDataPath duration:(CGFloat)duration toUser:(NSString *)toUser sendStatus:(void(^)(FLMessageModel *message))sendStatus;

/**
 发送位置消息

 @param locationName 位置名称
 @param detailLocationName 详细位置名称
 @param toUser 发送目标人
 @param sendStatus 状态改变返回消息模型
 @return 消息模型
 */
- (FLMessageModel *)sendLocationMessage:(CLLocationCoordinate2D)location locationName:(NSString *)locationName detailLocationName:(NSString *)detailLocationName toUser:(NSString *)toUser sendStatus:(void(^)(FLMessageModel *message))sendStatus;

/**
 消息重发
 
 @param message 消息模型
 @param sendStatus 发送状态回调
 */
- (void)resendMessage:(FLMessageModel *)message sendStatus:(void(^)(FLMessageModel *message))sendStatus;

@end
