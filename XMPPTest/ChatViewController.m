//
//  ChatViewController.m
//  XMPPTest
//
//  Created by huxinguang on 16/5/9.
//  Copyright © 2016年 IOSDEV. All rights reserved.
//

#import "ChatViewController.h"
#import "ChatTextCell.h"
#import "ChatModel.h"
#import "ZBMessageInputView.h"
#import "ZBMessageShareMenuView.h"
#import "ZBMessageManagerFaceView.h"
#import "ZBMessage.h"
#import "ChatTextAttachment.h"
#import "HXGVoiceTool.h"

#define  MessageFont [UIFont systemFontOfSize:15]
#define  MessageMaxWidth 200
#define  MessageBgTopOffset 6
#define  MessageTopOffset 19.5
#define  MessageBottomOffset (MessageTopOffset - MessageBgTopOffset)
#define  MessageBgBottomOffset 8

#define  InputViewHeight 50
#define  Padding 10


typedef NS_ENUM(NSInteger,ZBMessageViewState) {
    ZBMessageViewStateShowFace,
    ZBMessageViewStateShowShare,
    ZBMessageViewStateShowKeyboard,
    ZBMessageViewStateShowNone
    
};

@interface ChatViewController ()<UITableViewDataSource,UITableViewDelegate,XMPPStreamDelegate,NSFetchedResultsControllerDelegate,ZBMessageInputViewDelegate,ZBMessageShareMenuViewDelegate,ZBMessageManagerFaceViewDelegate>{
    double animationDuration;
    CGRect keyboardRect;
    CGFloat previousToolViewHeight;
    UIImageView *voiceAnimationView;
    NSMutableArray *voiceAnimationImgArr;

    AVAudioRecorder *recorder;//录音器
    AVAudioPlayer *player;//播放器
    NSDictionary *recorderSettingsDict;//录音配置
    NSTimer *timer;//定时器
    NSMutableArray *volumImages;//图片组
    double lowPassResults;
    NSString *playName;//录音名字
}

@property (weak, nonatomic) IBOutlet UITableView *chatTableView;

@property (nonatomic ,strong)NSMutableArray *dataArr;

@property (nonatomic,strong) ZBMessageInputView *messageToolView;

@property (nonatomic,strong) ZBMessageManagerFaceView *faceView;

@property (nonatomic,strong) ZBMessageShareMenuView *shareMenuView;

@property (nonatomic,assign) CGFloat previousTextViewContentHeight;

@end

@implementation ChatViewController

- (void)dealloc{
    self.messageToolView = nil;
    self.faceView = nil;
    self.shareMenuView = nil;
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
//    [self.messageToolView removeObserver:self forKeyPath:@"frame" context:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(keyboardWillShow:)
                                                name:UIKeyboardWillShowNotification
                                              object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(keyboardWillHide:)
                                                name:UIKeyboardWillHideNotification
                                              object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(sendMsg)
                                                name:@"SendMessageNotification"
                                              object:nil];

    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = Color(235, 235, 235);
    self.navigationItem.title = self.friendJID.user;
    previousToolViewHeight = InputViewHeight;
    [self initilzer];
    
    animationDuration = 0.25;
    _chatTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //tableview 的背景视图
//    _chatTableView.backgroundView = []
//    _chatTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    _dataArr = [[NSMutableArray alloc]init];
    
    [[XMPPManager shareManager].xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [self loadData];
    

}

#pragma mark - 初始化
- (void)initilzer{
    
    self.messageToolView = [[ZBMessageInputView alloc]initWithFrame:CGRectMake(0, ScreenHeight - InputViewHeight,ScreenWidth,InputViewHeight)];
    self.messageToolView.layer.masksToBounds = YES;
    self.messageToolView.delegate = self;
    [self.view addSubview:self.messageToolView];
    [self shareFaceView];
    [self shareShareMeun];
    
//    [self.messageToolView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    
}

- (void)shareFaceView{
    
    if (!self.faceView)
    {
        self.faceView = [[ZBMessageManagerFaceView alloc]initWithFrame:CGRectMake(0,ScreenHeight, ScreenWidth, 196)];
        self.faceView.delegate = self;
        [self.view addSubview:self.faceView];
        
    }
}

