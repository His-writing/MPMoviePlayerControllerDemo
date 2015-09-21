//
//  KrVideoPlayerController.m
//  KrVideoPlayerPlus
//
//  Created by JiaHaiyang on 15/6/19.
//  Copyright (c) 2015年 JiaHaiyang. All rights reserved.
//

#import "KrVideoPlayerController.h"
#import "KrVideoPlayerControlView.h"
#import <AVFoundation/AVFoundation.h>

static const CGFloat kVideoPlayerControllerAnimationTimeinterval = 0.3f;

@interface KrVideoPlayerController()

@property (nonatomic, strong) KrVideoPlayerControlView *videoControl;
@property (nonatomic, strong) UIView *movieBackgroundView;
@property (nonatomic, assign) BOOL isFullscreenMode;
@property (nonatomic, assign) CGRect originFrame;
@property (nonatomic, strong) NSTimer *durationTimer;

@end

@implementation KrVideoPlayerController

- (void)dealloc
{
    [self cancelObserver];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self) {
        self.view.frame = frame;
        self.view.backgroundColor = [UIColor blackColor];
        self.controlStyle = MPMovieControlStyleNone;
        [self.view addSubview:self.videoControl];
        self.videoControl.frame = self.view.bounds;
        [self configObserver];
        [self configControlAction];
        [self ListeningRotating];
    }
    return self;
}

#pragma mark - Override Method

- (void)setContentURL:(NSURL *)contentURL
{
    [self.videoControl.indicatorView stopAnimating];

    
    [self stop];
    
    
//    if ([self isPreparedToPlay]) {
//
//    }
    
    
    [super setContentURL:contentURL];
//    [self play];
    
//    [self.videoControl.indicatorView startAnimating];

}

#pragma mark - Publick Method

- (void)showInWindow
{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    if (!keyWindow) {
        keyWindow = [[[UIApplication sharedApplication] windows] firstObject];
    }
    [keyWindow addSubview:self.view];
    self.view.alpha = 0.0;
    [UIView animateWithDuration:kVideoPlayerControllerAnimationTimeinterval animations:^{
        self.view.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

- (void)dismiss
{
    [self stopDurationTimer];
    [self stop];
    [UIView animateWithDuration:kVideoPlayerControllerAnimationTimeinterval animations:^{
        self.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        
        
        [self.view removeFromSuperview];
        if (self.dimissCompleteBlock) {
            self.dimissCompleteBlock();
        }
    }];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

#pragma mark - Private Method

- (void)configObserver
{
    //	媒体网络加载状态改变
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMoviePlayerLoadStateDidChangeNotification) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
    //	播放状态改变，可配合playbakcStat
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMoviePlayerPlaybackStateDidChangeNotification) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMoviePlayerReadyForDisplayDidChangeNotification) name:MPMoviePlayerReadyForDisplayDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMovieDurationAvailableNotification) name:MPMovieDurationAvailableNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMediaPlaybackIsPreparedToPlayDidChangeNotification) name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification object:nil];

}

