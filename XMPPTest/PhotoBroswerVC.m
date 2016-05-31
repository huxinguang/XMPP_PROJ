

#import "PhotoBroswerVC.h"
#import "PhotoBroswerLayout.h"
#import "UIView+Extend.h"
#import "UIImage+Extend.h"
#import "PBConst.h"
#import "CoreArchive.h"
#import "PBScrollView.h"
#import "PhotoBrowseEnterAnimation.h"
#import "PhotoBrowseExitAnimation.h"
#import <AssetsLibrary/ALAssetsLibrary.h>

@interface PhotoBroswerVC ()<UIScrollViewDelegate>

/** scrollView */
@property (weak, nonatomic) IBOutlet PBScrollView *scrollView;


/** 顶部条管理视图 */
@property (weak, nonatomic) IBOutlet UIView *topBarView;

/** 顶部label */
@property (weak, nonatomic) IBOutlet UILabel *topBarLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topBarHeightC;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewRightMarginC;


#define URL @"http://m.baozou.com/articles/"

/** 相册数组 */
@property (nonatomic,strong) NSArray *photoModels;

/** 总页数 */
@property (nonatomic,assign) NSUInteger pageCount;

/** page */
@property (nonatomic,assign) NSUInteger page;


/** 上一个页码 */
@property (nonatomic,assign) NSUInteger lastPage;


/** 初始显示的index */
@property (nonatomic,assign) NSUInteger index;


/** 可重用集合 */
@property (nonatomic,strong) NSMutableSet *reusablePhotoItemViewSetM;

/** 显示中视图字典 */
@property (nonatomic,strong) NSMutableDictionary *visiblePhotoItemViewDictM;

/** 要显示的下一页 */
@property (nonatomic,assign) NSUInteger nextPage;

/** drag时的page */
@property (nonatomic,assign) NSUInteger dragPage;

/** 当前显示中的itemView */
//@property (nonatomic,weak) PhotoItemView *currentItemView;


@end

@implementation PhotoBroswerVC
{
    UILabel *_pageLable;
    
    BOOL orginStatusBarSate;
}

+(void)show:(UIViewController *)vc index:(NSUInteger)index andView:(ShapedPhotoView*)clickedPhotoView photoModelBlock:(NSArray *(^)())photoModelBlock
{
    //取出相册数组
    NSArray *photoModels = photoModelBlock();
    if(photoModels == nil || photoModels.count == 0) return;
    
    BOOL isOK = [PhotoModel check:photoModels];
    
    if(!isOK){
        return;
    }
    PhotoBroswerVC *pbVC = [[self alloc] init];
    if(index >= photoModels.count){
        return;
    }
    //记录
    pbVC.photoModels = photoModels;
    pbVC.index = index;
    pbVC.spv = clickedPhotoView;
    [vc.navigationController pushViewController:pbVC animated:YES];

}


//获取当前屏幕显示的viewcontroller
-(BOOL)getCurrentVC
{
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    __block BOOL result =NO;
    [window.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *frontView = obj;
        id nextResponder = [frontView nextResponder];
        
        if ([nextResponder isKindOfClass:[PhotoBroswerVC class]])
            result =YES; *stop =YES;
    }];
    
    return result;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    //控制器准备
    [self vcPrepare];
    
    [self saveImageUI];
    _scrollView.backgroundColor = Color(20, 20, 20);
    
    orginStatusBarSate = [UIApplication sharedApplication].isStatusBarHidden;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES];

}