- (void)shareShareMeun
{
    if (!self.shareMenuView)
    {
        self.shareMenuView = [[ZBMessageShareMenuView alloc]initWithFrame:CGRectMake(0,ScreenHeight,ScreenWidth, 196)];
        [self.view addSubview:self.shareMenuView];
        self.shareMenuView.delegate = self;
        
        ZBMessageShareMenuItem *sharePicItem = [[ZBMessageShareMenuItem alloc]initWithNormalIconImage:[UIImage imageNamed:@"sharemore_pic_ios7"]title:@"照片"];
        ZBMessageShareMenuItem *shareVideoItem = [[ZBMessageShareMenuItem alloc]initWithNormalIconImage:[UIImage imageNamed:@"sharemore_video_ios7"]title:@"拍摄"];
        ZBMessageShareMenuItem *shareLocItem = [[ZBMessageShareMenuItem alloc]initWithNormalIconImage:[UIImage imageNamed:@"sharemore_location_ios7"]title:@"位置"];
        ZBMessageShareMenuItem *shareVoipItem = [[ZBMessageShareMenuItem alloc]initWithNormalIconImage:[UIImage imageNamed:@"sharemore_videovoip"]title:@"小视频"];
        self.shareMenuView.shareMenuItems = [NSArray arrayWithObjects:sharePicItem,shareVideoItem,shareLocItem,shareVoipItem, nil];
        [self.shareMenuView reloadData];
        
    }
}

#pragma mark - ZBMessageInputView Delegate
- (void)didSelectedMultipleMediaAction:(BOOL)changed{
    
    if (changed)
    {
        [self.view insertSubview:self.shareMenuView aboveSubview:self.faceView];
        [self messageViewAnimationWithMessageRect:self.shareMenuView.frame
                         withMessageInputViewRect:self.messageToolView.frame
                                      andDuration:animationDuration
                                         andState:ZBMessageViewStateShowShare
                         doesToolViewNeedAnimation:YES];
    }
    else{
        [self messageViewAnimationWithMessageRect:keyboardRect
                         withMessageInputViewRect:self.messageToolView.frame
                                      andDuration:animationDuration
                                         andState:ZBMessageViewStateShowKeyboard
                        doesToolViewNeedAnimation:NO];
    }
    
}

- (void)didSendFaceAction:(BOOL)sendFace{
    if (sendFace) {
        [self.view insertSubview:self.faceView aboveSubview:self.shareMenuView];
        [self messageViewAnimationWithMessageRect:self.faceView.frame
                         withMessageInputViewRect:self.messageToolView.frame
                                      andDuration:animationDuration
                                         andState:ZBMessageViewStateShowFace
                        doesToolViewNeedAnimation:YES];
    }
    else{
        [self messageViewAnimationWithMessageRect:keyboardRect
                         withMessageInputViewRect:self.messageToolView.frame
                                      andDuration:animationDuration
                                         andState:ZBMessageViewStateShowKeyboard
                        doesToolViewNeedAnimation:NO];
    }
}

- (void)didChangeSendVoiceAction:(BOOL)changed{
    if (changed){
        [self messageViewAnimationWithMessageRect:keyboardRect
                         withMessageInputViewRect:self.messageToolView.frame
                                      andDuration:animationDuration
                                         andState:ZBMessageViewStateShowKeyboard
                        doesToolViewNeedAnimation:YES];
    }
    else{
        [self messageViewAnimationWithMessageRect:CGRectZero
                         withMessageInputViewRect:self.messageToolView.frame
                                      andDuration:animationDuration
                                         andState:ZBMessageViewStateShowNone
                        doesToolViewNeedAnimation:YES];
    }
}

//
//- (CGFloat)calculateTextViewHeight:(ZBMessageTextView *)textView{
//    CGFloat topPadding = (CGRectGetHeight(textView.frame)-textView.font.lineHeight)/2;
//    CGFloat bottomPadding = topPadding;
//    CGRect rect=[textView.text boundingRectWithSize:CGSizeMake(CGRectGetWidth(textView.frame), 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:textView.font,NSFontAttributeName, nil] context:nil];
//    return topPadding + rect.size.height + bottomPadding;
//    
//}
//
//
//- (CGFloat)textViewMaxHeight:(ZBMessageTextView *)textView{
//    CGFloat topPadding = (CGRectGetHeight(textView.frame)-textView.font.lineHeight)/2;
//    CGFloat bottomPadding = topPadding;
//    return topPadding + textView.font.lineHeight * 6 +bottomPadding;
//}

