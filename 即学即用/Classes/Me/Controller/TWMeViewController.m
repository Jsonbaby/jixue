//
//  TWMeViewController.m
//  即学即用
//
//  Created by Apple on 16/4/5.
//  Copyright © 2016年 8lei. All rights reserved.
//

#import "TWMeViewController.h"
#import "SDCycleScrollView.h"
#import <MJRefresh.h>
#import <AFNetworking.h>
#import "TWTopicCell.h"
#import "TWSettingViewController.h"
#import "TWStoreViewController.h"
#import "TWAccount.h"
#import "TWAccountTool.h"
#import <SVProgressHUD.h>
#import "TWMyStatus.h"
#import <MJExtension.h>
#import "TWAccount.h"
#import "TWAccountTool.h"
#import "TWPhoto.h"
#import <UIImageView+WebCache.h>
#import "TWMemberInfo.h"
#import "TWCommentViewController.h"
#import "RegexKitLite.h"
#import "TWTextPart.h"
@interface TWMeViewController ()<SDCycleScrollViewDelegate,TYAttributedLabelDelegate>
/** 帖子数据 */
@property (nonatomic, strong) NSMutableArray *topics;

@property (nonatomic, strong) NSData *imageData;
@end

@implementation TWMeViewController

- (NSMutableArray *)topics
{
    if (!_topics) {
        _topics = [NSMutableArray array];
    }
    return _topics;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置导航栏
    [self setupNav];
    
    // 设置tableView的header
    [self setupHeader];
    
    // 设置背景色
    self.view.backgroundColor = TWGlobalBg;
    [self cheakNetworkStatus];
    // 添加刷新控件
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
                TTLog(@"未知网络");
                break;
                
            case AFNetworkReachabilityStatusNotReachable: // 没有网络(断网)
                [SVProgressHUD showImage:nil status:@"请连接网络"];
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN: // 手机自带网络
                TTLog(@"手机自带网络");
                break;
                
            case AFNetworkReachabilityStatusReachableViaWiFi: // WIFI
                TTLog(@"WIFI");
                break;
        }
    }];
    
    // 3.开始监控
    [mgr startMonitoring];
}

- (void)setupHeader
{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    TWAccount *accout = [TWAccountTool account];
    
    params[@"key"] = accout.key;
    params[@"client"] = @"ios";
    
    [[AFHTTPSessionManager manager] POST:@"http://www.jixuejiyong.com/mobile/index.php?act=hg_member_sns_home&op=web_lbpic" parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
            NSArray *arrPicture = responseObject[@"datas"][@"pic_img"];
            NSArray *titles = responseObject[@"datas"][@"pic_title"];
            NSMutableArray *images = [[NSMutableArray alloc] init];
            for (int i = 0 ;i < arrPicture.count; i++) {
               NSString *arr = [NSString stringWithFormat:@"http://www.jixuejiyong.com/data/upload/%@",arrPicture[i]];
                [images addObject:arr];
               
                if (images.count == arrPicture.count) {
                    
                    // 网络加载 --- 创建带标题的图片轮播器
                    SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, TWScreenW, TWScreenW*0.5) delegate:self placeholderImage:[UIImage imageNamed:@"placeholder"]];
                    
                    cycleScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentRight;
                    cycleScrollView.titlesGroup = titles;
                    cycleScrollView.currentPageDotColor = [UIColor whiteColor]; // 自定义
                    cycleScrollView.imageURLStringsGroup = images;
            
                    self.tableView.tableHeaderView = cycleScrollView;
                }
            }
        
        
       
       
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [SVProgressHUD showErrorWithStatus:@"请求错误"];
    }];
    
}

- (void)setupNav
{
    // 设置导航栏左边的按钮
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithImage:@"mine-setting-icon" highImage:@"mine-setting-icon-click" target:self action:@selector(settingClick)];
    
    // 设置导航栏右边的按钮
    UIButton *btn = [[UIButton alloc] init];
    [btn setTitle:@"收藏" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn sizeToFit];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn addTarget:self action:@selector(storeClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:btn];

}

- (void)settingClick
{
    TWSettingViewController *svc = [[TWSettingViewController alloc] init];
 
    [self.navigationController pushViewController:svc animated:YES];
}

- (void)storeClick
{
    TWStoreViewController *svc = [[TWStoreViewController alloc] init];
    [self.navigationController pushViewController:svc animated:YES];
}

