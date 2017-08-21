//
//  FLVideoViewController.m
//  FLSocketIM
//
//  Created by 冯里 on 11/08/2017.
//  Copyright © 2017 冯里. All rights reserved.
//

#import "FLVideoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "FLVideoProgressView.h"
#import <AssetsLibrary/AssetsLibrary.h>


typedef void(^PropertyChangeBlock)(AVCaptureDevice *captureDevice);
@interface FLVideoViewController ()<AVCaptureFileOutputRecordingDelegate>

/**
 文本提示Label
 */
@property (weak, nonatomic) IBOutlet UILabel *labelTipTitle;

/**
 聚焦光标
 */
@property (weak, nonatomic) IBOutlet UIImageView *focusCurson;

/**
 返回按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *btnBack;

/**
 重新拍照录制
 */
@property (weak, nonatomic) IBOutlet UIButton *btnAfresh;

/**
 确定
 */
@property (weak, nonatomic) IBOutlet UIButton *btnConfirm;

/**
 摄像头切换
 */
@property (weak, nonatomic) IBOutlet UIButton *btnCameraChangeDirection;

/**
 背景视图
 */
@property (weak, nonatomic) IBOutlet UIView *backView;

/**
 视频录制进度
 */
@property (weak, nonatomic) IBOutlet FLVideoProgressView *progressView;

/**
 录制
 */
@property (weak, nonatomic) IBOutlet UIImageView *imageRecord;

/**
 刷新按钮CenterX约束
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *refreshCenterX;

/**
 确定按钮CenterX约束
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *confirmCenterX;

/**
 音视频数据的传递
 */
@property (nonatomic, strong) AVCaptureSession *session;

/**
 视频输入流
 */
@property (nonatomic, strong) AVCaptureDeviceInput *cameraInput;

/**
 音频输入流
 */
@property (nonatomic, strong) AVCaptureDeviceInput *audioInput;

/**
 视频输入流
 */
@property (nonatomic, strong) AVCaptureMovieFileOutput *movieOutPut;

/**
 预览图层
 */
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

/**
 是否在对焦
 */
@property (assign, nonatomic) BOOL isFocus;
//后台任务标识
@property (assign,nonatomic) UIBackgroundTaskIdentifier backgroundTaskIdentifier;
@property (assign,nonatomic) UIBackgroundTaskIdentifier lastBackgroundTaskIdentifier;
//记录需要保存视频的路径
@property (strong, nonatomic) NSURL *saveVideoUrl;
//是否是摄像 YES 代表是录制  NO 表示拍照
@property (assign, nonatomic) BOOL isVideo;
//记录录制的时间 默认最大60秒
@property (assign, nonatomic) NSInteger seconds;
// 拍摄的图片
@property (strong, nonatomic) UIImage *takeImage;

/**
 视频预览播放器
 */
@property (nonatomic, strong) FLVideoPlayer *player;

/**
 展示显示的图片
 */
@property (strong, nonatomic) UIImageView *takeImageView;
@end

#define PhotoTimeMax 1
@implementation FLVideoViewController

