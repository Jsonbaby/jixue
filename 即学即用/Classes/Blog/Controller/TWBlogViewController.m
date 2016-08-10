//
//  TWBlogViewController.m
//  即学即用
//
//  Created by Apple on 16/4/5.
//  Copyright © 2016年 8lei. All rights reserved.
//

#import "TWBlogViewController.h"
#import "TWBlogContentViewController.h"
#import <AFNetworking.h>
#import "TWAccount.h"
#import "TWAccountTool.h"
#import <SVProgressHUD.h>
#import "TWBlog.h"
#import <MJExtension.h>
#import "TWBlogTableViewCell.h"
#import <UIImageView+WebCache.h>
#import <MJRefresh.h>
@interface TWBlogViewController ()

@property (nonatomic, strong) NSMutableArray *blogArray;

@end


@implementation TWBlogViewController

-(NSMutableArray *)blogArray{
    if (_blogArray == nil) {
        _blogArray = [[NSMutableArray alloc] init];
    }
    return _blogArray;
}

- (void)viewDidLoad{
    
    [super viewDidLoad];
    
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
    TWLog(@"%@ %@",accout.key,accout.username);
    params[@"key"] = accout.key;
    params[@"client"] = @"ios";
    
    [[AFHTTPSessionManager manager] POST:@"http://www.jixuejiyong.com/mobile/index.php?act=hg_member_sns_home&op=blog" parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
            self.blogArray = [TWBlog mj_objectArrayWithKeyValuesArray:responseObject[@"datas"][@"blog_list"]];
            [self.tableView.mj_header endRefreshing];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            [SVProgressHUD dismiss];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.tableView.mj_header endRefreshing];
        [SVProgressHUD showErrorWithStatus:@"请求错误"];
    }];
    
}

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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return self.blogArray.count;
    
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // static修饰局部变量:可以保证局部变量只分配一次存储空间(只初始化一次)
    static NSString *ID = @"blog";
    
    // 1.通过一个标识去缓存池中寻找可循环利用的cell
    TWBlogTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    // 2.如果没有可循环利用的cell
    if (cell == nil){
        cell = [[TWBlogTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    
    // 3.给cell设置新的数据
    TWBlog *blog = self.blogArray[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@",blog.blog_title];
    
    
    // 转化时间戳
    long long int date1 = (long long int)[blog.blog_add_time intValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:date1];
    
    // 设置时间格式
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *currentDateStr = [dateFormatter stringFromDate:date];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ ",currentDateStr];
    
    NSString *str = [NSString stringWithFormat:@"http://www.jixuejiyong.com/data/upload/shop/avatar/%@",blog.member_avatar];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:str] placeholderImage:[UIImage imageNamed:@"timeline_image_placeholder"]];
    
    
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    return cell;
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
        return 60;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TWBlogContentViewController *cvc = [[TWBlogContentViewController alloc] init];
    TWBlog *blog = self.blogArray[indexPath.row];
    cvc.blog_id = blog.blog_id;
    NSString *str = [NSString stringWithFormat:@"http://www.jixuejiyong.com/data/upload/shop/avatar/%@",blog.member_avatar];
    cvc.blog_avatar = str;
    [self.navigationController pushViewController:cvc animated:YES];
}

@end
