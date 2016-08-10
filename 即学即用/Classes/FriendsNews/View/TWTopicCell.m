

#import "TWTopicCell.h"
#import "TWPeopleMainViewController.h"
#import <UIImageView+WebCache.h>

#import "UIView+ViewController.h"
#import <SVProgressHUD.h>
#import <AFNetworking.h>
#import "TWAccount.h"
#import "TWAccountTool.h"
#import "TWMyStatus.h"
#import "TWCommentViewController.h"
#import "UIView+ViewController.h"
#import "TWMemberInfo.h"
#import "TWZhanfaViewController.h"
#import "TWNavigationController.h"
@interface TWTopicCell()<UIAlertViewDelegate>


/** 图片帖子中间的内容 */

- (IBAction)like:(id)sender;
- (IBAction)dislike:(id)sender;
- (IBAction)zhuanfa:(id)sender;

- (IBAction)comment:(id)sender;


@end

@implementation TWTopicCell


// 0喜欢、1不喜欢
- (IBAction)like:(id)sender {
  UIButton *btn = (UIButton *)sender;
    if (![self.topic.liked isEqualToString:@"1"]) {
    
        [btn setImage:[UIImage imageNamed:@"app_heartR"] forState:UIControlStateNormal];
        if ([btn.currentTitle isEqualToString:@"不喜欢"]) {
            [btn setTitle:@"1" forState:UIControlStateNormal];
        }else{
            int i = [btn.currentTitle intValue];
            i++;
            NSString *str = [NSString stringWithFormat:@"%d",i];
            [btn setTitle:str forState:UIControlStateNormal];
        }
        // 请求参数
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        TWAccount *accout = [TWAccountTool account];
        params[@"do"] = @"like_post";
        params[@"id"] = self.topic.trace_id;
        params[@"member_id"] = self.topic.trace_memberid;
        params[@"handle"] = @"post";
        params[@"key"] = accout.key;
        params[@"client"] = @"ios";

        [[AFHTTPSessionManager manager] POST:@"http://www.jixuejiyong.com/mobile/index.php?act=hg_member_sns_home&op=api" parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

            if (responseObject[@"datas"][@"result"]) {
                self.topic.liked = [NSString stringWithFormat:@"%d",1];
            }
            [SVProgressHUD dismiss];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
           [SVProgressHUD showImage:nil status:@"请求失败"];
        }];
        

    }else{
        int i = [btn.currentTitle intValue];
        i--;
        NSString *str = [NSString stringWithFormat:@"%d",i];
        if ([str isEqualToString:@"0"]) {
            [btn setTitle:@"不喜欢" forState:UIControlStateNormal];
        }else{
            [btn setTitle:str forState:UIControlStateNormal];
        }
        [btn setImage:[UIImage imageNamed:@"app_heartG"] forState:UIControlStateNormal];
        
        
        // 请求参数
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        TWAccount *accout = [TWAccountTool account];
        params[@"do"] = @"unlike_post";
        params[@"id"] = self.topic.trace_id;
        params[@"member_id"] = self.topic.trace_memberid;
        params[@"handle"] = @"post";
        params[@"key"] = accout.key;
        params[@"client"] = @"ios";
        
        [[AFHTTPSessionManager manager] POST:@"http://www.jixuejiyong.com/mobile/index.php?act=hg_member_sns_home&op=api" parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

            if (responseObject[@"datas"][@"result"]) {
                self.topic.liked = [NSString stringWithFormat:@"%d",0];
            }
            [SVProgressHUD dismiss];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
           [SVProgressHUD showImage:nil status:@"请求失败"];
        }];
        }
}

// 删除
- (IBAction)dislike:(id)sender {
   TWAccount *accout = [TWAccountTool account];
   if([self.topic.trace_memberid  isEqualToString:accout.member_id])
   {
        // 请求参数
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
        params[@"do"] = @"delete_post";
        params[@"id"] = self.topic.trace_id;
        params[@"member_id"] = self.topic.trace_memberid;
        params[@"handle"] = @"post";
        params[@"key"] = accout.key;
        params[@"client"] = @"ios";
        
        [[AFHTTPSessionManager manager] POST:@"http://www.jixuejiyong.com/mobile/index.php?act=hg_member_sns_home&op=api" parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

            if ([responseObject[@"datas"][@"result"] isEqualToString:@"success"]) {
                [SVProgressHUD showImage:nil status:@"请求成功"];
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            [SVProgressHUD showImage:nil status:@"请求失败"];
        }];
   }else{
       [SVProgressHUD showImage:nil status:@"只能删除本人的状态哦"];
   }

}

- (IBAction)zhuanfa:(id)sender
{
   
    TWZhanfaViewController *zvc = [[TWZhanfaViewController alloc] init];
    zvc.topic = self.topic;
    
    TWNavigationController *nav = [[TWNavigationController alloc] initWithRootViewController:zvc];
    
    // 这里不能使用self来弹出其他控制器, 因为self执行了dismiss操作
    UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
    [root presentViewController:nav animated:YES completion:nil];;
}

