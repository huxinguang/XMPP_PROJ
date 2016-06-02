//
//  PhotoScrollView.m
//  XMPPTest
//
//  Created by huxinguang on 16/6/1.
//  Copyright © 2016年 IOSDEV. All rights reserved.
//

#import "PhotoScrollView.h"
#import "PhotoItemView.h"
#import "PBConst.h"
@implementation PhotoScrollView



-(void)layoutSubviews{
    
    [super layoutSubviews];
    
    __block CGRect frame = self.bounds;
    
    CGFloat w = frame.size.width ;
    
    frame.size.width =w - PBMargin;
    
    [self.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if([obj isKindOfClass:[PhotoItemView class]])
        {
            PhotoItemView *photoItemView = obj;
            CGFloat x;
            @try {
                if(photoItemView.pageIndex >100)
                {
                    x =0;
                }
                else
                {
                    x = w * photoItemView.pageIndex;
                }
                
            }
            @catch (NSException *exception) {
                NSLog(@"x==%f,photoItemView = %@",x,photoItemView);
            }
            @finally {
                
            };
            
            
            frame.origin.x = x;
            photoItemView.frame = frame;
        }
    }];
    
    
    if(_isScrollToIndex){
        
        //显示第index张图
        CGFloat offsetX = w * _index;
        NSLog(@"offsetX= %f",offsetX);
        [self setContentOffset:CGPointMake(offsetX, 0) animated:NO];
        
        _isScrollToIndex = NO;
    }
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
}

@end
