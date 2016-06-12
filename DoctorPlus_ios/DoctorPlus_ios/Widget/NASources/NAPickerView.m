//
//  NAPickerView.m
//  NAPickerView
//
//  Created by iNghia on 8/4/13.
//  Copyright (c) 2013 nghialv. All rights reserved.
//

#import "NAPickerView.h"
#import "NALabelCell.h"
#import <QuartzCore/QuartzCore.h>

@interface NAPickerView() <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *items;
@property (strong, nonatomic) NSString *cellClassName;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSIndexPath *currentIndex;
@property (strong, nonatomic) UIView *overlay;

@end

@implementation NAPickerView
@synthesize showOverlay = mShowOverlay;

- (id)initWithFrame:(CGRect)frame
           andItems:(NSArray *)items
   andCellClassName:(NSString *)className
        andDelegate:(id)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self configWithFrame:frame
                     andItems:items
             andCellClassName:className
                  andDelegate:delegate];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
           andItems:(NSArray *)items
        andDelegate:(id)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self configWithFrame:frame
                     andItems:items
             andCellClassName:@"NALabelCell"
                  andDelegate:delegate];
    }
    return self;
}

- (void)configWithFrame:(CGRect)frame
               andItems:(NSArray *)items
       andCellClassName:(NSString *)className
            andDelegate:(id)delegate
{
    self.items = items;
    self.delegate = delegate;
    self.cellClassName = className;
    
    self.tableView = [[UITableView alloc] initWithFrame:self.bounds];//CGRectMake(0, 0, ScreenWidth, ScreenHeight) style:UITableViewStylePlain];//self.bounds
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.allowsSelection = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.tableView];
    
    self.currentIndex = [NSIndexPath indexPathForRow:0 inSection:0];
    self.backgroundColor = [UIColor grayColor];
    
    mShowOverlay = NO;
    self.showOverlay = YES;
    
    self.configureBlock = ^(NALabelCell *cell, NSString *item) {
        [cell.textView setText:item];
        cell.textView.textAlignment = UITextAlignmentCenter;
        cell.textView.font = [UIFont fontWithName:@"Helvetica" size:26];
        cell.textView.backgroundColor = [UIColor clearColor];
        cell.textView.textColor = [UIColor grayColor];
    };
    
    self.highlightBlock = ^(NALabelCell *cell) {
        cell.textView.textColor = [UIColor greenColor];
    };
    
    self.unhighlightBlock = ^(NALabelCell *cell) {
        cell.textView.textColor = [UIColor grayColor];
    };
}

- (CGFloat)headerHeight
{
    return 0;//self.bounds.size.height/2 - [self cellHeight]/2;
}

- (CGFloat)cellHeight
{
    return [NSClassFromString(self.cellClassName) cellHeight];
}

- (void)setBorderWidth:(CGFloat)borderWidth
{
    self.layer.borderWidth = borderWidth;
}

- (void)setBorderColor:(UIColor *)borderColor
{
    [self.layer setBorderColor:[borderColor CGColor]];
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = YES;
}

- (void)setIndex:(NSInteger)index
{
    self.currentIndex = [NSIndexPath indexPathForItem:index inSection:0];
    [self.tableView scrollToRowAtIndexPath:self.currentIndex
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:NO];
}

- (void)setShowOverlay:(BOOL)showOverlay
{
    if (showOverlay != mShowOverlay) {
        mShowOverlay = showOverlay;
        [self setOverlayView];
    }
}

