//
//  FLMessageCellContentView.m
//  FLSocketIM
//
//  Created by 冯里 on 21/08/2017.
//  Copyright © 2017 冯里. All rights reserved.
//

#import "FLMessageCellContentView.h"
#import "FLMessageBubbleView.h"
#import "AudioManager.h"
#import "AudioAmrUtil.h"

@interface FLMessageCellContentView ()



@end
@implementation FLMessageCellContentView

- (instancetype)initWithCellType:(FLMessageCellType)cellType isSender:(BOOL)isSender{
   
        
    FLMessageCellContentView *contentView;
    switch (cellType) {
        case FLTextMessageCell:{
            contentView = [[FLTextMessageContentView alloc] initWithIsSender:isSender];
            break;
        }
        case FLImgMessageCell:{
            contentView = [[FLImageMessageContentView alloc] initWithIsSender:isSender];
            break;
        }
        case FLLocMessageCell:{
            contentView = [[FLLocMessageContentView alloc] initWithIsSender:isSender];
            break;
        }
        
        case FLAudioMessageCell: {
            contentView = [[FLAudioMessageContentView alloc] initWithIsSender:isSender];
            break;
        }
            
        default:
            contentView = [[FLLocMessageContentView alloc] initWithIsSender:isSender];
            break;
    }
    
    [contentView addTarget:self action:@selector(tapViewAction) forControlEvents:UIControlEventTouchUpInside];
    return contentView;
}



- (void)creatUI {
    
}

- (instancetype)initWithIsSender:(BOOL)isSender {
    
    if (self = [super init]) {
        self.isSender = isSender;
        [self creatUI];
    }
    return self;
}



- (void)updateFrame {
    
}
- (void)setMessage:(FLMessageModel *)message {
    _message = message;
    [self updateFrame];
}

- (void)tapViewAction {
    
}


@end

@interface FLTextMessageContentView ()


@property (nonatomic, strong) FLMessageBubbleView *bubbleView;      // 文字气泡

@end
@implementation FLTextMessageContentView


- (void)creatUI {
    _bubbleView = [[FLMessageBubbleView alloc] initWithIsSender:self.isSender];
    _bubbleView.frame = self.bounds;
    [_bubbleView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self addSubview:_bubbleView];
}


- (void)updateFrame {
    UIEdgeInsets insets = self.isSender?[FLMessageBubbleView appearance].textSendInsets:[FLMessageBubbleView appearance].textRecInsets;
    CGFloat width = self.message.textMessageLabelSize.width + insets.left + insets.right;
    CGFloat height = self.message.textMessageLabelSize.height + insets.top + insets.bottom;
    self.frame = CGRectMake(self.isSender?kScreenWidth - self.horizontalOffset - width:self.horizontalOffset, self.verticalOffset, width, height);

}

- (void)setHorizontalOffset:(CGFloat)horizontalOffset {
    super.horizontalOffset = horizontalOffset;
    _bubbleView.horizontalOffset = horizontalOffset;
}

- (void)setMessage:(FLMessageModel *)message {
    super.message = message;
    _bubbleView.message = message;
}
- (void)setTextFont:(UIFont *)textFont {
    super.textFont = textFont;
    _bubbleView.textFont = textFont;
}

@end


@interface FLImageMessageContentView ()

@property (nonatomic, strong) UIImageView *messageImage;            // 消息图片
@property (nonatomic, strong) CAShapeLayer *maskLayer;


@end
@implementation FLImageMessageContentView

- (void)creatUI {
    
    
    CGFloat width = kScreenWidth/4.0;
    CGFloat height = width*1.5;
    
    _maskLayer = [CAShapeLayer layer];
    _maskLayer.frame = CGRectMake(0, 0, width, height);
    CGRect rect = self.isSender?CGRectMake(0.35, 0.6, 0, 0) : CGRectMake(0.55, 0.6, 0, 0);
    _maskLayer.contentsCenter = rect;
    
    
    UIImage *image = [UIImage imageNamed:self.isSender ? @"video_send_bubble" : @"video_recive_bubble"];;
    _maskLayer.contents = (id)image.CGImage;
    _maskLayer.contentsScale = [UIScreen mainScreen].scale;
    
    
    
    _messageImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    _messageImage.contentMode = UIViewContentModeScaleAspectFill;
    _messageImage.clipsToBounds = YES;
    _messageImage.layer.mask = _maskLayer;
    [self addSubview:_messageImage];
    
   

}

- (void)updateFrame {
    CGFloat width = kScreenWidth/4.0;
    CGFloat height = width*1.5;
    CGRect frame = self.isSender?CGRectMake(kScreenWidth - self.horizontalOffset - width, self.verticalOffset, width, height):CGRectMake(self.horizontalOffset, self.verticalOffset, width, height);
    self.frame = frame;
}

