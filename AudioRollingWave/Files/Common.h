//
//  Common.h
//  AudioRollingWave
//
//  Created by 梁秋炳 on 2018/12/25.
//  Copyright © 2018 梁秋炳. All rights reserved.
//

#ifndef Common_h
#define Common_h

#define kNotificationCenter [NSNotificationCenter defaultCenter]
#define IMAGE_NAMED(name) [UIImage imageNamed:name]

#ifdef DEBUG
#define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define DLog(...)
#endif

#define kWeakSelf(type)  __weak typeof(type) weak##type = type;

#endif /* Common_h */