- (IBAction)comment:(id)sender {
    TWCommentViewController *cvc = [[TWCommentViewController alloc] init];
    cvc.topic = self.topic;

    [self.viewController.navigationController pushViewController:cvc animated:YES];
}


- (void)awakeFromNib
{
    UIImageView *bgView = [[UIImageView alloc] init];
    bgView.image = [UIImage imageNamed:@"mainCellBackground"];
    self.backgroundView = bgView;
    
    self.profileImageView.userInteractionEnabled = YES;
    [self.profileImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headIconClick:)]];
    self.profileImageView.image = [UIImage imageNamed:@"bg_deal_purchaseButton_highlighted"];
    
//    self.profileImageView.layer.cornerRadius = self.profileImageView.width * 0.5;
//    self.profileImageView.layer.masksToBounds = YES;
   
    
}

- (void)headIconClick:(UITapGestureRecognizer *)tap
{
    TWPeopleMainViewController *mvc = [[TWPeopleMainViewController alloc] init];
    mvc.mid = self.topic.trace_memberid;
    [self.viewController.navigationController pushViewController:mvc animated:YES];
}





- (IBAction)more {
    TWAccount *accout = [TWAccountTool account];
    if ([self.topic.trace_memberid isEqualToString:accout.member_id]) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"收藏" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            // 请求参数
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            TWAccount *accout = [TWAccountTool account];
            params[@"key"] = accout.key;
            params[@"client"] = @"ios";
            params[@"trace_id"]=self.topic.trace_id;
            params[@"favourite_item_type"] = @1;
            [[AFHTTPSessionManager manager] POST:@"http://www.jixuejiyong.com/mobile/index.php?act=hg_member_sns_home&op=favoritesFn" parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [SVProgressHUD showImage:nil status:@"收藏成功"];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
                [SVProgressHUD showErrorWithStatus:@"请求错误"];
            }];
            
        }]];
         [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [self.viewController presentViewController:alert animated:YES completion:nil];
        
    }else{

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"收藏" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            // 请求参数
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            TWAccount *accout = [TWAccountTool account];
            params[@"key"] = accout.key;
            params[@"client"] = @"ios";
            params[@"trace_id"]=self.topic.trace_id;
            params[@"favourite_item_type"] = @1;
            [[AFHTTPSessionManager manager] POST:@"http://www.jixuejiyong.com/mobile/index.php?act=hg_member_sns_home&op=favoritesFn" parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [SVProgressHUD showImage:nil status:@"收藏成功"];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
                [SVProgressHUD showErrorWithStatus:@"请求错误"];
            }];
            
        }]];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"取消关注" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            // 请求参数
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            TWAccount *accout = [TWAccountTool account];
            
            params[@"key"] = accout.key;
            params[@"client"] = @"ios";
            params[@"mid"] = self.topic.trace_memberid;
            
            [[AFHTTPSessionManager manager] POST:@"http://www.jixuejiyong.com/mobile/index.php?act=hg_member_sns_home&op=cancelfollow" parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                
                [SVProgressHUD showImage:nil status:@"取消关注成功"];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
                [SVProgressHUD showImage:nil status:@"请求失败"];
            }];

        }]];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"举报" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            UIAlertView * alerView = [[UIAlertView alloc]initWithTitle:@"举报内容" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"发送",nil];
            
            alerView.alertViewStyle = UIAlertViewStylePlainTextInput;
            
            alerView.delegate = self;
            
            UITextField * newGroup = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, 100, 20)];
            
            newGroup.tag = 1001;
            
            [alerView addSubview:newGroup];
            
            [alerView show];

        }]];
        
//        [alert addAction:[UIAlertAction actionWithTitle:@"加入黑名单" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//            
//            // 请求参数
//            NSMutableDictionary *params = [NSMutableDictionary dictionary];
//            TWAccount *accout = [TWAccountTool account];
//            
//            params[@"key"] = accout.key;
//            params[@"client"] = @"ios";
//            params[@"id"] = self.topic.trace_memberid;
//            
//            [[AFHTTPSessionManager manager] POST:@"http://www.jixuejiyong.com/mobile/index.php?act=hg_member_sns_home&op=addblack" parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//                
//                [SVProgressHUD showImage:nil status:@"加入黑名单成功"];
//            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//                
//                [SVProgressHUD showImage:nil status:@"请求失败"];
//            }];
//            
//        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [self.viewController presentViewController:alert animated:YES completion:nil];
    }
    
}

#pragma mark UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex

{
    
    if (buttonIndex == 0)
    {
        
       
        
    }else if (buttonIndex == 1)
        
    {
        
        [SVProgressHUD showImage:nil status:@"举报成功"];
        
    }
    
}
@end
