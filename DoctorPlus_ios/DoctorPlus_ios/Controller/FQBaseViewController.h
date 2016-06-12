//
//  FQBaseNavigationViewController.h
//  DoctorPlus_ios
//
//  Created by 廖敏 on 15/7/16.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FQBaseViewController : UIViewController

-(void)hiddenTittle:(BOOL)hide;

-(void)setRightBtnTittle:(NSString*)str;

-(void)setLeftTitle:(NSString*)str;

-(void)hiddenLeftImage:(BOOL)hide;

-(void)hiddenRightImage:(BOOL)hide;

-(void)setLeftImage:(BOOL)hide image:(UIImage*)image;

-(void)setRightImage:(BOOL)hide image:(UIImage*)image;

-(NSString*)getXibName;

-(void)onLeftBtnOnClick:(UIButton*)sender;

-(void)onRightBtnOnClick:(UIButton*)sender;

-(void)setBigRightButtonHiden:(BOOL)hide;

+(void)addChildViewFullInParent:(UIView*)child parent:(UIView*)parent;


@property (weak, nonatomic) IBOutlet UIButton *centerButton;
@property (weak, nonatomic) IBOutlet UIImageView *leftImage;
@property (weak, nonatomic) IBOutlet UIImageView *rightImage;
@property (weak, nonatomic) IBOutlet UILabel *leftText;
@property (weak, nonatomic) IBOutlet UIButton *leftBtn;
@property (weak, nonatomic) IBOutlet UIButton *rightBtn;
@property (weak, nonatomic) IBOutlet UIButton *bigLeftBtn;
@property (weak, nonatomic) IBOutlet UIButton *bigRightBtn;
@property (weak, nonatomic) IBOutlet UILabel *topTittle;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *topbar;

@end
