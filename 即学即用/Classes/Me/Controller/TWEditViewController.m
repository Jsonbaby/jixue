//
//  TWEditViewController.m
//  即学即用
//
//  Created by Apple on 16/4/7.
//  Copyright © 2016年 8lei. All rights reserved.
//

#import "TWEditViewController.h"
#import "TWAccount.h"
#import "TWAccountTool.h"
#import <SVProgressHUD.h>
#import <AFNetworking.h>
@interface TWEditViewController ()
@property (nonatomic, weak) UITextField  *textField;
@end

@implementation TWEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 1.设置导航栏
    self.navigationItem.title = @"编辑昵称";
    self.view.backgroundColor=[UIColor colorWithRed:235/255.0 green:235/255.0 blue:241/255.0 alpha:1];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(storeClick)];
    rightButton.tintColor=[UIColor redColor];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    // 2.输入文本框
    UITextField *text = [[UITextField alloc]initWithFrame:CGRectMake(10, 90, TWScreenW-20, 30)];
    text.clearButtonMode = UITextFieldViewModeWhileEditing;
    text.backgroundColor=[UIColor whiteColor];
    text.text = self.name;
    [self.view addSubview:text];
    self.textField = text;
    
    // 3.提示信息
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 130, 200, 10)];
    label.text = @"好的昵称可以彰显个性";
    label.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:label];
    

}

- (void)storeClick{
    // 1.关闭页面
    [self.navigationController popViewControllerAnimated:YES];
    // 2.通知代理
    if ([self.delegate respondsToSelector:@selector(editViewController:didSaveName:)]) {
        // 更新模型数据
        [self.delegate editViewController:self didSaveName:self.textField.text];
    }
    // 4.请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    TWAccount *accout = [TWAccountTool account];
    params[@"key"] = accout.key;
    params[@"client"] = @"ios";
    params[@"id"] = accout.member_id;
    params[@"nickname"] = self.textField.text;
    
    // 5.发送请求
    [[AFHTTPSessionManager manager] POST:@"http://www.jixuejiyong.com/mobile/index.php?act=hg_member_sns_home&op=avatarnickname" parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
    
        if ([responseObject[@"datas"][@"result"] isEqualToString:@"success"]) {
            [SVProgressHUD showImage:nil status:@"修改成功"];
            TWAccount *accout = [TWAccountTool account];
            accout.member_nickname = self.textField.text;
            [TWAccountTool saveAccount:accout];
        }else{
            [SVProgressHUD showErrorWithStatus:@"操作失败"];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [SVProgressHUD showErrorWithStatus:@"请求失败"];
        
    }];


}


@end
