//
//  PhotoBrowseEnterAnimation.m
//  XMPPTest
//
//  Created by huxinguang on 16/5/31.
//  Copyright © 2016年 IOSDEV. All rights reserved.
//

#import "PhotoBrowseEnterAnimation.h"
#import "PhotoBroswerVC.h"
@implementation PhotoBrowseEnterAnimation

#pragma mark - UIViewControllerAnimatedTransitioning

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    
    PhotoBroswerVC *toViewController =(PhotoBroswerVC*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    
    [_clickedPhotoView setHidden:YES];
    
    
    UIImageView *imageView = nil;
    
    CGRect rect = [self calFrameWithImage:_clickedPhotoView.contentImage];
    
    imageView  =[[UIImageView alloc]initWithImage:_clickedPhotoView.contentImage];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [imageView setFrame:[containerView convertRect:_clickedPhotoView.frame fromView:_clickedPhotoView.superview]];
    
    UIControl *mask = [[UIControl alloc]initWithFrame:containerView.bounds];
    [mask setBackgroundColor:Color(20, 20, 20)];
    [containerView addSubview:mask];
    mask.alpha = 0.0f;
    
    toViewController.view.alpha = 0;
    [containerView addSubview:toViewController.view];
    
    
    [containerView addSubview:imageView];
    [containerView bringSubviewToFront:imageView];
    
    [toViewController.view setHidden:YES];
    
    [UIView animateWithDuration:duration animations:^{
        
        toViewController.view.alpha = 1.0;
        
        [imageView setFrame:rect];
        
        mask.alpha = 1.0f;
        
    } completion:^(BOOL finished) {
        
        _clickedPhotoView.hidden = NO;
        
        [imageView setHidden:YES];
        [imageView removeFromSuperview];
        
        [toViewController.view setHidden:NO];
        
        [mask removeFromSuperview];
        
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.35*0.6;
}


/*
 *  确定frame
 */
-(CGRect)calFrameWithImage:(UIImage*)image
{
    
    CGSize size = image.size;
    
    CGFloat w = size.width;
    CGFloat h = size.height;
    
    CGRect superFrame = [UIScreen mainScreen].bounds;
    CGFloat superW =superFrame.size.width ;
    CGFloat superH =superFrame.size.height;
    
    CGFloat calW = superW;
    CGFloat calH = superW;
    
    if (w>=h) {//较宽
        
        if(w> superW){//比屏幕宽
            
            CGFloat scale = superW / w;
            
            //确定宽度
            calW = w * scale;
            calH = h * scale;
            
        }else if(w <= superW){//比屏幕窄，直接居中显示
            
            //            calW = w;
            //            calH = h;
            
            float sc = superW/w;
            calW = superW;
            calH = h *sc;
        }
        
    }else if(w<h){//较高
        
        CGFloat scale1 = superH / h;
        CGFloat scale2 = superW / w;
        
        BOOL isFat = w * scale1 > superW;//比较胖
        
        CGFloat scale =isFat ? scale1 : scale2;
        
        if(h> superH){//比屏幕高
            
            //确定宽度
            calW = w * scale;
            calH = h * scale;
            
            if(w >=superW)
            {
                calW = superW;
                calH = h * superW/w;
            }
            
            if(calH < superH)
            {
                return CGRectMake(0,(superH - calH)/2,calW,calH) ;
            }
            else
            {
                return CGRectMake(0, 0, calW, calH);
            }
            
            
        }else if(h <= superH){//比屏幕窄，直接居中显示
            
            if(w>superW){
                
                //确定宽度
                CGFloat scaleW = superW /w;
                calW = superW;
                calH = h *scaleW;
                
                
            }else{
                
                float sc = superW/w;
                calW = superW;
                calH = h * sc;
            }
            
        }
    }
    
    CGRect frame = [PhotoBrowseEnterAnimation frameWithW:calW h:calH center:CGPointMake([UIScreen mainScreen].bounds.size.width *0.5f, [UIScreen mainScreen].bounds.size.height * 0.5f)];
    
    return frame;
}


/*
 *  计算frame
 */
+(CGRect)frameWithW:(CGFloat)w h:(CGFloat)h center:(CGPoint)center{
    
    CGFloat x = center.x - w *.5f;
    CGFloat y = center.y - h * .5f;
    if(y<0) y=0;
    CGRect frame = (CGRect){CGPointMake(x, y),CGSizeMake(w, h)};
    
    return frame;
}


@end
