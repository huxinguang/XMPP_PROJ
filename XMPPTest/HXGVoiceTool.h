//
//  HXGVoiceTool.h
//  XMPPTest
//
//  Created by huxinguang on 16/5/20.
//  Copyright © 2016年 IOSDEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface HXGVoiceTool : NSObject

/** 录音器 */
@property(nonatomic,strong) AVAudioRecorder *recorder;

/** 录音地址 */
@property(nonatomic,strong) NSURL *recordURL;

/** 播放器 */
@property(nonatomic,strong) AVAudioPlayer *player;

/** 播放完成时回调 */
@property(nonatomic,copy) void (^palyCompletion)();

+ (instancetype)shareInstance;

+ (BOOL)canRecord;


@end