#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.progressView setCornerRadius:self.progressView.width/2.0];
    
    if (_maxSeconds == 0) {
        _maxSeconds = 60;
    }
    [self performSelector:@selector(hiddenTipsLabel) withObject:nil afterDelay:4];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self customCamera];
    [self.session startRunning];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.session stopRunning];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)dealloc {
    [self removeNotification];
}
#pragma mark - Core
- (void)customCamera {
    
    
    self.session = [[AVCaptureSession alloc] init];
    //设置分辨率 (设备支持的最高分辨率)
    if ([self.session canSetSessionPreset:AVCaptureSessionPresetHigh]) {
        self.session.sessionPreset = AVCaptureSessionPresetHigh;
    }
    // 默认后置摄像头
    AVCaptureDevice *camera = [self getCameraDeviceWithPostion:AVCaptureDevicePositionBack];
    // 获取麦克风
    AVCaptureDevice *microphone = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio].firstObject;
    
    // 初始化输入设备
    NSError *error = nil;
    self.cameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:camera error:&error];
    
    if (error) {
        FLLog(@"视频输入错误：%@", error.localizedDescription);
        return;
    }
    
    error = nil;
    self.audioInput = [[AVCaptureDeviceInput alloc] initWithDevice:microphone error:&error];
    if (error) {
        FLLog(@"音频输入错误：%@", error.localizedDescription);
        return;
    }
    
    // 输出
    self.movieOutPut = [[AVCaptureMovieFileOutput alloc] init];
    // 会话添加输入
    if ([self.session canAddInput:self.cameraInput] && [self.session canAddInput:self.audioInput]) {
        
        [self.session addInput:self.cameraInput];
        [self.session addInput:self.audioInput];
        
        //设置视频防抖
        AVCaptureConnection *connection = [self.movieOutPut connectionWithMediaType:AVMediaTypeVideo];
        if ([connection isVideoStabilizationSupported]) {
            connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeCinematic;
        }
    }
    
    // 将输出设备添加到会话
    if ([self.session canAddOutput:self.movieOutPut]) {
        [self.session addOutput:self.movieOutPut];
    }
    
    //创建视频预览层，用于实时展示摄像头状态
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.previewLayer.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;//填充模式
    [self.backView.layer addSublayer:self.previewLayer];
    
    [self addNotificationToCaptureDevice:camera];
    [self addGenstureRecognizer];
}

#pragma mark - Pravite

//重新拍摄时调用
- (void)recoverLayout{
    if (self.isVideo) {
        self.isVideo = NO;
        [self.player stopPlayer];
        self.player.hidden = YES;
    }
    [self.session startRunning];
    
    if (!self.takeImageView.hidden) {
        self.takeImageView.hidden = YES;
    }
    self.refreshCenterX.constant = 0;
    self.confirmCenterX.constant = 0;
    self.btnAfresh.hidden = YES;
    self.btnConfirm.hidden = YES;
    self.imageRecord.hidden = NO;
//    self.progressView.hidden = NO;
    self.btnCameraChangeDirection.hidden = NO;
    self.btnBack.hidden = NO;
    [UIView animateWithDuration:0.25 animations:^{
        
        [self.view layoutIfNeeded];
    }];
}
/**
 *  移除所有通知
 */
-(void)removeNotification{
    NSNotificationCenter *notificationCenter= [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self];
}

/**
 *  添加点按手势，点按时聚焦
 */
-(void)addGenstureRecognizer{
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapScreen:)];
    [self.backView addGestureRecognizer:tapGesture];
}

/**
 点击屏幕聚焦

 @param tapGesture 手势
 */
-(void)tapScreen:(UITapGestureRecognizer *)tapGesture {
    if ([self.session isRunning]) {
        CGPoint point = [tapGesture locationInView:self.backView];
        // 将UI坐标转换为摄像头坐标
        CGPoint cameraPoint = [self.previewLayer captureDevicePointOfInterestForPoint:point];
        [self setFocusCursorWithPoint:point];
        [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposureMode:AVCaptureExposureModeContinuousAutoExposure atPoint:cameraPoint];
    }
}
/**
 *  设置聚焦光标位置
 *
 *  @param point 光标位置
 */
-(void)setFocusCursorWithPoint:(CGPoint)point{
    if (!self.isFocus) {
        self.isFocus = YES;
        self.focusCurson.center = point;
        [self.focusCurson setTransform:CGAffineTransformMakeScale(1.25, 1.25)];
        self.focusCurson.alpha = 1.0;
        [UIView animateWithDuration:0.5 animations:^{
            
            self.focusCurson.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            
            [self performSelector:@selector(onHiddenFocusCurSorAction) withObject:nil afterDelay:0.5];
        }];
    }
}

/**
 *  设置聚焦模式
 *
 *  @param focusMode 聚焦模式
 */
