#import "TWCommentViewController.h"
#import "TWTopicCell.h"
#import <MJRefresh.h>
#import <AFNetworking.h>
#import <MJExtension.h>
#import "TWCommentCell.h"
#import "TWMyStatus.h"
#import <UIImageView+WebCache.h>
#import "TWMemberInfo.h"
#import "TWComment.h"
#import "TWAccount.h"
#import "TWAccountTool.h"
#import <SVProgressHUD.h>
#import "RegexKitLite.h"
#import "TWTextPart.h"
@interface TWCommentViewController () <UITableViewDelegate, UITableViewDataSource,TYAttributedLabelDelegate>
/** 工具条底部间距 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSapce;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)send:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *textField;

/** 管理者 */
@property (nonatomic, strong) AFHTTPSessionManager *manager;
@end

@implementation TWCommentViewController

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
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.textField becomeFirstResponder];
    });
    
}

- (void)setupBasic
{
    self.title = @"评论";

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
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
    
    // 取消所有任务
    [self.manager.tasks makeObjectsPerformSelector:@selector(cancel)];
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
        return 1;
    }
    return self.topic.comment_list.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        TWMyStatus *status = self.topic;
        return status.cellHeight;
    }else{
        TWComment *comment = self.topic.comment_list[indexPath.row];
        return comment.cellHeight;
    }
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section ==0 ) {
        // static修饰局部变量:可以保证局部变量只分配一次存储空间(只初始化一次)
        static NSString *ID = @"topic";
        
        // 1.通过一个标识去缓存池中寻找可循环利用的cell
        TWTopicCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        
        // 2.如果没有可循环利用的cell
        if (cell == nil){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"TWTopicCell" owner:nil options:nil] lastObject];
        }
        // 头像
        if ([self.topic.trace_memberavatar isEqualToString:@""]) {
            cell.profileImageView.image=[UIImage imageNamed:@"123.png"];
        }else{
            
             NSString *str = [NSString stringWithFormat:@"http://www.jixuejiyong.com/data/upload/shop/avatar/%@",self.topic.member_info.member_avatar];
            // 下载图片
            [cell.profileImageView sd_setImageWithURL:[NSURL URLWithString:str] placeholderImage:[UIImage imageNamed:@"defaultUserIcon"]];
        }
        
        // 昵称
        cell.nameLabel.text = self.topic.member_info.member_nickname?self.topic.member_info.member_nickname:self.topic.trace_membername;
        
        // 转化时间戳
        long long int date1 = (long long int)[self.topic.trace_addtime intValue];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:date1];
        // 设置时间格式
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *currentDateStr = [dateFormatter stringFromDate:date];
        cell.createTimeLabel.text = currentDateStr;
        
        if(!self.topic.trace_real_title||[self.topic.trace_real_title isEqualToString:@""])
        {
            
            if ([self.topic.trace_title isEqualToString:@""]) {
                cell.text_label.text = self.topic.trace_content;
                
            }else{
                cell.text_label.text = self.topic.trace_title;
            }
        }else {
            NSString *str = [NSString stringWithFormat:@"《%@》",self.topic.trace_real_title];
            cell.text_label.text = [NSString stringWithFormat:@"%@\n%@",str,self.topic.trace_content];
            
        }
        
        if (self.topic.photos) {
            cell.photoView.hidden = NO;
            cell.photoView.photos = self.topic.photos;
        }else{
            cell.photoView.hidden = YES;
        }
        
        cell.topic = self.topic;
        if (![self.topic.trace_copycount isEqualToString:@"0"]) {
            [cell.shareButton setTitle:self.topic.trace_copycount forState:UIControlStateNormal];
        }else{
            [cell.shareButton setTitle:@"转发" forState:UIControlStateNormal];
        }
        
        if (![self.topic.trace_commentcount isEqualToString:@"0"]) {
            [cell.commentButton setTitle:self.topic.trace_commentcount forState:UIControlStateNormal];
        }else{
            [cell.commentButton setTitle:@"评论" forState:UIControlStateNormal];
        }
        cell.commentButton.userInteractionEnabled = NO;
        if ([self.topic.liked isEqualToString:@"1"]) {
            [cell.likeBtn setImage:[UIImage imageNamed:@"app_heartR"] forState:UIControlStateNormal];
            [cell.likeBtn setTitle:@"喜欢" forState:UIControlStateNormal];
            
        }else{
            [cell.likeBtn setImage:[UIImage imageNamed:@"app_heartG"] forState:UIControlStateNormal];
            [cell.likeBtn setTitle:@"不喜欢" forState:UIControlStateNormal];
            
        }
        
        if (![self.topic.trace_like_count isEqualToString:@"0"]) {
            [cell.likeBtn setTitle:self.topic.trace_like_count forState:UIControlStateNormal];
            
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

       
    }else{
        // static修饰局部变量:可以保证局部变量只分配一次存储空间(只初始化一次)
        static NSString *ID = @"comment";
        
        // 1.通过一个标识去缓存池中寻找可循环利用的cell
        TWCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        
        // 2.如果没有可循环利用的cell
        if (cell == nil){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"TWCommentCell" owner:nil options:nil] lastObject];
        }
         TWComment *comment = self.topic.comment_list[indexPath.row];
        NSString *str = [NSString stringWithFormat:@"http://www.jixuejiyong.com/data/upload/shop/avatar/%@",comment.comment_memberavatar];
        [cell.profileImageView sd_setImageWithURL:[NSURL URLWithString:str] placeholderImage:[UIImage imageNamed:@"timeline_image_placeholder"]];
        cell.contentLabel.text = comment.comment_content;
        cell.usernameLabel.text = comment.comment_membername;
        
        // 转化时间戳
        long long int date1 = (long long int)[comment.comment_addtime intValue];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:date1];
        // 设置时间格式
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *currentDateStr = [dateFormatter stringFromDate:date];
        cell.timeLabel.text = currentDateStr;
        // 转化时间戳
