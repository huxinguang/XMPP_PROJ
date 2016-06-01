//
//  ChatViewController.h
//  XMPPTest
//
//  Created by huxinguang on 16/5/9.
//  Copyright © 2016年 IOSDEV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatViewController : UIViewController

@property (nonatomic ,strong)XMPPJID *friendJID;
@property (nonatomic ,strong)NSFetchedResultsController *fetchedResultsController;
@property (nonatomic ,strong)UITableView *chatTableView;
@property (nonatomic ,assign)NSIndexPath *currentIndex;//点击的图片所在的cell
@end
