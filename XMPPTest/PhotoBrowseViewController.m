//
//  PhotoBrowseViewController.m
//  XMPPTest
//
//  Created by huxinguang on 16/6/1.
//  Copyright © 2016年 IOSDEV. All rights reserved.
//

#import "PhotoBrowseViewController.h"
#import "PhotoBrowseTransitionAnimation.h"

@interface PhotoBrowseViewController ()

@property (nonatomic ,strong)UIScrollView *photoScrollView;

@end

@implementation PhotoBrowseViewController

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
}

- (void)configSubViews{
    self.photoScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    self.photoScrollView.backgroundColor = Color(20, 20, 20);
    self.photoScrollView.showsVerticalScrollIndicator = NO;
    self.photoScrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.photoScrollView];
    
    
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
