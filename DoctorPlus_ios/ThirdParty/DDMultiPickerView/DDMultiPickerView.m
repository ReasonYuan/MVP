////
////  DDMultiPickerView.m
////  PickerView
////
////  Created by roofeel on 14/8/4.
////  Copyright (c) 2014年 RooFeel. All rights reserved.
////
//

#import "DDMultiPickerView.h"


@interface DDMultiPickerView() <CSPickerViewDataSource, CSPickerViewDelegate>
{
    NSMutableArray* _pickerViews;
}
-(void)loadData;
@end

@implementation DDMultiPickerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)setDataSource:(id<DDMultiPickerViewDataSource>)dataSource {
    _dataSource = dataSource;
    [self loadData];
}

- (void)setDelegate:(id<DDMultiPickerViewDelegate>)delegate {
    _delegate = delegate;
    [self loadData];
}

- (void)loadData {
    if (_delegate && _dataSource) {
        _pickerViews = [[NSMutableArray alloc] init];
        NSInteger components_count = [_dataSource numberOfComponentsInPickerView:self];
        float pickerItemWidth = self.frame.size.width / components_count;
        for (int i = 0; i < components_count; i++) {
            float left = pickerItemWidth * i;
            CSPickerView *pickerItemView = [[CSPickerView alloc] initWithFrame:CGRectMake(left, 0, pickerItemWidth, self.frame.size.height)];
            pickerItemView.component = i;
            pickerItemView.dataSource = self;
            pickerItemView.delegate = self;
            [_pickerViews addObject:pickerItemView];
            [self addSubview:pickerItemView];
        }
    }
}


- (void)setSelectedRow:(NSInteger)selectedRow inComponent:(NSInteger)componen animated:(BOOL)animated{
    for (NSInteger i = 0; i < _pickerViews.count; i++) {
        CSPickerView *pickerItemView = [_pickerViews objectAtIndex:i];
        if(pickerItemView.component == componen){
            [pickerItemView setSelectedRow:selectedRow animated:animated];
        }
    }
}

#pragma mark - CSPickerView Data Source

- (CGFloat)pickerView:(CSPickerView*)pickerView heightForRowsInTableView:(UITableView *)tableView
{
    return [_dataSource pickerView:self heightForRowsInTableView:(UITableView *)tableView inComponent:pickerView.component];
}

- (NSInteger)numberOfRowsInPickerView:(CSPickerView *)pickerView
{
    return [_dataSource pickerView:self numberOfRowsInComponent:pickerView.component];
}

- (UITableViewCell *)pickerView:(CSPickerView *)pickerView tableView:(UITableView *)tableView cellForRow:(NSInteger)row
{
    return [_dataSource pickerView:self tableView:tableView cellForRow:row inComponent:pickerView.component];
}

-(void)pickerView:(CSPickerView *)pickerView didSelectRow:(NSInteger)row
{
     [_delegate pickerView:self didSelectRow:row inComponent:pickerView.component];
}

#pragma mark - Picker Delegate

- (void)pickerView:(CSPickerView *)pickerView customizeTableView:(UITableView *)tableView {
    [_delegate pickerView:self customizeTableView:tableView inComponent:pickerView.component];
}


@end