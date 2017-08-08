//
//  FLMessageInputView_Voice.m
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/26.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import "FLMessageInputView_Voice.h"
#import "AudioManager.h"
#import "FLAudioVolumeView.h"
#import "FLAudioRecordView.h"

typedef NS_ENUM(NSInteger, FLMessageInputView_VoiceState) {
    FLMessageInputView_VoiceStateReady,
    FLMessageInputView_VoiceStateRecording,
    FLMessageInputView_VoiceStateCancel
};

@interface FLMessageInputView_Voice () <FLAudioRecordViewDelegate>

@property (strong, nonatomic) UILabel *recordTipsLabel;
@property (strong, nonatomic) FLAudioRecordView *recordView;
@property (strong, nonatomic) FLAudioVolumeView *volumeLeftView;
@property (strong, nonatomic) FLAudioVolumeView *volumeRightView;
@property (assign, nonatomic) FLMessageInputView_VoiceState state;
@property (assign, nonatomic) int duration;
@property (strong, nonatomic) NSTimer *timer;

@end
@implementation FLMessageInputView_Voice

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self creatUI];
    }
    return self;
}


- (void)creatUI {
    
    self.backgroundColor = FLBackGroundColor;
    
    _recordTipsLabel = [[UILabel alloc] init];
    _recordTipsLabel.font = FLFont(18);
    [self addSubview:_recordTipsLabel];
    
    _volumeLeftView = [[FLAudioVolumeView alloc] initWithFrame:CGRectMake(0, 0, kAudioVolumeViewWidth, kAudioVolumeViewHeight)];
    _volumeLeftView.type = FLAudioVolumeViewTypeLeft;
    _volumeLeftView.hidden = YES;
    [self addSubview:_volumeLeftView];
    
    _volumeRightView = [[FLAudioVolumeView alloc] initWithFrame:CGRectMake(0, 0, kAudioVolumeViewWidth, kAudioVolumeViewHeight)];
    _volumeRightView.type = FLAudioVolumeViewTypeRight;
    _volumeRightView.hidden = YES;
    [self addSubview:_volumeRightView];
    
    
    _recordView = [[FLAudioRecordView alloc] initWithFrame:CGRectMake((self.frame.size.width - 86) / 2, 62, 86, 86)];
    _recordView.delegate = self;
    [self addSubview:_recordView];
    
    UILabel *tipLabel = [[UILabel alloc] init];
    tipLabel.font = FLFont(12);
    tipLabel.textColor = [UIColor colorWithHex:0x999999];
    tipLabel.text = @"向上滑动，取消发送";
    [tipLabel sizeToFit];
    [self addSubview:tipLabel];
    tipLabel.center = CGPointMake(self.width/2.0, self.height - 25);
    
    _duration = 0;
    self.state = FLMessageInputView_VoiceStateReady;
}

- (void)dealloc {
    self.state = FLMessageInputView_VoiceStateReady;
}

- (void)setState:(FLMessageInputView_VoiceState)state {
    _state = state;
    switch (state) {
        case FLMessageInputView_VoiceStateReady:
            _recordTipsLabel.textColor = [UIColor colorWithHex:0x999999];
            _recordTipsLabel.text = @"按住说话";
            _volumeRightView.hidden = YES;
            _volumeLeftView.hidden = YES;
            break;
            
        case FLMessageInputView_VoiceStateRecording:
            if (_duration < [AudioManager shared].maxRecordDuration - 5) {
                _recordTipsLabel.textColor = [UIColor colorWithHex:0x2faeea];
            }
            else {
                _recordTipsLabel.textColor = [UIColor colorWithHex:0xde4743];
            }
            _recordTipsLabel.text = [self formattedTime:_duration];
            break;
            
        case FLMessageInputView_VoiceStateCancel:
            _recordTipsLabel.textColor = [UIColor colorWithHex:0x999999];
            _recordTipsLabel.text = @"松开取消";
            _volumeLeftView.hidden = YES;
            _volumeRightView.hidden = YES;
            break;
        default:
            break;
    }
    [_recordTipsLabel sizeToFit];
    _recordTipsLabel.center = CGPointMake(self.width/2, 20);
    if (self.state == FLMessageInputView_VoiceStateRecording) {
        _volumeLeftView.center = CGPointMake(_recordTipsLabel.frame.origin.x - _volumeLeftView.frame.size.width/2 - 12, _recordTipsLabel.center.y);
        _volumeLeftView.hidden = NO;
        _volumeRightView.center = CGPointMake(_recordTipsLabel.frame.origin.x + _recordTipsLabel.frame.size.width + _volumeRightView.frame.size.width/2 + 12, _recordTipsLabel.center.y);
        _volumeRightView.hidden = NO;
    }
}
#pragma mark - RecordTimer
- (void)startTimer {
    _duration = 0;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(increaseRecordTime) userInfo:nil repeats:YES];
}

- (void)stopTimer {
    if (_timer) {
        [_timer invalidate];
        self.timer = nil;
    }
}

- (void)increaseRecordTime {
    _duration ++;
    _duration++;
    if (self.state == FLMessageInputView_VoiceStateRecording) {
        //update time label
        self.state = FLMessageInputView_VoiceStateRecording;
    }

}

- (NSString *)formattedTime:(int)duration {
    return [NSString stringWithFormat:@"%02d:%02d", duration / 60, duration % 60];
}

#pragma mark - FLAudioRecordViewDelegate
- (void)recordViewRecordStarted:(FLAudioRecordView *)recordView {
    [_volumeLeftView clearVolume];
    [_volumeRightView clearVolume];
    
    self.state = FLMessageInputView_VoiceStateRecording;
    [self startTimer];
}

- (void)recordViewRecordFinished:(FLAudioRecordView *)recordView file:(NSString *)file duration:(NSTimeInterval)duration {
    [self stopTimer];
    if (self.state == FLMessageInputView_VoiceStateRecording) {
        if (_recordSuccessfully) {
            _recordSuccessfully(file, duration);
        }
    }
    else if (self.state == FLMessageInputView_VoiceStateCancel) {
        [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
    }
    
    self.state = FLMessageInputView_VoiceStateReady;
    _duration = 0;
}

- (void)recordView:(FLAudioRecordView *)recordView touchStateChanged:(FLAudioRecordViewTouchState)touchState {
    if (self.state != FLMessageInputView_VoiceStateReady) {
        if (touchState == FLAudioRecordViewTouchStateInside) {
            self.state = FLMessageInputView_VoiceStateRecording;
        }
        else {
            self.state = FLMessageInputView_VoiceStateCancel;
        }
    }
}

- (void)recordView:(FLAudioRecordView *)recordView volume:(double)volume {
    [_volumeLeftView addVolume:volume];
    [_volumeRightView addVolume:volume];
}

- (void)recordViewRecord:(FLAudioRecordView *)recordView err:(NSError *)err {
    [self stopTimer];
    if (self.state == FLMessageInputView_VoiceStateRecording) {
        FLLog(@"错误%@", err.domain);
    }
    self.state = FLMessageInputView_VoiceStateReady;
    _duration = 0;
}

@end
