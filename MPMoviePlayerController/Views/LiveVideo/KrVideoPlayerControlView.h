//
//  KrVideoPlayerControlView.h
//  KrVideoPlayerPlus
//
//  Created by JiaHaiyang on 15/6/19.
//  Copyright (c) 2015年 JiaHaiyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KrVideoPlayerControlView : UIView

@property (nonatomic, strong, readonly) UIView *topBar;
@property (nonatomic, strong, readonly) UIView *bottomBar;
@property (nonatomic, strong, readonly) UIButton *playButton;
@property (nonatomic, strong) UIButton *playButton1;


@property (nonatomic, strong) UIButton *certerPlayButton;


@property (nonatomic, strong, readonly) UIButton *pauseButton;
@property (nonatomic, strong) UIButton *pauseButton1;


@property (nonatomic, strong) UIButton *certerPauseButton;


@property (nonatomic, strong, readonly) UIButton *fullScreenButton;
@property (nonatomic, strong) UIButton *fullScreenButton1;

@property (nonatomic, strong, readonly) UIButton *shrinkScreenButton;
@property (nonatomic, strong) UIButton *shrinkScreenButton1;

@property (nonatomic, strong, readonly) UISlider *progressSlider;
@property (nonatomic, strong, readonly) UIButton *closeButton;
@property (nonatomic, strong, readonly) UILabel *timeLabel;
@property (nonatomic, strong, readonly) UIActivityIndicatorView *indicatorView;

- (void)animateHide;
- (void)animateShow;
- (void)autoFadeOutControlBar;
- (void)cancelAutoFadeOutControlBar;

@end