/*
 * 点击输入框代理方法
 */
- (void)inputTextViewWillBeginEditing:(ZBMessageTextView *)messageInputTextView{
    
}

- (void)inputTextViewDidBeginEditing:(ZBMessageTextView *)messageInputTextView
{
//    [self messageViewAnimationWithMessageRect:keyboardRect
//                     withMessageInputViewRect:self.messageToolView.frame
//                                  andDuration:animationDuration
//                                     andState:ZBMessageViewStateShowNone
//                    doesToolViewNeedAnimation:YES];
    
    if (!self.previousTextViewContentHeight)
    {
        self.previousTextViewContentHeight = messageInputTextView.contentSize.height;
    }
}


- (void)inputTextViewDidChange:(ZBMessageTextView *)messageInputTextView
{
    CGFloat maxHeight = [ZBMessageInputView maxHeight];
    CGSize size = [messageInputTextView sizeThatFits:CGSizeMake(CGRectGetWidth(messageInputTextView.frame), maxHeight)];
    CGFloat textViewContentHeight = size.height;
    
    // End of textView.contentSize replacement code
    BOOL isShrinking = textViewContentHeight < self.previousTextViewContentHeight;
    CGFloat changeInHeight = textViewContentHeight - self.previousTextViewContentHeight;
    
    if(!isShrinking && self.previousTextViewContentHeight == maxHeight) {
        changeInHeight = 0;
    }
    else {
        changeInHeight = MIN(changeInHeight, maxHeight - self.previousTextViewContentHeight);
    }
    
    if(changeInHeight != 0.0f) {
        
        [UIView animateWithDuration:0.01f
                         animations:^{
                             
                             if(isShrinking) {
                                 // if shrinking the view, animate text view frame BEFORE input view frame
                                 [self.messageToolView adjustTextViewHeightBy:changeInHeight];
                             }
                             
                             CGRect inputViewFrame = self.messageToolView.frame;
                             self.messageToolView.frame = CGRectMake(0.0f,
                                                                     inputViewFrame.origin.y - changeInHeight,
                                                                     inputViewFrame.size.width,
                                                                     inputViewFrame.size.height + changeInHeight);
                             
                             if(!isShrinking) {
                                 [self.messageToolView adjustTextViewHeightBy:changeInHeight];
                             }
                         }
                         completion:^(BOOL finished) {
                             
                         }];
        
        self.previousTextViewContentHeight = MIN(textViewContentHeight, maxHeight);
    }
}

/*
 * 发送信息
 */
- (void)didSendTextAction:(ZBMessageTextView *)messageInputTextView{
    
    NSLog(@"发送消息");
//    ZBMessage *message = [[ZBMessage alloc]initWithText:messageInputTextView.text sender:nil timestamp:[NSDate date]];
//    [self sendMessage:message];
//    
//    [messageInputTextView setText:nil];
//    [self inputTextViewDidChange:messageInputTextView];
    if ([messageInputTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0) {
        XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:self.friendJID];
        [message addBody:messageInputTextView.text];
        [[XMPPManager shareManager].xmppStream sendElement:message];
        [messageInputTextView setText:nil];
    }
    
}

- (void)sendMessage:(ZBMessage *)message{
    
    if ([self.messageToolView.messageInputTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0) {
        XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.friendJID];
        [msg addBody:self.messageToolView.messageInputTextView.text];
        [[XMPPManager shareManager].xmppStream sendElement:msg];
        [self.messageToolView.messageInputTextView setText:nil];
    }
    
}

#pragma end

- (void)sendMsg{

    [self sendMessage:nil];
}


- (void)loadData{
    
    if ([self.fetchedResultsController performFetch:nil]) {
        id <NSFetchedResultsSectionInfo>  info=self.fetchedResultsController.sections[0];
        NSArray *fetchArray = [info objects];
        [self refreshWithFetchedMessageArray:fetchArray];
    }
}

