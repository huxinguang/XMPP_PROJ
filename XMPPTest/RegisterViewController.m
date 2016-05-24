//
//  RegisterViewController.m
//  XMPPTest
//
//  Created by huxinguang on 16/5/4.
//  Copyright © 2016年 IOSDEV. All rights reserved.
//

#import "RegisterViewController.h"
#import "XMPPManager.h"

@interface RegisterViewController ()<XMPPStreamDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userNameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[XMPPManager shareManager].xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
}
- (IBAction)registerAction:(UIButton *)sender {
    
    [[XMPPManager shareManager]registerWithUserName:_userNameTextfield.text password:_passwordTextfield.text];
}

#pragma mark - XMPPStreamDelegate

-(void)xmppStreamDidRegister:(XMPPStream *)sender{
    NSLog(@"%s__%d__|注册成功",__FUNCTION__,__LINE__);
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error{
    NSLog(@"%s__%d__|注册失败",__FUNCTION__,__LINE__);
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
