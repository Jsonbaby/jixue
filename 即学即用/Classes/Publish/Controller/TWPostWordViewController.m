//
//  TWPostWordViewController.m
//  即学即用
//
//  Created by Apple on 16/4/5.
//  Copyright © 2016年 8lei. All rights reserved.
//

#import "TWPostWordViewController.h"
#import "TWPlaceholderTextView.h"
#import "IWComposeToolbar.h"
#import <AFNetworking.h>
#import "TWAccount.h"
#import "TWAccountTool.h"
#import <SVProgressHUD.h>
#import "ImageTool.h"
#import "UIImage+ZLPhotoLib.h"
#import "ZLPhoto.h"
#import "UIButton+WebCache.h"

@interface TWPostWordViewController () <UITextViewDelegate,IWComposeToolbarDelegate, ZLPhotoPickerBrowserViewControllerDelegate>
/** 文本输入控件 */
@property (nonatomic, weak) TWPlaceholderTextView *textView;
@property (nonatomic, weak) IWComposeToolbar *toolbar;

@property (nonatomic , strong) NSMutableArray *assets;
@property (weak,nonatomic) UIScrollView *scrollView;
@property (nonatomic , strong) NSMutableArray *pictureArray;
@property (nonatomic , weak) UISwitch *sw;
@property (nonatomic, strong) NSData *picdata;

@end

@implementation TWPostWordViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNav];
    
    [self setupTextView];
    
    // 添加toolbar
//    [self setupToolbar];
    
    // 九宫格创建ScrollView
    [self reloadScrollView];
    
   
}
- (void)setupNav
{
    self.title = @"说说";
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
    if (self.assets.count > 0) {
//        NSMutableArray *imageUrlArray = [[NSMutableArray alloc]init];
        [SVProgressHUD showImage:nil status:@"正在发送..."];
        for (int i = 0; i<self.assets.count; i++) {
            if ([[self.assets objectAtIndex:i] isKindOfClass:[ZLPhotoAssets class]]) {
                UIImage *image =  [self.assets[i] originImage];
                CGSize psize = CGSizeMake(image.size.width*0.3 , image.size.height*0.3);
                self.picdata = UIImagePNGRepresentation([ImageTool image:image byScalingToSize:psize]);
            }else if ([[self.assets objectAtIndex:i] isKindOfClass:[ZLCamera class]]){
                UIImage *image =  [self.assets[i] thumbImage];
                CGSize psize = CGSizeMake(image.size.width , image.size.height);
                self.picdata = UIImagePNGRepresentation([ImageTool image:image byScalingToSize:psize]);
            }
           
            
            NSMutableDictionary *params1 = [NSMutableDictionary dictionary];
            
            // 上传图片
            TWAccount *accout = [TWAccountTool account];
            params1[@"key"] = accout.key;
            params1[@"client"] = @"ios";
            // 上传头像
            [[AFHTTPSessionManager manager] POST:@"http://www.jixuejiyong.com/mobile/index.php?act=hg_member_sns_home&op=image_upload" parameters:params1 constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                
                NSString *filename = [NSString stringWithFormat:@"publish%d.png",i];
                [formData appendPartWithFileData:self.picdata name:@"file" fileName:filename mimeType:@"image/png"];
                
                
            } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                TTLog(@"上传说说图片：%@",responseObject);
                [self.pictureArray addObjectsFromArray:responseObject[@"datas"][@"file"]];
                if (self.pictureArray.count == self.assets.count) {
                    
                    // 请求参数
                    NSMutableDictionary *params = [NSMutableDictionary dictionary];
                    TWAccount *accout = [TWAccountTool account];
                    
                    params[@"content"] = self.textView.text;
                    params[@"privacy"] = @(2);
                    params[@"key"] = accout.key;
                    params[@"client"] = @"ios";
                    params[@"photos"] = self.pictureArray;
                    TTLog(@"%@",params);
                    [[AFHTTPSessionManager manager] POST:@"http://www.jixuejiyong.com/mobile/index.php?act=hg_member_sns_home&op=addtrace" parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                        TTLog(@"发表说说图片：%@",responseObject);
                        if ([responseObject[@"datas"][@"result"] isEqualToString:@"success"]) {
                            [self cancel];
                            [SVProgressHUD showImage:nil status:@"发表成功！"];
                        }
                        
                       
                    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                        
                        [SVProgressHUD showErrorWithStatus:@"请求错误"];
                    }];

                }
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [SVProgressHUD showErrorWithStatus:@"请求错误"];
            }];

        }
    }
    else{
        // 请求参数
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        TWAccount *accout = [TWAccountTool account];
        
        params[@"content"] = self.textView.text;
        params[@"privacy"] =  @(self.sw.isOn ? 0 : 2);
        params[@"key"] = accout.key;
        params[@"client"] = @"ios";
//        TWLog(@"%@",self.textView.text);
        
        [[AFHTTPSessionManager manager] POST:@"http://www.jixuejiyong.com/mobile/index.php?act=hg_member_sns_home&op=addtrace" parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//            TWLog(@"发表说说图片：%@",responseObject);
            if ([responseObject[@"datas"][@"result"] isEqualToString:@"success"]) {
                [self cancel];
                [SVProgressHUD showImage:nil status:@"发表成功！"];
            }
            
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            [SVProgressHUD showErrorWithStatus:@"请求错误"];
        }];
        

    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.textView becomeFirstResponder];
}

#pragma mark - <UITextViewDelegate>
- (void)textViewDidChange:(UITextView *)textView
{
    self.navigationItem.rightBarButtonItem.enabled = textView.hasText || self.assets.count!=0;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}


/**
 *  添加toolbar
 */
