

#import "TWRecommendUserCell.h"

#import <UIImageView+WebCache.h>
#import <AFNetworking.h>
#import "TWAccount.h"
#import "TWAccountTool.h"
#import <SVProgressHUD.h>
#import "TWAddPeople.h"
#import "TWSearch.h"
@interface TWRecommendUserCell()


- (IBAction)guanzhuClick:(UIButton *)sender;
@end

@implementation TWRecommendUserCell

- (void)setUser:(TWRecommendUser *)user
{
    _user = user;
   
}



- (IBAction)guanzhuClick:(UIButton *)sender {
    
  
    if (self.peopleInfo.state) {//  取消关注
//        [sender setTitle:@"+ 关注" forState:UIControlStateNormal];
//        // 请求参数
//        NSMutableDictionary *params = [NSMutableDictionary dictionary];
//        TWAccount *accout = [TWAccountTool account];
//        
//        params[@"key"] = accout.key;
//        params[@"client"] = @"ios";
//        params[@"mid"] = @(sender.tag);
//        
//        [[AFHTTPSessionManager manager] POST:@"http://www.jixuejiyong.com/mobile/index.php?act=hg_member_sns_home&op=cancelfollow" parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//            TTLog(@"取消关注数据：%@",responseObject);
//            
//            [SVProgressHUD showImage:nil status:@"取消关注成功"];
//        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//            //                                        TWLog(@"失败数据：%@",error);
//            [SVProgressHUD showImage:nil status:@"请求失败"];
//        }];

    }else{// 添加关注
        // 请求参数
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        TWAccount *accout = [TWAccountTool account];
        
        params[@"key"] = accout.key;
        params[@"client"] = @"ios";
        params[@"mid"] = @(sender.tag);
        [[AFHTTPSessionManager manager] POST:@"http://www.jixuejiyong.com/mobile/index.php?act=hg_member_sns_home&op=addfollow" parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
                NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@(self.indexRow),@"changeRow", nil];
                //创建通知
                NSNotification *notification =[NSNotification notificationWithName:@"guanzhu" object:nil userInfo:dict];
                //通过通知中心发送通知
                [[NSNotificationCenter defaultCenter] postNotification:notification];
            
          
            
            [sender setTitle:@"已关注" forState:UIControlStateNormal];
            
            [SVProgressHUD showImage:nil status:@"关注成功"];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    
           [SVProgressHUD showImage:nil status:@"请求失败"];
        }];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
