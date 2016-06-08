//
//  XMPPManager.h
//  XMPPTest
//
//  Created by huxinguang on 16/5/4.
//  Copyright © 2016年 IOSDEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"
#import "XMPPRoster.h"
#import "XMPPMessageArchiving.h"
#import "XMPPRosterCoreDataStorage.h"
#import "XMPPMessageArchivingCoreDataStorage.h"

#import "XMPPvCardCoreDataStorage.h"
#import "XMPPvCardTempModule.h"
#import "XMPPvCardAvatarModule.h"
#import "XMPPvCardTemp.h"


typedef NS_ENUM(NSInteger,ConnectSeverPurpose) {
    ConnectSeverPurposeLogin,
    ConnectSeverPurposeRegister
};

@interface XMPPManager : NSObject<XMPPStreamDelegate,XMPPRosterDelegate,UIAlertViewDelegate>

@property (nonatomic ,strong)XMPPStream *xmppStream;                        //通信通道对象
@property (nonatomic ,assign)ConnectSeverPurpose connectSeverPurpose;
@property (nonatomic ,strong)XMPPRoster *xmppRoster;                        //好友花名册管理对象
@property (nonatomic ,strong)XMPPMessageArchiving *xmppMessageArchiving;    //信息归档对象
@property (nonatomic ,strong)NSManagedObjectContext *context;               //数据管理器
@property (nonatomic ,strong)XMPPRosterCoreDataStorage *xmppRosterCoreDataStorage;


@property (nonatomic , strong) XMPPvCardCoreDataStorage *xmppvCardStorage;
@property (nonatomic , strong) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic , strong) XMPPvCardAvatarModule *xmppvCardAvatarModule;




+ (instancetype)shareManager;

- (void)loginWithUserName:(NSString *)userName password:(NSString *)password;

- (void)registerWithUserName:(NSString *)userName password:(NSString *)password;

@end