- (void)setupRefresh
{
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewTopics)];
    // 自动改变透明度
    self.tableView.mj_header.automaticallyChangeAlpha= YES;
    [self.tableView.mj_header beginRefreshing];
    
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreTopics)];
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
    
    [[AFHTTPSessionManager manager] POST:@"http://www.jixuejiyong.com/mobile/index.php?act=hg_member_sns_home&op=index" parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self.tableView.mj_header endRefreshing];

       self.topics = [TWMyStatus mj_objectArrayWithKeyValuesArray:responseObject[@"datas"][@"traceList"]];

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
  
    
    // 参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    TWAccount *accout = [TWAccountTool account];
    
    params[@"key"] = accout.key;
    params[@"client"] = @"ios";
    params[@"num"] = @(self.topics.count + 1);
    // 发送请求
    
    [[AFHTTPSessionManager manager] POST:@"http://www.jixuejiyong.com/mobile/index.php?act=hg_member_sns_home&op=index" parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self.tableView.mj_footer endRefreshing];
        
        NSArray *arr = [TWMyStatus mj_objectArrayWithKeyValuesArray:responseObject[@"datas"][@"traceList"]];
        
        [self.topics addObjectsFromArray:arr];

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        [SVProgressHUD dismiss];
        if (arr.count == 0) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.tableView.mj_footer endRefreshing];
        [SVProgressHUD showErrorWithStatus:@"请求错误"];
    }];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    self.tableView.mj_footer.hidden = (self.topics.count == 0);
    return self.topics.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // static修饰局部变量:可以保证局部变量只分配一次存储空间(只初始化一次)
    static NSString *ID = @"mytopic";
    
    // 1.通过一个标识去缓存池中寻找可循环利用的cell
    TWTopicCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    // 2.如果没有可循环利用的cell
    if (cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"TWTopicCell" owner:nil options:nil] lastObject];
    }
    // 3.给cell设置新的数据
    TWMyStatus *status = self.topics[indexPath.row];

    // 转化时间戳
    long long int date1 = (long long int)[status.trace_addtime intValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:date1];
    
    // 设置时间格式
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *currentDateStr = [dateFormatter stringFromDate:date];
    
    NSString *str = [NSString stringWithFormat:@"http://www.jixuejiyong.com/data/upload/shop/avatar/%@",status.trace_memberavatar];
    // 下载图片
    [cell.profileImageView sd_setImageWithURL:[NSURL URLWithString:str] placeholderImage:nil];
   
    if(!self.imageData)
    {
        
        NSString *patch = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        self.imageData = UIImagePNGRepresentation(cell.profileImageView.image);
            [self.imageData writeToFile:[NSString stringWithFormat:@"%@/%@",patch,@"icon.png"] atomically:YES];
    }
    cell.nameLabel.text = status.member_info.member_nickname;
    
    cell.createTimeLabel.text = currentDateStr;
    
    if(!status.trace_real_title||[status.trace_real_title isEqualToString:@""])
    {
        if ([status.trace_title isEqualToString:@""]) {
            cell.text_label.text = status.trace_content;
            
        }else{
            cell.text_label.text = status.trace_title;
        }
    }else {
        NSString *str = [NSString stringWithFormat:@"《%@》",status.trace_real_title];
        cell.text_label.text = [NSString stringWithFormat:@"%@\n%@",str,status.trace_content];
        
    }

   
    cell.topic = status;
    if (status.photos) {
        cell.photoView.hidden = NO;
        cell.photoView.photos = status.photos;
    }else{
        cell.photoView.hidden = YES;
    }
    
    if (![status.trace_copycount isEqualToString:@"0"]) {
        [cell.shareButton setTitle:status.trace_copycount forState:UIControlStateNormal];
    }else{
        [cell.shareButton setTitle:@"转发" forState:UIControlStateNormal];
    }
    
    if (![status.trace_commentcount isEqualToString:@"0"]) {
        [cell.commentButton setTitle:status.trace_commentcount forState:UIControlStateNormal];
    }else{
        [cell.commentButton setTitle:@"评论" forState:UIControlStateNormal];
    }
    
    if ([status.liked isEqualToString:@"1"]) {
        [cell.likeBtn setImage:[UIImage imageNamed:@"app_heartR"] forState:UIControlStateNormal];
        [cell.likeBtn setTitle:@"喜欢" forState:UIControlStateNormal];
        
    }else{
        [cell.likeBtn setImage:[UIImage imageNamed:@"app_heartG"] forState:UIControlStateNormal];
        [cell.likeBtn setTitle:@"不喜欢" forState:UIControlStateNormal];
        
    }
    
    if (![status.trace_like_count isEqualToString:@"0"]) {
        [cell.likeBtn setTitle:status.trace_like_count forState:UIControlStateNormal];
        
    }else{
        [cell.likeBtn setImage:[UIImage imageNamed:@"app_heartG"] forState:UIControlStateNormal];
        [cell.likeBtn setTitle:@"不喜欢" forState:UIControlStateNormal];
        
    }
    
    NSMutableAttributedString *attText = [[NSMutableAttributedString alloc] init];
    // @的规则
    NSString *atPattern = @"@[0-9a-zA-Z\\u4e00-\\u9fa5_]+";
    // 表情的规则
    NSString *emotionPattern = @":[a-z]+:";
    NSMutableArray *parts = [NSMutableArray array];
    
    // | 匹配多个条件,相当于or\或
    NSString *pattern = [NSString stringWithFormat:@"%@|%@", emotionPattern, atPattern];
    // 遍历所有的匹配结果
    [cell.text_label.text enumerateStringsMatchedByRegex:pattern usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        //        NSLog(@"%@ %@", *capturedStrings, NSStringFromRange(*capturedRanges));
        if ((*capturedRanges).length == 0) return;
        TWLog(@"%@",*capturedStrings);
        TWTextPart *part = [[TWTextPart alloc] init];
        part.special = YES;
        part.text = *capturedStrings;
        part.emotion = [part.text hasPrefix:@":"] && [part.text hasSuffix:@":"];
        part.range = *capturedRanges;
        [parts addObject:part];
    }];
    
    // 遍历所有的非特殊字符
    [cell.text_label.text enumerateStringsSeparatedByRegex:pattern usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        if ((*capturedRanges).length == 0) return;
        
        TWTextPart *part = [[TWTextPart alloc] init];
        part.special = NO;
        part.text = *capturedStrings;
        part.range = *capturedRanges;
        [parts addObject:part];
    }];
    
    // 排序
    // 系统是按照从小 -> 大的顺序排列对象
    [parts sortUsingComparator:^NSComparisonResult(TWTextPart *part1, TWTextPart *part2) {
        // NSOrderedAscending = -1L, NSOrderedSame, NSOrderedDescending
        // 返回NSOrderedSame:两个一样大
        // NSOrderedAscending(升序):part2>part1
        // NSOrderedDescending(降序):part1>part2
        if (part1.range.location > part2.range.location) {
            // part1>part2
            // part1放后面, part2放前面
            return NSOrderedDescending;
        }
        // part1<part2
        // part1放前面, part2放后面
        return NSOrderedAscending;
    }];
    
    for (TWTextPart *part in parts) {
        // 等会需要拼接的子串
        NSAttributedString *substr = nil;
        if (part.isEmotion) { // 表情
            NSTextAttachment *attch = [[NSTextAttachment alloc] init];
            NSString *name = [part.text substringWithRange:NSMakeRange(1, part.text.length-2)];
            
            
            if (name) { // 能找到对应的图片
                NSData  *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:@"gif"]];
                attch.image = [UIImage imageWithData:data];
                UIFont *font = [UIFont systemFontOfSize:16];
                attch.bounds = CGRectMake(0, -3, font.lineHeight, font.lineHeight);
                substr = [NSAttributedString attributedStringWithAttachment:attch];
            } else { // 表情图片不存在
                substr = [[NSAttributedString alloc] initWithString:part.text];
            }

        }
        else if (part.special) { // 非表情的特殊文字
            substr = [[NSAttributedString alloc] initWithString:part.text attributes:@{
                                                                                       NSForegroundColorAttributeName : [UIColor blueColor]
                                                                                       }];
            
            
        } else { // 非特殊文字
            substr = [[NSAttributedString alloc] initWithString:part.text];
        }
        [attText appendAttributedString:substr];
    }
    [attText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange(0, attText.length)];
    cell.text_label.attributedText = attText;
    return cell;
    
}

#pragma mark - 代理方法
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TWMyStatus *status = self.topics[indexPath.row];
    return status.cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TWCommentViewController *commentVc = [[TWCommentViewController alloc] init];
    
    commentVc.topic = self.topics[indexPath.row];
    [self.navigationController pushViewController:commentVc animated:YES];

}

#pragma mark - SDCycleScrollViewDelegate

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index
{
    NSLog(@"---点击了第%ld张图片", (long)index);
    
    
}

@end
