//
//  SwitchBase.m
//  DocPlus_ios
//
//  Created by niko on 14/12/11.
//  Copyright (c) 2014年 FQ. All rights reserved.
//

#import "SwitchBase.h"
//NSString *const SWITCH_BASE_IMAGE_L   = @"wifi_btn_unchecked.png";
//NSString *const SWITCH_BASE_IMAGE_R   = @"wifi_btn_checked.png";



@implementation SwitchBase
@synthesize baseType;
@synthesize imageL;
@synthesize imageR;

- (id)initWithImage:(UIImage *)image baseType:(SwitchBaseType)aBaseType
{
    self = [super initWithImage:image];
    if (self) {
        
        self.baseType = aBaseType;
        if (self.baseType == SwitchBaseTypeChangeImage)
        {
            //default select "L"
            self.image = [UIImage imageNamed:imageL];
            return self;
        }
    }
    return self;
}

- (void)selectedLeftSwitchBase
{
    if (self.baseType == SwitchBaseTypeChangeImage) {
        self.image = [UIImage imageNamed:imageL];
    }
}

- (void)selectedRightSwitchBase
{
    if (self.baseType == SwitchBaseTypeChangeImage) {
        self.image = [UIImage imageNamed:imageR];
    }
}


@end
