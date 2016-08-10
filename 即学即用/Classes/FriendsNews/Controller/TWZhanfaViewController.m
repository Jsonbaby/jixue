//
//  TWZhanfaViewController.m
//  即学即用
//
//  Created by tao wai on 16/5/7.
//  Copyright © 2016年 8lei. All rights reserved.
//

#import "TWZhanfaViewController.h"
#import "TWPlaceholderTextView.h"
#import <AFNetworking.h>
#import "TWAccount.h"
#import "TWAccountTool.h"
#import <SVProgressHUD.h>
#import "TWMyStatus.h"
#import "TWMemberInfo.h"
#import <UIImageView+WebCache.h>
@interface TWZhanfaViewController ()<UITextViewDelegate>
@property (nonatomic, weak) TWPlaceholderTextView *textView;

@property (weak,nonatomic) UIScrollView *scrollView;
@property (nonatomic , strong) NSMutableArray *pictureArray;
@property (nonatomic, weak) UILabel *myLabel;
@end

@implementation TWZhanfaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNav];
    
    [self setupTextView];

}
- (void)setupNav
{
    self.title = @"转发";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cancel)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发表" style:UIBarButtonItemStyleDone target:self action:@selector(post)];
//    self.navigationItem.rightBarButtonItem.enabled = NO; // 默认不能点击
    // 强制刷新
    [self.navigationController.navigationBar layoutIfNeeded];
}

- (void)cancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)post
{
    // 请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    TWAccount *accout = [TWAccountTool account];
    params[@"do"] = @"forward";
    params[@"id"] = self.topic.trace_id;
    params[@"member_id"] = self.topic.trace_memberid;
    params[@"handle"] = @"post";
    params[@"key"] = accout.key;
    params[@"client"] = @"ios";
    params[@"originalid"] = self.topic.trace_id;
    if (self.topic.trace_real_title) {
        params[@"originaltype"] = @1;
    }else{
        params[@"originaltype"] = @0;
    }
   
    if (self.topic.trace_img_memid && ![self.topic.trace_img_memid isEqualToString:@""]) {
        params[@"trace_img_memid"] = self.topic.trace_img_memid;
    }else{
        params[@"trace_img_memid"] = self.topic.trace_memberid;
    }
    if (self.topic.trace_real_title) {
        params[@"forwardcontent"] = [NSString stringWithFormat:@"%@\n|| @%@:%@\n%@",self.textView.text,self.topic.member_info.member_nickname?self.topic.member_info.member_nickname:self.topic.member_info.member_name,self.topic.trace_real_title,self.topic.trace_content];
    }else{
        params[@"forwardcontent"] = [NSString stringWithFormat:@"%@\n|| @%@:%@",self.textView.text,self.topic.member_info.member_nickname?self.topic.member_info.member_nickname:self.topic.member_info.member_name,self.topic.trace_title];
    }
    [[AFHTTPSessionManager manager] POST:@"http://www.jixuejiyong.com/mobile/index.php?act=hg_member_sns_home&op=api" parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self cancel];
        TWLog(@"转发：%@",responseObject);
        [SVProgressHUD showImage:nil status:@"转发成功"];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TWLog(@"%@",error);
        [SVProgressHUD showErrorWithStatus:@"请求错误"];
    }];
   
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.textView becomeFirstResponder];
}

#pragma mark - <UITextViewDelegate>


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

/**
 *  添加textView
 */
- (void)setupTextView
{
    // 1.添加
    TWPlaceholderTextView *textView = [[TWPlaceholderTextView alloc] init];
    textView.tintColor = [UIColor grayColor];
    textView.font = [UIFont systemFontOfSize:15];
    textView.frame = self.view.bounds;
    // 垂直方向上永远可以拖拽
    textView.alwaysBounceVertical = YES;
    textView.delegate = self;
    textView.placeholder = @"说说分享心得...";
    [self.view addSubview:textView];
    self.textView = textView;
    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(10, 150, 40, 40)];
    NSString *str = [NSString stringWithFormat:@"http://www.jixuejiyong.com/data/upload/shop/avatar/%@",self.topic.member_info.member_avatar];
    // 下载图片
    [icon sd_setImageWithURL:[NSURL URLWithString:str] placeholderImage:[UIImage imageNamed:@"defaultUserIcon"]];
    [self.textView addSubview:icon];


    UILabel * label = [[UILabel alloc] init];
    label.x = 55;
    label.y = 150;
    label.width = TWScreenW - 65;
    label.height = 40;
    
    self.myLabel = label;
    
    label.textAlignment = NSTextAlignmentLeft;
    label.font =[UIFont systemFontOfSize:16];
    label.numberOfLines = 0;
    
    if(!self.topic.trace_real_title||[self.topic.trace_real_title isEqualToString:@""])
    {
        label.text = [NSString stringWithFormat:@"|| @%@:%@",self.topic.member_info.member_nickname?self.topic.member_info.member_nickname:self.topic.member_info.member_name,self.topic.trace_title];
    }else {
        
        label.text = [NSString stringWithFormat:@"|| @%@:%@",self.topic.member_info.member_nickname?self.topic.member_info.member_nickname:self.topic.member_info.member_name,self.topic.trace_content];
        
    }

    [self.textView addSubview:label];
  
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}





@end
