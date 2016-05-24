//
//  HXGVoiceTool.m
//  XMPPTest
//
//  Created by huxinguang on 16/5/20.
//  Copyright © 2016年 IOSDEV. All rights reserved.
//

#import "HXGVoiceTool.h"

@implementation HXGVoiceTool

+ (instancetype)shareInstance{
    static HXGVoiceTool *voiceTool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        voiceTool = [[HXGVoiceTool alloc]init];
    });
    return voiceTool;
}

- (instancetype)init{
    if (self = [super init]) {
        self.recorder = [[AVAudioRecorder alloc]init];
        
        self.player = [[AVAudioPlayer alloc]init];
    }
    return self;
}

- (void)createRecorder{


}


//判断是否允许使用麦克风7.0新增的方法requestRecordPermission
-(BOOL)canRecord
{
    __block BOOL bCanRecord = YES;
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending)
    {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                if (granted) {
                    bCanRecord = YES;
                }
                else {
                    bCanRecord = NO;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[[UIAlertView alloc] initWithTitle:nil
                                                    message:@"app需要访问您的麦克风。\n请启用麦克风-设置/隐私/麦克风"
                                                   delegate:nil
                                          cancelButtonTitle:@"关闭"
                                          otherButtonTitles:nil] show];
                    });
                }
            }];
        }
    }
    
    return bCanRecord;
}

@end
