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

@interface PersonalViewController ()<UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *iconBtn;
//@property (nonatomic , strong) XMPPvCardCoreDataStorage *xmppvCardStorage;
//@property (nonatomic , strong) XMPPvCardTempModule *xmppvCardTempModule;
//@property (nonatomic , strong) XMPPvCardAvatarModule *xmppvCardAvatarModule;

@end

@implementation PersonalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"我";
    
//    _xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
//    _xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:_xmppvCardStorage];
//    _xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:_xmppvCardTempModule];
    

    
    [[XMPPManager shareManager].xmppvCardTempModule addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [[XMPPManager shareManager].xmppvCardAvatarModule addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    NSData *photoData = [[XMPPManager shareManager].xmppvCardAvatarModule photoDataForJID:[XMPPManager shareManager].xmppStream.myJID];
    if (photoData) {
        [self.iconBtn setImage:[UIImage imageWithData:photoData] forState:UIControlStateNormal];
    }
    
    
}

- (IBAction)iconClickAction:(UIButton *)sender {
    
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"相册中选择", nil];
    [sheet showInView:self.view];
    
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.delegate = self;
        if (IsIOS7) {
            picker.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
        }
        // 设置导航默认标题的颜色及字体大小
        picker.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor],
                                                     NSFontAttributeName : [UIFont boldSystemFontOfSize:18]};
        [self presentViewController:picker animated:YES completion:nil];
        //
    }else if(buttonIndex == 1){
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    
    }else{
    
        
    }


}


#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    [self updateWithImage:image];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}



- (void)updateWithImage:(UIImage *)img {
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
        
        XMPPvCardTemp * myvCardTemp = [[XMPPManager shareManager].xmppvCardTempModule myvCardTemp];
        if (myvCardTemp) {
            myvCardTemp.photo = dataFromImage;
            [[XMPPManager shareManager].xmppvCardTempModule activate: [XMPPManager shareManager].xmppStream];
            [[XMPPManager shareManager].xmppvCardTempModule updateMyvCardTemp:myvCardTemp];
        } else {
            XMPPvCardTemp *newvCardTemp = [XMPPvCardTemp vCardTempFromElement:vCardXML];
            newvCardTemp.nickname = xmppName;
            [[XMPPManager shareManager].xmppvCardTempModule activate: [XMPPManager shareManager].xmppStream];
            [[XMPPManager shareManager].xmppvCardTempModule updateMyvCardTemp:newvCardTemp];
        }
    });
}

#pragma mark - XMPPvCardTempModuleDelegate

-(void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule didReceivevCardTemp:(XMPPvCardTemp *)vCardTemp forJID:(XMPPJID *)jid
{
    [self.iconBtn setImage:[UIImage imageWithData:vCardTemp.photo] forState:UIControlStateNormal];
}


- (void)xmppvCardTempModuleDidUpdateMyvCard:(XMPPvCardTempModule *)vCardTempModule{
    NSLog(@"头像设置成功");
}

- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule failedToUpdateMyvCard:(NSXMLElement *)error{

    NSLog(@"头像设置失败");
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
