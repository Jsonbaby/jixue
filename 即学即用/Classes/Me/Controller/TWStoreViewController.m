//
//  TWStoreViewController.m
//  即学即用
//
//  Created by Apple on 16/4/8.
//  Copyright © 2016年 8lei. All rights reserved.
//  保存界面

#import "TWStoreViewController.h"
#import "TWPostWordViewController.h"
#import <MJRefresh.h>
#import <AFNetworking.h>
#import "TWStoreTopicCell.h"
#import <MJExtension.h>
#import "TWAccount.h"
#import "TWAccountTool.h"
#import <SVProgressHUD.h>
#import "TWStore.h"
#import "TWDetail.h"
#import <UIImageView+WebCache.h>
#import "RegexKitLite.h"
#import "TWTextPart.h"
@interface TWStoreViewController ()<TYAttributedLabelDelegate>
/** 帖子数据 */
@property (nonatomic, strong) NSMutableArray *topics;
/** 当前页码 */
@property (nonatomic, assign) NSInteger page;
/** 当加载下一页数据时需要这个参数 */
@property (nonatomic, copy) NSString *maxtime;
/** 上一次的请求参数 */
@property (nonatomic, strong) NSDictionary *params;

/** 上次选中的索引(或者控制器) */
@property (nonatomic, assign) NSInteger lastSelectedIndex;
@end

@implementation TWStoreViewController




- (NSMutableArray *)topics
{
    if (!_topics) {
        _topics = [NSMutableArray array];
    }
    return _topics;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // 添加刷新控件
    [self setupRefresh];
}

static NSString * const XMGTopicCellId = @"store";



- (void)setupRefresh
{
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewTopics)];
    // 自动改变透明度
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
    [self.tableView.mj_header beginRefreshing];
    
//    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreTopics)];
}


#pragma mark - 数据处理
/**
 * 加载新的帖子数据
 */
- (void)loadNewTopics
{
    // 结束上啦
    [self.tableView.mj_footer endRefreshing];
    
    // 请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    TWAccount *accout = [TWAccountTool account];
    
    params[@"key"] = accout.key;
    params[@"client"] = @"ios";
    
    [[AFHTTPSessionManager manager] POST:@"http://www.jixuejiyong.com/mobile/index.php?act=hg_member_sns_home&op=favourites" parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        TTLog(@"%@",responseObject);
        [self.tableView.mj_header endRefreshing];
        self.topics = [TWStore mj_objectArrayWithKeyValuesArray:responseObject[@"datas"][@"favourites_list"]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        [SVProgressHUD dismiss];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.tableView.mj_header endRefreshing];
        [SVProgressHUD showErrorWithStatus:@"请求错误"];
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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    self.tableView.mj_footer.hidden = (self.topics.count == 0);
    return self.topics.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // static修饰局部变量:可以保证局部变量只分配一次存储空间(只初始化一次)
    static NSString *ID = @"storeTopic";
    
    // 1.通过一个标识去缓存池中寻找可循环利用的cell
    TWStoreTopicCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    // 2.如果没有可循环利用的cell
    if (cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"TWStoreTopicCell" owner:nil options:nil] lastObject];
    }
    TWStore *store = self.topics[indexPath.row];
    // 头像
    if ([store.detail.trace_memberavatar isEqualToString:@""]||!store.detail.trace_memberavatar) {
        cell.profileImageView.image = [UIImage imageNamed:@"123.png"];
    }else{
        NSString *str = [NSString stringWithFormat:@"http://www.jixuejiyong.com/data/upload/shop/avatar/%@",store.detail.trace_memberavatar];
        // 下载图片
        [cell.profileImageView sd_setImageWithURL:[NSURL URLWithString:str] placeholderImage:[UIImage imageNamed:@"defaultUserIcon"]];
        
    }
    if(store.detail.trace_membername){
        // 昵称
        cell.nameLabel.text = store.detail.trace_membername;
    }else{
        cell.nameLabel.text = store.detail.blog_member_name;
    }
    
    // 转化时间戳
    if(store.detail.trace_addtime){
        // 昵称
        long long int date1 = (long long int)[store.detail.trace_addtime intValue];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:date1];
        // 设置时间格式
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *currentDateStr = [dateFormatter stringFromDate:date];
        cell.createTimeLabel.text = currentDateStr;
    }else{
        long long int date1 = (long long int)[store.detail.blog_add_time intValue];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:date1];
        // 设置时间格式
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *currentDateStr = [dateFormatter stringFromDate:date];
        cell.createTimeLabel.text = currentDateStr;
    }
    
    if (store.photos) {
        cell.photoView.hidden = NO;
        cell.photoView.photos = store.photos;
    }else{
        cell.photoView.hidden = YES;
    }

    cell.bottomTool.hidden = YES;
    if(store.detail.trace_title)
    {
        if (store.detail.trace_real_title) {
            NSString *str = [NSString stringWithFormat:@"《%@》",store.detail.trace_title];
            cell.text_label.text = [NSString stringWithFormat:@"%@\n%@",str,store.detail.trace_content];

        }else{
            cell.text_label.text = store.detail.trace_title;
        }
    }else {
        NSString *str = [NSString stringWithFormat:@"《%@》",store.detail.blog_title];
        cell.text_label.text = [NSString stringWithFormat:@"%@\n%@",str,store.detail.blog_content];
        
    }
    cell.topic = store;

   
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
    
    TWStore *store = self.topics[indexPath.row];
    // 返回这个模型对应的cell高度
    return store.cellHeight;
}




@end
