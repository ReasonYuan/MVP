//
//  CameraBaseViewController.h
//  DoctorPlus_ios
//
//  Created by Monkey on 15/12/25.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TalkingData.h"

@interface CameraBaseViewController : UIViewController

-(NSString*)getXibName;

-(void)onLeftBtnOnClick:(UIButton*)sender;

-(void)onRightBtnOnClick:(UIButton*)sender;

-(void)onFlashBtnOnClick:(UIButton*)sender;

+(void)addChildViewFullInParent:(UIView*)child parent:(UIView*)parent;


@property (weak, nonatomic) IBOutlet UIButton *flashButton;
@property (weak, nonatomic) IBOutlet UIButton *leftBtn;
@property (weak, nonatomic) IBOutlet UIButton *rightBtn;
@property (weak, nonatomic) IBOutlet UIView *containerView;

- (IBAction)onLeftBtnClickListener:(UIButton *)sender;
- (IBAction)onRightBtnClickListener:(UIButton *)sender;
- (IBAction)onFlashBtnClickListener:(UIButton *)sender;

@end
