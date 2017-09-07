//
//  FLMessageInputView.h
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/11.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, FLMessageInputViewState) {
    FLMessageInputViewStateSystem,
    FLMessageInputViewStateEmotion,
    FLMessageInputViewStateAdd,
    FLMessageInputViewStateVoice
};

@protocol FLMessageInputViewDelegate;

@interface FLMessageInputView : UIView <UITextViewDelegate>

@property (nonatomic, weak) id<FLMessageInputViewDelegate> delegate;

- (void)prepareToShow;
- (void)prepareToDissmiss;
- (BOOL)isAndResignFirstResponder;

@end

@protocol FLMessageInputViewDelegate <NSObject>


/**
 底部高度变化

 @param inputView 输入视图
 @param heightToBottom 变化后的高度
 */
- (void)messageInputView:(FLMessageInputView *)inputView heightToBottomChange:(CGFloat)heightToBottom;

/**
 发送文本

 @param inputView 输入试图
 @param text 文本内容
 */
- (void)messageInputView:(FLMessageInputView *)inputView sendText:(NSString *)text;

/**
 发送大Emotion

 @param inputView 输入视图
 @param emotionName Emotion的名字
 */
- (void)messageInputView:(FLMessageInputView *)inputView sendBigEmotion:(NSString *)emotionName;

/**
 发送语音

 @param inputView 输入视图
 @param saveFile 语音保存的本地路径
 @param duration 语音时长
 */
- (void)messageInputView:(FLMessageInputView *)inputView sendVoice:(NSString *)saveFile duration:(CGFloat)duration;
/**
 更多发送选项点击

 @param inputView 输入视图
 @param index 点击选项index
 */
- (void)messageInputView:(FLMessageInputView *)inputView addIndexClicked:(NSInteger)index;
@end
