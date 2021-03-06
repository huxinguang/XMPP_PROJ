//
//  PhotoBrowseTransitionAnimation.m
//  XMPPTest
//
//  Created by huxinguang on 16/6/1.
//  Copyright © 2016年 IOSDEV. All rights reserved.
//

#import "PhotoBrowseTransitionAnimation.h"
#import "ChatViewController.h"
#import "PhotoBrowseViewController.h"
#import "ChatTextCell.h"
#import "ShapedPhotoView.h"

#define AnimationDuration 0.2

@implementation PhotoBrowseTransitionAnimation

- (id)initWithTransitionType:(PhotoBrowseTransitionType)type{

    if (self = [super init]) {
        self.transitionType = type;
        
    }
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext{
    
    return AnimationDuration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext{

    if (self.transitionType == PhotoBrowseTransitionTypeEnter) {
        ChatViewController *fromVC = (ChatViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        PhotoBrowseViewController *toVC = (PhotoBrowseViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        
        ChatTextCell *cell = [fromVC.chatTableView cellForRowAtIndexPath:fromVC.currentIndex];
        UIView *containerView = [transitionContext containerView];
        
        UIImageView *animationImgView = [[UIImageView alloc]initWithImage:cell.photoMsgView.contentImage];
        animationImgView.contentMode = UIViewContentModeScaleAspectFill;
        animationImgView.frame = [containerView convertRect:cell.photoMsgView.frame fromView:cell.photoMsgView.superview];
        
        [containerView addSubview:toVC.view];
        [containerView addSubview:animationImgView];

        cell.photoMsgView.hidden = YES;
        toVC.view.alpha = 0.0;
        for (UIView *item in fromVC.view.subviews) {
            item.hidden = YES;
        }
        fromVC.view.backgroundColor = Color(20, 20, 20);
        
        CGRect rect = [self calFrameWithImage:cell.photoMsgView.contentImage];
        
        [UIView animateWithDuration:AnimationDuration animations:^{
            animationImgView.frame = rect;
        } completion:^(BOOL finished) {
            toVC.view.alpha = 1.0;
            
            for (UIView *item in fromVC.view.subviews) {
                item.hidden = NO;
            }
            fromVC.view.backgroundColor = Color(235, 235, 235);
            
            cell.photoMsgView.hidden = NO;
            animationImgView.hidden = YES;
            [animationImgView removeFromSuperview];
            //如果动画过渡取消了就标记不完成，否则才完成，这里可以直接写YES，如果有手势过渡才需要判断，必须标记，否则系统不会中动画完成的部署，会出现无法交互之类的bug
            [transitionContext completeTransition:YES];
            
            fromVC.view.backgroundColor = Color(235, 235, 235);
            
            fromVC.transitionStatus = TransitionStatusStarted;
        }];
        
        
    }else{
        
        PhotoBrowseViewController *fromVC = (PhotoBrowseViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        ChatViewController *toVC = (ChatViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        ChatTextCell *cell = [toVC.chatTableView cellForRowAtIndexPath:toVC.currentIndex];//当浏览图片的过程中翻页时currentIndex会相应改变
        UIView *containerView = [transitionContext containerView];
        
        UIImageView *animationImgView = [[UIImageView alloc]initWithImage:fromVC.currentItemView.photoImageView.image];
        animationImgView.contentMode = UIViewContentModeScaleAspectFill;
        animationImgView.frame = [containerView convertRect:fromVC.currentItemView.photoImageView.frame fromView:fromVC.currentItemView.photoImageView.superview];
        [containerView addSubview:toVC.view];
        [containerView addSubview:animationImgView];
        
//        ShapedPhotoView *spv = [[ShapedPhotoView alloc]init];
//        CGRect rect = [containerView convertRect:fromVC.currentItemView.photoImageView.frame fromView:fromVC.currentItemView.photoImageView.superview];
//        [containerView addSubview:toVC.view];
//        [containerView addSubview:spv];
//    
//        spv.frame = rect;
//        
//        if (cell.cm.chatCellOwner == ChatCellOwnerMe) {
//            [spv configWithShapeLayerContentImage:[UIImage imageNamed:@"chat_dialog_me_male"] subLayerContentImage:fromVC.currentItemView.photoImageView.image];
//        }else{
//            [spv configWithShapeLayerContentImage:[UIImage imageNamed:@"chat_dialog_others"] subLayerContentImage:fromVC.currentItemView.photoImageView.image];
//        }
        
        
        
        cell.photoMsgView.hidden = YES;
        
        CGRect imageBackRect = [containerView convertRect:cell.photoMsgView.frame fromView:cell.photoMsgView.superview];
        
    
        [UIView animateWithDuration:AnimationDuration animations:^{
            toVC.view.alpha = 1.0;
            if ([toVC.chatTableView.visibleCells containsObject:cell]) {//不在可视范围内的cell无法确定其photoMsgView的frame,所以不加frame动画，加透明度动画
                animationImgView.frame = imageBackRect;
//                spv.frame = imageBackRect;
            }else{
                animationImgView.alpha = 0;
//                spv.alpha = 0;
            }
            
        } completion:^(BOOL finished) {
            
            cell.photoMsgView.hidden = NO;
            animationImgView.hidden = YES;
            [animationImgView removeFromSuperview];
//            spv.hidden = YES;
//            [spv removeFromSuperview];
            [transitionContext completeTransition:YES];
            toVC.transitionStatus = TransitionStatusEnded;
            
        }];
    
    
    }
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
    
    CGRect frame = [self frameWithW:calW h:calH center:CGPointMake([UIScreen mainScreen].bounds.size.width *0.5f, [UIScreen mainScreen].bounds.size.height * 0.5f)];
    
    return frame;
}


/*
 *  计算frame
 */
-(CGRect)frameWithW:(CGFloat)w h:(CGFloat)h center:(CGPoint)center{
    
    CGFloat x = center.x - w *.5f;
    CGFloat y = center.y - h * .5f;
    if(y<0) y=0;
    CGRect frame = (CGRect){CGPointMake(x, y),CGSizeMake(w, h)};
    
    return frame;
}

@end
