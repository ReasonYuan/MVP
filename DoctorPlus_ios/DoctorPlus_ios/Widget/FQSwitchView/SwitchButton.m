//
//  SwitchButton.m
//  DocPlus_ios
//
//  Created by niko on 14/12/11.
//  Copyright (c) 2014年 FQ. All rights reserved.
//

#import "SwitchButton.h"

@implementation SwitchButton
//change button image option
//NSString *const SWITCH_BUTTON_IMAGE_L    = @"";
//NSString *const SWITCH_BUTTON_IMAGE_R    = @"";

@synthesize buttonType;
@synthesize imageL;
@synthesize imageR;

- (id)initWithImage:(UIImage *)image buttonType:(SwitchButtonType)aButtonType
{
    self = [super initWithImage:image];
    if (self) {
        self.buttonType = aButtonType;
        if (self.buttonType == SwitchButtonTypeChangeImage)
        {
            //default select "L"
            self.image = [UIImage imageNamed:imageL];
            return self;
        }
    }
    return self;
}

- (void)selectedLeftSwitchButton
{
    if (self.buttonType == SwitchButtonTypeChangeImage)
    {
        self.image = [UIImage imageNamed:imageL];
    }
}

- (void)selectedRightSwitchButton
{
    if (self.buttonType == SwitchButtonTypeChangeImage)
    {
        self.image = [UIImage imageNamed:imageR];
        
    }
}


@end
