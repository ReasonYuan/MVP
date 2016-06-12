//
//  ContactTagsListViewController.m
//  DoctorPlus_ios
//
//  Created by niko on 15/6/1.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

#import "ContactTagsListViewController.h"
#import "DoctorPlus_ios-Swift.h"
@interface ContactTagsListViewController()
{
    ComFqHalcyonLogic2TagLogic *logic;
}

@end

@implementation ContactTagsListViewController

@synthesize tableView = _tableView;
@synthesize headViewArray;
@synthesize dialog;
@synthesize label;
@synthesize loadingDialog;

- (void)viewDidLoad
{
    [super viewDidLoad];
    headViewArray = [[NSMutableArray alloc]init];
    _tagsNameArray = ComFqLibToolsConstants_tagList_;
    [self loadModel];
    self.view.backgroundColor = [UIColor whiteColor];
    NSInteger screenWidth = [[UIScreen mainScreen] bounds].size.width;
    NSInteger screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    label = [[UILabel alloc]initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width/2 - [[UIScreen mainScreen] bounds].size.width/3, ([[UIScreen mainScreen] bounds].size.height - 70) / 2 + 60, [[UIScreen mainScreen] bounds].size.width/3 * 2, 20)];
    [label setText: @"您还没有标签，请点击右上角添加"];
    [label setFont:[UIFont systemFontOfSize:12]];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor lightGrayColor];
    label.hidden = true;
    [self.view addSubview:label];
    
    UIView* topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 70)];
    topView.backgroundColor = [[UIColor alloc]initWithRed:98/255.0 green:192/255.0 blue:180/255.0 alpha:1];
    [self.view addSubview:topView];
    UIButton* backBtn = [[UIButton alloc]initWithFrame:CGRectMake(20, 35, 17, 17)];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"btn_back.png"] forState:UIControlStateNormal];
    [self.view addSubview:backBtn];
    UIButton* backBtnView = [[UIButton alloc]initWithFrame:CGRectMake(11, 26, 34, 34)];
    [backBtnView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:backBtnView];
    UIButton* addBtn = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth-37, 35, 17, 17)];
    [addBtn setBackgroundImage:[UIImage imageNamed:@"btn_add_icon.png"] forState:UIControlStateNormal];
    [self.view addSubview:addBtn];
    UIButton* addBtnView = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth-46, 26, 34, 34)];
    [addBtnView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:addBtnView];
    UILabel * titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth/2-240, 29, 480, 29)];
    titleLabel.textColor = [[UIColor alloc]initWithRed:245.0/255.0 green:229.0/255.0 blue:207.0/255.0 alpha:1];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = @"标签";
    [self.view addSubview:titleLabel];
    [backBtnView addTarget:self action:@selector(doBackPressed:) forControlEvents:UIControlEventTouchUpInside];
    [addBtnView addTarget:self action:@selector(addPressed:) forControlEvents:UIControlEventTouchUpInside];
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 70,screenWidth,screenHeight - 70) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorColor = [UIColor clearColor];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    _tagsNameArray = ComFqLibToolsConstants_tagList_;
    [self loadModel];
    [_tableView reloadData];
    logic = [[ComFqHalcyonLogic2TagLogic alloc] init];
    loadingDialog = [[UIAlertViewTool getInstance] showLoadingDialog:@"获取标签列表..."];
    [logic getListAllTagsWithComFqHalcyonLogic2TagLogic_RequestTagInfCallBack:self];
   
}

-(void)resTagListWithJavaUtilArrayList:(JavaUtilArrayList *)tags{
    ComFqLibToolsConstants_tagList_ = tags;
    _tagsNameArray = ComFqLibToolsConstants_tagList_;
    [self loadModel];
    if([self.headViewArray count] == 0){
        label.hidden = false;
    }else{
        label.hidden = true;
    }
    [_tableView reloadData];
    [loadingDialog close];
}

-(void)onErrorWithInt:(int)code withJavaLangThrowable:(JavaLangThrowable *)error{
    [loadingDialog close];
    [[UIAlertViewTool getInstance] showAutoDismisDialog:@"获取标签列表失败" width:210 height:120];
}
-(void)doBackPressed:id{
    [self.navigationController popViewControllerAnimated:true];
}

-(void)addPressed:id{
    NewBuildTagViewController *controllor = [[NewBuildTagViewController alloc] init];
    ComFqHalcyonEntityTag *tag = [[ComFqHalcyonEntityTag alloc] init];
    controllor.mTag = tag;
    [self.navigationController pushViewController:controllor animated:true];
}

- (void)loadModel{
    _currentRow = -1;
    
    [self.headViewArray removeAllObjects];
    
    for(int i = 0;i< _tagsNameArray.size ;i++)
    {
        HeadView* headview = [[HeadView alloc] init];
        headview.delegate = self;
        headview.section = i;
        NSString *title = [[_tagsNameArray getWithInt:i] getName];
        
        [headview.backBtn setTitle:[NSString stringWithFormat:@"%@(%d)",title,[[_tagsNameArray getWithInt:i] getContacts].size] forState:UIControlStateNormal];
        [headview.backBtn setTag:i];
        //长按事件
        UILongPressGestureRecognizer* longPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPressGesture:)];
        longPressGesture.minimumPressDuration = 1;
        longPressGesture.allowableMovement = 15;
        longPressGesture.numberOfTouchesRequired = 1;
        [headview.backBtn addGestureRecognizer:longPressGesture];
        headview.backBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
        [[headview.backBtn titleLabel] setFont:[UIFont systemFontOfSize:15.0]];
        [headview.backBtn setContentEdgeInsets:UIEdgeInsetsMake(0, 40, 0, 0)];
        headview.backBtn.contentHorizontalAlignment = 1;
        [self.headViewArray addObject:headview];
    }
}

