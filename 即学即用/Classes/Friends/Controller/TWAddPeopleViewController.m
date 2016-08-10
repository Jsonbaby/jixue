//
//  TWAddPeopleViewController.m
//  即学即用
//
//  Created by Apple on 16/4/8.
//  Copyright © 2016年 8lei. All rights reserved.
//

#import "TWAddPeopleViewController.h"
#import "TWRecommendUserCell.h"
#import <AFNetworking.h>
#import "TWAccount.h"
#import "TWAccountTool.h"
#import <SVProgressHUD.h>
#import "TWAddPeople.h"
#import <MJExtension.h>
#import "TWRecommendUserCell.h"
#import <UIImageView+WebCache.h>
#import <MJRefresh.h>
@interface TWAddPeopleViewController ()
@property (nonatomic, strong) NSMutableArray *peopleArray;
@end

@implementation TWAddPeopleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(guanzhu:) name:@"guanzhu" object:nil];
    // 添加刷新控件
    [self setupRefresh];
}
- (void)guanzhu:(NSNotification *)text
{
   NSInteger myInterger = [text.userInfo[@"changeRow"] integerValue];
   TWAddPeople *changePeople = self.peopleArray[myInterger];
    changePeople.state = [NSString stringWithFormat:@"%d",1];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
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
    // 请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    TWAccount *accout = [TWAccountTool account];
    
    params[@"key"] = accout.key;
    params[@"client"] = @"ios";
    
    [[AFHTTPSessionManager manager] POST:@"http://www.jixuejiyong.com/mobile/index.php?act=hg_member_sns_home&op=getmemberlist" parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
   
        self.peopleArray = [TWAddPeople mj_objectArrayWithKeyValuesArray:responseObject[@"datas"][@"member_list"]];
        
        [self.tableView.mj_header endRefreshing];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        [SVProgressHUD dismiss];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //                                TWLog(@"失败数据：%@",error);
        [SVProgressHUD showErrorWithStatus:@"请求错误"];
        [self.tableView.mj_header endRefreshing];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.peopleArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // static修饰局部变量:可以保证局部变量只分配一次存储空间(只初始化一次)
    static NSString *ID = @"addpeople";
    
    // 1.通过一个标识去缓存池中寻找可循环利用的cell
    TWRecommendUserCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"TWRecommendUserCell" owner:nil options:nil]lastObject];
    }
    // 3.给cell设置新的数据
    TWAddPeople *people = self.peopleArray[indexPath.row];
    
    if ([people.member_avatar isEqualToString:@""]||!people.member_avatar) {
        cell.headerImageView.image=[UIImage imageNamed:@"123.png"];
    }else{
       
        NSString *str = [NSString stringWithFormat:@"http://www.jixuejiyong.com/data/upload/shop/avatar/%@",people.member_avatar];
        // 下载图片
        [cell.headerImageView sd_setImageWithURL:[NSURL URLWithString:str] placeholderImage:[UIImage imageNamed:@"timeline_image_placeholder"]];
        
    }
    cell.peopleInfo = people;
    if (people.member_nickname&&![people.member_nickname isEqualToString:@""]) {
        cell.screenNameLabel.text = [NSString stringWithFormat:@"%@ ",people.member_nickname];
    }else{
        cell.screenNameLabel.text = [NSString stringWithFormat:@"%@ ",people.member_name];
    }
    
    cell.fansCountLabel.text = [NSString stringWithFormat:@"ID:%@ ",people.member_id];
    
    TWLog(@"%@",people.member_id);
    cell.guanzhuBtn.tag = [people.member_id intValue];
    cell.guanzhuBtn.enabled = YES;
    if (people.state) {
        [cell.guanzhuBtn setTitle:@"已关注" forState:UIControlStateNormal];
        cell.guanzhuBtn.enabled = YES;
    }
    TWAccount *account = [TWAccountTool account];
    if ([people.member_id isEqualToString:account.member_id]) {
        [cell.guanzhuBtn setTitle:@"本人" forState:UIControlStateDisabled];
        cell.guanzhuBtn.enabled = NO;
    }
    cell.indexRow = indexPath.row;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 91;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
