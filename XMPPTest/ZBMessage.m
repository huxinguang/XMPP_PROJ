//
//  ZBMessage.m
//  MessageDisplay
//
//  Created by zhoubin@moshi on 14-5-16.
//  Copyright (c) 2014年 Crius_ZB. All rights reserved.
//

#import "ZBMessage.h"

@implementation ZBMessage

- (instancetype)initWithText:(NSString *)text
                      sender:(NSString *)sender
                   timestamp:(NSDate *)timestamp{
    self = [super init];
    if (self) {
        self.text = text;
        
        self.sender = sender;
        self.timestamp = timestamp;
        
        self.messageType = ZBBubbleMessageText;
    }
    return self;
}

/**
 *  初始化图片类型的消息
 *
 *  @param photo          目标图片
 *  @param thumbnailUrl   目标图片在服务器的缩略图地址
 *  @param originPhotoUrl 目标图片在服务器的原图地址
 *  @param sender         发送者
 *  @param date           发送时间
 *
 *  @return 返回Message model 对象
 */
- (instancetype)initWithPhoto:(UIImage *)photo
                 thumbnailUrl:(NSString *)thumbnailUrl
               originPhotoUrl:(NSString *)originPhotoUrl
                       sender:(NSString *)sender
                    timestamp:(NSDate *)timestamp {
    self = [super init];
    if (self) {
        self.photo = photo;
        self.thumbnailUrl = thumbnailUrl;
        self.originPhotoUrl = originPhotoUrl;
        
        self.sender = sender;
        self.timestamp = timestamp;
        
        self.messageType = ZBBubbleMessagePhoto;
    }
    return self;
}

/**
 *  初始化视频类型的消息
 *
 *  @param videoConverPhoto 目标视频的封面图
 *  @param videoPath        目标视频的本地路径，如果是下载过，或者是从本地发送的时候，会存在
 *  @param videoUrl         目标视频在服务器上的地址
 *  @param sender           发送者
 *  @param date             发送时间
 *
 *  @return 返回Message model 对象
 */
- (instancetype)initWithVideoConverPhoto:(UIImage *)videoConverPhoto
                               videoPath:(NSString *)videoPath
                                videoUrl:(NSString *)videoUrl
                                  sender:(NSString *)sender
                               timestamp:(NSDate *)timestamp {
    self = [super init];
    if (self) {
        self.videoConverPhoto = videoConverPhoto;
        self.videoPath = videoPath;
        self.videoUrl = videoUrl;
        
        self.sender = sender;
        self.timestamp = timestamp;
        
        self.messageType = ZBBubbleMessageVideo;
    }
    return self;
}

/**
 *  初始化语音类型的消息
 *
 *  @param voicePath 目标语音的本地路径
 *  @param voiceUrl  目标语音在服务器的地址
 *  @param sender    发送者
 *  @param date      发送时间
 *
 *  @return 返回Message model 对象
 */
- (instancetype)initWithVoicePath:(NSString *)voicePath
                         voiceUrl:(NSString *)voiceUrl
                           sender:(NSString *)sender
                        timestamp:(NSDate *)timestamp {
    self = [super init];
    if (self) {
        self.voicePath = voicePath;
        self.videoUrl = voiceUrl;
        
        self.sender = sender;
        self.timestamp = timestamp;
        
        self.messageType = ZBBubbleMessageVoice;
    }
    return self;
}

//- (instancetype)initWithLocalPositionPhoto:(UIImage *)localPositionPhoto
//                              geolocations:(NSString *)geolocations
//                                  location:(CLLocation *)location
//                                    sender:(NSString *)sender
//                                 timestamp:(NSDate *)timestamp {
//    self = [super init];
//    if (self) {
//        self.localPositionPhoto = localPositionPhoto;
//        self.geolocations = geolocations;
//        self.location = location;
//        
//        self.sender = sender;
//        self.timestamp = timestamp;
//        
//        self.messageMediaType = XHBubbleMessageLocalPosition;
//    }
//    return self;
//}

- (void)dealloc{
    self.text = nil;
    
    self.photo = nil;
    self.thumbnailUrl = nil;
    self.originPhotoUrl = nil;
    
    self.videoConverPhoto = nil;
    _videoPath = nil;
    _videoUrl = nil;
    
    _voicePath = nil;
    _voiceUrl = nil;
    
    _emotionPath = nil;
    
    _localPositionPhoto = nil;
    _geolocations = nil;
  //  _location = nil;
    
    _avator = nil;
    _avatorUrl = nil;
    
    _sender = nil;
    
    _timestamp = nil;
    
}


@end
