//
//  TWSettingViewController.m
//  即学即用
//
//  Created by Apple on 16/4/7.
//  Copyright © 2016年 8lei. All rights reserved.
//

#import "TWSettingViewController.h"
#import "TWEditViewController.h"
#import "TWAccount.h"
#import "TWAccountTool.h"
#import <AFNetworking.h>
#import <SVProgressHUD.h>
#import "ImageTool.h"
#import "TWLoginRegisterViewController.h"
#import "TWContactViewController.h"
@interface TWSettingViewController ()<TWEditViewControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>
@property (nonatomic, weak) UIImageView *imgView;
@end

@implementation TWSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 设置导航栏
    self.navigationItem.title = @"设置";
    
}

#pragma mark -- UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==0)
    {
        return 60;
    }
    
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *ID = @"setup";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
        if(indexPath.row==0){
            // 头像图标
            UIImageView *imageview=[[UIImageView alloc]initWithFrame:CGRectMake(TWScreenW-80, 10, 40, 40)];
            imageview.layer.masksToBounds=YES;
            imageview.layer.cornerRadius=20;
            
            // 从沙盒中取出图片并设置图片
            NSString *patch = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
            NSData *data = [[NSData alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",patch,@"icon.png"]];
            UIImage *image = [[UIImage alloc] initWithData:data];
            imageview.image=image;
            self.imgView = imageview;
            [cell.contentView addSubview:imageview];
            cell.textLabel.text=@"头像";
            // 设置指示箭头
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
                
            }else {
                
                NSArray *array = @[@"头像",@"昵称",@"清除缓存",@"切换账号",@"联系我们"];
                cell.textLabel.text=array[indexPath.row];
                if (indexPath.row == 1) {
                   // 从沙盒中读取昵称
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    cell.detailTextLabel.text = [defaults objectForKey:@"name"];
                    if (cell.detailTextLabel.text.length == 0) {
                        TWAccount *accout = [TWAccountTool account];
                        cell.detailTextLabel.text = accout.member_nickname;
                    }
                    // 设置指示箭头
                    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
                }
                if (indexPath.row == 2) {
                    NSFileManager *mgr = [NSFileManager defaultManager];
                    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
                    
                     //计算缓存文件夹的大小
                    NSArray *subpaths = [mgr subpathsAtPath:cachePath];
                    long long totalSize = 0;
                    for (NSString *subpath in subpaths) {
                        NSString *fullpath = [cachePath stringByAppendingPathComponent:subpath];
                        BOOL dir = NO;
                        [mgr fileExistsAtPath:fullpath isDirectory:&dir];
                        if (dir == NO) {// 文件
                            totalSize += [[mgr attributesOfItemAtPath:fullpath error:nil][NSFileSize] longLongValue];
                        }
                    }
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%lld MB",totalSize/1024/1024];

                }
                if (indexPath.row == 4) {
                                        // 设置指示箭头
                    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
                }
                
            }
        
        
       
        
    }
    return cell;
}

#pragma mark -- UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.section==0){
        if(indexPath.row==0){
            
            UIActionSheet *actionSheet=[[UIActionSheet alloc]initWithTitle:@"选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"相机",@"相册",nil];
            [actionSheet showInView:self.tableView];
        }
        if(indexPath.row==1){
            TWEditViewController *evc = [[TWEditViewController alloc]init];
            evc.delegate = self;
            // 从沙盒中读取昵称
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            evc.name = [defaults objectForKey:@"name"];
            if (evc.name.length == 0) {
                TWAccount *accout = [TWAccountTool account];
                evc.name = accout.member_nickname;
            }

         
            [self.navigationController pushViewController:evc animated:YES];
        }
        if(indexPath.row==2){
           
            // 执行清除缓存
            NSFileManager *mgr = [NSFileManager defaultManager];
            NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
            [mgr removeItemAtPath:cachePath error:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [SVProgressHUD showImage:nil status:@"清理完毕"];
            });
            
        }
        if (indexPath.row == 3) {
            TWLoginRegisterViewController *lvc = [[TWLoginRegisterViewController alloc] init];
            [self presentViewController:lvc animated:YES completion:nil];

        
        }
        if (indexPath.row == 4) {
            TWContactViewController *cvc = [[TWContactViewController alloc] init];
            [self.navigationController pushViewController:cvc animated:YES];
            
            
        }

        
    }
}

#pragma mark -- UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==0){
        // 图片选择控制器
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = YES;
        imagePickerController.sourceType =UIImagePickerControllerSourceTypeCamera;
        
        [self.navigationController presentViewController:imagePickerController animated:YES completion:nil];
        
    }else if(buttonIndex==1){
        
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = YES;
        imagePickerController.sourceType =UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        
        [self.navigationController presentViewController:imagePickerController animated:YES completion:nil];
    }
}





#pragma mark -- TWEditViewControllerDelegate
- (void)editViewController:(TWEditViewController *)editVc didSaveName:(NSString *)name{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:name forKey:@"name"];
    [defaults synchronize];
    
    // 刷新某一行
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:1 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
    
}

#pragma mark -- UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    
    // 获取选中的图片
    UIImage *image = info[@"UIImagePickerControllerEditedImage"];
    // 对图片做裁剪
    self.imgView.image = [ImageTool image:image byScalingToSize:CGSizeMake(120, 120)];
    // 对裁剪过的图片做本地化存储
    NSString *patch = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSData *imageData = UIImagePNGRepresentation(self.imgView.image);
    [imageData writeToFile:[NSString stringWithFormat:@"%@/%@",patch,@"icon.png"] atomically:YES];

    // 请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    TWAccount *accout = [TWAccountTool account];
    params[@"key"] = accout.key;
    params[@"client"] = @"ios";
    
    // 上传头像
    [[AFHTTPSessionManager manager] POST:@"http://www.jixuejiyong.com/mobile/index.php?act=hg_member_sns_home&op=changeAvatarHandle" parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [formData appendPartWithFileData:imageData name:@"file" fileName:@"icon.png" mimeType:@"image/png"];
        
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        TWAccount *accout = [TWAccountTool account];
        accout.member_avatar = responseObject[@"datas"][@"result"][@"src"];
        [TWAccountTool saveAccount:accout];
        TTLog(@"哈哈%@",responseObject[@"datas"][@"result"][@"src"]);
        if ([responseObject[@"datas"][@"src"] isEqualToString:@""]) {
            [SVProgressHUD showErrorWithStatus:@"操作失败"];
        }else{
            // 请求参数
            NSMutableDictionary *params1 = [NSMutableDictionary dictionary];
            params1[@"key"] = accout.key;
            params1[@"client"] = @"ios";
            params1[@"id"] = accout.member_id;
            params1[@"src"] = responseObject[@"datas"][@"result"][@"src"];
            // 修改头像
            [[AFHTTPSessionManager manager] POST:@"http://www.jixuejiyong.com/mobile/index.php?act=hg_member_sns_home&op=avatarheader" parameters:params1 progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                if ([responseObject[@"datas"][@"result"] isEqualToString:@"success"]) {
                    [SVProgressHUD showImage:nil status:@"修改成功"];
                }else{
                    [SVProgressHUD showErrorWithStatus:@"操作失败"];
                }
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [SVProgressHUD showErrorWithStatus:@"请求错误"];
            }];

            
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         [SVProgressHUD showErrorWithStatus:@"请求错误"];
    }];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
