//
//  LQBAudioUploadView.m
//  AudioRollingWave
//
//  Created by 梁秋炳 on 2018/12/12.
//  Copyright © 2018年 梁秋炳. All rights reserved.
//

#import "LQBAudioUploadView.h"
#import <AVKit/AVKit.h>
#import "LQBAudioPlayView.h"

@interface LQBAudioUploadView ()<UITextViewDelegate>

@property (nonatomic, strong) UIScrollView *backScrollView;

@property (nonatomic, strong) UIView *centerView; // 中间

@property (nonatomic,strong) LQBAudioPlayView *playView;

@end

@implementation LQBAudioUploadView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColor.groupTableViewBackgroundColor;
        [self creatUI];
    }
    return self;
}

#pragma mark —————— 创建UI ——————
- (void)creatUI {
    [self setUpBackScrollView];
    [self setUpAudioView];
    [self setUpCenterView];
}

- (void)setUpBackScrollView {
    UIScrollView *backScrollView = [[UIScrollView alloc] init];
    backScrollView.frame = self.frame;
    backScrollView.showsVerticalScrollIndicator = NO;
    backScrollView.contentSize = CGSizeMake(self.width, self.height);
    [self addSubview:backScrollView];
    
    _backScrollView = backScrollView;
}


- (void)setUpAudioView{
    _playView =[[LQBAudioPlayView alloc] initWithFrame:CGRectMake(8, 8, self.width-8*2, 100)];
    [_backScrollView addSubview:_playView];
}

- (void)setUpCenterView {
    UIView *backView = [[UIView alloc] init];
    backView.frame = CGRectMake(8, _playView.bottom + 5, self.width-8*2, 200);
    [_backScrollView addSubview:backView];
    _centerView = backView;
    backView.backgroundColor = [UIColor whiteColor];
    
}

-(void)setFileName:(NSString *)fileName{
    _fileName = fileName;
    _playView.fileName = fileName;
}
@end
