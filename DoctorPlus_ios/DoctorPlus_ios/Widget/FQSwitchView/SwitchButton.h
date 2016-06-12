

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum{
   SwitchButtonTypeDefault,
    SwitchButtonTypeChangeImage,
}SwitchButtonType;

@interface SwitchButton : UIImageView

@property (nonatomic) SwitchButtonType buttonType;
@property NSString *imageL;
@property NSString *imageR;
- (id)initWithImage:(UIImage *)image buttonType:(SwitchButtonType)aButtonType;
- (void)selectedLeftSwitchButton;
- (void)selectedRightSwitchButton;

@end
