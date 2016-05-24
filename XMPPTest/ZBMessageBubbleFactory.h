//
//  ZBMessageBubble.h
//  MessageDisplay
//
//  Created by zhoubin@moshi on 14-5-17.
//  Copyright (c) 2014年 Crius_ZB. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ZBBubbleMessageType) {
    ZBBubbleMessageTypeSending = 0,
    ZBBubbleMessageTypeReceiving
};

typedef NS_ENUM(NSInteger, ZBBubbleMessageMediaType) {
    ZBBubbleMessageText = 0,
    ZBBubbleMessagePhoto = 1,
    ZBBubbleMessageVideo = 2,
    ZBBubbleMessageVoice = 3,
    ZBBubbleMessageFace = 4,
    ZBBubbleMessageLocalPosition = 5,
};

typedef NS_ENUM(NSInteger, ZBBubbleMessageMenuSelecteType) {
    ZBBubbleMessageTextCopy = 0,
    ZBBubbleMessageTextTranspond = 1,
    ZBBubbleMessageTextFavorites = 2,
    ZBBubbleMessageTextMore = 3,
    
    ZBBubbleMessagePhotoCopy = 4,
    ZBBubbleMessagePhotoTranspond = 5,
    ZBBubbleMessagePhotoFavorites = 6,
    ZBBubbleMessagePhotoMore = 7,
    
    ZBBubbleMessageVideoTranspond = 8,
    ZBBubbleMessageVideoFavorites = 9,
    ZBBubbleMessageVideoMore = 10,
    
    ZBBubbleMessageVoicePlay = 11,
    ZBBubbleMessageVoiceFavorites = 12,
    ZBBubbleMessageVoiceTurnToText = 13,
    ZBBubbleMessageVoiceMore = 14,
};

@interface ZBMessageBubbleFactory : NSObject

+ (UIImage *)bubbleImageViewForType:(ZBBubbleMessageType)type
                          meidaType:(ZBBubbleMessageMediaType)mediaType;

@end
