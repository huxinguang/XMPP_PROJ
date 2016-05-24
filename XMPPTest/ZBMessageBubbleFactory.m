//
//  ZBMessageBubble.m
//  MessageDisplay
//
//  Created by zhoubin@moshi on 14-5-17.
//  Copyright (c) 2014年 Crius_ZB. All rights reserved.
//

#import "ZBMessageBubbleFactory.h"

@implementation ZBMessageBubbleFactory

+ (UIImage *)bubbleImageViewForType:(ZBBubbleMessageType)type
                          meidaType:(ZBBubbleMessageMediaType)mediaType {
    NSString *messageTypeString;
    
    messageTypeString = @"chatBubble";
   
    switch (type) {
        case ZBBubbleMessageTypeSending:
            // 发送
            messageTypeString = [messageTypeString stringByAppendingString:@"_Sending"];
            break;
        case ZBBubbleMessageTypeReceiving:
            // 接收
            messageTypeString = [messageTypeString stringByAppendingString:@"_Receiving"];
            break;
        default:
            break;
    }
    
    switch (mediaType) {
        case ZBBubbleMessagePhoto:
        case ZBBubbleMessageVideo:
            messageTypeString = [messageTypeString stringByAppendingString:@"_Solid"];
            break;
        case ZBBubbleMessageText:
        case ZBBubbleMessageVoice:
            messageTypeString = [messageTypeString stringByAppendingString:@"_Solid"];
            break;
        default:
            break;
    }
    
    UIImage *bublleImage = [UIImage imageNamed:messageTypeString];
    UIEdgeInsets bubbleImageEdgeInsets = [self bubbleImageEdgeInsetsWithStyle];
    [bublleImage resizableImageWithCapInsets:bubbleImageEdgeInsets];
    return bublleImage;
}

+ (UIEdgeInsets)bubbleImageEdgeInsetsWithStyle {
    UIEdgeInsets edgeInsets;
    
    edgeInsets = UIEdgeInsetsMake(30, 20, 10, 20);
    return edgeInsets;
}


@end
