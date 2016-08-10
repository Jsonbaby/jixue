

#import <UIKit/UIKit.h>
@class TWRecommendUser,TWAddPeople;

@interface TWRecommendUserCell : UITableViewCell
/** 用户模型 */
@property (nonatomic, strong) TWRecommendUser *user;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *fansCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *guanzhuBtn;

@property (nonatomic, strong) TWAddPeople *peopleInfo;


@property (nonatomic, assign) NSInteger indexRow;
@end
