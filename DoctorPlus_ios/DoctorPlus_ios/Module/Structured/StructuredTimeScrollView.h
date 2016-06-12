//
//  StructuredTimeScrollView.h
//  DoctorPlus_ios
//
//  Created by 廖敏 on 15/7/24.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "java/util/arraylist.h"
#import "JSONObject.h"
#import "JSONArray.h"

@interface  StructuredTitleView : UIView

@end

@interface  StructuredTitleItemView : UIView

@end

@interface  StructuredTimeItemView : UIView

@end

@interface StructuredTimeScrollView : UIScrollView

@property (nonatomic,weak) FQJSONArray* data;

@end
