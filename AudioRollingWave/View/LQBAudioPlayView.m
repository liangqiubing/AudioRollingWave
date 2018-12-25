//
//  LQBAudioPlayView.m
//  AudioRollingWave
//
//  Created by 梁秋炳 on 2018/12/15.
//  Copyright © 2018 梁秋炳. All rights reserved.
//

#import "LQBAudioPlayView.h"
#import "AudioRollingWave-Swift.h"

#define MARGIN        5
#define HEAD_H        44
#define LABEL_W        45
#define LABEL_H        (HEAD_H - 2*MARGIN)
#define BTN_H        (HEAD_H - 2*MARGIN)

@interface LQBAudioPlayView()

@property (nonatomic, strong) UIButton  *playButton;
@property (nonatomic, strong) UILabel   *currentTimeLabel;
@property (nonatomic, strong) UILabel   *totalDurationLabel;
@property (nonatomic, strong) UISlider  *mediaProgressSlider;

@property (nonatomic,assign) BOOL isMediaSliderBeingDragged;

@property (nonatomic, strong) CADisplayLink *displayLink;

@end
@implementation LQBAudioPlayView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColor.whiteColor;
        [self setUpPlayView];
    }
    return self;
}
-(void)setUpPlayView{
    
    self.playButton = ({
        UIButton *playBtn = [[UIButton alloc] init];
        [playBtn setImage:[UIImage imageNamed:@"icon_play"] forState:UIControlStateNormal];
        [playBtn setImage:[UIImage imageNamed:@"icon_pause"] forState:UIControlStateSelected];
        
        [playBtn addTarget:self action:@selector(playControl) forControlEvents:UIControlEventTouchUpInside];
        playBtn;
    });
    [self addSubview:self.playButton];
    
    
    self.currentTimeLabel  = ({
        
        UILabel *label    = [[UILabel alloc] init];
        label.font        = [UIFont systemFontOfSize:10];
        label.textAlignment = NSTextAlignmentCenter;
        [label setTextColor:[UIColor grayColor]];
        
        label;
    });
    [self addSubview:self.currentTimeLabel];
    
    
    self.totalDurationLabel = ({
        
        UILabel *label    = [[UILabel alloc] init];
        label.font        = [UIFont systemFontOfSize:10];
        label.textAlignment = NSTextAlignmentCenter;
        [label setTextColor:[UIColor grayColor]];
        
        label;
        
    });
    [self addSubview:self.totalDurationLabel];
    
    
    self.mediaProgressSlider = ({
        
        UISlider *slider = [[UISlider alloc] init];
        slider.minimumValue = 0.0;
        slider.maximumValue = 0.0;
        [slider setThumbImage:[UIImage imageNamed:@"icon_progress"] forState:UIControlStateNormal];
        [slider addTarget:self action:@selector(slideTouchDown) forControlEvents:UIControlEventTouchDown];
        [slider addTarget:self action:@selector(slideTouchCancel) forControlEvents:UIControlEventTouchCancel | UIControlEventTouchUpOutside];
        [slider addTarget:self action:@selector(slideTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
        [slider addTarget:self action:@selector(slideValueChanged) forControlEvents:UIControlEventValueChanged];
        
        slider;
    });
    [self addSubview:self.mediaProgressSlider];
    
    _playButton.frame = CGRectMake(MARGIN, 50, BTN_H, BTN_H);
    
    _currentTimeLabel.frame = CGRectMake(self.playButton.right + MARGIN, MARGIN, LABEL_W, LABEL_H);
    _currentTimeLabel.centerY = _playButton.centerY;

    CGFloat ttLeft = self.width - MARGIN - LABEL_W;
    _totalDurationLabel.frame = CGRectMake(ttLeft, MARGIN, LABEL_W, LABEL_H);
    _totalDurationLabel.centerY = _playButton.centerY;
    
    // sliderView
    CGFloat slidW = ttLeft - 2*MARGIN - self.currentTimeLabel.right;
    _mediaProgressSlider.frame = CGRectMake(self.currentTimeLabel.right + MARGIN, MARGIN, slidW, LABEL_H);
    _mediaProgressSlider.centerY = _playButton.centerY;

    [kNotificationCenter addObserver:self
                            selector:@selector(didFinishPlayingNotify:)
                                name:AudioPlayer.AudioPalyerDidFinishPlayingNotify
                              object:nil];
}

-(void)didFinishPlayingNotify:(NSNotification *)notification {
    _playButton.selected = NO;
    [_displayLink performSelector:@selector(invalidate) withObject:nil afterDelay:0.25];
//    [_displayLink invalidate];
}
- (void)playControl{
    if (_playButton.isSelected) {
        [AudioPlayer.shared finishPlaying];//停止播放
        _playButton.selected = NO;
    }else{
        [AudioPlayer.shared playWithFileName:self.fileName];//播放录音
        _playButton.selected = YES;
        [_displayLink invalidate];
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkCallback)];
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
}

-(void)displayLinkCallback{
    AVAudioPlayer *player = [AudioPlayer shared].player;
    [player updateMeters];
    CGFloat normalizedValue = pow (10, [player averagePowerForChannel:0] / 40);
    DLog(@"normalizedValue:%@",@(normalizedValue));
    
    NSTimeInterval duration = player.duration;
    DLog(@"duration:%@",@(duration));

    NSInteger intDuration = duration + 0.0;
    
    NSTimeInterval currentTime = player.currentTime;
    DLog(@"currentTime:%@",@(normalizedValue));
    // position
    NSTimeInterval position;
    if (_isMediaSliderBeingDragged) {
        position = self.mediaProgressSlider.value;
    } else {
        position = currentTime;
        if (intDuration > 0) {
            _mediaProgressSlider.value = position;
        } else {
            _mediaProgressSlider.value = 0.0f;
        }
    }
    NSInteger intPosition = position + 0.0;
    _currentTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", (int)(intPosition / 60), (int)(intPosition % 60)];
}

- (void)slideTouchDown{
    _isMediaSliderBeingDragged = YES;
}

- (void)slideTouchCancel{
    _isMediaSliderBeingDragged = NO;
}

- (void)slideTouchUpInside{
    [AudioPlayer shared].player.currentTime = _mediaProgressSlider.value;
    [self slideTouchCancel];
}

- (void)slideValueChanged{
    [self displayLinkCallback];
}

-(void)setFileName:(NSString *)fileName{
    _fileName = fileName;
    NSTimeInterval duration = [[AudioPlayer shared] durationWithFileName:_fileName];
    DLog(@"duration:%@",@(duration));
    NSInteger intDuration = duration + 0.0;
    if (intDuration > 0) {
        _mediaProgressSlider.maximumValue = duration;
        _totalDurationLabel.text = [NSString stringWithFormat:@"%02d:%02d", (int)(intDuration / 60), (int)(intDuration % 60)];
    } else {
        _mediaProgressSlider.maximumValue = 1.0f;
        _totalDurationLabel.text = @"--:--";
    }
    _currentTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", 0, 0];
}

- (void)dealloc{
    [_displayLink invalidate];
}

@end