-(void)setFocusMode:(AVCaptureFocusMode )focusMode{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFocusModeSupported:focusMode]) {
            [captureDevice setFocusMode:focusMode];
        }
    }];
}

/**
 隐藏聚焦
 */
- (void)onHiddenFocusCurSorAction {
    self.focusCurson.alpha=0;
    self.isFocus = NO;
}
/**
 *  设置聚焦点
 *
 *  @param point 聚焦点
 */
-(void)focusWithMode:(AVCaptureFocusMode)focusMode exposureMode:(AVCaptureExposureMode)exposureMode atPoint:(CGPoint)point{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFocusPointOfInterestSupported]) {
            [captureDevice setFocusPointOfInterest:point];
        }
        if ([captureDevice isExposurePointOfInterestSupported]) {
            [captureDevice setExposurePointOfInterest:point];
        }
        if ([captureDevice isExposureModeSupported:exposureMode]) {
            [captureDevice setExposureMode:exposureMode];
        }
        if ([captureDevice isFocusModeSupported:focusMode]) {
            [captureDevice setFocusMode:focusMode];
        }
    }];
}
/**
 隐藏文字提示
 */
- (void)hiddenTipsLabel {
    self.labelTipTitle.hidden = YES;
}
/**
 获取指定方向的摄像头

 @param postion 方向
 @return 摄像头
 */
- (AVCaptureDevice *)getCameraDeviceWithPostion:(AVCaptureDevicePosition)postion {
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        
        if (camera.position == postion) {
            return camera;
        }
    }
    return nil;
}

/**
 *  给输入设备添加通知
 */
-(void)addNotificationToCaptureDevice:(AVCaptureDevice *)captureDevice{
    //注意添加区域改变捕获通知必须首先设置设备允许捕获
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        
        captureDevice.subjectAreaChangeMonitoringEnabled = YES;
    }];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(areaChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:captureDevice];
}

/**
 *  移除通知
 */
-(void)removeNotificationFromCaptureDevice:(AVCaptureDevice *)captureDevice{
    NSNotificationCenter *notificationCenter= [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:captureDevice];
}

/**
 *  改变设备属性的统一操作方法
 *
 *  @param propertyChange 属性改变操作
 */
