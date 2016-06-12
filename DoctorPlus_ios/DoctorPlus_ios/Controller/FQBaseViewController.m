//
//  FQBaseNavigationViewController.m
//  DoctorPlus_ios
//
//  Created by 廖敏 on 15/7/16.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

#import "FQBaseViewController.h"
#import "TalkingData.h"

@interface FQBaseViewController ()



@end

@implementation FQBaseViewController

-(id)init
{
    self = [super initWithNibName:@"FQBaseViewController" bundle:nil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage* leftDefaultImage = [UIImage imageNamed:@"icon_topleft.png"];
    [_leftBtn setBackgroundImage:leftDefaultImage forState:UIControlStateNormal];
    [_bigLeftBtn addTarget:self action:@selector(onLeftBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIImage* rightDefaultImage = [UIImage imageNamed:@"btn_add_icon.png"];
    [_rightBtn setBackgroundImage:rightDefaultImage forState:UIControlStateNormal];
    [_bigRightBtn addTarget:self action:@selector(onRightBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
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
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)onRightBtnOnClick:(UIButton*)sender
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


-(void)setTitle:(NSString *)title
{
    self.topTittle.hidden = NO;
    self.topTittle.text = title;
}


-(void)hiddenTittle:(BOOL)hide
{
    self.topTittle.hidden = YES;
}

-(void)setRightBtnTittle:(NSString*)str
{
    _rightBtn.hidden = YES;
    _bigRightBtn.hidden = NO;
    [_bigRightBtn setTitle:str forState:UIControlStateNormal];
}

-(void)setLeftTitle:(NSString*)str
{
    _leftText.text = str;
}

-(void)hiddenLeftImage:(BOOL)hide
{
    _leftBtn.hidden = hide;
    _bigLeftBtn.hidden = hide;
    _leftText.hidden = hide;
}

-(void)setBigRightButtonHiden:(BOOL)hide
{
    _bigRightBtn.hidden = hide;
}

-(void)hiddenRightImage:(BOOL)hide
{
    _rightBtn.hidden = hide;
    _bigRightBtn.hidden = hide;
}

-(void)setLeftImage:(BOOL)hide image:(UIImage*)image
{
    if (hide) {
        _leftBtn.hidden = hide;
        _bigLeftBtn.hidden = hide;
        _leftText.hidden = hide;
    }else {
        [_leftBtn setBackgroundImage:image forState:UIControlStateNormal];
        _leftText.hidden = hide;
    }

}

-(void)setRightImage:(BOOL)hide image:(UIImage*)image
{
    if (hide) {
        _rightBtn.hidden = hide;
        _bigRightBtn.hidden = hide;
    }else {
         [_rightBtn setBackgroundImage:image forState:UIControlStateNormal];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