//保存按钮
-(void)saveImageUI
{
    UIButton *downloadBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    downloadBtn.backgroundColor = [UIColor redColor];
    downloadBtn.frame = CGRectMake(ScreenWidth-44-10, ScreenHeight-44,44,44);
    [downloadBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [downloadBtn addTarget:self action:@selector(rightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:downloadBtn];
}



//Transparent Gradient Layer
- (void) insertTransparentGradient:(UIView*)View
{
    UIColor *colorOne = ColorA(0, 0, 0, 0.0f);
    UIColor *colorTwo = ColorA(0, 0, 0, 0.5);
    NSArray *colors = [NSArray arrayWithObjects:(id)colorOne.CGColor, colorTwo.CGColor,nil];
    NSNumber *stopOne = [NSNumber numberWithFloat:0.0];
    NSNumber *stopTwo = [NSNumber numberWithFloat:1.0];
    NSArray *locations = [NSArray arrayWithObjects:stopOne, stopTwo,nil];
    
    //crate gradient layer
    CAGradientLayer *headerLayer = [CAGradientLayer layer];
    
    headerLayer.colors = colors;
    headerLayer.locations = locations;
    headerLayer.frame = View.bounds;
    
    [View.layer insertSublayer:headerLayer atIndex:0];
}


//color gradient layer
- (void) insertColorGradient:(UIView*)View
{
    UIColor *colorOne = [UIColor colorWithRed:(0) green:(0) blue:(0) alpha:0];
    UIColor *colorTwo = [UIColor colorWithRed:(0)  green:(0)  blue:(0)  alpha:0.5];
    
    NSArray *colors = [NSArray arrayWithObjects:(id)colorOne.CGColor, colorTwo.CGColor,nil];
    NSNumber *stopOne = [NSNumber numberWithFloat:0.0];
    NSNumber *stopTwo = [NSNumber numberWithFloat:1.0];
    
    NSArray *locations = [NSArray arrayWithObjects:stopOne, stopTwo,nil];
    CAGradientLayer *headerLayer = [CAGradientLayer layer];
    headerLayer.colors = colors;
    headerLayer.locations = locations;
    headerLayer.frame = View.bounds;
    
    [View.layer insertSublayer:headerLayer above:0];
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    //[self clearSaveRecord];
    self.navigationController.delegate=nil;

    if (orginStatusBarSate) {
        [self.navigationController setNavigationBarHidden:NO];
        [[UIApplication sharedApplication] setStatusBarHidden:orginStatusBarSate];
    } else {
        [[UIApplication sharedApplication] setStatusBarHidden:orginStatusBarSate];
        [self.navigationController setNavigationBarHidden:NO];
    }
}

/*
 *清除model的保存记录
 */
//-(void)clearSaveRecord
//{
//    for(PhotoModel *ph in self.photoModels)
//    {
//        [ph saveNo];
//    }
//}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.delegate=self;//设置导航协议
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}


/*
 *  控制器准备
 */
-(void)vcPrepare{
    
    //去除自动处理
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationController.navigationBarHidden = YES;
    
    //每页准备
    [self pagesPrepare];
    
    //间距
    _scrollViewRightMarginC.constant = - PBMargin;
}



/** 每页准备 */
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

-(UIImage*)cutDownImage:(UIImage*)oldImage
{
    //判断图片是否大于460px宽，如果大于的话先进行图片压缩
    float scaleSize=460.0/oldImage.size.width;
    if (scaleSize>1.0) {
        return oldImage;
    }
    return [self scaleImage:oldImage toScale:scaleSize];
}

#pragma mark 图片缩放
/*
 功能:等比率缩放
 _image:需要缩放的图片
 _scaleSize:缩放图片的比例
 返回值:缩放后的图片
 */
-(UIImage *)scaleImage:(UIImage *)_image toScale:(float)_scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(_image.size.width*_scaleSize, _image.size.height*_scaleSize));
    [_image drawInRect:CGRectMake(0, 0, _image.size.width * _scaleSize, _image.size.height * _scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

-(void)singleTap{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UINavigationControllerDelegate methods

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC {

    if([toVC isKindOfClass:[PhotoBroswerVC class]])
    {
        return nil;
    }
    if (fromVC == self && [toVC isKindOfClass:[UIViewController class]] && _spv != nil) {
        
        PhotoBrowseExitAnimation *animationBack = [[PhotoBrowseExitAnimation alloc] init];
        
        if(_index != self.page)
        {
            if([[_spv.superview viewWithTag:(_page+100)] isKindOfClass:[ShapedPhotoView class]])
            {
                animationBack.clickedPhotoView = [_spv.superview viewWithTag:(_page+100)];
            }
            else
            {
                return nil;
            }
            
        }
        else
        {
            animationBack.clickedPhotoView =_spv;
        }
        
        [_spv.superview.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
        }];
        
        return animationBack;
        
    }
    else {
        return nil;
    }
    
}

-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    self.scrollView.isScrollToIndex = YES;
    [self.scrollView setNeedsLayout];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
}

/*
 *  scrollView代理方法区
 */
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
    
    
}



-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    //NSUInteger page = [self pageCalWithScrollView:scrollView];
    
    //[self reuserAndVisibleHandle:page];
}


-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    //重围
    self.dragPage = 0;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
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




-(NSUInteger)pageCalWithScrollView:(UIScrollView *)scrollView{
    NSUInteger page =  scrollView.contentOffset.x / scrollView.bounds.size.width + .5f;
    return page;
}






-(void)setPhotoModels:(NSArray *)photoModels{
    
    _photoModels = photoModels;
    
    self.pageCount = photoModels.count;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //初始化页码信息
        self.page = _index;
    });
}



