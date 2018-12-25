//
//
//  Created by 梁秋炳 on 2017/12/14.
//  Copyright © 2017年 梁秋炳. All rights reserved.
//

#import "LQBRootViewController.h"

@interface LQBRootViewController ()

@end

@implementation LQBRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (@available(iOS 11.0, *)) {
        [UIScrollView appearance].contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    } else {
        self.automaticallyAdjustsScrollViewInsets = YES;
    }
}

- (void)dealloc {
    DLog(@"=====释放%@=====", [self class]);
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
