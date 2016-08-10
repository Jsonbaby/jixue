

#import "TWLoginRegisterViewController.h"
#import "TWTabBarController.h"
#import <AFNetworking.h>
#import "XMGTextField.h"
#import "TWAccountTool.h"
#import "TWAccount.h"
#import <MJExtension.h>
#import <SVProgressHUD.h>
#import "TWVerifyViewController.h"
#import "TWNavigationController.h"
#import "TWProtocolViewController.h"
@interface TWLoginRegisterViewController ()
/** 登录框距离控制器view左边的间距 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginViewLeftMargin;
@property (weak, nonatomic) IBOutlet XMGTextField *username;
@property (weak, nonatomic) IBOutlet XMGTextField *pwd;
- (IBAction)registerClick:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet XMGTextField *phoneNumber;
@property (weak, nonatomic) IBOutlet XMGTextField *registerPwd;

- (IBAction)protocolClick;

@end

@implementation TWLoginRegisterViewController
- (void)viewDidLoad{
    [super viewDidLoad];
    [self cheakNetworkStatus];
   
}
- (void)cheakNetworkStatus{
    // 1.获得网络监控的管理者
    AFNetworkReachabilityManager *mgr = [AFNetworkReachabilityManager sharedManager];
    
    // 2.设置网络状态改变后的处理
    [mgr setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        // 当网络状态改变了, 就会调用这个block
        switch (status) {
            case AFNetworkReachabilityStatusUnknown: // 未知网络
                break;
                
            case AFNetworkReachabilityStatusNotReachable: // 没有网络(断网)
                [SVProgressHUD showImage:nil status:@"请连接网络"];
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN: // 手机自带网络
                break;
                
            case AFNetworkReachabilityStatusReachableViaWiFi: // WIFI
                break;
        }
    }];
    
    // 3.开始监控
    [mgr startMonitoring];
}

- (IBAction)loginClick:(id)sender {
     [self.view endEditing:YES];
    [SVProgressHUD show];
    // 请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"username"] = self.username.text;
    params[@"password"] = self.pwd.text;
    params[@"client"] = @"ios";
    
        [[AFHTTPSessionManager manager] POST:@"http://www.jixuejiyong.com/mobile/index.php?act=hg_member_sns_home&op=login" parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            TTLog(@"登录功能：%@",responseObject);
            TWAccount *accout = [TWAccount mj_objectWithKeyValues:responseObject[@"datas"]];
            
            if (accout.key) {
                // 保存账号信息
                [TWAccountTool saveAccount:accout];
                // 进入app主页
                [UIApplication sharedApplication].keyWindow.rootViewController = [[TWTabBarController alloc] init];
                
            }else{
                [SVProgressHUD showImage:nil status:@"登录失败"];
            }
            
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [SVProgressHUD showImage:nil status:@"登录失败"];
            
        }];
    
    
}

- (IBAction)back {
   
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (IBAction)showLoginOrRegister:(UIButton *)button {
    // 退出键盘
    [self.view endEditing:YES];
    
    if (self.loginViewLeftMargin.constant == 0) { // 显示注册界面
        self.loginViewLeftMargin.constant = - self.view.width;
        button.selected = YES;
    } else { // 显示登录界面
        self.loginViewLeftMargin.constant = 0;
        button.selected = NO;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
}
- (IBAction)registerClick:(UIButton *)sender {
    
    if ((self.phoneNumber.text.length != 0)&&(self.registerPwd.text.length != 0))
    {
            TWVerifyViewController *vertify = [[TWVerifyViewController alloc] init];
            vertify.phone = self.phoneNumber.text;
            vertify.pwd = self.registerPwd.text;
            TWNavigationController *nav = [[TWNavigationController alloc]initWithRootViewController:vertify];
            [self presentViewController:nav animated:YES completion:nil];
        
    }else{
        [SVProgressHUD showImage:nil status:@"请输入手机号或密码"];
        
    }
}
- (IBAction)protocolClick {
    TWProtocolViewController *pvc = [[TWProtocolViewController alloc] init];
    TWNavigationController *nav = [[TWNavigationController alloc]initWithRootViewController:pvc];
    [self presentViewController:nav animated:YES completion:nil];
}
@end
