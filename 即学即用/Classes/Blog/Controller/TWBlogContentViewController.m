//
//  TWBlogContentViewController.m
//  即学即用
//
//  Created by Apple on 16/4/9.
//  Copyright © 2016年 8lei. All rights reserved.
//

#import "TWBlogContentViewController.h"
#import "TWBlogDetailCell.h"
#import <SVProgressHUD.h>
#import <MJRefresh.h>
#import <AFNetworking.h>
#import "TWAccountTool.h"
#import <MJExtension.h>
#import "TWAccount.h"
#import "TWCommentCell.h"
#import "TWBlogDetail.h"
#import <UIImageView+WebCache.h>
#import "TWComment.h"
#import "TWTextPart.h"
#import "RegexKitLite.h"
#import "TWTopicCell.h"
@interface TWBlogContentViewController ()<UITableViewDelegate, UITableViewDataSource,UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

/** 工具条底部间距 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSapce;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic, strong) TWBlogDetail *blogDetail;
@property (nonatomic, copy) NSString *HEIGHT;
- (IBAction)send:(UIButton *)sender;

@property (nonatomic, weak) UILabel *lab;

/** 保存帖子的top_cmt */
@property (nonatomic, strong) TWComment *saved_top_cmt;

/** 保存当前的页码 */
@property (nonatomic, assign) NSInteger page;

/** 管理者 */
@property (nonatomic, strong) AFHTTPSessionManager *manager;
@end

@implementation TWBlogContentViewController

- (AFHTTPSessionManager *)manager
{
    if (!_manager) {
        _manager = [AFHTTPSessionManager manager];
    }
    return _manager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupBasic];
    
    
    
    [self setupRefresh];
}

- (void)setupRefresh
{
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewComments)];
    [self.tableView.mj_header beginRefreshing];
    
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreComments)];
    self.tableView.mj_footer.hidden = YES;
}

- (void)loadMoreComments
{
    // 结束之前的所有请求
    [self.manager.tasks makeObjectsPerformSelector:@selector(cancel)];
    

    
    // 参数
    
}

