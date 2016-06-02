//
//  PhotoBrowseViewController.h
//  XMPPTest
//
//  Created by huxinguang on 16/6/2.
//  Copyright © 2016年 IOSDEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoItemView.h"

@protocol SyncCurrentIndexDelegate <NSObject>

@optional

- (void)syncCurrentIndex:(NSInteger)index;

@end

@interface PhotoBrowseViewController : UIViewController

@property (nonatomic,strong) NSArray *photoModels;
@property (nonatomic ,strong)UIImageView *currentImg;
@property (nonatomic,weak) PhotoItemView *currentItemView;
@property (nonatomic,assign) NSUInteger page;//当前显示的
@property (nonatomic,assign) NSUInteger index;//初始显示的index
@property (nonatomic,assign)id<SyncCurrentIndexDelegate> delegate;

@end