-(void)handleLongPressGesture:(UILongPressGestureRecognizer*)gestureRecognizer{
    int i = [gestureRecognizer.self.view tag];
    if([gestureRecognizer state] == UIGestureRecognizerStateBegan){
         dialog = [[UIAlertViewTool getInstance] showNewDelDialog:[NSString stringWithFormat:@"是否编辑标签:%@?",[[_tagsNameArray getWithInt:i] getName]]  target:self actionOk:@selector(sureClicked:) actionCancle:@selector(cancleClicked:)];
        self.tags = [_tagsNameArray getWithInt:i];
    }else if([gestureRecognizer state] == UIGestureRecognizerStateEnded){
        
    }
    
}

-(void)sureClicked:selector{
    [dialog close];
    NewBuildTagViewController* controller = [[NewBuildTagViewController alloc]init];
    controller.mTag = self.tags;
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)cancleClicked:selector{
    [dialog close];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    _tableView= nil;
}

#pragma mark - TableViewdelegate&&TableViewdataSource

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 0.5)];
    [footerView setBackgroundColor:[UIColor grayColor]];
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    HeadView* headView = [self.headViewArray objectAtIndex:indexPath.section];
    
    return headView.open?45:0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 45;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}


- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [self.headViewArray objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    HeadView* headView = [self.headViewArray objectAtIndex:section];
    int i = [[_tagsNameArray getWithInt:section] getContacts].size;
    return headView.open?i:0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.headViewArray count];
}



- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *indentifier = @"ContactsTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    JavaUtilArrayList *contactsList = [[_tagsNameArray getWithInt:_currentSection] getContacts];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indentifier];
        UIButton* backBtn=  [[UIButton alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 45)];
        backBtn.tag = 20000;
        backBtn.userInteractionEnabled = NO;
        [cell.contentView addSubview:backBtn];
        
        UIImageView* headView = [[UIImageView alloc]initWithFrame:CGRectMake(55, 2, 40, 40)];
        [self setRoundBounds:20.0f view:headView];
        [self setBorderWithView:1.0 color:[[UIColor alloc]initWithRed:98/255.0 green:192/255.0 blue:180/255.0 alpha:1].CGColor view:headView];
        
        [cell.contentView addSubview:headView];
        [headView setTag:10000];
        
        headView.image = [UIImage imageNamed:@""];
        UILabel * nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(120, 11, 190, 21)];
        [cell.contentView addSubview:nameLabel];
        [nameLabel setTag:30000];
        nameLabel.textAlignment = 0;
    }
    
    UILabel* nameLabel = (UILabel*)[cell.contentView viewWithTag:30000];
    nameLabel.text = [[contactsList getWithInt:(int)indexPath.row] getUsername];
    UIImageView* headView = (UIImageView*)[cell.contentView viewWithTag:10000];
    ComFqHalcyonEntityPhoto* photo = [[ComFqHalcyonEntityPhoto alloc] init];
    [photo setImageIdWithInt:[[contactsList getWithInt:(int)indexPath.row] getImageId]];
    
    OcDownLoadImage * download = [[OcDownLoadImage alloc] init];
    int userId = [(ComFqHalcyonEntityContacts*)[contactsList getWithInt:(int)indexPath.row] getImageId];
    [download downLoadImage:userId view:headView];
    
    UIButton* backBtn = (UIButton*)[cell.contentView viewWithTag:20000];
    HeadView* view = [self.headViewArray objectAtIndex:indexPath.section];
    
    if (view.open) {
        if (indexPath.row == _currentRow) {
        }
    }
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor blackColor];
    return cell;
}

/**child click listener*/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _currentRow = indexPath.row;
    NSLog(@"%ld",(long)_currentRow);
    [_tableView reloadData];
    JavaUtilArrayList *contactsList = [[_tagsNameArray getWithInt:_currentSection] getContacts];
    UserInfoViewController* controller = [[UserInfoViewController alloc]init];
    controller.mUser = [contactsList getWithInt:(int)indexPath.row];
    controller.isFriend = true;
    controller.mRelationId = [[contactsList getWithInt:(int)indexPath.row] getRelationId];
    [self.navigationController pushViewController:controller animated:YES];
}


#pragma mark - HeadViewdelegate
-(void)selectedWith:(HeadView *)view{
    _currentRow = -1;
    if (view.open) {
        for(int i = 0;i<[headViewArray count];i++)
        {
            HeadView *head = [headViewArray objectAtIndex:i];
            head.open = NO;
        }
        [_tableView reloadData];
        return;
    }
    _currentSection = view.section;
    
    [self reset];
    
}

//界面重置
- (void)reset
{
    for(int i = 0;i<[headViewArray count];i++)
    {
        HeadView *head = [headViewArray objectAtIndex:i];
        
        if(head.section == _currentSection)
        {
            head.open = YES;
            
        }else {
            
            head.open = NO;
        }
        
    }
    [_tableView reloadData];
}

-(void)setRoundBounds:(CGFloat)radius view:(UIView*)mView {
    mView.layer.masksToBounds = YES;
    mView.layer.cornerRadius = radius;
}

-(void)setBorderWithView:(CGFloat)width color :(CGColorRef)tmpColor view:(UIView*)mView{
    mView.layer.borderColor = tmpColor;
    mView.layer.borderWidth = width;
    mView.layer.backgroundColor = [[UIColor alloc]initWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1].CGColor;
}


@end

