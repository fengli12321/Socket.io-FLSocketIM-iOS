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
    FLMessageOther
};

typedef NS_ENUM(NSInteger, FLMessageSendStatus) {
    
    FLMessageSending,   // 正在发送
    FLMessageSendSuccess,   // 发送成功
    FLMessageSendFail   // 发送失败
};
@interface FLMessageModel : NSObject


/** 在聊天界面行高 */
@property (nonatomic, assign) CGFloat messageCellHeight;
/** 文字气泡尺寸 */
@property (nonatomic, assign) CGSize textMessageLabelSize;
/** 消息类型 */
@property (nonatomic, assign) FLMessageModelType type;
/** 消息ID */
@property (nonatomic, copy) NSString *msg_id;
/** 消息发送时间 */
@property (nonatomic, assign) long long timestamp;
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

- (instancetype)initWithToUser:(NSString *)toUser fromUser:(NSString *)fromUser chatType:(NSString *)chatType messageBody:(FLMessageBody *)body;

@end

@interface FLMessageBody : NSObject

@property (nonatomic, copy) NSString *type;     // 消息类型
@property (nonatomic, copy) NSString *msg;      // 文本消息内容
@property (nonatomic, copy) NSString *imgUrl;   // 图片远程地址
@property (nonatomic, copy) NSString *imageName;    // 图片名称
@property (nonatomic, strong) NSData *imgData;  // 图片数据

@end
