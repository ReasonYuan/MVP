//
//  FQSwitchView.h
//  DocPlus_ios
//
//  Created by niko on 14/12/11.
//  Copyright (c) 2014年 FQ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "SwitchBase.h"
#import "SwitchButton.h"

@protocol FQSwitchViewDelegate;

typedef enum{
    FQSwitchViewTypeWithLabel,
    FQSwitchViewTypeNoLabel,
}FQSwitchViewType;

typedef enum{
    SwitchButtonSelectedLeft,
   SwitchButtonSelectedRight,
}SwitchButtonSelected;

@interface FQSwitchView : UIView <UIGestureRecognizerDelegate>
{
    id<FQSwitchViewDelegate> _swicthDelegate;
    
    float _leftEdge;
    float _rightEdge;
    
    SwitchButton *_switchButton;
    SwitchBase *_switchBase;
    UIView *_baseView;
    UIButton *_leftButton;
    UIButton *_rightButton;
    
    
}
@property (nonatomic, assign) id<FQSwitchViewDelegate> switchDelegate;
@property (nonatomic) FQSwitchViewType viewType;
@property (nonatomic) SwitchButtonSelected selectedButton;


- (id)initWithFrame:(CGRect)frame
     switchViewType:(FQSwitchViewType)viewType
     switchBaseType:(SwitchBaseType)baseType
   switchButtonType:(SwitchButtonType)buttonType
         baseImageL:(NSString*)imagel
         baseImageR:(NSString*)imageR
          btnImageL:(NSString*)btnImageL
          btnImageR:(NSString*)btnImageR;
- (void)setSelectedButton:(SwitchButtonSelected)selectedButton;

@end

@protocol FQSwitchViewDelegate <NSObject>
- (void)selectLeftButton;
- (void)selectRightButton;


@end
