//
//  PhotoBrowseExitAnimation.h
//  XMPPTest
//
//  Created by huxinguang on 16/5/31.
//  Copyright © 2016年 IOSDEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShapedPhotoView.h"
@interface PhotoBrowseExitAnimation : NSObject<UIViewControllerAnimatedTransitioning>//从浏览界面返回的动画

@property(nonatomic,strong)ShapedPhotoView *clickedPhotoView;

@end
