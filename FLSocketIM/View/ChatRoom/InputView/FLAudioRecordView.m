//
//  FLAudioRecordView.m
//  FLSocketIM
//
//  Created by 冯里 on 2017/7/26.
//  Copyright © 2017年 冯里. All rights reserved.
//

#import "FLAudioRecordView.h"
#import "AudioManager.h"
#import <QuartzCore/QuartzCore.h>

@interface FLAudioRecordView () <AudioManagerDelegate>

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, assign) FLAudioRecordViewTouchState touchState;

@property (nonatomic, strong) UIView *recordBgView;
@property (nonatomic, strong) UIView *spreadView;
@property (nonatomic, strong) UIView *flashView;

@end
@implementation FLAudioRecordView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        _isRecording = NO;
        _spreadView = [[UIView alloc] initWithFrame:CGRectMake(-8, -8, self.width + 16, self.height + 16)];
        _spreadView.backgroundColor = [UIColor colorWithHex:0xc6ecfd];
        [_spreadView setCornerRadius:_spreadView.width/2.0];
        _spreadView.alpha = 0;
        [self addSubview:_spreadView];
        
        _recordBgView = [[UIView alloc] initWithFrame:CGRectMake(-8, -8, self.width + 16, self.height + 16)];
        _recordBgView.backgroundColor = [UIColor colorWithHex:0x7acffb];
        [_recordBgView setCornerRadius:_recordBgView.width/2.0];
        _recordBgView.hidden = YES;
        [self addSubview:_recordBgView];
        
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.image = [UIImage imageNamed:@"keyboard_voice_record"];
        [self addSubview:_imageView];
        
        _flashView = [[UIView alloc] initWithFrame:self.bounds];
        _flashView.backgroundColor = [UIColor whiteColor];
        [_flashView setCornerRadius:_flashView.width/2.0f];
        _flashView.alpha = 0;
        [self addSubview:_flashView];
        
        [self addTarget:self action:@selector(onTouchDown:) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(onTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [self addTarget:self action:@selector(onTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    }
    return self;
    
}
- (void)dealloc {
    [self stop];
}
- (void)record {
    [self stop];
    
    [[AudioManager shared] stopPlay];
    [AudioManager shared].delegate = self;
    [[AudioManager shared] record];
}

- (void)stop {
    _isRecording = NO;
    [self stopAnimation];
    [[AudioManager shared] stopRecord];
}

- (void)onTouchDown:(id)sender {
    [self record];
}

- (void)onTouchUpInside:(id)sender {
    [self stop];
}

- (void)onTouchUpOutside:(id)sender {
    [self stop];
}

#pragma mark - touch
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    _touchState = FLAudioRecordViewTouchStateInside;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    BOOL touchInside = [self pointInside:[touch locationInView:self] withEvent:nil];
    BOOL touchStateChanged = NO;
    if (_touchState == FLAudioRecordViewTouchStateInside && !touchInside) {
        _touchState = FLAudioRecordViewTouchStateOutside;
        touchStateChanged = YES;
    }
    else if (_touchState == FLAudioRecordViewTouchStateOutside && touchInside) {
        _touchState = FLAudioRecordViewTouchStateInside;
        touchStateChanged = YES;
    }
    if (touchStateChanged) {
        if (_delegate && [_delegate respondsToSelector:@selector(recordView:touchStateChanged:)]) {
            [_delegate recordView:self touchStateChanged:_touchState];
        }
    }
}
#pragma mark - animation
- (void)startAnimation {
    _recordBgView.hidden = NO;
    _spreadView.alpha = 1.0f;
    _spreadView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    _flashView.alpha = 0.4;
    
    [UIView beginAnimations:@"RecordAnimation" context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:1.5f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationRepeatCount:FLT_MAX];
    
    _flashView.alpha = 0;
    _spreadView.transform = CGAffineTransformMakeScale(1.5f, 1.5f);
    _spreadView.alpha = 0;
    
    [UIView commitAnimations];
}
- (void)stopAnimation {

    [_flashView.layer removeAllAnimations];
    [_spreadView.layer removeAllAnimations];
    
    _recordBgView.hidden = YES;
    _spreadView.alpha = 0;
    _flashView.alpha = 0;
}
#pragma mark - AudioManagerDelegate
- (void)didAudioRecordStarted:(AudioManager *)am {
    _isRecording = YES;
    [self startAnimation];
    if (_delegate && [_delegate respondsToSelector:@selector(recordViewRecordStarted:)]) {
        [_delegate recordViewRecordStarted:self];
    }
}

- (void)didAudioRecording:(AudioManager *)am volume:(double)volume {
    if (_delegate && [_delegate respondsToSelector:@selector(recordView:volume:)]) {
        [_delegate recordView:self volume:volume];
    }
}

- (void)didAudioRecordStoped:(AudioManager *)am file:(NSString *)file duration:(NSTimeInterval)duration successfully:(BOOL)successfully {
    _isRecording = NO;
    [self stop];
    if (_delegate && [_delegate respondsToSelector:@selector(recordViewRecordFinished:file:duration:)]) {
        [_delegate recordViewRecordFinished:self file:file duration:duration];
    }
}

- (void)didAudioRecord:(AudioManager *)am err:(NSError *)err {
    _isRecording = NO;
    [self stop];
    if (_delegate && [_delegate respondsToSelector:@selector(recordViewRecord:err:)]) {
        [_delegate recordViewRecord:self err:err];
    }
}
@end
