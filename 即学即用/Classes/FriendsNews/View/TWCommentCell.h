

#import <UIKit/UIKit.h>
@class TWComment;

@interface TWCommentCell : UITableViewCell
/** 评论 */
@property (nonatomic, strong) TWComment *comment;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIImageView *sexView;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end
