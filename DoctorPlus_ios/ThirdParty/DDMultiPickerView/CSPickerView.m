//
// CSPickerView.m
//
// Copyright (c) 2013 Cheapshot (http://cheapshot.co/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <QuartzCore/QuartzCore.h>
#import "CSPickerView.h"

@interface CSPickerTableView : UITableView
@property (nonatomic) CSPickerView *pickerView;
@end

@interface CSPickerView () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) CSPickerTableView *topTableView;
@property (nonatomic) CSPickerTableView *bottomTableView;
@property (nonatomic) CSPickerTableView *frontTableView;
@property (nonatomic) NSInteger count;
@property (nonatomic) CGFloat frontTableViewY;
@property (nonatomic) CGFloat frontTableViewHeight;
@property (nonatomic) CGFloat backTableViewHeight;
@property (nonatomic) CGFloat heightRatio;
@end

@implementation CSPickerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupTables];
        [self setupScrollView];
        [self setupGradientView];
        self.ignoreTatchSelect = YES;
    }
    return self;
}

- (void)setupTables
{
    // Top table.
    _topTableView = [self createTableView:kCSPickerViewBackTopTableTag];
    _topTableView.pickerView = self;
    [self addSubview:_topTableView];
    
    // Bottom table.
    _bottomTableView = [self createTableView:kCSPickerViewBackBottomTableTag];
    _bottomTableView.pickerView = self;
    [self addSubview:_bottomTableView];
    
    // Front table.
    _frontTableView = [self createTableView:kCSPickerViewFrontTableTag];
    [self addSubview:_frontTableView];
}

- (CSPickerTableView *)createTableView:(int)tag
{
    CSPickerTableView *tableView = [[CSPickerTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.tag = tag;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.userInteractionEnabled = NO;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.showsHorizontalScrollIndicator = NO;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.backgroundColor = [UIColor clearColor];
    return tableView;
}

- (void)setupScrollView
{
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.delegate = self;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _scrollView.bounces = YES;
    [self addSubview:_scrollView];
    
    // Add tap gesture for selecting row.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [_scrollView addGestureRecognizer:tap];
}

- (void)setupGradientView
{
    _gradientView = [[CSPickerGradientView alloc] initWithFrame:self.bounds];
    _gradientView.locations = @[ @0.0f, @0.3f, @0.7f, @1.f];
    _gradientView.CGColors = @[ (id)[UIColor whiteColor].CGColor,
                                (id)[[UIColor whiteColor] colorWithAlphaComponent:0.0f].CGColor,
                                (id)[[UIColor whiteColor] colorWithAlphaComponent:0.0f].CGColor,
                                (id)[UIColor whiteColor].CGColor ];
    [self addSubview:_gradientView];
}

#pragma mark - Geometry

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _scrollView.frame = self.bounds;
    _gradientView.frame = self.bounds;
    [self updateGeometry];
    [self scrollViewDidScroll:_frontTableView];
}

- (void)updateGeometry
{
    _backTableViewHeight = [_dataSource pickerView:self heightForRowsInTableView:_topTableView];
    _frontTableViewHeight = [_dataSource pickerView:self heightForRowsInTableView:_frontTableView];
    
    _heightRatio = _frontTableViewHeight / _backTableViewHeight;
    _frontTableViewY = (self.frame.size.height - _frontTableViewHeight) / 2.f;
    _frontTableView.frame = CGRectMake(0.f, _frontTableViewY, self.frame.size.width, _frontTableViewHeight);
    _topTableView.frame = CGRectMake(0.f, 0.f, self.frame.size.width, _frontTableViewY);

    CGFloat height = _frontTableViewY;
    if (_delegate) {
        // Reduce bottom table height by number of cells.
        NSInteger numberOfRows = [self tableView:_bottomTableView numberOfRowsInSection:0];
        if (numberOfRows > 0) {
            height = fminf(_frontTableViewY, numberOfRows * [_dataSource pickerView:self heightForRowsInTableView:_bottomTableView]);
        } else {
            height = 0;
        }
    }

    _bottomTableView.frame = CGRectMake(0.f, _frontTableViewY + _frontTableViewHeight, self.frame.size.width, height);
    // Update Scroll View content size.
    [self updateScrollViewContentSize];
}

#pragma mark - setter

- (void)setDelegate:(id<CSPickerViewDelegate>)delegate
{
    _delegate = delegate;
    [self updateGeometry];
    
    // Table View customization.
    if ([_delegate respondsToSelector:@selector(pickerView:customizeTableView:)]) {
        [_delegate pickerView:self customizeTableView:_frontTableView];
        [_delegate pickerView:self customizeTableView:_topTableView];
        [_delegate pickerView:self customizeTableView:_bottomTableView];
    }
    
    [self reloadData];
}

- (void)setDataSource:(id<CSPickerViewDataSource>)dataSource
{
    _dataSource = dataSource;
    [self reloadData];
}

- (void)setComponent:(NSInteger)component
{
    _component = component;
    [self reloadData];
}

- (void)reloadData
{
    if (_delegate && _dataSource && _component >= 0) {
        [_topTableView reloadData];
        [_bottomTableView reloadData];
        [_frontTableView reloadData];
        _count = [_dataSource numberOfRowsInPickerView:self];
        [self updateScrollViewContentSize];
        [self updateGeometry];
        [self scrollViewDidScroll:_frontTableView];
    }
}

- (void)updateScrollViewContentSize
{
    _scrollView.contentSize = CGSizeMake(self.frame.size.width,
                                         _frontTableView.contentSize.height
                                         + self.frame.size.height - _frontTableViewHeight);
}

- (void)setSelectedRow:(NSInteger)selectedRow
{
    [self setSelectedRow:selectedRow animated:NO];
}

- (void)setSelectedRow:(NSInteger)selectedRow animated:(BOOL)animated
{
    _selectedRow = selectedRow;
    [_scrollView setContentOffset:CGPointMake(0.f, _selectedRow * _frontTableViewHeight) animated:animated];
    
    // Delegate row selecting.
    if ([_delegate respondsToSelector:@selector(pickerView:didSelectRow:)]) {
        [_delegate pickerView:self didSelectRow:_selectedRow];
    }
}

#pragma mark - Table View Data Source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSource ? [_dataSource numberOfRowsInPickerView:self] : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _dataSource ? [_dataSource pickerView:self tableView:tableView cellForRow:indexPath.row] : nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _dataSource ? [_dataSource pickerView:self heightForRowsInTableView:tableView] : _frontTableViewHeight;
}

