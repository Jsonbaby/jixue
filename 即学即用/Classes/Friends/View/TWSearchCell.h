

#import <UIKit/UIKit.h>
@class TWRecommendUser,TWSearch;

@interface TWSearchCell : UITableViewCell
/** 用户模型 */
@property (nonatomic, strong) TWRecommendUser *user;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *fansCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *guanzhuBtn;


@property (nonatomic, strong) TWSearch *peopleSearch;

@property (nonatomic, assign) NSInteger indexRow;
@end
