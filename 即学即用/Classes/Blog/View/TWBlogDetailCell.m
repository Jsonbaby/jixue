

#import "TWBlogDetailCell.h"
#import "TWPeopleMainViewController.h"
#import <UIImageView+WebCache.h>
#import "TWBlogDetail.h"
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
@interface TWBlogDetailCell()<UIActionSheetDelegate>


/** 图片帖子中间的内容 */


@end

@implementation TWBlogDetailCell




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
    mvc.mid = self.topic.blog_member_id;
    [self.viewController.navigationController pushViewController:mvc animated:YES];
}





- (IBAction)more {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"删除日志", nil];
    sheet.delegate = self;
    [sheet showInView:self.window];
}
#pragma UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
       
    if (buttonIndex ==0) {
        // 请求参数
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        
        TWAccount *accout = [TWAccountTool account];
        params[@"blog_id"] = self.topic.blog_id;
        params[@"key"] = accout.key;
        params[@"client"] = @"ios";
        
        [[AFHTTPSessionManager manager] POST:@"http://www.jixuejiyong.com/mobile/index.php?act=hg_member_sns_home&op=blog_delete" parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            TTLog(@"删除日志接口：%@，%@,%@",responseObject,responseObject[@"datas"],self.topic.blog_id);
            if ([responseObject[@"datas"][@"result"] isEqualToString:@"success"]) {
                [SVProgressHUD showImage:nil status:@"删除日志成功"];
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            [SVProgressHUD showImage:nil status:@"请求失败"];
        }];

    }
    
}
@end
