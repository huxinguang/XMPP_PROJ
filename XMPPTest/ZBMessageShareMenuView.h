//
//  ZBShareMenuView.h
//  MessageDisplay
//
//  Created by zhoubin@moshi on 14-5-13.
//  Copyright (c) 2014年 Crius_ZB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBMessageShareMenuItem.h"

#define kZBMessageShareMenuPageControlHeight 30

@protocol ZBMessageShareMenuViewDelegate <NSObject>

@optional
- (void)didSelecteShareMenuItem:(ZBMessageShareMenuItem *)shareMenuItem atIndex:(NSInteger)index;

@end

@interface ZBMessageShareMenuView : UIView

/**
 *  第三方功能Models
 */
@property (nonatomic, strong) NSArray *shareMenuItems;

@property (nonatomic, assign) id <ZBMessageShareMenuViewDelegate> delegate;

- (void)reloadData;

@end
