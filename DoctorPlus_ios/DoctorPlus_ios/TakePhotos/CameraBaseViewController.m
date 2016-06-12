//
//  CameraBaseViewController.m
//  DoctorPlus_ios
//
//  Created by Monkey on 15/12/25.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

#import "CameraBaseViewController.h"

@interface CameraBaseViewController ()

@end

@implementation CameraBaseViewController

-(id)init
{
    self = [super initWithNibName:@"CameraBaseViewController" bundle:nil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString*  xibName= [self getXibName];
    if(![xibName isEqualToString:@""]){
        UIView* contentView = [[NSBundle mainBundle] loadNibNamed:xibName owner:self options:nil][0];
        [FQBaseViewController addChildViewFullInParent:contentView parent:_containerView];
    }
    
}


-(NSString*)getXibName{
    NSString* className = [NSString stringWithUTF8String:object_getClassName(self)];
    return className;
}

-(void)onLeftBtnOnClick:(UIButton*)sender
{
    
}

-(void)onRightBtnOnClick:(UIButton*)sender
{
    
}

-(void)onFlashBtnOnClick:(UIButton *)sender
{

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [TalkingData trackPageBegin:self.getXibName];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    [TalkingData trackPageEnd:self.getXibName];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


+(void)addChildViewFullInParent:(UIView *)child parent:(UIView *)parent
{
    if(child && parent && !child.superview){
        [child setTranslatesAutoresizingMaskIntoConstraints:NO];
        [parent addSubview:child];
        [parent addConstraint:[NSLayoutConstraint constraintWithItem:child attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:parent attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        [parent addConstraint:[NSLayoutConstraint constraintWithItem:child attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:parent attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
        [parent addConstraint:[NSLayoutConstraint constraintWithItem:child attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:parent attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
        [parent addConstraint:[NSLayoutConstraint constraintWithItem:child attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:parent attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

-(void)dealloc
{
    NSLog(@"------------>%s dealloc!",object_getClassName(self));
}


- (IBAction)onLeftBtnClickListener:(UIButton *)sender {
    [self onLeftBtnOnClick:sender];
}

- (IBAction)onRightBtnClickListener:(UIButton *)sender {
    [self onRightBtnOnClick:sender];
}

- (IBAction)onFlashBtnClickListener:(UIButton *)sender {
    [self onFlashBtnOnClick:sender];
}
@end