- (void)setupToolbar
{
    IWComposeToolbar *toolbar = [[IWComposeToolbar alloc] init];
    toolbar.delegate = self;
    CGFloat toolbarH = 44;
    CGFloat toolbarW = self.view.frame.size.width;
    CGFloat toolbarX = 0;
    CGFloat toolbarY = self.view.frame.size.height - toolbarH;
    toolbar.frame = CGRectMake(toolbarX, toolbarY, toolbarW, toolbarH);
    [self.view addSubview:toolbar];
    self.toolbar = toolbar;
}

#pragma mark - toolbar的代理方法
- (void)composeToolbar:(IWComposeToolbar *)toolbar didClickedButton:(IWComposeToolbarButtonType)buttonType
{
    switch (buttonType) {
        case IWComposeToolbarButtonTypeCamera: // 相机
            [self openCamera];
            break;
            
        case IWComposeToolbarButtonTypePicture: // 相册
            [self openPhotoLibrary];
            break;
            
        default:
            break;
    }
}

/**
 *  打开相机
 */
- (void)openCamera
{
    
}

/**
 *  打开相册
 */
- (void)openPhotoLibrary
{
    [self photoSelectet];
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
    textView.placeholder = @"创业多年，用日记的方式记录创业点点滴滴，这些文字写给自己，也写给正在创业路上的你，予人玫瑰，手留余香。";
    [self.view addSubview:textView];
    self.textView = textView;
    
    // 2.监听textView文字改变的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange) name:UITextViewTextDidChangeNotification object:textView];
    
    // 3.监听键盘的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

/**
 *  键盘即将显示的时候调用
 */
- (void)keyboardWillShow:(NSNotification *)note
{
    // 1.取出键盘的frame
    CGRect keyboardF = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    // 2.取出键盘弹出的时间
    CGFloat duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    // 3.执行动画
    [UIView animateWithDuration:duration animations:^{
        self.toolbar.transform = CGAffineTransformMakeTranslation(0, -keyboardF.size.height);
    }];
}

/**
 *  键盘即将退出的时候调用
 */
- (void)keyboardWillHide:(NSNotification *)note
{
    // 1.取出键盘弹出的时间
    CGFloat duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    // 2.执行动画
    [UIView animateWithDuration:duration animations:^{
        self.toolbar.transform = CGAffineTransformIdentity;
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}



/**
 *  监听文字改变
 */
- (void)textDidChange
{
    self.navigationItem.rightBarButtonItem.enabled = (self.textView.text.length != 0 || self.assets.count!=0);
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 图片选择
- (NSMutableArray *)assets{
    if (!_assets) {
        _assets = [NSMutableArray array];
    }
    return _assets;
}
- (NSMutableArray *)pictureArray{
    if (!_pictureArray) {
        _pictureArray = [NSMutableArray array];
    }
    return _pictureArray;
}

- (UIScrollView *)scrollView{
    if (!_scrollView) {
        UIScrollView *scrollView = [[UIScrollView alloc] init];
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.frame = CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.height - 100);
        scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.textView addSubview:_scrollView = scrollView];
    }
    return _scrollView;
}
- (void)reloadScrollView{
    // 先移除，后添加
    [[self.scrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    NSUInteger column = 4;
    // 加一是为了有个添加button
    NSUInteger assetCount = self.assets.count + 1;
    CGFloat width = self.view.frame.size.width / column;
    
    for (NSInteger i = 0; i < assetCount; i++) {
        
        NSInteger row = i / column;
        NSInteger col = i % column;
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.imageView.contentMode = UIViewContentModeScaleAspectFill;
        btn.frame = CGRectMake(width * col, 40 + row * width, width, width);
        
        // UIButton
        if (i == self.assets.count){
            // 最后一个Button
            [btn setImage:[UIImage ml_imageFromBundleNamed:@"iconfont-tianjia"] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(photoSelectet) forControlEvents:UIControlEventTouchUpInside];
        }else{
            [self textDidChange];
            // 如果是本地ZLPhotoAssets就从本地取，否则从网络取
            if ([[self.assets objectAtIndex:i] isKindOfClass:[ZLPhotoAssets class]]) {
                [btn setImage:[self.assets[i] originImage] forState:UIControlStateNormal];
            }else if ([[self.assets objectAtIndex:i] isKindOfClass:[ZLCamera class]]){
                [btn setImage:[self.assets[i] thumbImage] forState:UIControlStateNormal];
            }else if ([[self.assets objectAtIndex:i] isKindOfClass:[NSString class]]){
                [btn sd_setImageWithURL:[NSURL URLWithString:self.assets[i]] forState:UIControlStateNormal];
            }
            btn.tag = i;
        }
        
        [self.scrollView addSubview:btn];
    }
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, CGRectGetMaxY([[self.scrollView.subviews lastObject] frame]));
}

#pragma mark - 选择图片
- (void)photoSelectet{
    ZLPhotoPickerViewController *pickerVc = [[ZLPhotoPickerViewController alloc] init];
    // MaxCount, Default = 9
    pickerVc.maxCount = 9;
    // Jump AssetsVc
    pickerVc.status = PickerViewShowStatusCameraRoll;
    // Filter: PickerPhotoStatusAllVideoAndPhotos, PickerPhotoStatusVideos, PickerPhotoStatusPhotos.
    pickerVc.photoStatus = PickerPhotoStatusPhotos;
    // Recoder Select Assets
    pickerVc.selectPickers = self.assets;
    // Desc Show Photos, And Suppor Camera
    pickerVc.topShowPhotoPicker = YES;
    pickerVc.isShowCamera = YES;
    // CallBack
    pickerVc.callBack = ^(NSArray<ZLPhotoAssets *> *status){
        self.assets = status.mutableCopy;
        [self reloadScrollView];
    };
    [pickerVc showPickerVc:self];
}



@end
