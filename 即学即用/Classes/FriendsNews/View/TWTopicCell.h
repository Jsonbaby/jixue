
#import <UIKit/UIKit.h>
#import "IWPhotosView.h"
#import <TYAttributedLabel.h>
@class TWMyStatus;
@interface TWTopicCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *bottomTool;
@property (weak, nonatomic) IBOutlet TYAttributedLabel *tyLabel;
@property (weak, nonatomic) IBOutlet UIWebView *webview;

/** 帖子数据 */

@property (nonatomic, strong) TWMyStatus *topic;
/** 头像 */
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
/** 昵称 */
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
/** 时间 */
@property (weak, nonatomic) IBOutlet UILabel *createTimeLabel;
/** 顶 */
@property (weak, nonatomic) IBOutlet UIButton *dingButton;
/** 踩 */
@property (weak, nonatomic) IBOutlet UIButton *caiButton;
/** 分享 */
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
/** 评论 */
@property (weak, nonatomic) IBOutlet UIButton *commentButton;

/** 帖子的文字内容 */
@property (weak, nonatomic) IBOutlet UILabel *text_label;

@property (weak, nonatomic) IBOutlet IWPhotosView *photoView;
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;

@end
