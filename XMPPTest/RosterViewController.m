//
//  RosterViewController.m
//  XMPPTest
//
//  Created by huxinguang on 16/5/6.
//  Copyright © 2016年 IOSDEV. All rights reserved.
//

#import "RosterViewController.h"
#import "RosterTableViewCell.h"
#import "ChatViewController.h"
@interface RosterViewController ()<UITableViewDelegate,UITableViewDataSource,XMPPRosterDelegate>{

    NSMutableArray *dataArray;
}

@property (weak, nonatomic) IBOutlet UITableView *rosterTableView;

@end

@implementation RosterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"好友列表";
    dataArray = [NSMutableArray array];
    [[XMPPManager shareManager].xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"CellIdentifier";
    RosterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"RosterTableViewCell" owner:self options:nil]lastObject];
    }
    cell.backgroundColor = [UIColor lightGrayColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    XMPPJID *jid = dataArray[indexPath.row];
    NSData *photoData = [[XMPPManager shareManager].xmppvCardAvatarModule photoDataForJID:jid];
    cell.iconImgView.image = [UIImage imageWithData:photoData];
    cell.cellTitleLabel.text = jid.user;

    return cell;
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 70;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    XMPPJID *jid = [dataArray objectAtIndex:indexPath.row];
    
    ChatViewController *chatVC = [[ChatViewController alloc]init];
    chatVC.transitionStatus = TransitionStatusNone;
    chatVC.isEditingCell = NO;
    chatVC.friendJID = jid;
    [self.navigationController pushViewController:chatVC animated:YES];

}

#pragma mark - XMPPRosterDelegate

// 开始检索好友
-(void)xmppRosterDidBeginPopulating:(XMPPRoster *)sender withVersion:(NSString *)version{
    NSLog(@"%s__%d__|开始检索好友",__FUNCTION__,__LINE__);
}

// 检索到好友
-(void)xmppRoster:(XMPPRoster *)sender didReceiveRosterItem:(DDXMLElement *)item{

    //获取JID字符串
    NSString *jidStr = [[item attributeForName:@"jid"]stringValue];
    //创建JID对象
    XMPPJID *jid = [XMPPJID jidWithString:jidStr];
    //把JID对象加入数组
    if ([dataArray containsObject:jid]) {
        return;
    }
    [dataArray addObject:jid];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:dataArray.count-1 inSection:0];
    [self.rosterTableView beginUpdates];
    [self.rosterTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.rosterTableView endUpdates];
    
    
}

// 检索好友结束
-(void)xmppRosterDidEndPopulating:(XMPPRoster *)sender{
    NSLog(@"%s__%d__|检索好友完毕",__FUNCTION__,__LINE__);
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