- (void)setMessage:(FLMessageModel *)message {
    super.message = message;
    [self.messageImage fl_setImageWithURL:[NSString stringWithFormat:@"%@/%@", BaseUrl, message.bodies.fileRemotePath] locSavePath:message.bodies.fileName placeholderImage:[UIImage imageNamed:@"Fruit-5"]];
    
}



@end

@interface FLLocMessageContentView ()

@property (nonatomic, strong) UIView *locationBackView;             // 位置背景视图
@property (nonatomic, strong) UILabel *locationNameLabel;           // 位置名称label
@property (nonatomic, strong) UIImageView *locationImageView;       // 定位地图图片
@property (nonatomic, strong) UIView *sepLine;

@end

@implementation FLLocMessageContentView

- (void)creatUI {
    
    
    
    _locationBackView = [[UIView alloc] init];
    [self addSubview:_locationBackView];
    _locationBackView.backgroundColor = [UIColor whiteColor];
    [_locationBackView setCornerRadius:5];
    [_locationBackView setBorderWidth:0.5 color:FLLightGrayColor];

    
    _locationNameLabel = [[UILabel alloc] init];
    _locationNameLabel.font = FLFont(12);
    [_locationBackView addSubview:_locationNameLabel];

    
    _locationImageView = [[UIImageView alloc] init];
    [_locationBackView addSubview:_locationImageView];

    
    
    _sepLine = [[UIView alloc] init];
    _sepLine.backgroundColor = FLLightGrayColor;
    [_locationBackView addSubview:_sepLine];
}

- (void)updateFrame {
    CGFloat width = 200;
    CGFloat imageHeight = width/2.0;
    CGFloat labelH = 30;
    
    CGRect frame = self.isSender ? CGRectMake(kScreenWidth - self.horizontalOffset - width, self.verticalOffset, width, imageHeight + labelH) : CGRectMake(self.horizontalOffset, self.verticalOffset, width, imageHeight + labelH);
    self.frame = frame;
    
    _locationBackView.frame = self.bounds;
    _locationNameLabel.frame = CGRectMake(5, 0, self.width - 5, labelH);
    _locationImageView.frame = CGRectMake(0, labelH, self.width, imageHeight);
    _sepLine.frame = CGRectMake(0, labelH - 0.5, self.width, 0.5);
}


- (void)setMessage:(FLMessageModel *)message {
    super.message = message;
    _locationNameLabel.text = message.bodies.locationName;
}

- (void)resetLocImage {
    if (self.message.bodies.fileRemotePath.length) {
        [_locationImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", BaseUrl, self.message.bodies.fileRemotePath]]];
    }
}
@end


@interface FLAudioMessageContentView () <AudioManagerDelegate>

@property (nonatomic, strong) UIImageView *bubbleImageView;
@property (nonatomic, strong) UIImageView *playImageView;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, assign) CGFloat maxWidth;
@property (nonatomic, assign) CGFloat minWidth;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;


@end

@implementation FLAudioMessageContentView



- (void)creatUI {
    
    _maxWidth = kScreenWidth*2.0/3.0;
    _minWidth = 80;
        
    _bubbleImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _bubbleImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_bubbleImageView];
    _bubbleImageView.image = [UIImage imageNamed:self.isSender ? @"video_send_bubble" : @"video_recive_bubble"];
    
    _playImageView = [[UIImageView alloc] init];
    _playImageView.image = self.isSender?[UIImage imageNamed:@"bubble_right_play_2"]:[UIImage imageNamed:@"bubble_left_play_2"];
    [_bubbleImageView addSubview:_playImageView];
    
    _durationLabel = [[UILabel alloc] init];
    _durationLabel.textColor = self.isSender?[UIColor whiteColor]:FLSecondColor;
    _durationLabel.font = FLFont(14);
    [_bubbleImageView addSubview:_durationLabel];
    
    
    _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    _activityView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    _activityView.hidesWhenStopped = YES;
    [_activityView stopAnimating];
    [_bubbleImageView addSubview:_activityView];
    
}



- (void)updateFrame {
    CGFloat duration = self.message.bodies.duration;
    
    CGFloat maxShowValue = 60.0;
    CGFloat value = MIN(maxShowValue, duration);
    CGFloat width = _minWidth + (_maxWidth - _minWidth) * (value / maxShowValue);
    CGRect selfFrame = self.isSender?CGRectMake(kScreenWidth - self.horizontalOffset - width, self.verticalOffset, width, 40):CGRectMake(self.horizontalOffset, self.verticalOffset, width, 40);
    self.frame = selfFrame;
    
    CGFloat imageW = 20;
    CGRect playerImageFrame = self.isSender?CGRectMake(self.width - imageW -[FLMessageBubbleView appearance].textSendInsets.right, (self.height - imageW)/2.0, imageW, imageW):CGRectMake([FLMessageBubbleView appearance].textRecInsets.left, (self.height - imageW)/2.0, imageW, imageW);
    _playImageView.frame = playerImageFrame;
    
    
    
}

