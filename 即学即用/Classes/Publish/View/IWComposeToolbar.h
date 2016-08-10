

#import <UIKit/UIKit.h>

@class IWComposeToolbar;

typedef enum {
    IWComposeToolbarButtonTypeCamera,
    IWComposeToolbarButtonTypePicture,
    IWComposeToolbarButtonTypeMention,
    IWComposeToolbarButtonTypeTrend,
    IWComposeToolbarButtonTypeEmotion
} IWComposeToolbarButtonType;

@protocol IWComposeToolbarDelegate <NSObject>
@optional
- (void)composeToolbar:(IWComposeToolbar *)toolbar didClickedButton:(IWComposeToolbarButtonType)buttonType;
@end

@interface IWComposeToolbar : UIView
@property (weak, nonatomic) id<IWComposeToolbarDelegate> delegate;
@end
