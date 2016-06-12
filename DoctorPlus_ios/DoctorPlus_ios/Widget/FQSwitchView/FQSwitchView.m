//
//  FQSwitchView.m
//  DocPlus_ios
//
//  Created by niko on 14/12/11.
//  Copyright (c) 2014年 FQ. All rights reserved.
//

#import "FQSwitchView.h"
//NSString *const SWITCH_BUTTON_IMAGE      = @"";
//NSString *const SWITCH_BASE_IMAGE1       = @"switch_frame.png";
//NSString *const LEFT_BUTTON_IMAGE        = @"switch_btn_pressed.png";
//NSString *const LEFT_BUTTON_IMAGE_SEL    = @"switch_btn_pressed.png";
//NSString *const RIGHT_BUTTON_IMAGE       = @"switch_btn_pressed.png";
//NSString *const RIGHT_BUTTON_IMAGE_SEL   = @"switch_btn_pressed.png";

#define LEFT_BUTTON_RECT CGRectMake(0, 0, 72.f, 72.f)
#define RIGHT_BUTTON_RECT CGRectMake(0, 0, 72.f, 72.f)
#define TOGGLE_SLIDE_DULATION 0.1f

@implementation FQSwitchView
@synthesize switchDelegate;
@synthesize viewType;


- (id)initWithFrame:(CGRect)frame
     switchViewType:(FQSwitchViewType)aViewType
     switchBaseType:(SwitchBaseType)aBaseType
   switchButtonType:(SwitchButtonType)aButtonType
         baseImageL:(NSString*)imageL
         baseImageR:(NSString*)imageR
          btnImageL:(NSString*)btnImageL
          btnImageR:(NSString*)btnImageR;
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        self.viewType = aViewType;
        
        self.backgroundColor = [UIColor clearColor];
        
        //set up toggle base image.
        _switchBase = [[SwitchBase alloc]initWithImage:[UIImage imageNamed:imageL] baseType:aBaseType];
        _switchBase.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        _switchBase.imageL = imageL;
        _switchBase.imageR = imageR;
        _switchBase.userInteractionEnabled = YES;
        
        //set up toggle button image.
        _switchButton = [[SwitchButton alloc]initWithImage:[UIImage imageNamed:btnImageL] buttonType:aButtonType];
        _switchButton.imageL = btnImageL;
        _switchButton.imageR = btnImageR;
        _switchButton.userInteractionEnabled = YES;
        
        CGRect baseViewFrame = CGRectMake(_switchBase.frame.origin.x + _switchButton.frame.size.width/2,
                                          _switchBase.frame.origin.y,
                                          _switchBase.frame.size.width - _switchButton.frame.size.width,
                                          _switchBase.frame.size.height);
        _baseView = [[UIView alloc]initWithFrame:baseViewFrame];
        [self addSubview:_baseView];
        
        //calculate left/right edge
        _leftEdge = _switchBase.frame.origin.x + _switchButton.frame.size.width/2;
        _rightEdge = _switchBase.frame.origin.x + _switchBase.frame.size.width - _switchButton.frame.size.width/2;
        _switchButton.center = CGPointMake(_leftEdge, self.frame.size.height/2);
        
        if (self.viewType == FQSwitchViewTypeWithLabel)
        {
            //set up toggle left label image.
            _leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [_leftButton setFrame:LEFT_BUTTON_RECT];
//            [_leftButton setImage:[UIImage imageNamed:LEFT_BUTTON_IMAGE] forState:UIControlStateNormal];
//            [_leftButton setImage:[UIImage imageNamed:LEFT_BUTTON_IMAGE_SEL] forState:UIControlStateSelected];
            [_leftButton addTarget:self action:@selector(onLeftButton:) forControlEvents:UIControlEventTouchUpInside];
            _leftButton.center = CGPointMake(_leftEdge - _leftButton.frame.size.width, _switchBase.center.y);
            [self addSubview:_leftButton];
            
            //set up toggle right label image.
            _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [_rightButton setFrame:RIGHT_BUTTON_RECT];
//            [_rightButton setImage:[UIImage imageNamed:RIGHT_BUTTON_IMAGE] forState:UIControlStateNormal];
//            [_rightButton setImage:[UIImage imageNamed:RIGHT_BUTTON_IMAGE_SEL] forState:UIControlStateSelected];
            [_rightButton addTarget:self action:@selector(onRightButton:) forControlEvents:UIControlEventTouchUpInside];
            _rightButton.center = CGPointMake(_rightEdge + _rightButton.frame.size.width, _switchBase.center.y);
            [self addSubview:_rightButton];
            
            _leftButton.selected = YES;
            _rightButton.selected = NO;
        }
        
        [self addSubview:_switchBase];
        [self addSubview:_switchButton];
        
        UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        
        UITapGestureRecognizer* buttonTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleButtonTapGesture:)];
        
        UITapGestureRecognizer* baseTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleBaseTapGesture:)];
        
        [_switchButton addGestureRecognizer:panGesture];
        [_switchButton addGestureRecognizer:buttonTapGesture];
        [_switchBase addGestureRecognizer:baseTapGesture];
        
    }
    return self;
}
- (void)onLeftButton:(id)sender
{
    [UIView animateWithDuration:TOGGLE_SLIDE_DULATION animations:^{
        _switchButton.center = CGPointMake(_leftEdge, self.frame.size.height/2);
    }];
    if (self.viewType == FQSwitchViewTypeWithLabel)
    {
        _leftButton.selected = YES;
        _rightButton.selected = NO;
    }
    [_switchBase selectedLeftSwitchBase];
    [_switchButton selectedLeftSwitchButton];
    [self.switchDelegate selectLeftButton];
}

