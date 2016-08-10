//
//  TWBlackListController.m
//  即学即用
//
//  Created by tao wai on 16/6/23.
//  Copyright © 2016年 8lei. All rights reserved.
//

#import "TWBlackListController.h"
#import <AFNetworking.h>
#import "TWAccount.h"
#import "TWAccountTool.h"
#import <SVProgressHUD.h>
#import "TWFriend.h"
#import <MJExtension.h>
#import <MJRefresh.h>
#import <UIImageView+WebCache.h>
#import "TWPeopleMainViewController.h"
#import "TWGuanZhuViewController.h"
#import "TWFriendsTableViewCell.h"
@interface TWBlackListController ()

@end

@implementation TWBlackListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    
    [self cheakNetworkStatus];
    [self setupRefresh];
    
}

- (void)cheakNetworkStatus{
    // 1.获得网络监控的管理者
    AFNetworkReachabilityManager *mgr = [AFNetworkReachabilityManager sharedManager];
    
    // 2.设置网络状态改变后的处理
    [mgr setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        // 当网络状态改变了, 就会调用这个block
        switch (status) {
            case AFNetworkReachabilityStatusUnknown: // 未知网络
                NSLog(@"未知网络");
                break;
                
            case AFNetworkReachabilityStatusNotReachable: // 没有网络(断网)
                [SVProgressHUD showImage:nil status:@"请连接网络"];
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN: // 手机自带网络
                NSLog(@"手机自带网络");
                break;
                
            case AFNetworkReachabilityStatusReachableViaWiFi: // WIFI
                NSLog(@"WIFI");
                break;
        }
    }];
    
    // 3.开始监控
    [mgr startMonitoring];
}

- (void)setupRefresh
{
    
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewTopics)];
    // 自动改变透明度
    self.tableView.mj_header.automaticallyChangeAlpha= YES;
    [self.tableView.mj_header beginRefreshing];
    
    //    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreTopics)];
}

#pragma mark - 数据处理
/**
 * 加载新的帖子数据
 */
- (void)loadNewTopics
{
    [SVProgressHUD show];
    // 结束上啦
    [self.tableView.mj_footer endRefreshing];
    // 请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    TWAccount *accout = [TWAccountTool account];
    
    params[@"key"] = accout.key;
    params[@"client"] = @"ios";
    
    [[AFHTTPSessionManager manager] POST:@"http://www.jixuejiyong.com/mobile/index.php?act=hg_member_sns_home&op=blacklist" parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        TTLog(@"%@",responseObject);
        self.friends = [TWFriend mj_objectArrayWithKeyValuesArray:responseObject[@"datas"][@"friend_list"]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        [SVProgressHUD dismiss];
        [self.tableView.mj_header endRefreshing];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [SVProgressHUD showErrorWithStatus:@"请求错误"];
        [self.tableView.mj_header endRefreshing];
    }];
    
    
}

// 先下拉刷新, 再上拉刷新第5页数据

// 下拉刷新成功回来: 只有一页数据, page == 0
// 上啦刷新成功回来: 最前面那页 + 第5页数据

/**
 * 加载更多的帖子数据
 */
- (void)loadMoreTopics
{
    // 结束下拉
    [self.tableView.mj_header endRefreshing];
    
    // 参数
    
    
    // 发送请求
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // static修饰局部变量:可以保证局部变量只分配一次存储空间(只初始化一次)
    static NSString *ID = @"goodfriend";
    
    // 1.通过一个标识去缓存池中寻找可循环利用的cell
    TWFriendsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    // 2.如果没有可循环利用的cell
    if (cell == nil){
        cell = [[TWFriendsTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    // 3.给cell设置新的数据
    TWFriend *friend = self.friends[indexPath.row];
    if ([friend.friend_frommavatar isEqualToString:@""]) {
        cell.iconView.image=[UIImage imageNamed:@"123.png"];
    }else{
        // 下载图片
        NSString *str = [NSString stringWithFormat:@"http://www.jixuejiyong.com/data/upload/shop/avatar/%@",friend.friend_frommavatar];
        [cell.iconView sd_setImageWithURL:[NSURL URLWithString:str] placeholderImage:[UIImage imageNamed:@"defaultUserIcon"]];
    }
    
    if (friend.member_nickname) {
        cell.titleView.text = friend.member_nickname;
    }else{
        cell.titleView.text = friend.member_name;
    }
    
    // 转化时间戳
    long long int date1 = (long long int)[friend.friend_addtime intValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:date1];
    
    // 设置时间格式
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *currentDateStr = [dateFormatter stringFromDate:date];
    cell.priceView.text= [NSString stringWithFormat:@"加入时间：%@",currentDateStr];
    UIButton *cancelBtn = [[UIButton alloc] init];
    [cancelBtn setTitle:@"移出黑名单" forState:UIControlStateNormal];
    [cancelBtn setBackgroundImage:[UIImage imageNamed:@"comment-bar-record"] forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [cancelBtn addTarget:self action:@selector(clickni:) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.tag = [friend.member_id intValue];
    cancelBtn.frame = CGRectMake(TWScreenW - 80, 22, 70, 25);
    [cell.contentView addSubview:cancelBtn];
    return cell;
    
}
- (void)clickni:(UIButton *)btn{
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"确定移出黑名单吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.delegate = self;
    alert.tag = btn.tag;
    [alert show];
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 1){
        // 请求参数
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        TWAccount *accout = [TWAccountTool account];
        
        params[@"key"] = accout.key;
        params[@"client"] = @"ios";
        params[@"id"] = @(alertView.tag);
        
        [[AFHTTPSessionManager manager] POST:@"http://www.jixuejiyong.com/mobile/index.php?act=hg_member_sns_home&op=rmblack" parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            TTLog(@"%@",responseObject);
            
            [SVProgressHUD showImage:nil status:@"移出黑名单成功"];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            TTLog(@"%@",error);
            [SVProgressHUD showImage:nil status:@"请求失败"];
        }];
        
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TWPeopleMainViewController *mvc = [[TWPeopleMainViewController alloc] init];
    TWFriend *friend = self.friends[indexPath.row];
    mvc.mid = friend.member_id;
    [self.navigationController pushViewController:mvc animated:YES];
}


@end
