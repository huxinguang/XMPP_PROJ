//
//  PersonalViewController.m
//  XMPPTest
//
//  Created by huxinguang on 16/6/7.
//  Copyright © 2016年 IOSDEV. All rights reserved.
//

#import "PersonalViewController.h"
#import "XMPPvCardCoreDataStorage.h"
#import "XMPPvCardTempModule.h"
#import "XMPPvCardAvatarModule.h"
#import "XMPPvCardTemp.h"

@interface PersonalViewController ()

@property (nonatomic , strong) XMPPvCardCoreDataStorage *xmppvCardStorage;
@property (nonatomic , strong) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic , strong) XMPPvCardAvatarModule *xmppvCardAvatarModule;

@end

@implementation PersonalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"我";
}


- (void)uploadWithImage:(UIImage *)img {
    dispatch_queue_t  global_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(global_queue, ^{
        NSString *xmppName = [NSString stringWithFormat:@"%d", 101];
        
        NSXMLElement *vCardXML = [NSXMLElement elementWithName:@"vCard"];
        [vCardXML addAttributeWithName:@"xmlns" stringValue:@"vcard-temp"];
        NSXMLElement *photoXML = [NSXMLElement elementWithName:@"PHOTO"];
        NSXMLElement *typeXML = [NSXMLElement elementWithName:@"TYPE" stringValue:@"image/jpeg"];
        
        NSData *dataFromImage = UIImageJPEGRepresentation(img, 1.0f);//图片放缩
        NSXMLElement *binvalXML = [NSXMLElement elementWithName:@"BINVAL" stringValue:[dataFromImage base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]];
        [photoXML addChild:typeXML];
        [photoXML addChild:binvalXML];
        [vCardXML addChild:photoXML];
        
        XMPPvCardTemp * myvCardTemp = [_xmppvCardTempModule myvCardTemp];
        if (myvCardTemp) {
            myvCardTemp.photo = dataFromImage;
            [_xmppvCardTempModule activate: [XMPPManager shareManager].xmppStream];
            [_xmppvCardTempModule updateMyvCardTemp:myvCardTemp];
        } else {
            XMPPvCardTemp *newvCardTemp = [XMPPvCardTemp vCardTempFromElement:vCardXML];
            newvCardTemp.nickname = xmppName;
            [_xmppvCardTempModule activate: [XMPPManager shareManager].xmppStream];
            [_xmppvCardTempModule updateMyvCardTemp:newvCardTemp];
        }
    });
}

-(void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule didReceivevCardTemp:(XMPPvCardTemp *)vCardTemp forJID:(XMPPJID *)jid
{
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
