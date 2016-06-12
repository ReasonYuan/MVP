//
//  TextViewController.m
//  DoctorPlus_ios
//
//  Created by reason on 15-7-19.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

#import "TextViewController.h"
#import "RecordViewCell.h"
#import "PracticeLoadingView.h"
#import "RecognitionLogic.h"


@interface TextViewController ()

@end

@implementation TextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
//    _tableView.frame = CGRectMake(20, 0, [[UIScreen mainScreen] bounds].size.width-40, [[UIScreen mainScreen] bounds].size.height);
    
    [_tableView registerNib:[UINib nibWithNibName:@"RecordViewCell" bundle:nil] forCellReuseIdentifier:@"RecordViewCell"];
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    
//    [[UIAlertViewTool getInstance] showLoadingDialog:@"sb"];
    
    
    
   ComFqHalcyonLogicPracticeRecognitionLogic* logic = [[ComFqHalcyonLogicPracticeRecognitionLogic alloc] initWithComFqHalcyonLogicPracticeRecognitionLogic_RecognitionCallBack:nil];
    
    [logic loadRecognitionListWithInt:0 withInt:1 withInt:5];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
//    _tableView.frame = CGRectMake(5, 0, [[UIScreen mainScreen] bounds].size.width-10, [[UIScreen mainScreen] bounds].size.height);
//    _tableView.backgroundColor = [UIColor grayColor];
    
//    [_tableView registerNib:[UINib nibWithNibName:@"ContactsTableViewCell" bundle:nil] forCellReuseIdentifier:@"ContactsTableViewCell"];
    
    
    
//    PracticeLoadingView* loading = [[PracticeLoadingView alloc] initWithFrame:self.view.frame];
//    loading.frame = CGRectMake(0, 0, 320, 500);
    
    //loading.frame = CGRectMake(0, 0, _containerView.frame.size.width, _containerView.frame.size.height);
//    [loading setTag:999];
//    [FQBaseViewController addChildViewFullInParent:loading parent:self.view];
//    [_containerView addSubview:loading];

    
}


//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 1;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 30;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    printf("dsb");
}

- (UITableViewCell *)tableView: (UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    RecordViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"RecordViewCell"];
    return cell;
    
    
//    PatientItemCell* cell = [[PatientItemCell alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
//    return cell;
    
    
    
//    UITableViewCell* cell = [RecordViewCell getRecordCell:_tableView];
//    
//    NSString* cellIdentifier = @"programmaticCell";
//    MGSwipeTableCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//    if(!cell){
//        cell = [[MGSwipeTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
//        
//        cell.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width-80, 44);
//      cell.contentView.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width-80, 44);
//    }
//    
//    
//    ContactsTableViewCell* view = [[NSBundle mainBundle] loadNibNamed:@"ContactsTableViewCell" owner:self options:nil][0];
//    view.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width-80, 44);
//    view.contentView.frame =CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width-80, 44);
//
//    [cell.contentView addSubview:view];
//    cell.delegate = self;
//    
//    cell.rightSwipeSettings.transition = MGSwipeTransitionStatic;
//    cell.rightExpansion.buttonIndex = -1;
//    cell.rightExpansion.fillOnTrigger = false;
//    cell.rightButtons = [self createRightButtons:3];
//    //        cell.backgroundColor= [UIColor clearColor];

 
    return cell;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


/**
 *创建左滑打开的多个按钮
 *
 */
-(NSMutableArray *)createRightButtons:(int)count{
    NSMutableArray* array = [[NSMutableArray alloc] init];
    NSArray* iconNames = [NSArray arrayWithObjects:@"btn_patient_jiegou.png",@"btn_patient_share.png",@"btn_patient_del.png", nil];
    
    UIColor* color = [UIColor colorWithRed:29/255.f green:31/255.f blue:102/255.f alpha:1];
    
    for(int i = 0; i < 3; i++){
        MGSwipeButton* button;
        button = [MGSwipeButton  buttonWithTitle:nil icon:[UIImage imageNamed:[iconNames objectAtIndex:i]] backgroundColor:[UIColor redColor]];
        button.imageEdgeInsets = UIEdgeInsetsMake(30, 10, 30, 10);
        
        [array addObject:button];
    }
    
    return array;
}


@end