- (void)setFrameWithIconView:(UIView *)iconView {
    
}

- (void)setMessage:(FLMessageModel *)message {
    super.message = message;
    CGFloat duration = message.bodies.duration;
    NSInteger minute = duration/60;
    NSInteger second = (NSInteger)duration%60;
    NSString *showDuration = minute > 0 ? [NSString stringWithFormat:@"%ld\'%ld\"", minute, second] : [NSString stringWithFormat:@"%ld\"", second];
    _durationLabel.text = showDuration;
    
    [_durationLabel sizeToFit];
    CGFloat width = _durationLabel.width;
    CGRect labelFrame = self.isSender?CGRectMake([FLMessageBubbleView appearance].textSendInsets.left, 0, width, self.height):CGRectMake(self.width - width - [FLMessageBubbleView appearance].textRecInsets.right, 0, width, self.height);
    _durationLabel.frame = labelFrame;
}

- (void)tapViewAction {
    
    if (self.playState == FLAudioPlayViewStateNormal) {
        
        [self play];
    }
    else if (self.playState == FLAudioPlayViewStatePlaying) {
        
        [self stop];
    }
}

- (void)stop {
    self.playState = FLAudioPlayViewStateNormal;
    [[AudioManager shared] stopPlay];
}

- (void)play {
    [self stop];
    if (self.message.bodies.fileRemotePath == nil) {
        return;
    }
    
    if ([[AudioManager shared].delegate isKindOfClass:[self class]] && [AudioManager shared].delegate != self) {
        FLAudioMessageContentView *view = (FLAudioMessageContentView *)[AudioManager shared].delegate;
        if (view.playState == FLAudioPlayViewStatePlaying) {
            view.playState = FLAudioPlayViewStateNormal;
        }
    }
    
    [AudioManager shared].delegate = self;
    
    NSString *remotePath = [BaseUrl stringByAppendingPathComponent:self.message.bodies.fileRemotePath];
    // 先去本地查找文件
    NSString *filePath = [[NSString getAudioSavePath] stringByAppendingPathComponent:self.message.bodies.fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        
        [self playFile:filePath];
    }
    else { // 先下载，再播放
        
        [self downLoadAudioWithRemotepath:remotePath filePath:filePath];
    }
}

- (void)downLoadAudioWithRemotepath:(NSString *)remotepath filePath:(NSString *)filePath{
    __weak typeof(self) weakSelf = self;
    [FLNetWorkManager downLoadWithUrl:remotepath progress:nil success:^(id response) {
        
        NSData *audioData = response;
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        [audioData writeToFile:filePath atomically:YES];
        [weakSelf playFile:filePath];
        
    } fail:^(NSError *error) {
        
        weakSelf.playState = FLAudioPlayViewStateNormal;
    }];
    self.playState = FLAudioPlayViewStateDownloading;
}

- (void)playFile:(NSString *)file {
    [self stop];
    if (file.length == 0) {
        return;
    }
    NSString *f = nil;
    if ([@"amr" isEqualToString:file.pathExtension]) {
        f = [AudioAmrUtil convertedWaveFromAmr:file];
        if (f == nil) {
            f = [AudioAmrUtil decodeAmrToWave:file];
        }
    }
    else {
        f = file;
    }
    self.playState = FLAudioPlayViewStatePlaying;
    [[AudioManager shared] play:f validator:nil];
}

- (void)setPlayState:(FLAudioPlayViewState)playState {
    _playState = playState;
    if (playState == FLAudioPlayViewStatePlaying) {
        [_activityView stopAnimating];
        [self startPlayingAnimation];
    }
    else if (playState == FLAudioPlayViewStateDownloading) {
        [_activityView startAnimating];
        [self stopPlayingAnimation];
    }
    else {
        [_activityView stopAnimating];
        [self stopPlayingAnimation];
    }
}

- (void)startPlayingAnimation {
    _playImageView.image = nil;
    if (self.isSender) {
        _playImageView.image = [UIImage animatedImageNamed:@"bubble_right_play_" duration:0.8];
    }
    else {
        _playImageView.image = [UIImage animatedImageNamed:@"bubble_left_play_" duration:0.8];
    }
    [_playImageView startAnimating];
}

- (void)stopPlayingAnimation {
    [_playImageView stopAnimating];
    if (self.isSender) {
        _playImageView.image = [UIImage imageNamed:@"bubble_right_play_2"];
    }
    else {
        _playImageView.image = [UIImage imageNamed:@"bubble_left_play_2"];
    }
}

#pragma mark - AudioManagerDelegate
- (void)didAudioPlayStoped:(AudioManager *)am successfully:(BOOL)successfully {
    self.playState = FLAudioPlayViewStateNormal;
}

- (void)didAudioPlay:(AudioManager *)am err:(NSError *)err {
    FLLog(@"播放错误");
}

@end
