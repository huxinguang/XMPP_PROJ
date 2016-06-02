//
//  PhotoBrowseViewController.m
//  XMPPTest
//
//  Created by huxinguang on 16/6/2.
//  Copyright © 2016年 IOSDEV. All rights reserved.
//

#import "PhotoBrowseViewController.h"
#import "PhotoScrollView.h"
#import "PBConst.h"
#import "PhotoBrowseTransitionAnimation.h"
#import "ChatViewController.h"
@interface PhotoBrowseViewController ()<UIScrollViewDelegate,UINavigationControllerDelegate>{

     BOOL orginStatusBarSate;

}

@property (weak, nonatomic) IBOutlet PhotoScrollView *scrollView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewRightMarginC;

/** 总页数 */
@property (nonatomic,assign) NSUInteger pageCount;

/** 上一个页码 */
@property (nonatomic,assign) NSUInteger lastPage;

/** 可重用集合 */
@property (nonatomic,strong) NSMutableSet *reusablePhotoItemViewSetM;

/** 显示中视图字典 */
@property (nonatomic,strong) NSMutableDictionary *visiblePhotoItemViewDictM;

/** 要显示的下一页 */
@property (nonatomic,assign) NSUInteger nextPage;

/** drag时的page */
@property (nonatomic,assign) NSUInteger dragPage;

@end

@implementation PhotoBrowseViewController

-(void)dealloc
{
    self.reusablePhotoItemViewSetM = nil;
    self.visiblePhotoItemViewDictM =nil;
    self.currentItemView = nil;
    self.scrollView =nil;
    for (UIView *tempView in [self.view subviews])
    {
        [tempView removeFromSuperview];
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    
    return UIStatusBarStyleLightContent;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.delegate = self;//设置导航协议
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.delegate=nil;

    if (orginStatusBarSate) {
        [self.navigationController setNavigationBarHidden:NO];
        [[UIApplication sharedApplication] setStatusBarHidden:orginStatusBarSate];
    } else {
        [[UIApplication sharedApplication] setStatusBarHidden:orginStatusBarSate];
        [self.navigationController setNavigationBarHidden:NO];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    [self pagesPrepare];
    
    _scrollView.backgroundColor = Color(20, 20, 20);
    orginStatusBarSate = [UIApplication sharedApplication].isStatusBarHidden;
    _scrollViewRightMarginC.constant = - PBMargin;
}

/** 
 * 每页准备
 */
-(void)pagesPrepare{
    
    __block CGRect frame = [UIScreen mainScreen].bounds;
    
    CGFloat widthEachPage = frame.size.width + PBMargin;
    
    //展示页码对应的页面
    [self showWithPage:self.index];
    
    //设置contentSize
    self.scrollView.contentSize = CGSizeMake(widthEachPage * self.photoModels.count, 0);
    self.scrollView.index = _index;
    
}


/*
 *  展示页码对应的页面
 */
-(void)showWithPage:(NSUInteger)page{
    
    //如果对应页码对应的视图正在显示中，就不用再显示了
    if([self.visiblePhotoItemViewDictM objectForKey:@(page)] != nil) return;
    //取出重用photoItemView
    PhotoItemView *photoItemView = [self dequeReusablePhotoItemView];
    
    if(photoItemView == nil){//没有取到
        //重新创建
        photoItemView = [PhotoItemView viewFromXIB];
    }
    //数据覆盖
    __weak typeof(self) wself =self;
    photoItemView.ItemViewSingleTapBlock = ^(){
        [wself singleTap];
    };
    //到这里，photoItemView一定有值，而且一定显示为当前页
    //加入到当前显示中的字典
    [self.visiblePhotoItemViewDictM setObject:photoItemView forKey:@(page)];
    //传递数据
    //设置页标
    photoItemView.pageIndex = page;
    photoItemView.photoModel = self.photoModels[page];
    photoItemView.alpha=1.0f;
    [self.scrollView addSubview:photoItemView];
}

/** 取出可重用照片视图 */
-(PhotoItemView *)dequeReusablePhotoItemView{
    
    PhotoItemView *photoItemView = [self.reusablePhotoItemViewSetM anyObject];
    
    if(photoItemView != nil){
        //从可重用集合中移除
        [self.reusablePhotoItemViewSetM removeObject:photoItemView];
        
        [photoItemView reset];
    }
    
    return photoItemView;
}


-(void)singleTap{
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    NSUInteger page = [self pageCalWithScrollView:scrollView];
    
    [self reuserAndVisibleHandle:page];
    
    //记录dragPage
    if(self.dragPage == 0) self.dragPage = page;
    
    self.page = page;
    
    CGFloat offsetX = scrollView.contentOffset.x;
    
    CGFloat pageOffsetX = self.dragPage * scrollView.bounds.size.width;
    
    if(offsetX > pageOffsetX){//正在向左滑动，展示右边的页面
        
        if(page >= self.pageCount - 1) return;
        
        self.nextPage = page + 1;
        
    }else if(offsetX < pageOffsetX){//正在向右滑动，展示左边的页面
        
        if(page == 0) return;
        
        self.nextPage = page - 1;
    }
    
    NSLog(@"nextPage = %ld",self.nextPage);
    
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    //重围
    self.dragPage = 0;
}


-(NSUInteger)pageCalWithScrollView:(UIScrollView *)scrollView{
    NSUInteger page =  scrollView.contentOffset.x / scrollView.bounds.size.width + .5f;
    return page;
}


-(void)reuserAndVisibleHandle:(NSUInteger)page{
    
    //遍历可视视图字典，除了page之外的所有视图全部移除，并加入重用集合
    __weak typeof(self) wself =self;
    [self.visiblePhotoItemViewDictM enumerateKeysAndObjectsUsingBlock:^(NSValue *key, PhotoItemView *photoItemView, BOOL *stop) {
        if((![key isEqualToValue:@(page)]) && (![key isEqualToValue:@(page-1)]) && (![key isEqualToValue:@(page+1)])){
            
            [wself.reusablePhotoItemViewSetM addObject:photoItemView];
            [photoItemView reset];
            
            [wself.visiblePhotoItemViewDictM removeObjectForKey:key];
        }
    }];
}


-(void)setPhotoModels:(NSArray *)photoModels{
    
    _photoModels = photoModels;
    
    self.pageCount = photoModels.count;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //初始化页码信息
        self.page = _index;
    });
}



