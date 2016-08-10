//
//  TWPostBlogViewController.m
//  即学即用
//
//  Created by Apple on 16/4/14.
//  Copyright © 2016年 8lei. All rights reserved.
//

#import "TWPostBlogViewController.h"
#import "TWPlaceholderTextView.h"
#import <AFNetworking.h>
#import "TWAccount.h"
#import "TWAccountTool.h"
#import <SVProgressHUD.h>
@interface TWPostBlogViewController ()<UITextViewDelegate,UITextFieldDelegate>
@property (nonatomic, weak) TWPlaceholderTextView *textView;
@property (nonatomic, weak) UITextField *nametextView;
@end

@implementation TWPostBlogViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = TWGlobalBg;
    [self setupNav];
    
    [self setupTextView];
    
    [self setupToolbar];
}

/**
 * 监听键盘的弹出和隐藏
 */
- (void)keyboardWillChangeFrame:(NSNotification *)note
{
    // 键盘最终的frame
//    CGRect keyboardF = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    // 动画时间
//    CGFloat duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    
}

- (void)setupToolbar
{
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)setupTextView
{
    
    UITextField *nametextView = [[UITextField alloc] init];
    nametextView.placeholder = @"日志名称...";
    nametextView.frame = CGRectMake(0, 64, TWScreenW, 30);
    nametextView.delegate = self;
    nametextView.backgroundColor = [UIColor whiteColor];
    self.nametextView = nametextView;
    [self.view addSubview:nametextView];
    TWPlaceholderTextView *textView = [[TWPlaceholderTextView alloc] init];
    textView.placeholder = @"创业多年，用日记的方式记录创业点点滴滴，这些文字写给自己，也写给正在创业路上的你，予人玫瑰，手留余香。";
    textView.frame = CGRectMake(0, 99, TWScreenW, TWScreenH-35);
    textView.delegate = self;
    [self.view addSubview:textView];
    self.textView = textView;
}

- (void)setupNav
{
    self.title = @"发表文字";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发表" style:UIBarButtonItemStyleDone target:self action:@selector(post)];
    self.navigationItem.rightBarButtonItem.enabled = NO; // 默认不能点击
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
    params[@"blog_title"] = self.nametextView.text;
    params[@"blog_content"] = self.textView.text;
    
    
    params[@"key"] = accout.key;
    params[@"client"] = @"ios";
    
    [[AFHTTPSessionManager manager] POST:@"http://www.jixuejiyong.com/mobile/index.php?act=hg_member_sns_home&op=blog_add" parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if ([responseObject[@"datas"][@"result"] isEqualToString:@"success"]) {
            [SVProgressHUD showImage:nil status:@"发表日志成功！"];
            [self cancel];
           
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
       
         [SVProgressHUD showImage:nil status:@"发表失败！"];
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // 先退出之前的键盘
    [self.view endEditing:YES];
    // 再叫出键盘
    [self.nametextView becomeFirstResponder];
}

#pragma mark - <UITextViewDelegate>
- (void)textViewDidChange:(UITextView *)textView
{
    self.navigationItem.rightBarButtonItem.enabled = (textView.hasText) && (self.nametextView.text.length != 0);
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}
@end
