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

@end

@protocol FLMessageInputViewDelegate <NSObject>

- (void)messageInputView:(FLMessageInputView *)inputView heightToBottomChange:(CGFloat)heightToBottom;
- (void)messageInputView:(FLMessageInputView *)inputView sendText:(NSString *)text;

- (void)messageInputViewSendImage;
@end
