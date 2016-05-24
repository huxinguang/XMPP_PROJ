//
//  ViewController.m
//  XMPPTest
//
//  Created by huxinguang on 16/4/24.
//  Copyright © 2016年 IOSDEV. All rights reserved.
//

#import "ViewController.h"
#import "XMPPManager.h"
#import "RosterViewController.h"
@interface ViewController ()<XMPPStreamDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userNameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[XMPPManager shareManager].xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
}
- (IBAction)hideKeyboard:(UITapGestureRecognizer *)sender {
    [_userNameTextfield resignFirstResponder];
    [_passwordTextfield resignFirstResponder];

}

- (IBAction)loginAction:(id)sender {
    [[XMPPManager shareManager]loginWithUserName:_userNameTextfield.text password:_passwordTextfield.text];
}

#pragma mark - XMPPStreamDelegate

//登录成功
-(void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    NSLog(@"%s__%d__|登录成功",__FUNCTION__,__LINE__);
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"];
    [[XMPPManager shareManager].xmppStream sendElement:presence];
    
    RosterViewController *rvc = [[RosterViewController alloc]init];
    [self.navigationController pushViewController:rvc animated:YES];
}

//登录失败
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error{
    NSLog(@"%s__%d__|登录失败",__FUNCTION__,__LINE__);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error{

//    NSLog(@"%@",[error localizedDescription]);
}

@end