- (void)setOverlayView
{
    if (self.showOverlay) {
        
        int cellCount = (self.frame.size.height - 70)/[self cellHeight];
        
        CGFloat pointY = 0.f;
        
        if(cellCount%2 == 0){
            pointY = cellCount/2 * [self cellHeight];
        }else{
            pointY = (cellCount/2 + 1) * [self cellHeight];
        }
        
        self.overlay = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                pointY,
                                                                self.frame.size.width,
                                                                [self cellHeight])];
        self.overlay.backgroundColor = [UIColor clearColor];
        self.overlay.alpha = 1.0;
        UIColor *labelColor = [UIColor colorWithRed:146.0/255.0 green:206.0/255.0 blue:193.0/255.0 alpha:1.0];
        UILabel *lable1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 1.0f)];
        lable1.backgroundColor = labelColor;
        UILabel *lable2 = [[UILabel alloc] initWithFrame:CGRectMake(0, [self cellHeight], self.frame.size.width,1.0f)];
        lable2.backgroundColor = labelColor;
        [self.overlay addSubview:lable1];
        [self.overlay addSubview:lable2];
        self.overlay.userInteractionEnabled = NO;
        [self addSubview:self.overlay];
    } else {
        [self.overlay removeFromSuperview];
    }
}

#pragma mark - UITableView delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;//[self headerHeight];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *emptyHeader = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                   0,
                                                                   self.tableView.frame.size.width,
                                                                   0)];                        //[self headerHeight])];
    emptyHeader.backgroundColor = [UIColor clearColor];
    return emptyHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return [self headerHeight];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *emptyHeader = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                   0,
                                                                   self.tableView.frame.size.width,
                                                                   [self headerHeight])];
    emptyHeader.backgroundColor = [UIColor clearColor];
    return emptyHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [self cellHeight];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.items count];
}
-(NSInteger)numberOfSectionInTableView:(UITableView*)tableView
{
    return [self.items count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"NACellIdentifier";
    NAPickerCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(!cell) {
        cell = [[NSClassFromString(self.cellClassName) alloc] initWithStyle:UITableViewCellStyleDefault
                                                            reuseIdentifier:cellIdentifier
                                                                  cellWidth:self.tableView.bounds.size.width];
    }
    
    self.configureBlock(cell, [self.items objectAtIndex:indexPath.row]);
    if(indexPath.row == self.currentIndex.row) {
        self.highlightBlock(cell);
    } else {
        self.unhighlightBlock(cell);
    }
    return cell;
}

#pragma mark - ScrollViewDelegate
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset
{
    GLfloat rowHeight = [self cellHeight];
    CGFloat floatVal = targetContentOffset->y / rowHeight;
	NSInteger rounded = (NSInteger)(lround(floatVal));
	targetContentOffset->y = rounded * rowHeight;
    [self.delegate didSelectedAtIndexDel:rounded];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSArray *visibleIndex = [self.tableView indexPathsForVisibleRows];
    NSArray *visibleIndexSorted = [visibleIndex sortedArrayUsingComparator:^NSComparisonResult(id a, id b){
        CGRect r1 = [self.tableView rectForRowAtIndexPath:(NSIndexPath *)a];
        CGRect r2 = [self.tableView rectForRowAtIndexPath:(NSIndexPath *)b];
        CGFloat y1 = fabsf(r1.origin.y + r1.size.height/2 - self.tableView.contentOffset.y - self.tableView.center.y);
        CGFloat y2 = fabsf(r2.origin.y + r2.size.height/2 - self.tableView.contentOffset.y - self.tableView.center.y);
        if (y1 > y2) {
            return NSOrderedDescending;
        }
        return NSOrderedAscending;
    }];
    
    NSIndexPath *middleIndex = [visibleIndexSorted objectAtIndex:0];
    if (!self.currentIndex) {
        self.currentIndex = middleIndex;
    }
    if (self.currentIndex.row == middleIndex.row) {
        return;
    }
    if (_currentIndex.row==_items.count-6) {
        NSLog(@"a");
        self.currentIndex = middleIndex;
        [self.tableView reloadData];
    }
    NAPickerCell *currentCell = (NAPickerCell *)[self.tableView cellForRowAtIndexPath:self.currentIndex];
    self.unhighlightBlock(currentCell);
    NAPickerCell *middleCell = (NAPickerCell *)[self.tableView cellForRowAtIndexPath:middleIndex];
    self.highlightBlock(middleCell);
    self.currentIndex = middleIndex;
}
- (NSIndexPath*) getCurrentIndex
{
    return _currentIndex;
}

-(void)updateTabView
{
    [self.tableView reloadData];
}
@end
