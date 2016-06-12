//
//  FQTexfield.m
//  FangTai
//
//  Created by liaomin on 14-7-24.
//  Copyright (c) 2014年 FQ. All rights reserved.
//

#import "FQTexfield.h"

@implementation FQTexfield

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self FQInit];
    }
    return self;
}

-(void)FQInit
{
    _delegate = [[FQTexfieldInlineDelegate alloc] init];
    self.delegate = _delegate;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self FQInit];
    }
    return self;
}

-(void)setNextTextField:(FQTexfield *)next
{
    _delegate.nextTextField = next;
}


-(void)setFQTexfieldDelegate:(id<FQTexfieldDelegate>)delegate
{
    if(_delegate){
        _delegate._delegete = delegate;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/



//- (void)drawPlaceholderInRect:(CGRect)rect{
//    UIColor *placeholderColor = [UIColor redColor];//设置颜色
//    [placeholderColor setFill];
//}

@end


static float KEY_BOARD_HEIGHT = 0;
static CGFloat MOVE_DIS_PORTRAIT = 0;
static CGFloat MOVE_DIS_lANDSCAPE = 0;


@implementation FQTexfieldInlineDelegate

@synthesize nextTextField;
@synthesize _textField;
@synthesize _delegete;

-(id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return  self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

// return NO to disallow editing.
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
 
    self._textField = textField;
    return YES;
}


/**
  *  计算一个view相对于屏幕(去除顶部statusbar的20像素)的坐标
  *  iOS7下UIViewController.view是默认全屏的，要把这20像素考虑进去
  */
+ (CGRect)relativeFrameForScreenWithView:(UIView *)v
{
//    CGFloat screenHeight = DeviceHeight;
    UIView *view = v;
    CGFloat x = .0;
    CGFloat y = .0;
    while (view) {
        x += view.frame.origin.x;
        y += view.frame.origin.y;
        view = view.superview;
        if ([view isKindOfClass:[UIScrollView class]])
        {
            x -= ((UIScrollView *) view).contentOffset.x;
            y -= ((UIScrollView *) view).contentOffset.y;
        }
    }
    return CGRectMake(x, y, v.frame.size.width, v.frame.size.height);
}


- (void)keyboardWillShow:(NSNotification *)aNotification
{
    BOOL isPortrait = YES;
    UIInterfaceOrientation currnetOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if( UIInterfaceOrientationLandscapeLeft == currnetOrientation || UIInterfaceOrientationLandscapeRight == currnetOrientation)
    {
        isPortrait = NO;
    }
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    if(isPortrait)
    {
         KEY_BOARD_HEIGHT = keyboardRect.size.height;
    }else
    {
         KEY_BOARD_HEIGHT = keyboardRect.size.width;
    }
   
    if(self._textField){
        CGRect textFrame = [FQTexfieldInlineDelegate relativeFrameForScreenWithView:self._textField];
        float maxOrginY = 0;
        if(isPortrait)
        {
            maxOrginY = [UIScreen mainScreen].bounds.size.height - KEY_BOARD_HEIGHT;
        }else
        {
            maxOrginY = [UIScreen mainScreen].bounds.size.width - KEY_BOARD_HEIGHT;
        }
        
        float textBoottom = textFrame.origin.y+textFrame.size.height + 10;
        float  dis = maxOrginY - textBoottom;
        if(dis < 0)
        {
            if(isPortrait)
            {
                MOVE_DIS_PORTRAIT += dis;
                [UIView beginAnimations:@"textAnimation" context:nil];
                [UIView setAnimationDuration:0.2];
                CGRect windFrame  = [UIApplication sharedApplication].keyWindow.frame;
                [UIApplication sharedApplication].keyWindow.frame = CGRectMake(windFrame.origin.x, windFrame.origin.y + dis, windFrame.size.width, windFrame.size.height);
                [UIView commitAnimations];
            }else
            {
                [UIView beginAnimations:@"textAnimation" context:nil];
                [UIView setAnimationDuration:0.2];
                CGRect windFrame  = [UIApplication sharedApplication].keyWindow.frame;
                 MOVE_DIS_lANDSCAPE += dis;
                if( UIInterfaceOrientationLandscapeLeft == currnetOrientation)
                {
                    [UIApplication sharedApplication].keyWindow.frame = CGRectMake(windFrame.origin.x + dis, windFrame.origin.y , windFrame.size.width, windFrame.size.height);
                }else
                {
                    [UIApplication sharedApplication].keyWindow.frame = CGRectMake(windFrame.origin.x - dis, windFrame.origin.y , windFrame.size.width, windFrame.size.height);
                }

                
                [UIView commitAnimations];
            }
            
        }

    }
    
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    if(MOVE_DIS_PORTRAIT !=  0)
    {
        [UIView beginAnimations:@"textAnimation" context:nil];
        [UIView setAnimationDuration:0.2];
        CGRect windFrame  = [UIApplication sharedApplication].keyWindow.frame;
        [UIApplication sharedApplication].keyWindow.frame = CGRectMake(windFrame.origin.x, windFrame.origin.y - MOVE_DIS_PORTRAIT, windFrame.size.width, windFrame.size.height);
        [UIView commitAnimations];
        MOVE_DIS_PORTRAIT = 0;
    }
    if(MOVE_DIS_lANDSCAPE != 0)
    {
        UIInterfaceOrientation currnetOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        [UIView beginAnimations:@"textAnimation" context:nil];
        [UIView setAnimationDuration:0.2];
        CGRect windFrame  = [UIApplication sharedApplication].keyWindow.frame;
        if( UIInterfaceOrientationLandscapeLeft == currnetOrientation)
        {
            [UIApplication sharedApplication].keyWindow.frame = CGRectMake(windFrame.origin.x - MOVE_DIS_lANDSCAPE, windFrame.origin.y , windFrame.size.width, windFrame.size.height);
        }else
        {
            [UIApplication sharedApplication].keyWindow.frame = CGRectMake(windFrame.origin.x + MOVE_DIS_lANDSCAPE, windFrame.origin.y , windFrame.size.width, windFrame.size.height);
        }
     
        [UIView commitAnimations];
        MOVE_DIS_lANDSCAPE = 0;
    }
    self._textField = nil;
}


// became first responder
// return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if(_delegete && [_delegete respondsToSelector:@selector(textFieldShouldEndEditing:)]){
        return [_delegete textFieldShouldEndEditing:textField];
    }
    return YES;
}

// may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(_delegete && [_delegete respondsToSelector:@selector(textFieldDidEndEditing:)]){
        [_delegete textFieldDidEndEditing:textField];
    }
}

// return NO to not change text
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(_delegete && [_delegete respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]){
        return [_delegete textField:textField shouldChangeCharactersInRange:range replacementString:string];
    }
    return YES;
}

// called when clear button pressed. return NO to ignore (no notifications)
- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if(_delegete && [_delegete respondsToSelector:@selector(textFieldShouldClear:)]){
        return [_delegete textFieldShouldClear:textField];
    }
    return YES;
}

// called when 'return' key pressed. return NO to ignore.
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if(nextTextField != nil)
    {
        [nextTextField becomeFirstResponder];
        
    }
    if(_delegete && [_delegete respondsToSelector:@selector(textFieldShouldReturn:)]){
        return [_delegete textFieldShouldReturn:textField];
    }
    return YES;
}

@end