- (void)refreshWithFetchedMessageArray:(NSArray *)fetchedArray{
    
        if (fetchedArray.count > 0) {
            
            [_dataArr removeAllObjects];
            
            for (int i = 0; i < fetchedArray.count; i++) {
                ChatModel *model = [[ChatModel alloc]init];
                XMPPMessageArchiving_Message_CoreDataObject *message = fetchedArray[i];
                
                if (message.body) {
                    
                    model.message = [[NSMutableAttributedString alloc]initWithString:message.body];
                    if (message.isOutgoing) {
                        model.chatCellOwner = ChatCellOwnerMe;
                        model.iconUrl = @"http://img.zcool.cn/community/01c552565bffbc6ac7253403a6ad11.jpg";
                    }else{
                        model.chatCellOwner = ChatCellOwnerOther;
                        model.iconUrl = @"http://imgsrc.baidu.com/forum/w%3D580/sign=2902b5fed662853592e0d229a0ee76f2/7b01722309f790522a7088320ff3d7ca7acbd5f1.jpg";
                    }
                    
                    [self dealWithMessage:model.message];
                    
                    //先确定message是一行显示还是多行显示
                    CGSize size =  [model.message size];
                    CGFloat labelW = size.width;
                    CGFloat labelH = size.height;
                    model.messageMinHeight = labelH;
                    if (labelW > MessageMaxWidth) {
                        //多行
                        CGRect rect = [model.message boundingRectWithSize:CGSizeMake(MessageMaxWidth, 0) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
                        model.messageLabelSize = CGSizeMake(rect.size.width, rect.size.height);
                        model.isSingleLine = NO;
                    }else{
                        //单行
                        model.messageLabelSize = CGSizeMake(labelW, labelH);
                        model.isSingleLine = YES;
                    }
                    [_dataArr addObject:model];
                }
                
            }
            
            [_chatTableView reloadData];
            if (_dataArr.count > 0) {
                if (_chatTableView.contentSize.height >= _chatTableView.frame.size.height) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_dataArr.count-1 inSection:0];
                    [_chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                }
                
            }
            
        }

}


- (void)dealWithMessage:(NSMutableAttributedString *)msg{
    //字体
    [msg addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange(0, msg.length)];
    
    //加载plist文件中的数据
    NSString *path = [[NSBundle mainBundle]pathForResource:@"expression" ofType:@"plist"];
    //表情字典
    NSDictionary *faceDic = [[NSDictionary alloc]initWithContentsOfFile:path];
    
    //正则匹配要替换的文字的范围
    NSString * pattern = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
    NSError *error = nil;
    NSRegularExpression * re = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    if (!re) {
        NSLog(@"%@", [error localizedDescription]);
    }
    //通过正则表达式来匹配字符串
    NSString *str = [msg string];
    NSArray *resultArray = [re matchesInString:str options:0 range:NSMakeRange(0, str.length)];
    
    //用来存放字典，字典中存储的是图片和图片对应的位置
    NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:resultArray.count];
    
    //根据匹配范围来用图片进行相应的替换
    for(NSTextCheckingResult *match in resultArray) {
        //获取数组元素中得到range
        NSRange range = [match range];
        //获取原字符串中对应的值
        NSString *subStr = [str substringWithRange:range];
        NSArray *faceNameArr = [faceDic allKeys];
        
        for (int i = 0; i < faceNameArr.count; i ++)
        {
            if ([faceNameArr[i] isEqualToString:subStr])
            {
                NSString *imgName = [faceDic objectForKey:faceNameArr[i]];
                //新建文字附件来存放我们的图片
                ChatTextAttachment *attachment = [[ChatTextAttachment alloc] initWithImage:[UIImage imageNamed:imgName]];
                //把附件转换成可变字符串，用于替换掉源字符串中的表情文字
                NSAttributedString *imageStr = [NSAttributedString attributedStringWithAttachment:attachment];
                
                //把图片和图片对应的位置存入字典中
                NSMutableDictionary *imageDic = [NSMutableDictionary dictionaryWithCapacity:2];
                [imageDic setObject:imageStr forKey:@"image"];
                [imageDic setObject:[NSValue valueWithRange:range] forKey:@"range"];
                
                //把字典存入数组中
                [imageArray addObject:imageDic];
                
            }
        }
    }
    
    //从后往前替换
    for (int i = (int)imageArray.count -1; i >= 0; i--)
    {
        NSRange range;
        [imageArray[i][@"range"] getValue:&range];
        //进行替换
        [msg replaceCharactersInRange:range withAttributedString:imageArray[i][@"image"]];
    }
    
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    request.sortDescriptors = @[sort];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bareJidStr == %@ and streamBareJidStr == %@",self.friendJID.bare,[XMPPManager shareManager].xmppStream.myJID.bare];
    request.predicate = predicate;
    NSManagedObjectContext *context = [XMPPManager shareManager].context;
    _fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    _fetchedResultsController.delegate = self;
    return _fetchedResultsController;
}


