//
//  FLMessageModel.h
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/7.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FLMessageBody;
typedef NS_ENUM(NSInteger, FLMessageModelType) {
    FLMessageText,
    FLMessageImage,
    FLMessageLoc,
    FlMessageAudio,
    FLMessageVideo,
    FLMessageOther
};

typedef NS_ENUM(NSInteger, FLMessageSendStatus) {
    
    FLMessageSending,   // 正在发送
    FLMessageSendSuccess,   // 发送成功
    FLMessageSendFail   // 发送失败
};



@interface FLMessageModel : NSObject <YYModel>


/** 在聊天界面行高 */
@property (nonatomic, assign) CGFloat messageCellHeight;
/** 文字气泡尺寸 */
@property (nonatomic, assign) CGSize textMessageLabelSize;
/** 消息类型 */
@property (nonatomic, assign) FLMessageModelType type;
/** 消息ID */
@property (nonatomic, copy) NSString *msg_id;
/** 消息发送服务器时间 */
@property (nonatomic, assign) long long timestamp;
/** 消息发送本地时间 */
@property (nonatomic, assign) long long sendtime;
/** 接收人的username或者接收group的ID */
@property (nonatomic, copy) NSString *to;
/** 发送人username */
@property (nonatomic, copy) NSString *from;
/** 聊天类型 */
@property (nonatomic, copy) NSString *chat_type;
/** 消息体对象 */
@property (nonatomic, strong) FLMessageBody *bodies;
/** 发送是否成功 */
@property (nonatomic, assign) BOOL isSendSuccess;
/** 消息发送状态 */
@property (nonatomic, assign) enum FLMessageSendStatus sendStatus;

- (void)setImageCellSize;
- (instancetype)initWithToUser:(NSString *)toUser fromUser:(NSString *)fromUser chatType:(NSString *)chatType messageBody:(FLMessageBody *)body;

@end

@interface FLMessageBody : NSObject <YYModel>


#pragma mark - 公共
/** 消息类型 */
@property (nonatomic, copy) NSString *type;

#pragma mark - 文本
/** 文本消息内容 */
@property (nonatomic, copy) NSString *msg;

#pragma mark - 图片
/** 图片尺寸 */
@property (nonatomic, copy) NSDictionary *size;
/** 缩略图远程地址 */
@property (nonatomic, copy) NSString *thumbnailRemotePath;
/** 父亲 */
@property (nonatomic, weak) FLMessageModel *superModel;

#pragma mark - 定位
/** 纬度 */
@property (nonatomic, assign) CGFloat latitude;
/** 经度 */
@property (nonatomic, assign) CGFloat longitude;
/** 位置名称 */
@property (nonatomic, copy) NSString *locationName;
/** 详细位置名称 */
@property (nonatomic, copy) NSString *detailLocationName;

#pragma mark - 语音
/** 语音消息时长 */
@property (nonatomic, assign) CGFloat duration;


#pragma mark - 文件
/** 文件服务器地址 */
@property (nonatomic, copy) NSString *fileRemotePath;
/** 文件名称 */
@property (nonatomic, copy) NSString *fileName;
/** 文件数据 */
@property (nonatomic, strong) NSData *fileData;

@end
