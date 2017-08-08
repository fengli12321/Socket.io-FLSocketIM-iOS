//
//  FLAudioRecordView.h
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/26.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, FLAudioRecordViewTouchState) {
    FLAudioRecordViewTouchStateInside,
    FLAudioRecordViewTouchStateOutside
};
@protocol FLAudioRecordViewDelegate;
@interface FLAudioRecordView : UIControl

@property (nonatomic, assign, readonly) BOOL isRecording;
@property (nonatomic, weak) id<FLAudioRecordViewDelegate> delegate;

@end


@protocol FLAudioRecordViewDelegate <NSObject>

@optional

- (void)recordViewRecordStarted:(FLAudioRecordView *)recordView;
- (void)recordViewRecordFinished:(FLAudioRecordView *)recordView file:(NSString *)file duration:(NSTimeInterval)duration;
- (void)recordView:(FLAudioRecordView *)recordView touchStateChanged:(FLAudioRecordViewTouchState)touchState;
- (void)recordView:(FLAudioRecordView *)recordView volume:(double)volume;
- (void)recordViewRecord:(FLAudioRecordView *)recordView err:(NSError *)err;

@end