- (void)cancelObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)configControlAction
{
    [self.videoControl.playButton addTarget:self action:@selector(playButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.certerPlayButton addTarget:self action:@selector(playButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.playButton1 addTarget:self action:@selector(playButtonClick) forControlEvents:UIControlEventTouchUpInside];

    
    [self.videoControl.certerPauseButton addTarget:self action:@selector(pauseButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    [self.videoControl.pauseButton addTarget:self action:@selector(pauseButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.pauseButton1 addTarget:self action:@selector(pauseButtonClick) forControlEvents:UIControlEventTouchUpInside];

    [self.videoControl.closeButton addTarget:self action:@selector(closeButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.fullScreenButton addTarget:self action:@selector(fullScreenButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.fullScreenButton1 addTarget:self action:@selector(fullScreenButtonClick) forControlEvents:UIControlEventTouchUpInside];

    [self.videoControl.shrinkScreenButton addTarget:self action:@selector(shrinkScreenButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.shrinkScreenButton1 addTarget:self action:@selector(shrinkScreenButtonClick) forControlEvents:UIControlEventTouchUpInside];

    [self.videoControl.progressSlider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.videoControl.progressSlider addTarget:self action:@selector(progressSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
    [self.videoControl.progressSlider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.progressSlider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpOutside];
    [self setProgressSliderMaxMinValues];
    [self monitorVideoPlayback];
}

- (void)onMPMoviePlayerPlaybackStateDidChangeNotification
{
  
    
    
    if (self.playbackState == MPMoviePlaybackStatePlaying) {
        
        self.videoControl.pauseButton.hidden = NO;
        self.videoControl.pauseButton1.hidden = NO;
        self.videoControl.certerPauseButton.hidden=NO;
        self.videoControl.playButton.hidden = YES;
        self.videoControl.certerPlayButton.hidden = YES;

        
//        [self startDurationTimer];
        [self.videoControl.indicatorView stopAnimating];
        [self.videoControl autoFadeOutControlBar];
    } else {
        self.videoControl.pauseButton.hidden = YES;
        self.videoControl.pauseButton1.hidden = YES;
        self.videoControl.certerPauseButton.hidden=YES;
        self.videoControl.certerPlayButton.hidden = NO;
        self.videoControl.playButton.hidden = NO;

        
        
//        [self stopDurationTimer];
        if (self.playbackState == MPMoviePlaybackStateStopped) {
            [self.videoControl animateShow];
        }
    }

    
//    switch (self.playbackState) {
//            
//        case MPMoviePlaybackStateStopped:
//            NSLog(@"停止");
//            self.videoControl.pauseButton.hidden = YES;
//            self.videoControl.pauseButton1.hidden = YES;
//            self.videoControl.certerPauseButton.hidden=YES;
//            self.videoControl.certerPlayButton.hidden = NO;
//            self.videoControl.playButton.hidden = NO;
//            [self.videoControl.indicatorView stopAnimating];
//            [self.videoControl animateShow];
//
//            break;
//            
//        case MPMoviePlaybackStatePlaying:
//            NSLog(@"播放中");
//            
//            self.videoControl.pauseButton.hidden = NO;
//            self.videoControl.pauseButton1.hidden = NO;
//            self.videoControl.certerPauseButton.hidden=NO;
//            self.videoControl.playButton.hidden = YES;
//            self.videoControl.certerPlayButton.hidden = YES;
////            [self startDurationTimer];
////            [self.videoControl.indicatorView stopAnimating];
//            [self.videoControl autoFadeOutControlBar];
//
//            break;
//            
//        case MPMoviePlaybackStatePaused:
//            NSLog(@"暫停");
//            [self.videoControl.indicatorView stopAnimating];
//            self.videoControl.pauseButton.hidden = YES;
//            self.videoControl.pauseButton1.hidden = YES;
//            self.videoControl.certerPauseButton.hidden=YES;
//            self.videoControl.certerPlayButton.hidden = NO;
////            [self.videoControl.certerPlayButton setSelected:NO];
//            self.videoControl.playButton.hidden = NO;
//            [self stopDurationTimer];
//
//            break;
//            
//        case MPMoviePlaybackStateInterrupted:
//            NSLog(@"播放被中斷");
//            [self.videoControl.indicatorView startAnimating];
//            break;
//            
//        case MPMoviePlaybackStateSeekingForward:
//            NSLog(@"往前快轉");
//            break;
//            
//        case MPMoviePlaybackStateSeekingBackward:
//            NSLog(@"往後快轉");
//            break;
//            
//        default:
//            NSLog(@"無法辨識的狀態");
//            break;
//    }

}

- (void)onMPMoviePlayerLoadStateDidChangeNotification
{
    
    if (self.loadState & MPMovieLoadStateStalled) {
        [self.videoControl.indicatorView startAnimating];
    }

//    MPMovieLoadStateUnknown        = 0,
//    MPMovieLoadStatePlayable       = 1 << 0,
//    MPMovieLoadStatePlaythroughOK  = 1 << 1, // Playback will be automatically started in this state when shouldAutoplay is YES
//    MPMovieLoadStateStalled
    
//    NSLog(@"loadState-----%lu",(unsigned long)self.loadState);
//    // 合并提取事件输入的error标识来获取错误信息
//    if (self.loadState==MPMovieLoadStateUnknown) {
//        [self pause];
//        NSLog(@"合并提取事件输入的error标识来获取错误信息");
//        //状态为可播放的情况下
//    }else if(self.loadState==MPMovieLoadStatePlayable){
//        [self.videoControl.indicatorView stopAnimating];
//        NSLog(@"状态为可播放的情况下");
//        //状态为缓冲几乎完成的情况，可以连续播放的状态
//    }else if (self.loadState==MPMovieLoadStatePlaythroughOK){
//        [self.videoControl.indicatorView stopAnimating];
//        NSLog(@"状态为缓冲几乎完成的情况，可以连续播放的状态");
//        //        if(!_timer)
//        //        {
//        //            _timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(changeValue) userInfo:nil repeats:YES];
//        //        }
//        //        [_timer fire];
//        //        [player play];
//        
//        //状态为缓冲中
//    }else if (self.loadState==MPMovieLoadStateStalled){
//        NSLog(@"状态为缓冲中");
//        
//                [self.videoControl.indicatorView startAnimating];
//
//        
//    }else {
//    
//        NSLog(@"weizhi");
//    }

/* 事件处理模版
         MPMoviePlayerController *player = notification.object;
         MPMovieLoadState loadState = player.loadState;
         if(loadState & MPMovieLoadStateUnknown){ }
         if(loadState & MPMovieLoadStatePlayable)
         { //第一次加载，或者前后拖动完成之后 /
         }
         if(loadState & MPMovieLoadStatePlaythroughOK)
         { }
         if(loadState & MPMovieLoadStateStalled)
         { //网络不好，开始缓冲了 }
   */
}

- (void)onMPMoviePlayerReadyForDisplayDidChangeNotification
{
    
}

- (void)onMPMediaPlaybackIsPreparedToPlayDidChangeNotification
{
    [self.videoControl.indicatorView stopAnimating];

    
    
}
- (void)onMPMovieDurationAvailableNotification
{
    [self setProgressSliderMaxMinValues];
}

- (void)playButtonClick
{

    [self play];
    
    self.videoControl.playButton.hidden = YES;
    self.videoControl.pauseButton.hidden = NO;
    self.videoControl.pauseButton1.hidden = NO;

    self.videoControl.certerPauseButton.hidden=NO;

    self.videoControl.certerPlayButton.hidden=YES;
    
//    [self.videoControl.certerPlayButton setSelected:YES];
    [self.videoControl.indicatorView startAnimating];


}

- (void)pauseButtonClick
{
    [self pause];

    self.videoControl.playButton.hidden = NO;
//    [self.videoControl.certerPlayButton setSelected:NO];
    self.videoControl.certerPlayButton.hidden=NO;

    self.videoControl.pauseButton.hidden = YES;
    
    self.videoControl.certerPauseButton.hidden=YES;
    self.videoControl.pauseButton1.hidden=YES;
    [self.videoControl.indicatorView stopAnimating];

}

- (void)closeButtonClick
{
    [self dismiss];
}

- (void)fullScreenButtonClick
{
    if (self.isFullscreenMode) {
        return;
    }
    [self setDeviceOrientationLandscapeRight];
}
- (void)shrinkScreenButtonClick
{
    if (!self.isFullscreenMode) {
        return;
    }
    
    [self backOrientationPortrait];
    
}
#pragma mark -- 设备旋转监听 改变视频全屏状态显示方向 --
//监听设备旋转方向
- (void)ListeningRotating{
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onDeviceOrientationChange)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil
     ];
    
}
- (void)onDeviceOrientationChange{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    switch (interfaceOrientation) {
            /**        case UIInterfaceOrientationUnknown:
             NSLog(@"未知方向");
             break;
             */
        case UIInterfaceOrientationPortraitUpsideDown:{
            NSLog(@"第3个旋转方向---电池栏在下");
            [self backOrientationPortrait];
        }
            break;
        case UIInterfaceOrientationPortrait:{
            NSLog(@"第0个旋转方向---电池栏在上");
            [self backOrientationPortrait];
        }
            break;
        case UIInterfaceOrientationLandscapeLeft:{
            NSLog(@"第2个旋转方向---电池栏在右");
            
            [self setDeviceOrientationLandscapeLeft];
        }
            break;
        case UIInterfaceOrientationLandscapeRight:{
            
            NSLog(@"第1个旋转方向---电池栏在左");
            
            [self setDeviceOrientationLandscapeRight];
            
        }
            break;
            
        default:
            break;
    }
    
}
//返回小屏幕
- (void)backOrientationPortrait{
    if (!self.isFullscreenMode) {
        return;
    }
    [UIView animateWithDuration:0.3f animations:^{
        [self.view setTransform:CGAffineTransformIdentity];
        self.frame = self.originFrame;
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    } completion:^(BOOL finished) {
        self.isFullscreenMode = NO;
        self.videoControl.fullScreenButton.hidden = NO;
        self.videoControl.fullScreenButton1.hidden = NO;

        self.videoControl.shrinkScreenButton.hidden = YES;
        self.videoControl.shrinkScreenButton1.hidden = YES;

        if (self.willBackOrientationPortrait) {
            self.willBackOrientationPortrait();
        }
    }];
    
    if (self.willBackOrientationPortraitAn) {
        self.willBackOrientationPortraitAn();
    }
    
}

//电池栏在左全屏
- (void)setDeviceOrientationLandscapeRight{
    
    //    if (self.integer==2) {
    //        self.originFrame = self.view.frame;
    //        CGFloat height = [[UIScreen mainScreen] bounds].size.width;
    //        CGFloat width = [[UIScreen mainScreen] bounds].size.height;
    //        CGRect frame = CGRectMake((height - width) / 2, (width - height) / 2, width, height);;
    //        [UIView animateWithDuration:0.3f animations:^{
    //            self.frame = frame;
    //            [self.view setTransform:CGAffineTransformMakeRotation(M_PI)];
    //        } completion:^(BOOL finished) {
    //            self.integer = 1;
    //            self.isFullscreenMode = YES;
    //            self.videoControl.fullScreenButton.hidden = YES;
    //            self.videoControl.shrinkScreenButton.hidden = NO;
    //        }];
    //    }
    if (self.isFullscreenMode) {
        return;
    }
    
    self.originFrame = self.view.frame;
    CGFloat height = [[UIScreen mainScreen] bounds].size.width;
    CGFloat width = [[UIScreen mainScreen] bounds].size.height;
    CGRect frame = CGRectMake((height - width) / 2, (width - height) / 2, width, height);;
    [UIView animateWithDuration:0.3f animations:^{
        self.frame = frame;
        [self.view setTransform:CGAffineTransformMakeRotation(M_PI_2)];
    } completion:^(BOOL finished) {
        self.isFullscreenMode = YES;
        self.videoControl.fullScreenButton.hidden = YES;
        self.videoControl.fullScreenButton1.hidden = YES;

        self.videoControl.shrinkScreenButton.hidden = NO;
        self.videoControl.shrinkScreenButton1.hidden = NO;

        if (self.willChangeToFullscreenMode) {
            self.willChangeToFullscreenMode();
        }
    }];
    
    if (self.willChangeToFullscreenModeAn) {
        self.willChangeToFullscreenModeAn();
    }
    
}
//电池栏在右全屏
- (void)setDeviceOrientationLandscapeLeft{
    
    //    if  (self.integer==1){
    //        self.originFrame = self.view.frame;
    //        CGFloat height = [[UIScreen mainScreen] bounds].size.width;
    //        CGFloat width = [[UIScreen mainScreen] bounds].size.height;
    //        CGRect frame = CGRectMake((height - width) / 2, (width - height) / 2, width, height);;
    //        [UIView animateWithDuration:0.3f animations:^{
    //            self.frame = frame;
    //            [self.view setTransform:CGAffineTransformMakeRotation(-M_PI)];
    //        } completion:^(BOOL finished) {
    //            self.integer = 2;
    //            self.isFullscreenMode = YES;
    //            self.videoControl.fullScreenButton.hidden = YES;
    //            self.videoControl.shrinkScreenButton.hidden = NO;
    //        }];
    //    }
    if (self.isFullscreenMode) {
        return;
    }
    self.originFrame = self.view.frame;
    CGFloat height = [[UIScreen mainScreen] bounds].size.width;
    CGFloat width = [[UIScreen mainScreen] bounds].size.height;
    CGRect frame = CGRectMake((height - width) / 2, (width - height) / 2, width, height);;
    [UIView animateWithDuration:0.3f animations:^{
        self.frame = frame;
        [self.view setTransform:CGAffineTransformMakeRotation(-M_PI_2)];
    } completion:^(BOOL finished) {
        self.isFullscreenMode = YES;
        self.videoControl.fullScreenButton.hidden = YES;
        self.videoControl.fullScreenButton1.hidden = YES;

        self.videoControl.shrinkScreenButton.hidden = NO;
        self.videoControl.shrinkScreenButton1.hidden = NO;

        if (self.willChangeToFullscreenMode) {
            self.willChangeToFullscreenMode();
        }
    }];
    
    if (self.willChangeToFullscreenModeAn) {
        self.willChangeToFullscreenModeAn();
    }

}

- (void)setProgressSliderMaxMinValues {
    CGFloat duration = self.duration;
    self.videoControl.progressSlider.minimumValue = 0.f;
    self.videoControl.progressSlider.maximumValue = duration;
}

- (void)progressSliderTouchBegan:(UISlider *)slider {
    [self pause];
    [self.videoControl cancelAutoFadeOutControlBar];
}

- (void)progressSliderTouchEnded:(UISlider *)slider {
    [self setCurrentPlaybackTime:floor(slider.value)];
    [self play];
    [self.videoControl autoFadeOutControlBar];
}

- (void)progressSliderValueChanged:(UISlider *)slider {
    double currentTime = floor(slider.value);
    double totalTime = floor(self.duration);
    [self setTimeLabelValues:currentTime totalTime:totalTime];
}

- (void)monitorVideoPlayback
{
    double currentTime = floor(self.currentPlaybackTime);
    double totalTime = floor(self.duration);
    [self setTimeLabelValues:currentTime totalTime:totalTime];
    self.videoControl.progressSlider.value = ceil(currentTime);
}

- (void)setTimeLabelValues:(double)currentTime totalTime:(double)totalTime {
    double minutesElapsed = floor(currentTime / 60.0);
    double secondsElapsed = fmod(currentTime, 60.0);
    NSString *timeElapsedString = [NSString stringWithFormat:@"%02.0f:%02.0f", minutesElapsed, secondsElapsed];
    
    double minutesRemaining = floor(totalTime / 60.0);;
    double secondsRemaining = floor(fmod(totalTime, 60.0));;
    NSString *timeRmainingString = [NSString stringWithFormat:@"%02.0f:%02.0f", minutesRemaining, secondsRemaining];
    
    self.videoControl.timeLabel.text = [NSString stringWithFormat:@"%@/%@",timeElapsedString,timeRmainingString];
}

- (void)startDurationTimer
{
    NSLog(@"startDuration");
    self.durationTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(monitorVideoPlayback) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.durationTimer forMode:NSDefaultRunLoopMode];
}

- (void)stopDurationTimer
{
    [self.durationTimer invalidate];
}

- (void)fadeDismissControl
{
    [self.videoControl animateHide];
}

#pragma mark - Property

- (KrVideoPlayerControlView *)videoControl
{
    if (!_videoControl) {
        _videoControl = [[KrVideoPlayerControlView alloc] init];
    }
    return _videoControl;
}

- (UIView *)movieBackgroundView
{
    if (!_movieBackgroundView) {
        _movieBackgroundView = [UIView new];
        _movieBackgroundView.alpha = 0.0;
        _movieBackgroundView.backgroundColor = [UIColor blackColor];
    }
    return _movieBackgroundView;
}

- (void)setFrame:(CGRect)frame
{
    [self.view setFrame:frame];
    [self.videoControl setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    [self.videoControl setNeedsLayout];
    [self.videoControl layoutIfNeeded];
}

#pragma mark - 取出视频图片
+ (UIImage*) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60) actualTime:NULL error:&thumbnailImageGenerationError];
    
    if (!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@", thumbnailImageGenerationError);
    
    UIImage *thumbnailImage = thumbnailImageRef ? [[UIImage alloc] initWithCGImage:thumbnailImageRef] : nil;
    
    return thumbnailImage;
}


@end
