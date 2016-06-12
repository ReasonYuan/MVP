//
//  SecondViewController.m
//  Test04
//
//  Created by HuHongbing on 9/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FirstViewController.h"
#import "DoctorPlus_ios-Swift.h"
@interface FirstViewController ()

@end

@implementation FirstViewController
@synthesize tableView = _tableView;
@synthesize headViewArray;


- (void)viewDidLoad
{
    [super viewDidLoad];
    headViewArray = [[NSMutableArray alloc]init];
    _titleNameArray = [[NSMutableArray alloc] init];
    _departmentDic = [NSMutableDictionary dictionary];
    _departmentNameArray = [[NSArray alloc ]initWithObjects: @"外科",@"泌尿科",@"胸外科",@"普通外科",@"乳腺外科",@"血管外科",@"神经外科",@"烧伤外科",@"整形外科",@"移植外科",@"显微外科",@"胰腺外科",@"心外科",@"肝外科",@"肛肠外科",@"胃肠外科",@"内科",@"呼吸内科",@"消化内科",@"肾脏内科",@"血液内科",@"感染科",@"风湿免疫科",@"神经内科",@"变态反应病科",@"老年病科",@"普通内科",@"心内科",@"内分泌科",@"肝内科",@"儿科",@"儿内科",@"儿外科",@"新生儿科",@"妇产科",@"妇科",@"产科",@"妇产内分泌科",@"皮肤性病科",@"肿瘤科",@"针灸科",@"推拿科",@"中医科",@"营养科",@"骨科",@"精神及心理科",@"重症医学科",@"眼科",@"耳鼻咽喉及头颈科",@"耳鼻咽喉头颈科",@"口腔科",@"麻醉科及疼痛医学",@"医学影像科",@"放射科",@"核医学科",@"超声诊断科",@"心超诊断",@"其他",nil];
   
    [self initDepartmentDatas];
    [self loadModel];
    self.view.backgroundColor = [UIColor whiteColor];
    NSInteger screenWidth = [[UIScreen mainScreen] bounds].size.width;
    NSInteger screenHeight = [[UIScreen mainScreen] bounds].size.height;
    UIView* topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 70)];
    topView.backgroundColor = [[UIColor alloc]initWithRed:98/255.0 green:192/255.0 blue:180/255.0 alpha:1];
    [self.view addSubview:topView];
    UIButton* backBtn = [[UIButton alloc]initWithFrame:CGRectMake(20, 35, 17, 17)];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"btn_back.png"] forState:UIControlStateNormal];
    [self.view addSubview:backBtn];
    UIButton* backBtnView = [[UIButton alloc]initWithFrame:CGRectMake(11, 26, 34, 34)];
    [backBtnView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:backBtnView];
    UILabel * titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth/2-240, 29, 480, 29)];
    titleLabel.textColor = [[UIColor alloc]initWithRed:245.0/255.0 green:229.0/255.0 blue:207.0/255.0 alpha:1];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = @"科室分布";
    [self.view addSubview:titleLabel];
    [backBtnView addTarget:self action:@selector(doBackPressed:) forControlEvents:UIControlEventTouchUpInside];
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 70,screenWidth,screenHeight - 70) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorColor = [UIColor clearColor];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
 
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self initDepartmentDatas];
    [self loadModel];
    [_tableView reloadData];
}

-(void)doBackPressed:id{
    [self.navigationController popViewControllerAnimated:true];
}

- (void)loadModel{
    _currentRow = -1;

    [self.headViewArray removeAllObjects];

    for(int i = 0;i< _titleNameArray.count ;i++)
	{
		HeadView* headview = [[HeadView alloc] init];
        headview.delegate = self;
		headview.section = i;
        NSString *title = _titleNameArray[i];
        JavaUtilArrayList *arrayList = [_departmentDic valueForKey:title];
        [headview.backBtn setTitle:[NSString stringWithFormat:@"%@(%d)",title,[arrayList size]] forState:UIControlStateNormal];
        headview.backBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
        [[headview.backBtn titleLabel] setFont:[UIFont systemFontOfSize:15.0]];
        [headview.backBtn setContentEdgeInsets:UIEdgeInsetsMake(0, 40, 0, 0)];
        headview.backBtn.contentHorizontalAlignment = 1;
		[self.headViewArray addObject:headview];
	}
}

- (void)initDepartmentDatas{

    [_titleNameArray removeAllObjects];

    [_departmentDic removeAllObjects];
    
    for (int i = 0; i < _departmentNameArray.count; i++) {
        NSString *title = _departmentNameArray[i];
        JavaUtilArrayList *arrayList = [ComFqLibToolsConstants_contactsDepartmentMap_ getWithId:title];
        
        if (arrayList.size > 0) {
            [_titleNameArray insertObject:title atIndex:0];
            [_departmentDic setValue:arrayList forKey:title];
        }else{
            [_departmentDic setValue:arrayList forKey:title];
            if ([_titleNameArray count] == 0) {
                [_titleNameArray insertObject:title atIndex:0];
            }else{
                [_titleNameArray insertObject:title atIndex:[_titleNameArray count]];
            }
            
        }
    }
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
    NSString *title = _titleNameArray[section];
    JavaUtilArrayList *arrayList = [_departmentDic valueForKey:title];
    return headView.open?[arrayList size]:0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.headViewArray count];
}



- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *indentifier = @"ContactsTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    NSString *openTitle = _titleNameArray[_currentSection];
    JavaUtilArrayList *arrayList = [_departmentDic valueForKey:openTitle];
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
    nameLabel.text = [[arrayList getWithInt:(int)indexPath.row] getUsername];
    UIImageView* headView = (UIImageView*)[cell.contentView viewWithTag:10000];
    ComFqHalcyonEntityPhoto* photo = [[ComFqHalcyonEntityPhoto alloc] init];
    [photo setImageIdWithInt:[[arrayList getWithInt:(int)indexPath.row] getImageId]];
    
    OcDownLoadImage * download = [[OcDownLoadImage alloc] init];
    int userId = [(ComFqHalcyonEntityContacts*)[arrayList getWithInt:(int)indexPath.row] getImageId];
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
    NSString *openTitle = _titleNameArray[_currentSection];
    JavaUtilArrayList *arrayList = [_departmentDic valueForKey:openTitle];
    UserInfoViewController* controller = [[UserInfoViewController alloc]init];
    controller.mUser = [arrayList getWithInt:(int)indexPath.row];
    controller.isFriend = true;
    controller.mRelationId = [[arrayList getWithInt:(int)indexPath.row] getRelationId];
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
