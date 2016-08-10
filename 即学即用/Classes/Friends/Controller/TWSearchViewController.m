//
//  TWSearchViewController.m
//  即学即用
//
//  Created by tao wai on 16/5/10.
//  Copyright © 2016年 8lei. All rights reserved.
//

#import "TWSearchViewController.h"
#import <MJRefresh.h>
#import <MJExtension.h>
#import <SVProgressHUD.h>
#import "TWAccount.h"
#import "TWAccountTool.h"
#import <AFNetworking.h>
#import "TWSearchCell.h"
#import "TWSearch.h"
#import <UIImageView+WebCache.h>
@interface TWSearchViewController ()<UISearchBarDelegate>
@property (nonatomic, weak) UISearchBar *searchBar;
@property (nonatomic, strong) NSMutableArray *topics;
@end

@implementation TWSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 中间的搜索框
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    self.searchBar = searchBar;
    searchBar.placeholder = @"请输入关键词...";
    searchBar.delegate = self;
    self.navigationItem.titleView = searchBar;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(guanzhu:) name:@"search" object:nil];
}

- (void)guanzhu:(NSNotification *)text
{
    TWLogFunc;
    NSInteger myInterger = [text.userInfo[@"changeRow"] integerValue];
    TWSearch *changePeople = self.topics[myInterger];
    changePeople.state = [NSString stringWithFormat:@"%d",1];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}


#pragma mark - 搜索框代理
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    // 进入下拉刷新状态, 发送请求给服务器
    // 添加刷新控件
    [self setupRefresh];
    
    // 退出键盘
    [searchBar resignFirstResponder];
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
//    params[@"membername"] = [self.searchBar.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    params[@"membername"] = self.searchBar.text;
    TTLog(@"%@", params[@"membername"]);
    [[AFHTTPSessionManager manager] POST:@"http://www.jixuejiyong.com/mobile/index.php?act=hg_member_sns_home&op=finduse" parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                 TTLog(@"%@",responseObject);
        self.topics = [TWSearch mj_objectArrayWithKeyValuesArray:responseObject[@"datas"][@"result"]];
        //        TWLog(@"%@",self.topics);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        [self.tableView.mj_header endRefreshing];
        [SVProgressHUD dismiss];
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

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    self.tableView.mj_footer.hidden = (self.topics.count == 0);
    return self.topics.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // static修饰局部变量:可以保证局部变量只分配一次存储空间(只初始化一次)
    static NSString *ID = @"addpeople";
    
    // 1.通过一个标识去缓存池中寻找可循环利用的cell
    TWSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"TWSearchCell" owner:nil options:nil]lastObject];
    }
    // 3.给cell设置新的数据
    TWSearch *search = self.topics[indexPath.row];
    
    if ([search.member_avatar isEqualToString:@""]||!search.member_avatar) {
        cell.headerImageView.image=[UIImage imageNamed:@"123.png"];
    }else{
        
        NSString *str = [NSString stringWithFormat:@"http://www.jixuejiyong.com/data/upload/shop/avatar/%@",search.member_avatar];
        // 下载图片
        [cell.headerImageView sd_setImageWithURL:[NSURL URLWithString:str] placeholderImage:[UIImage imageNamed:@"timeline_image_placeholder"]];
        
    }
    
    cell.screenNameLabel.text = [NSString stringWithFormat:@"%@ ",search.member_nickname?search.member_nickname:search.member_name];
    cell.fansCountLabel.text = [NSString stringWithFormat:@"ID:%@ ",search.member_id];
    
    
    cell.guanzhuBtn.tag = [search.member_id intValue];
    cell.peopleSearch = search;
    if (search.state) {
        [cell.guanzhuBtn setTitle:@"已关注" forState:UIControlStateNormal];
    }
    
    return cell;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 91;
    
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