-(void)changeDeviceProperty:(PropertyChangeBlock)propertyChange{
    AVCaptureDevice *captureDevice = [self.cameraInput device];
    NSError *error = nil;
    //注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁
    if ([captureDevice lockForConfiguration:&error]) {
        //自动白平衡
        if ([captureDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
            [captureDevice setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
        }
        //自动根据环境条件开启闪光灯
        if ([captureDevice isFlashModeSupported:AVCaptureFlashModeAuto]) {
            [captureDevice setFlashMode:AVCaptureFlashModeAuto];
        }
        
        propertyChange(captureDevice);
        [captureDevice unlockForConfiguration];
    }
    else {
        FLLog(@"摄像头属性设置错误");
    }
}

/**
 停止录制
 */
- (void)endRecord {
    
    [self.movieOutPut stopRecording];
}


/**
 根据录制时间判断为图片还是视频，如果超过最大录制时间，停止录制（在录制过程中不断调用）

 @param fileURL 保存路径
 */
- (void)onStartTranscribe:(NSURL *)fileURL {
    
    if ([self.movieOutPut isRecording]) {
        --self.seconds;
        if (self.seconds > 0) {
            if (self.maxSeconds - self.seconds >= PhotoTimeMax && !self.isVideo) {
                self.isVideo = YES;
                self.progressView.timeMax = self.seconds;
            }
            [self performSelector:@selector(onStartTranscribe:) withObject:nil afterDelay:1.0];
        }
        else {
            if ([self.movieOutPut isRecording]) {
                [self.movieOutPut stopRecording];
            }
        }
    }
}

//拍摄完成时调用
- (void)changeLayout{
    self.imageRecord.hidden = YES;
    self.btnCameraChangeDirection.hidden = YES;
    self.btnAfresh.hidden = NO;
    self.btnConfirm.hidden = NO;
    self.btnBack.hidden = YES;
    self.progressView.hidden = YES;
    if (self.isVideo) {
        [self.progressView clearProgress];
    }
    self.refreshCenterX.constant = -kScreenWidth/4.0;
    self.confirmCenterX.constant = kScreenWidth/4.0;
    [UIView animateWithDuration:0.25 animations:^{
        
        [self.view layoutIfNeeded];
    }];
    self.lastBackgroundTaskIdentifier = self.lastBackgroundTaskIdentifier;
    self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
    [self.session stopRunning];
}


/**
 从保存路径获取图片

 @param url 输出路径
 */
- (void)videoHandlePhoto:(NSURL *)url {
    
    AVURLAsset *urlAsset = [AVURLAsset assetWithURL:url];
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
    // 截图时调整到正确的方向
    imageGenerator.appliesPreferredTrackTransform = YES;
    NSError *error = nil;
    CMTime time = CMTimeMake(0,30);//缩略图创建时间 CMTime是表示电影时间信息的结构体，第一个参数表示是视频第几秒，第二个参数表示每秒帧数.(如果要获取某一秒的第几帧可以使用CMTimeMake方法)
    CMTime actualTime; // 缩略图的实际生成时间
    CGImageRef cgImage = [imageGenerator copyCGImageAtTime:time actualTime:&actualTime error:&error];
    if (error) {
        FLLog(@"获取视频图片失败:%@", error.localizedDescription);
    }
    CMTimeShow(actualTime);
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    if (image) {
        FLLog(@"视频截取成功");
    }
    else {
        FLLog(@"视频截取失败");
    }
    self.takeImage = image;
    
    [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
    if (!self.takeImageView) {
        self.takeImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        [self.backView addSubview:self.takeImageView];
    }
    self.takeImageView.hidden = NO;
    self.takeImageView.image = self.takeImage;
}

- (CGFloat)fileSize:(NSURL *)path
{
    return [[NSData dataWithContentsOfURL:path] length]/1024.00 /1024.00;
}
/**
 获取视频数据
 */
- (void)getVideoDataSuccess:(void(^)(NSString *savePath))success {
    
    FLLog(@"开始压缩,压缩前大小 %f MB",[self fileSize:self.saveVideoUrl]);
    NSString *videoName = [NSString stringWithFormat:@"%@.mp4", [[NSUUID UUID] UUIDString]];
    NSString *savePath = [[NSString getFielSavePath] stringByAppendingPathComponent:videoName];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:self.saveVideoUrl options:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
    exportSession.shouldOptimizeForNetworkUse = YES;
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.outputURL = [NSURL fileURLWithPath:savePath];
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        int exportStatus = exportSession.status;
        FLLog(@"%d",exportStatus);
        switch (exportStatus)
        {
            case AVAssetExportSessionStatusFailed:
            {
                // log error to text view
                NSError *exportError = exportSession.error;
                FLLog (@"AVAssetExportSessionStatusFailed: %@", exportError);
                break;
            }
            case AVAssetExportSessionStatusCompleted:
            {
                FLLog(@"视频转码成功");
                FLLog(@"压缩完毕,压缩后大小 %f MB",[self fileSize:[NSURL fileURLWithPath:savePath]]);
                success(savePath);
            }
        }
    }];
}

- (void)saveVideo:(NSURL *)outputFileURL
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeVideoAtPathToSavedPhotosAlbum:outputFileURL
                                completionBlock:^(NSURL *assetURL, NSError *error) {
                                    if (error) {
                                        NSLog(@"保存视频失败:%@",error);
                                    } else {
                                        NSLog(@"保存视频到相册成功");
                                    }
                                }];
}

#pragma mark - Observe
/**
 *  捕获区域改变
 *
 *  @param notification 通知对象
 */