- (void)onRightButton:(id)sender
{
    [UIView animateWithDuration:TOGGLE_SLIDE_DULATION animations:^{
        _switchButton.center = CGPointMake(_rightEdge, self.frame.size.height/2);
    }];
    if (self.viewType == FQSwitchViewTypeWithLabel)
    {
        _leftButton.selected = NO;
        _rightButton.selected = YES;
    }
    [_switchBase selectedRightSwitchBase];
    [_switchButton selectedRightSwitchButton];
    [self.switchDelegate selectRightButton];
}

- (void)setTogglePosition:(float)positonValue ended:(BOOL)isEnded
{
    if (!isEnded)
    {
        if (positonValue == 0.f)
        {
            _switchButton.center = CGPointMake(_leftEdge, _switchButton.center.y);
        }
        else if (positonValue == 1.f)
        {
            _switchButton.center = CGPointMake(_rightEdge, _switchButton.center.y);
        }
        else
        {
            _switchButton.center = CGPointMake(_baseView.frame.origin.x + (positonValue * _baseView.frame.size.width), _switchButton.center.y);
        }
        
    }
    else //isEnded == YES;
    {
        if (positonValue == 0.f)
        {
            _switchButton.center = CGPointMake(_leftEdge, _switchButton.center.y);
            [_switchBase selectedLeftSwitchBase];
            [_switchButton selectedLeftSwitchButton];
            [self.switchDelegate selectLeftButton];
            
        }
        else if (positonValue == 1.f)
        {
            _switchButton.center = CGPointMake(_rightEdge, _switchButton.center.y);
            [_switchBase selectedRightSwitchBase];
            [_switchButton selectedRightSwitchButton];
            [self.switchDelegate selectRightButton];
        }
        else if (positonValue > 0.f && positonValue < 0.5f)
        {
            [UIView animateWithDuration:TOGGLE_SLIDE_DULATION animations:^{
                _switchButton.center = CGPointMake(_leftEdge, _switchButton.center.y);
            } completion:^(BOOL finished) {
                [_switchBase selectedLeftSwitchBase];
                [_switchButton selectedLeftSwitchButton];
                [self.switchDelegate selectLeftButton];
            }];
        }
        else if (positonValue >= 0.5f && positonValue < 1.f)
        {
            [UIView animateWithDuration:TOGGLE_SLIDE_DULATION animations:^{
                _switchButton.center = CGPointMake(_rightEdge, _switchButton.center.y);
            } completion:^(BOOL finished) {
                [_switchBase selectedRightSwitchBase];
                [_switchButton selectedRightSwitchButton];
                [self.switchDelegate selectRightButton];
            }];
        }
    }
}