#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //显示时滚动到底部
    if (tableView.contentSize.height >= tableView.frame.size.height) {
        [tableView setContentOffset:CGPointMake(0, tableView.contentSize.height-tableView.frame.size.height) animated:NO];
    }
    return _dataArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"CellIdentifier";
    ChatTextCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[ChatTextCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [cell configCellWithModel:[_dataArr objectAtIndex:indexPath.row]];
    return cell;
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    ChatModel *model = [_dataArr objectAtIndex:indexPath.row];
    CGFloat cellHeight = MessageTopOffset + model.messageLabelSize.height + MessageBottomOffset + MessageBgBottomOffset;
    if (cellHeight < MessageBgTopOffset+45+MessageBgBottomOffset) {
        cellHeight = MessageBgTopOffset+45+MessageBgBottomOffset;
    }
    return cellHeight;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self hideKeyboard];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (self.messageToolView.frame.origin.y + self.messageToolView.frame.size.height !=  CGRectGetHeight(self.view.frame)) {
        [self hideKeyboard];
    }
}

- (void)hideKeyboard{
    [self.messageToolView.messageInputTextView resignFirstResponder];
    self.messageToolView.faceSendButton.selected = NO;
    self.messageToolView.multiMediaSendButton.selected = NO;
    [self messageViewAnimationWithMessageRect:CGRectZero withMessageInputViewRect:self.messageToolView.frame andDuration:animationDuration andState:ZBMessageViewStateShowNone doesToolViewNeedAnimation:YES];
}


#pragma mark - XMPPStreamDelegate

