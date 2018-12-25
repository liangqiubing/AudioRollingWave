//
//  LQBAudioUploadController.m
//  AudioRollingWave
//
//  Created by 梁秋炳 on 2018/12/12.
//  Copyright © 2018年 梁秋炳. All rights reserved.
//

#import "LQBAudioUploadController.h"
#import "LQBAudioUploadView.h"
#import "AudioRollingWave-Swift.h"

#import <AVFoundation/AVFoundation.h>



@interface LQBAudioUploadController ()<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) LQBAudioUploadView *wuzhengView;

@end

@implementation LQBAudioUploadController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"上传录音";
    [self setUpUI];
}

#pragma mark —————— 创建UI ——————

- (void)setUpUI {
    LQBAudioUploadView *wuzhengView = [[LQBAudioUploadView alloc] initWithFrame:self.view.frame];
    wuzhengView.fileName = _fileName;
    [self.view addSubview:wuzhengView];
    _wuzhengView = wuzhengView;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if ([[AudioPlayer shared]isPlaying]) {
        [[AudioPlayer shared]finishPlaying];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