- (void)handleButtonTapGesture:(UITapGestureRecognizer*) sender {
    
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        if (_switchButton.center.x == _rightEdge)
        {
            [UIView animateWithDuration:TOGGLE_SLIDE_DULATION animations:^{
                _switchButton.center = CGPointMake(_leftEdge, _switchButton.center.y);
            }completion:^(BOOL finished) {
                [_switchBase selectedLeftSwitchBase];
                [_switchButton selectedLeftSwitchButton];
                [self.switchDelegate selectLeftButton];
            }];
        }
        else if (_switchButton.center.x == _leftEdge)
        {
            [UIView animateWithDuration:TOGGLE_SLIDE_DULATION animations:^{
                _switchButton.center = CGPointMake(_rightEdge, _switchButton.center.y);
            }completion:^(BOOL finished) {
                [_switchBase selectedRightSwitchBase];
                [_switchButton selectedRightSwitchButton];
                [self.switchDelegate selectRightButton];
            }];
        }
    }
}

- (void)handleBaseTapGesture:(UITapGestureRecognizer*) sender {
    
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        if (_switchButton.center.x == _rightEdge)
        {
            [UIView animateWithDuration:TOGGLE_SLIDE_DULATION animations:^{
                _switchButton.center = CGPointMake(_leftEdge, _switchButton.center.y);
            }completion:^(BOOL finished) {
                [_switchBase selectedLeftSwitchBase];
                [_switchButton selectedLeftSwitchButton];
                [self.switchDelegate selectLeftButton];
            }];
        }
        else if (_switchButton.center.x == _leftEdge)
        {
            [UIView animateWithDuration:TOGGLE_SLIDE_DULATION animations:^{
                _switchButton.center = CGPointMake(_rightEdge, _switchButton.center.y);
            }completion:^(BOOL finished) {
                [_switchBase selectedRightSwitchBase];
                [_switchButton selectedRightSwitchButton];
                [self.switchDelegate selectRightButton];
            }];
        }
    }
}


- (void)handlePanGesture:(UIPanGestureRecognizer*) sender {
    
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        CGPoint currentPoint = [sender locationInView:_baseView];
        float position = currentPoint.x;
        float positionValue = position / _baseView.frame.size.width;
        
        if (positionValue < 1.f && positionValue > 0.f)
        {
            [self setTogglePosition:positionValue ended:NO];
        }
    }
    
    if (sender.state == UIGestureRecognizerStateChanged)
    {
        CGPoint currentPoint = [sender locationInView:_baseView];
        float position = currentPoint.x;
        float positionValue = position / _baseView.frame.size.width;
        
        if (positionValue < 1.f && positionValue > 0.f)
        {
            [self setTogglePosition:positionValue ended:NO];
        }
    }
    
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        
        CGPoint currentPoint = [sender locationInView:_baseView];
        float position = currentPoint.x;
        float positionValue = position / _baseView.frame.size.width;
        
        if (positionValue < 1.f && positionValue > 0.f)
        {
            [self setTogglePosition:positionValue ended:YES];
        }
        else if (positionValue >= 1.f)
        {
            [self setTogglePosition:1.f ended:YES];
        }
        else if (positionValue <= 0.f)
        {
            [self setTogglePosition:0.f ended:YES];
        }
    }
}

- (void)setSelectedButton:(SwitchButtonSelected)selectedButton
{
    switch (selectedButton) {
        case SwitchButtonSelectedLeft:
            [self onLeftButton:nil];
            break;
        case SwitchButtonSelectedRight:
            [self onRightButton:nil];
            break;
        default:
            break;
    }
}



@end
