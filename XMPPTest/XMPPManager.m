//
//  XMPPManager.m
//  XMPPTest
//
//  Created by huxinguang on 16/5/4.
//  Copyright © 2016年 IOSDEV. All rights reserved.
//

#import "XMPPManager.h"

@interface XMPPManager ()

@property (nonatomic ,copy)NSString *password;
@property (nonatomic ,strong)XMPPJID *fromJid;

@end

@implementation XMPPManager

+ (XMPPManager *)shareManager{
    static XMPPManager *xmppManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        xmppManager = [[XMPPManager alloc]init];
    });
    return xmppManager;
}

- (instancetype)init{
    if (self = [super init]) {
        //创建通信通道对象
        self.xmppStream = [[XMPPStream alloc]init];
        //设置服务器IP地址
        self.xmppStream.hostName = kHostName;
        //设置服务器端口
        self.xmppStream.hostPort = kHostPort;
        //设置代理
        [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        _xmppRosterCoreDataStorage = [XMPPRosterCoreDataStorage sharedInstance];
        self.xmppRoster = [[XMPPRoster alloc]initWithRosterStorage:_xmppRosterCoreDataStorage dispatchQueue:dispatch_get_main_queue()];
        [self.xmppRoster activate:self.xmppStream];
        [self.xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        
        //创建信息归档数据存储对象
        XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingCoreDataStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
        //创建信息归档对象
        self.xmppMessageArchiving = [[XMPPMessageArchiving alloc]initWithMessageArchivingStorage:xmppMessageArchivingCoreDataStorage dispatchQueue:dispatch_get_main_queue()];
        [self.xmppMessageArchiving activate:self.xmppStream];
        
        self.context = xmppMessageArchivingCoreDataStorage.mainThreadManagedObjectContext;
        
        
        _xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
        _xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:_xmppvCardStorage];
        _xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:_xmppvCardTempModule];
        
        
    }
    return self;
}

//登录
-(void)loginWithUserName:(NSString *)userName password:(NSString *)password{
    //连接服务器
    _password = password;
    kAppDelegate.userName = userName;
    self.connectSeverPurpose = ConnectSeverPurposeLogin;
    [self connectToSeverWithUserName:userName];
}


//注册
-(void)registerWithUserName:(NSString *)userName password:(NSString *)password{
    _password = password;
    self.connectSeverPurpose = ConnectSeverPurposeRegister;
    [self connectToSeverWithUserName:userName];
}


- (void)connectToSeverWithUserName:(NSString *)userName{

    //创建XMPPJID对象
    XMPPJID *jid = [XMPPJID jidWithUser:userName domain:kDomain resource:kResourse];
    //设置通信通道对象的jid
    self.xmppStream.myJID = jid;
    //发送连接请求（若已连接或正在连接那么先断开连接）
    
    if ([self.xmppStream isConnected] || [self.xmppStream isConnecting]) {
        //先发送下线状态
//        XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
        XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable" to:jid];
        [self.xmppStream sendElement:presence];
        
        //断开连接
        [self.xmppStream disconnect];
    }
    
    NSError *error = nil;
    [self.xmppStream connectWithTimeout:-1 error:&error];
    if (error) {
        NSLog(@"%s__%d__|连接服务器出错",__FUNCTION__,__LINE__);
    }
    
}

#pragma mark - XMPPStreamDelegate

- (void)xmppStreamConnectDidTimeout:(XMPPStream *)sender{
    NSLog(@"%s__%d__|连接服务器超时",__FUNCTION__,__LINE__);
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender{
    NSError *error = nil;
    if (self.connectSeverPurpose == ConnectSeverPurposeLogin) {
        [self.xmppStream authenticateWithPassword:_password error:&error];
        if (error) {
            NSLog(@"%s__%d__|验证失败",__FUNCTION__,__LINE__);
        }
    }else if (self.connectSeverPurpose == ConnectSeverPurposeRegister){
        [self.xmppStream registerWithPassword:_password error:&error];
        if (error) {
            NSLog(@"%s__%d__|注册失败",__FUNCTION__,__LINE__);
        }
    
    }
    
}

#pragma mark - XMPPRosterDelegate

-(void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence{
    self.fromJid = presence.from;
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"好友请求" message:presence.from.user delegate:self cancelButtonTitle:@"拒绝" otherButtonTitles:@"同意", nil];
    [alertView show];

}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    if (buttonIndex == 0) {
        //拒绝加好友请求
        [self.xmppRoster rejectPresenceSubscriptionRequestFrom:self.fromJid];
    }else{
        //同意好友请求
        [self.xmppRoster acceptPresenceSubscriptionRequestFrom:self.fromJid andAddToRoster:YES];
    }
}

@end
