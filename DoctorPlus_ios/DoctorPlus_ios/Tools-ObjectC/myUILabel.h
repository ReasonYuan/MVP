//
//  myUILabel.h
//  DoctorPlus_ios
//
//  Created by sunning on 15/12/21.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum
{
    VerticalAlignmentTop = 0, // default
    VerticalAlignmentMiddle,
    VerticalAlignmentBottom,
} VerticalAlignment;
@interface myUILabel : UILabel
{
@private
    VerticalAlignment _verticalAlignment;
}

@property (nonatomic) VerticalAlignment verticalAlignment;

@end