//
//  FQTexfield.h
//  FangTai
//
//  Created by liaomin on 14-7-24.
//  Copyright (c) 2014年 FQ. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UITextField;


@protocol FQTexfieldDelegate<UITextFieldDelegate>

@end


//FQTexfield的内敛delegate
@interface FQTexfieldInlineDelegate : NSObject<UITextFieldDelegate>

@property (weak,nonatomic) id<FQTexfieldDelegate> _delegete;

@property (weak,nonatomic) UITextField* _textField;

+ (CGRect)relativeFrameForScreenWithView:(UIView *)v;

@property (weak,nonatomic) UIView* nextTextField;

@end

@interface FQTexfield : UITextField
{
    FQTexfieldInlineDelegate* _delegate; //内敛delegate
}

-(void)setNextTextField:(FQTexfield*)next;

-(void)setFQTexfieldDelegate:(id<FQTexfieldDelegate>)delegate;


//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField;        // return NO to disallow editing.
//- (void)textFieldDidBeginEditing:(UITextField *)textField;           // became first responder
//- (BOOL)textFieldShouldEndEditing:(UITextField *)textField;          // return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
//- (void)textFieldDidEndEditing:(UITextField *)textField;             // may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
//
//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;   // return NO to not change text
//
//- (BOOL)textFieldShouldClear:(UITextField *)textField;               // called when clear button pressed. return NO to ignore (no notifications)
//- (BOOL)textFieldShouldReturn:(UITextField *)textField;              // called when 'return' key pressed. return NO to ignore.

@end
