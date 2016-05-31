//
//  PhotoBrowseExitAnimation.m
//  XMPPTest
//
//  Created by huxinguang on 16/5/31.
//  Copyright © 2016年 IOSDEV. All rights reserved.
//

#import "PhotoBrowseExitAnimation.h"
#import "PhotoBroswerVC.h"

@implementation PhotoBrowseExitAnimation

#pragma mark - UIViewControllerAnimatedTransitioning

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    PhotoBroswerVC *from = (PhotoBroswerVC*) [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    from.view.hidden = YES;
    
    UIViewController *toViewController =(UIViewController*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    containerView.backgroundColor = toViewController.view.backgroundColor;
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    [containerView addSubview:toViewController.view];
    toViewController.view.alpha = 0.0f;
    
    UIControl *mask = [[UIControl alloc]initWithFrame:containerView.bounds];
    [mask setBackgroundColor:[UIColor clearColor]];//COLOR(20, 20, 20)];
    [containerView addSubview:mask];
    mask.alpha = 1.0f;
    
    UIImageView *imageSnapshot = [[UIImageView alloc]init];
    imageSnapshot.frame = [containerView convertRect:from.currentItemView.photoImageView.frame fromView:from.currentItemView.photoImageView.superview];
    imageSnapshot.contentMode = UIViewContentModeScaleAspectFill;
    [imageSnapshot setImage:_clickedPhotoView.contentImage];
    [containerView addSubview:imageSnapshot];
    [containerView bringSubviewToFront:imageSnapshot];
    
    [_clickedPhotoView setHidden:YES];
    
    
    [UIView animateWithDuration:duration animations:^{
        
        toViewController.view.alpha = 1.0;
    
        CGRect imageBackRect = [containerView convertRect:_clickedPhotoView.frame fromView:_clickedPhotoView.superview];//坐标转换
        
        [imageSnapshot setFrame:imageBackRect];
        
        [mask setAlpha:0.0f];
        
        
    } completion:^(BOOL finished) {
        
        [_clickedPhotoView setHidden:NO];
        [imageSnapshot setHidden:YES];
        [imageSnapshot removeFromSuperview];
        [mask removeFromSuperview];
        
        
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.35*0.6;
}

@end