- (void)loadNewComments
{
    // 结束之前的所有请求
    [self.manager.tasks makeObjectsPerformSelector:@selector(cancel)];
    
    [SVProgressHUD show];
    // 结束上啦
    [self.tableView.mj_footer endRefreshing];
    
    // 请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    TWAccount *accout = [TWAccountTool account];
    params[@"key"] = accout.key;
    params[@"client"] = @"ios";
    params[@"blog_id"] = self.blog_id;
    [[AFHTTPSessionManager manager] POST:@"http://www.jixuejiyong.com/mobile/index.php?act=hg_member_sns_home&op=blog_detail" parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        self.blogDetail = [TWBlogDetail mj_objectWithKeyValues:responseObject[@"datas"][@"info"]];
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


- (void)setupBasic
{
    self.title = @"评论";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    // cell的高度设置
    //    self.tableView.estimatedRowHeight = 44;
    //    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    // 背景色
    self.tableView.backgroundColor = TWGlobalBg;

    // 去掉分割线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // 内边距
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 64, 0);
    self.tableView.autoresizingMask = NO;
}

- (void)keyboardWillChangeFrame:(NSNotification *)note
{
    // 键盘显示\隐藏完毕的frame
    CGRect frame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    // 修改底部约束
    self.bottomSapce.constant = TWScreenH - frame.origin.y;
    // 动画时间
    CGFloat duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    // 动画
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // 恢复帖子的top_cmt
    //    if (self.saved_top_cmt) {
    //        self.topic.top_cmt = self.saved_top_cmt;
    //        [self.topic setValue:@0 forKeyPath:@"cellHeight"];
    //    }
    //
    // 取消所有任务
    //    [self.manager.tasks makeObjectsPerformSelector:@selector(cancel)];
    [self.manager invalidateSessionCancelingTasks:YES];
}




#pragma mark - <UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        if (self.blogDetail) {
            return 1;
        }
        else{
            return 0;
        }
    }else{
        return self.blogDetail.comment_list.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        
        return self.blogDetail.cellHeight + [self.HEIGHT intValue];
        TWLogFunc
       
    }else{
        TWComment *comment = self.blogDetail.comment_list[indexPath.row];
        return comment.cellHeight;
    }
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section ==0 ) {
        // static修饰局部变量:可以保证局部变量只分配一次存储空间(只初始化一次)
        static NSString *ID = @"topic";
        
        // 1.通过一个标识去缓存池中寻找可循环利用的cell
        TWBlogDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        
        // 2.如果没有可循环利用的cell
        if (cell == nil){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"TWBlogDetailCell" owner:nil options:nil] lastObject];
            UILabel *tableHead = [[UILabel alloc] init];
            tableHead.frame = cell.bottomTool.bounds;
            [cell.bottomTool addSubview:tableHead];
            tableHead.textColor = [UIColor blackColor];
            self.lab = tableHead;
        }
        // 头像
        if ([self.blog_avatar isEqualToString:@""]) {
            cell.profileImageView.image=[UIImage imageNamed:@"123.png"];
        }else{
            // 下载图片
            [cell.profileImageView sd_setImageWithURL:[NSURL URLWithString:self.blog_avatar] placeholderImage:[UIImage imageNamed:@"timeline_image_placeholder"]];
        }
        TWLog(@"%@",self.blogDetail);
        // 昵称
        cell.nameLabel.text = self.blogDetail.member_name;
        cell.dingButton.hidden = YES;
        cell.caiButton.hidden = YES;
        cell.shareButton.hidden = YES;
        cell.commentButton.hidden = YES;
        cell.topic = self.blogDetail;
        // 转化时间戳
        long long int date1 = (long long int)[self.blogDetail.blog_add_time intValue];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:date1];
        // 设置时间格式
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *currentDateStr = [dateFormatter stringFromDate:date];
        cell.createTimeLabel.text = currentDateStr;
        
        [cell.dingButton setTitle:@"不喜欢" forState:UIControlStateNormal];
        [cell.dingButton setImage:[UIImage imageNamed:@"app_heartG"] forState:UIControlStateNormal];
        NSString *str = [NSString stringWithFormat:@"《%@》",self.blogDetail.blog_title];
        cell.text_label.text = [NSString stringWithFormat:@"%@<br />%@",str,self.blogDetail.blog_content];
        
        
        if (self.blogDetail.comment_list.count) {
            self.lab.text = [NSString stringWithFormat:@"   评论列表:%zd",self.blogDetail.comment_list.count];
        }else{
            self.lab.text = @"   暂时无评论";
        }
        
        
        // 表情的规则
        NSString *emotionPattern = @"/data/upload/shop";
        NSMutableArray *parts = [NSMutableArray array];
        
       
        // 遍历所有的匹配结果
        [cell.text_label.text enumerateStringsMatchedByRegex:emotionPattern usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
            
            if ((*capturedRanges).length == 0) return;
            TWTextPart *part = [[TWTextPart alloc] init];
            part.text = [NSString stringWithFormat:@"http://www.jixuejiyong.com%@",*capturedStrings];
            part.range = *capturedRanges;
            [parts addObject:part];
            
        }];
        
        // 遍历所有的非特殊字符
        [cell.text_label.text enumerateStringsSeparatedByRegex:emotionPattern usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
            if ((*capturedRanges).length == 0) return;
            
            TWTextPart *part = [[TWTextPart alloc] init];
            part.text = *capturedStrings;
            part.range = *capturedRanges;
            [parts addObject:part];
        }];

        [parts sortUsingComparator:^NSComparisonResult(TWTextPart *part1, TWTextPart *part2) {
            
            if (part1.range.location > part2.range.location) {
               
                return NSOrderedDescending;
            }
            
            return NSOrderedAscending;
        }];
        NSMutableString *mstr = [[NSMutableString alloc] init];
        for (TWTextPart *part in parts) {
            [mstr appendString:part.text];
        }
        NSLog(@"123%@",mstr);
        cell.text_label.hidden = YES;
        cell.webview.hidden = NO;
        if (!cell.webview.height) {
            [cell.webview loadHTMLString:mstr baseURL:nil];
            TTLog(@"222222");
        }
        cell.webview.delegate = self;
        [cell.contentView addSubview:cell.webview];
        cell.webview.height = [self.HEIGHT intValue];
        cell.webview.scrollView.bounces=NO;
        
        
        return cell;
        
        
    }else{
        // static修饰局部变量:可以保证局部变量只分配一次存储空间(只初始化一次)
        static NSString *ID = @"comment";
        
        // 1.通过一个标识去缓存池中寻找可循环利用的cell
        TWCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        
        // 2.如果没有可循环利用的cell
        if (cell == nil){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"TWCommentCell" owner:nil options:nil] lastObject];
        }
        TWComment *comment = self.blogDetail.comment_list[indexPath.row];
        NSString *str = [NSString stringWithFormat:@"http://www.jixuejiyong.com/data/upload/shop/avatar/%@",comment.comment_memberavatar];
        [cell.profileImageView sd_setImageWithURL:[NSURL URLWithString:str] placeholderImage:[UIImage imageNamed:@"timeline_image_placeholder"]];
        cell.contentLabel.text = comment.comment_content;
        cell.usernameLabel.text = comment.comment_membername;
        return cell;
        
    }
    //    cell.comment = [self commentInIndexPath:indexPath];
    
    
}

