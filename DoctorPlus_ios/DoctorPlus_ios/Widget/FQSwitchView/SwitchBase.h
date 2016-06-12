//
//  SwitchBase.h
//  DocPlus_ios
//
//  Created by niko on 14/12/11.
//  Copyright (c) 2014年 FQ. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    SwitchBaseTypeDefault,
    SwitchBaseTypeChangeImage,
}SwitchBaseType;


@interface SwitchBase : UIImageView
@property (nonatomic) SwitchBaseType baseType;
@property NSString *imageL;
@property NSString *imageR;
- (id)initWithImage:(UIImage *)image baseType:(SwitchBaseType)aBaseType;
- (void)selectedLeftSwitchBase;
- (void)selectedRightSwitchBase;

@end
