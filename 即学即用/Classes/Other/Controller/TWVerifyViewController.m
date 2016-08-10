//
//  TWVerifyViewController.m
//  即学即用
//
//  Created by Apple on 16/4/18.
//  Copyright © 2016年 8lei. All rights reserved.
//

#import "TWVerifyViewController.h"
#import "CountButton.h"
#import <AFNetworking.h>
#import "XMGTextField.h"
#import <SVProgressHUD.h>

@interface TWVerifyViewController ()<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet CountButton *smsVertifyBtn;
@property (weak, nonatomic) IBOutlet XMGTextField *smsVertifyTextField;
@property (nonatomic, strong) NSMutableDictionary *param1;
- (IBAction)smsClick;

@end

@implementation TWVerifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 基本设置
    self.view.backgroundColor = TWGlobalBg;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(post)];
    
    // 获取验证码
    [[AFHTTPSessionManager manager] GET:@"http://www.jixuejiyong.com/mobile/index.php?act=hg_member_sns_home&op=makecode" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        self.param1 = responseObject;
        
        if (!self.param1[@"datas"][@"captcha"]) {
            [SVProgressHUD showErrorWithStatus:@"请求失败"];
        }
       
        // 验证验证码
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        params[@"captcha"] = self.param1[@"datas"][@"captcha"];
        params[@"nchash"] = self.param1[@"datas"][@"nchash"];
//        [self smsClick];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"请求失败"];
       
    }];
    
    self.smsVertifyBtn.enabled = YES;

}

- (IBAction)smsClick {
    [self.smsVertifyBtn startCountDown];
    // 请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"type"] = @1;
    params[@"phone"] = self.phone;
    params[@"captcha"] = self.param1[@"datas"][@"captcha"];
    params[@"nchash"] = self.param1[@"datas"][@"nchash"];
    
    [[AFHTTPSessionManager manager] GET:@"http://www.jixuejiyong.com/mobile/index.php?act=hg_member_sns_home&op=get_captcha" parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (![responseObject[@"datas"][@"result"] isEqualToString:@"ture"]) {
            [SVProgressHUD showErrorWithStatus:@"发送短信失败"];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"发送短信失败"];
    }];
    
}

- (void)cancel{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)post{
   
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"sms_captcha"] = self.smsVertifyTextField.text;
    params[@"phone"] = self.phone;
    
    [[AFHTTPSessionManager manager] GET:@"http://www.jixuejiyong.com/mobile/index.php?act=hg_member_sns_home&op=check_captcha" parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (![responseObject[@"datas"][@"result"] isEqualToString:@"success"]) {
            [SVProgressHUD showErrorWithStatus:@"验证短信失败"];
        }
        // 请求参数
            NSMutableDictionary *params1 = [NSMutableDictionary dictionary];
            params1[@"sms_captcha"] = self.smsVertifyTextField.text;
            params1[@"phone"] = self.phone;
            params1[@"password"] =self.pwd;
        
            [[AFHTTPSessionManager manager] POST:@"http://www.jixuejiyong.com/mobile/index.php?act=hg_member_sns_home&op=register" parameters:params1 progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

                if ([responseObject[@"datas"][@"result"] isEqualToString:@"success"]) {
                    [SVProgressHUD showImage:nil status:@"注册成功，请登录"];
                    [self cancel];
                }
                
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [SVProgressHUD showErrorWithStatus:@"验证短信失败"];
            }];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"发送短信失败"];
    }];
    
    
}

@end