//消息发送成功
-(void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message{
    NSLog(@"%s__%d__|消息发送成功",__FUNCTION__,__LINE__);
}

//消息发送失败
- (void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error{
    NSLog(@"%s__%d__|消息发送失败",__FUNCTION__,__LINE__);
}

//接收到消息
-(void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{
    NSLog(@"%s__%d__|收到消息",__FUNCTION__,__LINE__);
}


#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller{

    id <NSFetchedResultsSectionInfo>  info=[controller.sections firstObject];
    NSArray *fetchArray = [info objects];
    [self refreshWithFetchedMessageArray:fetchArray];
    
}

#pragma mark -keyboard

- (void)keyboardWillHide:(NSNotification *)notification{
    
    animationDuration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    //先判断工具条的高度,如果大于50则按照50来处理
    previousToolViewHeight = self.messageToolView.frame.size.height;
    
    
    if ((!self.messageToolView.voiceChangeButton.selected)  &&  (!self.messageToolView.faceSendButton.selected) && (!self.messageToolView.multiMediaSendButton.selected)) {
        [self messageViewAnimationWithMessageRect:CGRectZero
                         withMessageInputViewRect:self.messageToolView.frame
                                      andDuration:animationDuration
                                         andState:ZBMessageViewStateShowNone
                        doesToolViewNeedAnimation:YES];
    }else{
//        [self messageViewAnimationWithMessageRect:CGRectZero
//                         withMessageInputViewRect:self.messageToolView.frame
//                                      andDuration:animationDuration
//                                         andState:ZBMessageViewStateShowNone
//                        doesToolViewNeedAnimation:NO];
    }
    
    [UIView animateWithDuration:animationDuration animations:^{
        if (_chatTableView.contentSize.height > _chatTableView.frame.size.height) {
            _chatTableView.contentOffset = CGPointMake(0, _chatTableView.contentSize.height-_chatTableView.frame.size.height);
        }else{
            _chatTableView.contentOffset = CGPointMake(0, -64);
        }
    } completion:nil];
    
    
}

- (void)keyboardWillShow:(NSNotification *)notification{

    animationDuration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    [UIView animateWithDuration:animationDuration animations:^{
        if (_chatTableView.contentSize.height-(_chatTableView.frame.size.height- keyboardRect.size.height) > 0) {
            _chatTableView.contentOffset = CGPointMake(0, _chatTableView.contentSize.height-(_chatTableView.frame.size.height- keyboardRect.size.height));
        }
        
    } completion:nil];
    
    if ([[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y<CGRectGetHeight(self.view.frame)) {
        [self messageViewAnimationWithMessageRect:[[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue]
                         withMessageInputViewRect:self.messageToolView.frame
                                      andDuration:animationDuration
                                         andState:ZBMessageViewStateShowNone
                        doesToolViewNeedAnimation:YES];
    }
    
}

#pragma end


#pragma mark - messageView animation
- (void)messageViewAnimationWithMessageRect:(CGRect)rect  withMessageInputViewRect:(CGRect)inputViewRect andDuration:(double)duration andState:(ZBMessageViewState)state doesToolViewNeedAnimation:(BOOL)need{
    
    [UIView animateWithDuration:duration animations:^{
        if (need) {
            
            self.messageToolView.frame = CGRectMake(0.0f,CGRectGetHeight(self.view.frame)-CGRectGetHeight(rect)-CGRectGetHeight(inputViewRect),CGRectGetWidth(self.view.frame),CGRectGetHeight(inputViewRect));
        }
        if (self.chatTableView.contentSize.height-(self.chatTableView.frame.size.height- CGRectGetHeight(rect)) > -64) {
            self.chatTableView.contentOffset = CGPointMake(0, self.chatTableView.contentSize.height-(self.chatTableView.frame.size.height- CGRectGetHeight(rect)));
        }else{
            self.chatTableView.contentOffset = CGPointMake(0, -64);
        }
        
        switch (state) {
            case ZBMessageViewStateShowFace:
            {
                self.faceView.frame = CGRectMake(0.0f,CGRectGetHeight(self.view.frame)-CGRectGetHeight(rect),CGRectGetWidth(self.view.frame),CGRectGetHeight(rect));
                
            }
                break;
                
            case ZBMessageViewStateShowShare:
            {
                self.shareMenuView.frame = CGRectMake(0.0f,CGRectGetHeight(self.view.frame)-CGRectGetHeight(rect),CGRectGetWidth(self.view.frame),CGRectGetHeight(rect));
                
            }
                break;
            case ZBMessageViewStateShowKeyboard:
            {

            }
                break;
            
            case ZBMessageViewStateShowNone:
            {
                self.faceView.frame = CGRectMake(0.0f,CGRectGetHeight(self.view.frame),CGRectGetWidth(self.view.frame),CGRectGetHeight(self.faceView.frame));
                
                self.shareMenuView.frame = CGRectMake(0.0f,CGRectGetHeight(self.view.frame),CGRectGetWidth(self.view.frame),CGRectGetHeight(self.shareMenuView.frame));
            }
                break;
                
            default:
                break;
        }
        
    } completion:^(BOOL finished) {
        
        
        switch (state) {
            case ZBMessageViewStateShowFace:
            {
                self.shareMenuView.frame = CGRectMake(0.0f,CGRectGetHeight(self.view.frame),CGRectGetWidth(self.view.frame),CGRectGetHeight(self.shareMenuView.frame));
            }
                break;
                
            case ZBMessageViewStateShowShare:
            {
                self.faceView.frame = CGRectMake(0.0f,CGRectGetHeight(self.view.frame),CGRectGetWidth(self.view.frame),CGRectGetHeight(self.faceView.frame));
            }
                break;
                
            case ZBMessageViewStateShowKeyboard:
            {
                
            }
                break;
                
            case ZBMessageViewStateShowNone:
            {

            }
                break;
                
            default:
                break;
        }
        
    }];
}


#pragma mark - ZBMessageFaceViewDelegate
- (void)sendTheFaceStr:(NSString *)faceStr isDelete:(BOOL)dele
{
    if (!dele) {
        self.messageToolView.messageInputTextView.text = [self.messageToolView.messageInputTextView.text stringByAppendingString:faceStr];
    }else{
        NSLog(@"%ld,%ld",self.messageToolView.messageInputTextView.selectedRange.location,self.messageToolView.messageInputTextView.selectedRange.length);
        return;
    }
    
    
    
    [self inputTextViewDidChange:self.messageToolView.messageInputTextView];
    
}
#pragma end

#pragma mark - ZBMessageShareMenuView Delegate
- (void)didSelecteShareMenuItem:(ZBMessageShareMenuItem *)shareMenuItem atIndex:(NSInteger)index{
    switch (index) {
        case 0:
            NSLog(@"照片");
            break;
        case 1:
            NSLog(@"拍摄");
            break;
        case 2:
            NSLog(@"位置");
            break;
        case 3:
            NSLog(@"小视频");
            break;
            
        default:
            break;
    }
    
}
#pragma end



-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    
//    if ([keyPath isEqualToString:@"frame"]) {
//        NSLog(@"%f",self.messageToolView.frame.origin.y);
//        CGFloat offsetY = self.chatTableView.contentSize.height-(ScreenHeight-self.messageToolView.frame.origin.y);
//        self.chatTableView.contentOffset = CGPointMake(0, offsetY);
//
//    }
}


#pragma mark - ZBMessageInputViewDelegate

// 按下录音按钮开始录音
- (void)didStartRecordingVoiceAction{
    

    voiceAnimationView = [[UIImageView alloc]initWithFrame:CGRectMake(ScreenWidth/2-122/2, ScreenHeight/2-122/2, 122, 122)];
    voiceAnimationView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.8];
    [[UIApplication sharedApplication].keyWindow addSubview:voiceAnimationView];
    voiceAnimationView.layer.masksToBounds = YES;
    voiceAnimationView.layer.cornerRadius = 3;
//
//    NSMutableArray *imgArr = [NSMutableArray array];
//    for (int i = 0 ; i < 7; i++) {
//        UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"press_speak_icon_%d",i]];
//        [imgArr addObject:img];
//    }
//    voiceAnimationView.animationImages = imgArr;
//    voiceAnimationView.animationDuration = 1;
//    [voiceAnimationView startAnimating];
//    
//    NSLog(@"开始录音");
    
    [self configAudioSettings];
    if ([self canRecord]) {
        
        NSError *error = nil;
        //必须真机上测试,模拟器上可能会崩溃
        recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL URLWithString:playName] settings:recorderSettingsDict error:&error];
        
        if (recorder) {
            recorder.meteringEnabled = YES;
            [recorder prepareToRecord];
            [recorder record];
            
            //启动定时器
            timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(levelTimer:) userInfo:nil repeats:YES];
            
        } else
        {
            int errorCode = CFSwapInt32HostToBig ([error code]);
            NSLog(@"Error: %@ [%4.4s])" , [error localizedDescription], (char*)&errorCode);
            
        }
    }
    
    
    
    
    
    
}