-(void)areaChange:(NSNotification *)notification{
    NSLog(@"捕获区域改变...");
}

#pragma mark - BtnAction


/**
 确定发送按钮点击

 @param sender 按钮
 */
- (IBAction)onEnsureAction:(id)sender {
    
    FLLog(@"去实现发送功能吧");
    if (self.saveVideoUrl) {
        __weak typeof(self) weakSelf = self;
        [self getVideoDataSuccess:^(NSString *savePath) {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                NSData *videoData = [NSData dataWithContentsOfFile:savePath];
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (weakSelf.takePhotoOrVideo) {
                        weakSelf.takePhotoOrVideo(videoData, NO);
                    }
                    [weakSelf dismissViewControllerAnimated:YES completion:nil];
                });
            });
            
        }];
    }
    else { // 照片
        
        
        NSData *imageData = UIImageJPEGRepresentation(self.takeImage, 0.5);
        if (self.takePhotoOrVideo) {
            self.takePhotoOrVideo(imageData, YES);
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

/**
 切换前后摄像头

 @param sender 按钮
 */
- (IBAction)onCameraAction:(id)sender {
    FLLog(@"切换摄像头方向");
    AVCaptureDevice *currentDevice = [self.cameraInput device];
    AVCaptureDevicePosition currentPosition = currentDevice.position;
    [self removeNotificationFromCaptureDevice:currentDevice];
    AVCaptureDevice *toChangeDevice;
    AVCaptureDevicePosition toChangePostion = AVCaptureDevicePositionFront;
    if (currentPosition == AVCaptureDevicePositionFront || currentPosition == AVCaptureDevicePositionUnspecified) {
        toChangePostion = AVCaptureDevicePositionBack;
    }
    
    toChangeDevice = [self getCameraDeviceWithPostion:toChangePostion];
    [self addNotificationToCaptureDevice:toChangeDevice];
    // 获得要调整设备的输入对象
    AVCaptureDeviceInput *toChangeDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:toChangeDevice error:nil];
    
    // 改变会话配置前先开启配置，修改完成在提交配置
    [self.session beginConfiguration];
    // 移除原来的输入对象
    [self.session removeInput:self.cameraInput];
    // 添加新的输入对象
    if ([self.session canAddInput:toChangeDeviceInput]) {
        [self.session addInput:toChangeDeviceInput];
        self.cameraInput = toChangeDeviceInput;
    }
    // 提交配置
    [self.session commitConfiguration];
}

/**
 退出界面

 @param sender 按钮
 */
- (IBAction)onCancelAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 重新录制

 @param sender 按钮
 */
- (IBAction)onAfreshAction:(UIButton *)sender {
    FLLog(@"重新录制");
    [self recoverLayout];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if ([touches anyObject].view == self.imageRecord) {
        
        FLLog(@"开始录制");
        //根据设备输出获得连接
        AVCaptureConnection *connection = [self.movieOutPut connectionWithMediaType:AVMediaTypeAudio];
        //根据连接取得设备输出的数据
        if (![self.movieOutPut isRecording]) {
            //如果支持多任务则开始多任务
            if ([[UIDevice currentDevice] isMultitaskingSupported]) {
                self.backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
            }
            if (self.saveVideoUrl) {
                [[NSFileManager defaultManager] removeItemAtURL:self.saveVideoUrl error:nil];
            }
            //预览图层和视频方向保持一致
            connection.videoOrientation = [self.previewLayer connection].videoOrientation;
            NSString *outputFielPath=[NSTemporaryDirectory() stringByAppendingString:@"myMovie.mov"];
            NSLog(@"save path is :%@",outputFielPath);
            NSURL *fileUrl=[NSURL fileURLWithPath:outputFielPath];
            NSLog(@"fileUrl:%@",fileUrl);
            [self.movieOutPut startRecordingToOutputFileURL:fileUrl recordingDelegate:self];
        } else {
            [self.movieOutPut stopRecording];
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if ([touches anyObject].view == self.imageRecord) {
        
        FLLog(@"结束录制");
        if (!self.isVideo) {
            [self performSelector:@selector(endRecord) withObject:nil afterDelay:0.3];
        }
        else {
            [self endRecord];
        }
    }
}

#pragma mark - AVCaptureFileOutputRecordingDelegate
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections {
    FLLog(@"输出检测到开始录制");
    self.seconds = self.maxSeconds;
    [self performSelector:@selector(onStartTranscribe:) withObject:fileURL afterDelay:1.0];
}
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error {
    FLLog(@"输出检测到视频录制完成");
    [self changeLayout];
    if (self.isVideo) {
        self.saveVideoUrl = outputFileURL;
        if (!self.player) {
            self.player = [[FLVideoPlayer alloc] initWithFrame:self.backView.bounds showInView:self.backView url:outputFileURL];
        }
        else {
            if (outputFileURL) {
                self.player.videoUrl = outputFileURL;
                self.player.hidden = NO;
            }
        }
    }
    else {
        // 照片
        self.saveVideoUrl = nil;
        [self videoHandlePhoto:outputFileURL];
    }
}
@end


@interface FLVideoPlayer ()


/**
 播放器
 */
@property (nonatomic, strong) AVPlayer *player;

@end

@implementation FLVideoPlayer

- (AVPlayer *)player {
    if (!_player) {
        _player = [AVPlayer playerWithPlayerItem:[self getAVPlayerItem]];
        [self addAVPlayerNtf:_player.currentItem];
    }
    return _player;
}
- (void)dealloc {
    
    [self removeAvPlayerNtf];
    [self stopPlayer];
    self.player = nil;
}
- (instancetype)initWithFrame:(CGRect)frame showInView:(UIView *)bgView url:(NSURL *)url {
    if (self = [super initWithFrame:frame]) {
        
        // 创建播放图片
        AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        playerLayer.frame = self.bounds;
        [self.layer addSublayer:playerLayer];
        if (url) {
            self.videoUrl = url;
        }
        [bgView addSubview:self];
    }
    return self;
}


- (AVPlayerItem *)getAVPlayerItem {
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:self.videoUrl];
    return playerItem;
}

- (void)setVideoUrl:(NSURL *)videoUrl {
    _videoUrl = videoUrl;
    [self removeAvPlayerNtf];
    [self nextPlayer];
}

- (void)nextPlayer {
    [self.player seekToTime:CMTimeMake(0, _player.currentItem.duration.timescale)];
    [self.player replaceCurrentItemWithPlayerItem:[self getAVPlayerItem]];
    [self addAVPlayerNtf:self.player.currentItem];
    if (self.player.rate == 0) {
        [self.player play];
    }
    
}

- (void) addAVPlayerNtf:(AVPlayerItem *)playerItem {
    // 监控状态属性
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    // 监控网络加载状况属性
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
    [FLNotificationCenter addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
}

- (void)removeAvPlayerNtf {
    AVPlayerItem *playerItem = self.player.currentItem;
    [playerItem removeObserver:self forKeyPath:@"status"];
    [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)stopPlayer {
    if (self.player.rate == 1) {
        [self.player pause];
    }
}

- (void)playbackFinished:(NSNotification *)ntf {
    FLLog(@"视频播放完成");
    [self.player seekToTime:CMTimeMake(0, 1)];
    [self.player play];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    AVPlayerItem *playerItem = object;
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status= [[change objectForKey:@"new"] intValue];
        if(status==AVPlayerStatusReadyToPlay){
            FLLog(@"正在播放...，视频总长度:%.2f",CMTimeGetSeconds(playerItem.duration));
        }
    }else if([keyPath isEqualToString:@"loadedTimeRanges"]){
        NSArray *array=playerItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;//缓冲总长度
        FLLog(@"共缓冲：%.2f",totalBuffer);
    }
}

@end
