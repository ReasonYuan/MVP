//
//  DDMultiPickerView.h
//  PickerView
//
//  Created by roofeel on 14/8/4.
//  Copyright (c) 2014年 RooFeel. All rights reserved.
//


#import "CSPickerView.h"
#import <UIKit/UIKit.h>

@protocol DDMultiPickerViewDataSource, DDMultiPickerViewDelegate;

@interface DDMultiPickerView : UIView

@property (nonatomic, weak) id <DDMultiPickerViewDelegate> delegate;
@property (nonatomic, weak) id <DDMultiPickerViewDataSource> dataSource;

- (void)setSelectedRow:(NSInteger)selectedRow inComponent:(NSInteger)componen animated:(BOOL)animated;

@end


#pragma mark - Multi Picker View Data Source

@protocol DDMultiPickerViewDataSource <NSObject>

@required
- (UITableViewCell *)pickerView:(DDMultiPickerView *)pickerView tableView:(UITableView *)tableView cellForRow:(NSInteger)row inComponent:(NSInteger)component;
- (NSInteger)numberOfComponentsInPickerView:(DDMultiPickerView *)pickerView;
- (CGFloat)pickerView:(DDMultiPickerView *)pickerView heightForRowsInTableView:(UITableView *)tableView inComponent:(NSInteger)component;
- (NSInteger)pickerView:(DDMultiPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;

@end

#pragma mark - Multi Picker View Delegate

@protocol DDMultiPickerViewDelegate <NSObject>

@optional
- (void)pickerView:(DDMultiPickerView *)pickerView customizeTableView:(UITableView *)tableView inComponent:(NSInteger)component;
- (void)pickerView:(DDMultiPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;

@end