// 手指向上滑动取消录音
- (void)didCancelRecordingVoiceAction{

    [recorder stop];
    if ([recorder deleteRecording]) {
        NSLog(@"文件删除成功");
    }
    recorder = nil;
    
    
    
    
    
    
    
    
    [timer invalidate];
    timer = nil;
    
    [voiceAnimationView removeFromSuperview];
    voiceAnimationView = nil;
    NSLog(@"取消录音");
}

// 按住拽出
- (void)didTouchDragExitAction{
    [timer setFireDate:[NSDate distantFuture]];
    [recorder pause];
    voiceAnimationView.image = [UIImage imageNamed:@"RecordCancel"];
}

// 按住拽入
- (void)didTouchDragEnterAction{
    [timer setFireDate:[NSDate distantPast]];
    [recorder record];
}

// 松开手指完成录音
- (void)didFinishRecoingVoiceAction{
    [recorder stop];
    recorder = nil;
    [timer invalidate];
    timer = nil;

    [voiceAnimationView removeFromSuperview];
    voiceAnimationView = nil;
    NSLog(@"录音完成");
    
    
    
    NSError *playerError;
    
    //播放
    player = nil;
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:playName] error:&playerError];
    
    if (player == nil)
    {
        NSLog(@"ERror creating player: %@", [playerError description]);
    }else{
        [player play];
    }
    
}

#pragma end

