//
//  ChatTextAttachment.m
//  XMPPTest
//
//  Created by huxinguang on 16/5/19.
//  Copyright © 2016年 IOSDEV. All rights reserved.
//

#import "ChatTextAttachment.h"

@implementation ChatTextAttachment

- (instancetype)initWithImage:(UIImage *)image
{
    if (self = [super init])
    {
        self.image = image;
    }
    return self;
    
}

- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex
{
    
//    return CGRectMake(0, -lineFrag.size.height * 0.2, lineFrag.size.height, lineFrag.size.height);
    return CGRectMake(0, -19 * 0.2, 19, 19);
}

@end
