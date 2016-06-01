//
//  PhotoBrowseTransitionAnimation.h
//  XMPPTest
//
//  Created by huxinguang on 16/6/1.
//  Copyright © 2016年 IOSDEV. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,PhotoBrowseTransitionType) {
    PhotoBrowseTransitionTypeEnter,
    PhotoBrowseTransitionTypeExit
};

@interface PhotoBrowseTransitionAnimation : NSObject<UIViewControllerAnimatedTransitioning>

@property (nonatomic,assign)PhotoBrowseTransitionType transitionType;

- (id)initWithTransitionType:(PhotoBrowseTransitionType)type;

@end
