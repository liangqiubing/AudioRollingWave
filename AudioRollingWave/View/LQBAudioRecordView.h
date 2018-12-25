//
//  LQBAudioRecordView.h
//  AudioRollingWave
//
//  Created by 梁秋炳 on 2018/12/15.
//  Copyright © 2018 梁秋炳. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^Finish)(NSString*fileName);

NS_ASSUME_NONNULL_BEGIN

@interface LQBAudioRecordView : UIView

@property (nonatomic, copy) Finish finish;

@end

NS_ASSUME_NONNULL_END