-(void)setPage:(NSUInteger)page{
    if(_page !=0 && _page == page) return;
    _lastPage = page;
    _page = page;
    [self showWithPage:page];
    self.currentItemView = [self.visiblePhotoItemViewDictM objectForKey:@(self.page)];
    self.currentImg = self.currentItemView.photoImageView;
    if ([self.delegate respondsToSelector:@selector(syncCurrentIndex:)]) {
        [self.delegate syncCurrentIndex:page];
    }
    
}


/** 可重用集合 */
-(NSMutableSet *)reusablePhotoItemViewSetM{
    
    if(_reusablePhotoItemViewSetM ==nil){
        _reusablePhotoItemViewSetM =[NSMutableSet set];
    }
    
    return _reusablePhotoItemViewSetM;
}

/** 显示中视图字典 */
-(NSMutableDictionary *)visiblePhotoItemViewDictM{
    
    if(_visiblePhotoItemViewDictM == nil){
        
        _visiblePhotoItemViewDictM = [NSMutableDictionary dictionary];
    }
    
    return _visiblePhotoItemViewDictM;
}


-(void)setNextPage:(NSUInteger)nextPage{
    
    if(_nextPage == nextPage) return;
    
    _nextPage = nextPage;
    
    [self showWithPage:nextPage];
    
}


#pragma mark - UINavigationControllerDelegate

- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                            animationControllerForOperation:(UINavigationControllerOperation)operation
                                                         fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC  NS_AVAILABLE_IOS(7_0)
{
    if(fromVC == self && [toVC isKindOfClass:[ChatViewController class]]){
        PhotoBrowseTransitionAnimation *pbTA = [[PhotoBrowseTransitionAnimation alloc]initWithTransitionType:PhotoBrowseTransitionTypeExit];
        return pbTA;
    }
    return nil;
}


-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    self.scrollView.isScrollToIndex = YES;
    [self.scrollView setNeedsLayout];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
