//
//  FLMessageCellContentView.h
//  FLSocketIM
//
//  Created by 冯里 on 21/08/2017.
//  Copyright © 2017 冯里. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, FLMessageCellType) {
    FLTextMessageCell,
    FLImgMessageCell,
    FLLocMessageCell,
    FLAudioMessageCell,
    FLVideoMessageCell,
    FLOtherMessageCell
};


@interface FLMessageCellContentView : UIControl
@property (nonatomic, assign) BOOL isSender;
@property (nonatomic, strong) FLMessageModel *message;
@property (nonatomic, strong) UIFont *textFont UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat horizontalOffset;
@property (nonatomic, assign) CGFloat verticalOffset;


/**
 工厂类创建入口

 @param cellType 消息类型
 @param isSender 是否是发送者
 @return 返回类簇
 */
- (instancetype)initWithCellType:(FLMessageCellType)cellType isSender:(BOOL)isSender;


/**
 子类的创建入口

 @param isSender 是否是发送者
 @return 自己
 */
- (instancetype)initWithIsSender:(BOOL)isSender;


/**
 子类实现各自的UI布局
 */
- (void)creatUI;

/**
 根据消息内容更新尺寸
 */
- (void)updateFrame;

/**
 点击事件
 */
- (void)tapViewAction;

@end


@interface FLTextMessageContentView : FLMessageCellContentView

@end

@interface FLImageMessageContentView : FLMessageCellContentView

@end

@interface FLLocMessageContentView : FLMessageCellContentView

- (void)resetLocImage;

@end


typedef NS_ENUM(NSInteger, FLAudioPlayViewState) {
    FLAudioPlayViewStateNormal,
    FLAudioPlayViewStateDownloading,
    FLAudioPlayViewStatePlaying
};
@interface FLAudioMessageContentView : FLMessageCellContentView

@property (nonatomic, assign) FLAudioPlayViewState playState;

@end