#pragma mark - Scroll Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.tag == kCSPickerViewBackTopTableTag || scrollView.tag == kCSPickerViewBackBottomTableTag) {
        return;
    }
    
    if (scrollView == _scrollView) {
        [_frontTableView setContentOffset:scrollView.contentOffset animated:NO];
        return;
    }
    
    [_topTableView setNeedsLayout];
    [_bottomTableView setNeedsLayout];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == _scrollView) {
        [self selectNearOffset:scrollView.contentOffset];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView == _scrollView && !decelerate) {
        [self selectNearOffset:scrollView.contentOffset];
    }
}

- (void)selectNearOffset:(CGPoint)point
{
    point.y = _frontTableViewHeight * floorf((point.y + _frontTableViewHeight / 2.f) / _frontTableViewHeight);
    [self setSelectedRow:ceilf(point.y / _frontTableViewHeight) animated:YES];
}

#pragma -

- (void)tap:(UITapGestureRecognizer *)gesture
{
    if(!self.ignoreTatchSelect){
        CGFloat y = [gesture locationInView:self].y;
        NSInteger rowOffset = 0;
        if (y < _topTableView.frame.size.height) {
            y = _topTableView.frame.size.height - y;
            rowOffset = -ceilf(y / _backTableViewHeight);
            
        } else if (y > _bottomTableView.frame.origin.y) {
            y -= _bottomTableView.frame.origin.y;
            rowOffset = ceilf(y / _backTableViewHeight);
        }
        
        if (rowOffset != 0) {
            NSInteger selectedRow = _selectedRow + rowOffset;
            if (selectedRow != _selectedRow && selectedRow >= 0 && selectedRow < _count) {
                [self setSelectedRow:selectedRow animated:YES];
            }
            
        } else if ([_delegate respondsToSelector:@selector(pickerView:didSelectRow:)]) {
            // Delegate row selecting.
            [_delegate pickerView:self didSelectRow:_selectedRow];
        }

    }
}

@end

#pragma mark - Picker Table View

@implementation CSPickerTableView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_pickerView)
    {
        
        CGFloat y = _pickerView.scrollView.contentOffset.y / _pickerView.heightRatio;
        CGPoint contentOffset = CGPointZero;
        if (_pickerView.topTableView == self) {
            contentOffset = CGPointMake(0.f, y - _pickerView.frontTableViewY);
        } else {
            contentOffset = CGPointMake(0.f, y + _pickerView.backTableViewHeight);
        }
        [self setContentOffset:contentOffset animated:NO];
    }
}

@end


#pragma mark - Gradient View

@implementation CSPickerGradientView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.userInteractionEnabled = NO;
    }
    return self;
}

+ (Class)layerClass
{
    return [CAGradientLayer class];
}

- (void)setLocations:(NSArray *)locations
{
    ((CAGradientLayer *)self.layer).locations = locations;
}

- (void)setCGColors:(NSArray *)CGColors
{
    ((CAGradientLayer *)self.layer).colors = CGColors;
}

@end