//        long long int date1 = (long long int)[comment.comment_addtime intValue];
//        NSDate *date = [NSDate dateWithTimeIntervalSince1970:date1];
//        // 设置时间格式
//        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//        NSString *currentDateStr = [dateFormatter stringFromDate:date];
//        cell.timeLabel.text = currentDateStr;
        return cell;

    }

    
    
}

#pragma mark - <UITableViewDelegate>
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
    
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section ==1) {
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
    }
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.textField resignFirstResponder];
}
#pragma mark - MenuItem处理
- (void)replay:(UIMenuController *)menu
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    NSLog(@"%s ", __func__);
    [self.textField becomeFirstResponder];
    TWComment *comment = self.topic.comment_list[indexPath.row];
    self.textField.text = [NSString stringWithFormat:@"@%@",comment.comment_membername];
    
}

- (IBAction)send:(id)sender {
    // 请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    TWAccount *accout = [TWAccountTool account];
    params[@"do"] = @"comment";
    params[@"originalid"] = self.topic.trace_id;
    params[@"id"] = self.topic.trace_id;
    params[@"member_id"] = self.topic.trace_memberid;
    params[@"handle"] = @"post";
    params[@"key"] = accout.key;
    params[@"client"] = @"ios";
    params[@"originaltype"] = @0;
    params[@"commentcontent"] = self.textField.text;
    params[@"showtype"] = @1;
    
    [[AFHTTPSessionManager manager] POST:@"http://www.jixuejiyong.com/mobile/index.php?act=hg_member_sns_home&op=api" parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        
            [SVProgressHUD showImage:nil status:@"评论成功"];
        
            TWComment *cmt = [[TWComment alloc] init];
            cmt.comment_membername = accout.member_nickname?accout.member_nickname:accout.username;
        
            NSDate *localDate = [NSDate date]; //获取当前时间
            NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[localDate timeIntervalSince1970]]; //转化为UNIX时间戳
            cmt.comment_addtime = timeSp;
            cmt.comment_content = self.textField.text;
            NSMutableString *mstr = [[NSMutableString alloc] initWithString:accout.member_avatar];
            [mstr deleteCharactersInRange:NSMakeRange(0, 51)];
            cmt.comment_memberavatar = mstr;
            TTLog(@"%@",accout.member_avatar);
            if (!self.topic.comment_list) {
                self.topic.comment_list = [[NSMutableArray alloc] init];
            }
            [self.topic.comment_list addObject:cmt];
            int i = [self.topic.trace_commentcount intValue];
            i ++;
            self.topic.trace_commentcount = [NSString stringWithFormat:@"%d",i];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            [self.view endEditing:YES];
            self.textField.text = @"";
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
       
        [SVProgressHUD showImage:nil status:@"评论失败"];
    }];
}
@end
