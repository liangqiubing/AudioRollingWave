//
//  LQBAudioRecordController.m
//  AudioRollingWave
//
//  Created by 梁秋炳 on 2018/12/12.
//  Copyright © 2018年 梁秋炳. All rights reserved.
//

#import "LQBAudioRecordController.h"
#import "LQBAudioRecordView.h"
#import "LQBAudioUploadController.h"
#import "AudioRollingWave-Swift.h"

@interface LQBAudioRecordController ()

@property (nonatomic, strong) LQBAudioRecordView *recordView;

@end

@implementation LQBAudioRecordController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"录音";
    [self setUpUI];
}

#pragma mark —————— 创建UI ——————

- (void)setUpUI {
    _recordView = [[LQBAudioRecordView alloc]initWithFrame:self.view.frame];
    kWeakSelf(self);
    _recordView.finish = ^(NSString *fileName) {
        LQBAudioUploadController *vc = [[LQBAudioUploadController alloc]init];
        vc.fileName = fileName;
        [weakself.navigationController pushViewController:vc animated:YES];

    };
    [self.view addSubview:_recordView];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if ([[AudioPlayer shared]isPlaying]) {
        [[AudioPlayer shared]finishPlaying];
    }
}
@end