#pragma mark - <UIWebViewDelegate>
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
//    webView.height = webView.scrollView.contentSize.height;
//    [self.tableView reloadData];
   
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self tableView:self.tableView heightForRowAtIndexPath:indexPath];
    self.HEIGHT = [webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"];
    webView.height = [self.HEIGHT intValue];
 
    [self.tableView reloadData];
}


#pragma mark - <UITableViewDelegate>
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
    
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIMenuController *menu = [UIMenuController sharedMenuController];
    if (menu.isMenuVisible) {
        [menu setMenuVisible:NO animated:YES];
    } else {
        // 被点击的cell
        TWCommentCell *cell = (TWCommentCell *)[tableView cellForRowAtIndexPath:indexPath];
        // 出现一个第一响应者
        [cell becomeFirstResponder];
        
        // 显示MenuController
       
        UIMenuItem *replay = [[UIMenuItem alloc] initWithTitle:@"回复" action:@selector(replay:)];
               menu.menuItems = @[replay];
        CGRect rect = CGRectMake(0, cell.height * 0.5, cell.width, cell.height * 0.5);
        [menu setTargetRect:rect inView:cell];
        [menu setMenuVisible:YES animated:YES];
    }
}

#pragma mark - MenuItem处理


- (void)replay:(UIMenuController *)menu
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    NSLog(@"%s ", __func__);
    [self.textField becomeFirstResponder];
    TWComment *comment = self.blogDetail.comment_list[indexPath.row];
    self.textField.text = [NSString stringWithFormat:@"@%@",comment.comment_membername];
}


- (IBAction)send:(UIButton *)sender {
    // 请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    TWAccount *accout = [TWAccountTool account];
    params[@"do"] = @"comment";
    params[@"originalid"] = self.blogDetail.blog_id;
//    params[@"id"] = self.blogDetail.blog_id;
    params[@"member_id"] = self.blogDetail.blog_member_id;
    params[@"handle"] = @"post";
    params[@"key"] = accout.key;
    
    params[@"client"] = @"ios";
    params[@"originaltype"] = @2;
    params[@"commentcontent"] = self.textField.text;
    
    [[AFHTTPSessionManager manager] POST:@"http://www.jixuejiyong.com/mobile/index.php?act=hg_member_sns_home&op=api" parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        TTLog(@"评论返回数据%@",responseObject);
        [self.view endEditing:YES];
        self.textField.text = @"";
        [SVProgressHUD showImage:nil status:@"评论成功"];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TWLog(@"%@",error);
        [SVProgressHUD showImage:nil status:@"评论失败"];
    }];

}
@end