- (void)configAudioSettings{
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending)
    {
        //7.0第一次运行会提示，是否允许使用麦克风
        AVAudioSession *session = [AVAudioSession sharedInstance];
        NSError *sessionError;
        //AVAudioSessionCategoryPlayAndRecord用于录音和播放
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
        if(session == nil)
            NSLog(@"Error creating session: %@", [sessionError description]);
        else
            [session setActive:YES error:nil];
    }
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    playName = [NSString stringWithFormat:@"%@/play.aac",docDir];
    //录音设置
    recorderSettingsDict =[[NSDictionary alloc] initWithObjectsAndKeys:
                           [NSNumber numberWithInt:kAudioFormatMPEG4AAC],AVFormatIDKey,
                           [NSNumber numberWithInt:1000.0],AVSampleRateKey,
                           [NSNumber numberWithInt:2],AVNumberOfChannelsKey,
                           [NSNumber numberWithInt:8],AVLinearPCMBitDepthKey,
                           [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,
                           [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                           nil];
    //音量图片数组
    volumImages = [[NSMutableArray alloc]initWithObjects:@"press_speak_icon_0",@"press_speak_icon_1",@"press_speak_icon_2",
                   @"press_speak_icon_3", @"press_speak_icon_4",@"press_speak_icon_5",
                   @"press_speak_icon_6", nil];

}

//判断是否允许使用麦克风7.0新增的方法requestRecordPermission
-(BOOL)canRecord
{
    __block BOOL bCanRecord = YES;
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending)
    {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession requestRecordPermission:^(BOOL granted) {
            if (granted) {
                bCanRecord = YES;
            }
            else {
                bCanRecord = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[[UIAlertView alloc] initWithTitle:nil
                                                message:@"app需要访问您的麦克风。\n请启用麦克风-设置/隐私/麦克风"
                                               delegate:nil
                                      cancelButtonTitle:@"关闭"
                                      otherButtonTitles:nil] show];
                });
            }
        }];
        
//        
//        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
//            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
//                if (granted) {
//                    bCanRecord = YES;
//                }
//                else {
//                    bCanRecord = NO;
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [[[UIAlertView alloc] initWithTitle:nil
//                                                    message:@"app需要访问您的麦克风。\n请启用麦克风-设置/隐私/麦克风"
//                                                   delegate:nil
//                                          cancelButtonTitle:@"关闭"
//                                          otherButtonTitles:nil] show];
//                    });
//                }
//            }];
//        }
    }
    
    return bCanRecord;
}


-(void)levelTimer:(NSTimer*)timer_
{
    //call to refresh meter values刷新平均和峰值功率,此计数是以对数刻度计量的,-160表示完全安静，0表示最大输入值
    [recorder updateMeters];
    const double ALPHA = 0.05;
    double peakPowerForChannel = pow(10, (0.05 * [recorder peakPowerForChannel:0]));
    lowPassResults = ALPHA * peakPowerForChannel + (1.0 - ALPHA) * lowPassResults;
    
    NSLog(@"Average input: %f Peak input: %f Low pass results: %f", [recorder averagePowerForChannel:0], [recorder peakPowerForChannel:0], lowPassResults);
    
    if(lowPassResults>=0.7){
        voiceAnimationView.image = [UIImage imageNamed:[volumImages objectAtIndex:6]];
    }else if(lowPassResults>=0.6){
        voiceAnimationView.image = [UIImage imageNamed:[volumImages objectAtIndex:5]];
    }else if(lowPassResults>=0.5){
        voiceAnimationView.image = [UIImage imageNamed:[volumImages objectAtIndex:4]];
    }else if(lowPassResults>=0.4){
        voiceAnimationView.image = [UIImage imageNamed:[volumImages objectAtIndex:3]];
    }else if(lowPassResults>=0.3){
        voiceAnimationView.image = [UIImage imageNamed:[volumImages objectAtIndex:2]];
    }else if(lowPassResults>=0.2){
        voiceAnimationView.image = [UIImage imageNamed:[volumImages objectAtIndex:1]];
    }else if(lowPassResults>=0.1){
        voiceAnimationView.image = [UIImage imageNamed:[volumImages objectAtIndex:0]];
    }else{
        voiceAnimationView.image = [UIImage imageNamed:[volumImages objectAtIndex:0]];
    }
    
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