-(void)setPage:(NSUInteger)page{
    
    if(_page !=0 && _page == page) return;
    
    _lastPage = page;
    
    _page = page;
    
    //设置标题
    NSString *text = [NSString stringWithFormat:@"%@ / %@", @(page + 1) , @(self.pageCount)];
    
    //__weak typeof(self) wself =self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.topBarLabel.text = text;
        [self.topBarLabel setNeedsLayout];
        [self.topBarLabel layoutIfNeeded];
        
        _pageLable.text = text;
        if(_photoModels.count>1)
        {
            [_pageLable setHidden:NO];
            //[_pageLable.superview setHidden:NO];
        }
        else
        {
            [_pageLable setHidden:YES];
            //[_pageLable.superview setHidden:YES];
        }
        
    });
    
    //显示对应的页面
    [self showWithPage:page];
    
    
    //获取当前显示中的photoItemView
    self.currentItemView = [self.visiblePhotoItemViewDictM objectForKey:@(self.page)];
}






-(UIStatusBarStyle)preferredStatusBarStyle{
    
    return UIStatusBarStyleLightContent;
}


- (IBAction)leftBtnClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)rightBtnClick:(id)sender {
    /*
    
    if (![DraftManager isHaveAuthorForLibrary])
    {
        return;
    }
    //取出itemView
    PhotoItemView *itemView = self.currentItemView;
    
    //取出对应模型
    PhotoModel *itemModel = (PhotoModel *)self.photoModels[self.page];
    
    if(!itemView.hasImage){
        [CoreSVP showSVPWithType:CoreSVPTypeCenterMsg Msg:@"请稍后重试~" duration:1.0f allowEdit:NO beginBlock:nil completeBlock:nil];
        return;
    }
    
    //    //读取缓存
    //    if([itemModel read]){//已经保存过本地
    //        [CoreSVP showSVPWithType:CoreSVPTypeInfo Msg:@"图片已存" duration:1.0f allowEdit:NO beginBlock:nil completeBlock:nil];
    //    }else{
    
    //展示提示框
    [CoreSVP showSVPWithType:CoreSVPTypeLoadingInterface Msg:@"保存中" duration:0 allowEdit:NO beginBlock:nil completeBlock:nil];
    
    
    [itemView save:^{
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [CoreSVP showSVPWithType:CoreSVPTypeSuccess Msg:@"保存成功" duration:1.0f allowEdit:NO beginBlock:nil completeBlock:nil];
            
            //保存记录
            [itemModel save];
        });
        
        
    } failBlock:^{
        
        [CoreSVP showSVPWithType:CoreSVPTypeError Msg:@"保存失败" duration:1.0f allowEdit:NO beginBlock:nil completeBlock:nil];
    }];
//    if (itemView.photoImageView.animatedImage)
//    {
//        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
//        [assetsLibrary writeImageDataToSavedPhotosAlbum:itemView.photoImageView.animatedImage.data metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
//            [CoreSVP showSVPWithType:CoreSVPTypeSuccess Msg:@"保存成功" duration:1.0f allowEdit:NO beginBlock:nil completeBlock:nil];
//        }];
//    }
//    else
//    {
//        [itemView save:^{
//            
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                
//                [CoreSVP showSVPWithType:CoreSVPTypeSuccess Msg:@"保存成功" duration:1.0f allowEdit:NO beginBlock:nil completeBlock:nil];
//                
//                //保存记录
//                [itemModel save];
//            });
//            
//            
//        } failBlock:^{
//            
//            [CoreSVP showSVPWithType:CoreSVPTypeError Msg:@"保存失败" duration:1.0f allowEdit:NO beginBlock:nil completeBlock:nil];
//        }];
//    }
     
     */
}

//保存图片
- (void)saveImageToPhotos:(UIImage*)savedImage
{
    UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

// 指定回调方法
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    //取出itemView
    //PhotoItemView *itemView = self.currentItemView;
    
    //取出对应模型
    PhotoModel *itemModel = (PhotoModel *)self.photoModels[self.page];
//    
//    if(error != NULL || image == nil){
//        
//        [CoreSVP showSVPWithType:CoreSVPTypeError Msg:@"保存失败" duration:1.0f allowEdit:NO beginBlock:nil completeBlock:nil];
//        
//    }else{
//        
//        [CoreSVP showSVPWithType:CoreSVPTypeSuccess Msg:@"保存成功" duration:1.0f allowEdit:NO beginBlock:nil completeBlock:nil];
//        
//        //保存记录
//        [itemModel save];
//    }
}

-(void)setIndex:(NSUInteger)index{
    _index = index ;
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


@end
