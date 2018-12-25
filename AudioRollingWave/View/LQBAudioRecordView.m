//
//  LQBAudioRecordView.m
//  AudioRollingWave
//
//  Created by 梁秋炳 on 2018/12/15.
//  Copyright © 2018 梁秋炳. All rights reserved.
//

#import "LQBAudioRecordView.h"
#import "AudioRollingWave-Swift.h"

@interface LQBAudioRecordView()
@property (nonatomic,strong) UIButton *playButton;

@property (nonatomic,strong) UIButton *deleteButton;

@property (nonatomic,strong) UIButton *recordButton;

@property (nonatomic,strong) UIButton *finishButton;

@property (nonatomic,strong) UILabel *timingLabel;

@property (nonatomic,strong) AudioWave *waver;

@property (nonatomic,strong) NSString *fileName;

@end

@implementation LQBAudioRecordView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColor.whiteColor;
        [self setUpRecordView];
    }
    return self;
}

- (void)setUpRecordView{
    _waver = ({
        AudioWave *waver = [[AudioWave alloc] init];
        waver;
    });
    [self addSubview:_waver];
    
    _timingLabel =({
        UILabel *label    = [[UILabel alloc] init];
        
        label.font        = [UIFont fontWithName:@"Avenir" size:50];
        label.textAlignment = NSTextAlignmentRight;
        [label setTextColor:[UIColor blackColor]];
        label.text = @"00:00";
        label;
    });
    [self addSubview:_timingLabel];

    _playButton = ({
        UIButton * button = [[UIButton alloc]init];
        [button setImage:IMAGE_NAMED(@"playNow") forState:UIControlStateNormal];
        [button setImage:IMAGE_NAMED(@"playEnd") forState:UIControlStateSelected];
        [button addTarget:self action:@selector(playClicked:) forControlEvents:UIControlEventTouchUpInside];
        button.hidden = YES;
        button;
    });
    [self addSubview:_playButton];
    
    _recordButton = ({
        UIButton * button = [[UIButton alloc]init];
        [button setImage:IMAGE_NAMED(@"recordNow") forState:UIControlStateNormal];
        [button setImage:IMAGE_NAMED(@"recordEnd") forState:UIControlStateSelected];
        [button addTarget:self action:@selector(recordClicked:) forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    [self addSubview:_recordButton];
    
    _deleteButton = ({
        UIButton * button = [[UIButton alloc]init];
        [button setImage:IMAGE_NAMED(@"cancel") forState:UIControlStateNormal];
        [button setImage:IMAGE_NAMED(@"cancel") forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(deleteClicked:) forControlEvents:UIControlEventTouchUpInside];
        button.hidden = YES;
        button;
    });
    [self addSubview:_deleteButton];
    
    _finishButton = ({
        UIButton * button = [[UIButton alloc]init];
        [button setImage:IMAGE_NAMED(@"done") forState:UIControlStateNormal];
        [button setImage:IMAGE_NAMED(@"done") forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(finishClicked:) forControlEvents:UIControlEventTouchUpInside];
        button.hidden = YES;
        button;
    });
    [self addSubview:_finishButton];

    CGFloat square = 64;
    CGFloat width = 34;
    CGFloat height = 54;
    
    _waver.frame = CGRectMake(0, 74, self.width, 208.0);
    _timingLabel.frame = CGRectMake(0, _waver.bottom+35, self.width-22, 60);
    _playButton.frame = CGRectMake(23, 250, 34, 34);
    _playButton.centerY = _timingLabel.centerY;
    _recordButton.frame = CGRectMake((self.width-square)/2, self.height-square-28, square, square);
    _deleteButton.frame = CGRectMake((self.width-_recordButton.width)/2-60-width, _recordButton.top+10, width, height);
    _finishButton.frame = CGRectMake(_recordButton.right+60, _recordButton.top+10, width, height);
    
    [kNotificationCenter addObserver:self
                            selector:@selector(handleInterruption:)
                                name:AudioPlayer.AudioPalyerDidFinishPlayingNotify
                              object:nil];
    [kNotificationCenter addObserver:self
                            selector:@selector(handleInterruption:)
                                name:AudioRecorder.AudioRecorderDidFinishRecordingNotify
                              object:nil];
    
    [kNotificationCenter addObserver:self
                            selector:@selector(handleInterruption:)
                                name:AVAudioSessionInterruptionNotification
                              object:nil];
    
}

-(void)handleInterruption:(NSNotification *)notification {
    [_waver.displayLink invalidate];
    _playButton.selected = NO;
    DLog(@"handleInterruption");
}

-(void)playClicked:(UIButton*)button{
    if (_playButton.isSelected) {
        [AudioPlayer.shared finishPlaying];//停止播放
        _playButton.selected = NO;
    }else{
        [AudioPlayer.shared playWithFileName:self.fileName];//播放录音
        _playButton.selected = YES;
        __weak typeof(AVAudioPlayer) *player = [AudioPlayer shared].player ;
        __weak typeof(self) weakSelf = self;
        _waver.waverLevelCallback = ^(AudioWave * waver) {
            [player updateMeters];
            NSTimeInterval currentTime = player.currentTime;
            [waver setLevel:[player averagePowerForChannel:0]];
            NSInteger intCurrentTime = currentTime + 0.0;
            weakSelf.timingLabel.text = [NSString stringWithFormat:@"%02d:%02d", (int)(intCurrentTime / 60), (int)(intCurrentTime % 60)];
        };
    }
}

#pragma mark —————— 事件响应 ——————
- (void)deleteClicked:(UIButton *)button {
    [self hideControls];
    [AudioPlayer.shared deleteAudio:_fileName error:nil];//删除录音
    _fileName = nil;
}
- (void)recordClicked:(UIButton *)button {
    if (button.isSelected){
        [self showControls];
        [AudioRecorder.shared finishRecording];//停止录音
        _recordButton.selected = NO;
    }else {
        [self hideControls];
        [AudioRecorder.shared recordWithFileName:self.fileName];//开始录音
        _recordButton.selected = YES;
        __weak typeof(AVAudioRecorder) *recorder = [AudioRecorder shared].recorder;
        __weak typeof(self) weakSelf = self;
        _waver.waverLevelCallback = ^(AudioWave * waver) {
            [recorder updateMeters];
            NSTimeInterval currentTime = recorder.currentTime;
            [waver setLevel:[recorder averagePowerForChannel:0]];
            NSInteger intCurrentTime = currentTime + 0.0;
            weakSelf.timingLabel.text = [NSString stringWithFormat:@"%02d:%02d", (int)(intCurrentTime / 60), (int)(intCurrentTime % 60)];
        };
    }
}
- (void)finishClicked:(UIButton *)button {
    _finish(_fileName);
    [[AudioPlayer shared] finishPlaying];
}

-(void)hideControls{
    _playButton.hidden = YES;
    _finishButton.hidden = YES;
    _deleteButton.hidden = YES;
    _playButton.selected = NO;
    [[AudioPlayer shared] finishPlaying];
    _timingLabel.text = [NSString stringWithFormat:@"%02d:%02d", 0, 0];
}
-(void)showControls{
    _playButton.hidden = NO;
    _finishButton.hidden = NO;
    _deleteButton.hidden = NO;
}

-(NSString *)fileName{
    if (!_fileName) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        formatter.dateFormat = @"yyyyMMddHHmmssS";
        _fileName = [[formatter stringFromDate:[NSDate date]] stringByAppendingString:@"_tmp.aac"];
    }
    return _fileName;
}

-(void)dealloc{
    [[AudioPlayer shared] finishPlaying];
    [AudioRecorder.shared finishRecording];
    [kNotificationCenter removeObserver:self];
    DLog(@"%@ dealloc",self);
}

@end
