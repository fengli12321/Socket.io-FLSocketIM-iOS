//
//  FLAudioVolumeView.m
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/26.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import "FLAudioVolumeView.h"

@interface FLAudioVolumeView ()

@property (nonatomic, strong) NSMutableArray *volumeViews;
@property (nonatomic, strong) NSMutableArray *volumes;

@end
@implementation FLAudioVolumeView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        _volumes = [[NSMutableArray alloc] initWithCapacity:kAudioVolumeViewVolumeNumber];
        _volumeViews = [[NSMutableArray alloc] initWithCapacity:kAudioVolumeViewVolumeNumber];
        for (int i = 0 ; i < kAudioVolumeViewVolumeNumber; i++) {
            
            UIView *volumeView = [[UIView alloc] initWithFrame:CGRectMake((kAudioVolumeViewVolumeWidth+kAudioVolumeViewVolumePadding)*i, (self.frame.size.height-kAudioVolumeViewVolumeMinHeight)/2, kAudioVolumeViewVolumeWidth, kAudioVolumeViewVolumeMinHeight)];
            volumeView.backgroundColor = [UIColor colorWithHex:0xfb8638];
            volumeView.layer.cornerRadius = volumeView.frame.size.width/2;
            [self addSubview:volumeView];
            [_volumeViews addObject:volumeView];
        }
        self.type = FLAudioVolumeViewTypeLeft;
    }
    return self;
}

- (void)addVolume:(double)volume {
    if (_type == FLAudioVolumeViewTypeRight) {
        
        [_volumes removeLastObject];
        [_volumes insertObject:[NSNumber numberWithDouble:volume] atIndex:0];
    }
    else {
        [_volumes removeObjectAtIndex:0];
        [_volumes addObject:[NSNumber numberWithDouble:volume]];
    }
    [self layoutVolumes];
}

- (void)clearVolume {
    [_volumes removeAllObjects];
    for (int i = 0; i < _volumeViews.count; i++) {
        [_volumes addObject:@0];
    }
    [self layoutVolumes];
}

- (void)layoutVolumes {
 
    for (int i = 0; i < _volumeViews.count; i++) {
        UIView *volumeView = _volumeViews[i];
        NSNumber *volume = _volumes[i];
        volumeView.height = [self heightOfVolume:volume.doubleValue];
        volumeView.center = CGPointMake(volumeView.center.x, self.frame.size.height/2);
    }
}

- (CGFloat)heightOfVolume:(double)volume {
    return kAudioVolumeViewVolumeMinHeight + (kAudioVolumeViewVolumeMaxHeight - kAudioVolumeViewVolumeMinHeight) * volume;
}
@end
