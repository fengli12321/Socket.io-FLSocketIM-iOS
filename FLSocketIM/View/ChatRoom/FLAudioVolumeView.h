//
//  FLAudioVolumeView.h
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/26.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kAudioVolumeViewVolumeWidth 2.0f
#define kAudioVolumeViewVolumeMinHeight 3.0f
#define kAudioVolumeViewVolumeMaxHeight 16.0f
#define kAudioVolumeViewVolumePadding 2.0f
#define kAudioVolumeViewVolumeNumber 10

#define kAudioVolumeViewWidth (kAudioVolumeViewVolumeWidth*kAudioVolumeViewVolumeNumber+kAudioVolumeViewVolumePadding*(kAudioVolumeViewVolumeNumber-1))
#define kAudioVolumeViewHeight kAudioVolumeViewVolumeMaxHeight

typedef NS_ENUM(NSInteger, FLAudioVolumeViewType) {
    FLAudioVolumeViewTypeLeft,
    FLAudioVolumeViewTypeRight
};

@interface FLAudioVolumeView : UIView

@property (nonatomic, assign) FLAudioVolumeViewType type;

- (void)addVolume:(double)volume;
- (void)clearVolume;

@end
