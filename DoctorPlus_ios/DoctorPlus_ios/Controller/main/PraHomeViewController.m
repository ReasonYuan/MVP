//
//  PraHomeViewController.m
//  DoctorPlus_ios
//
//  Created by reason on 15-7-16.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

#import "PraHomeViewController.h"
#import "DoctorPlus_ios-Swift.h"
#import "HomeGetChartDataLogic.h"
#import "ReadHistoryManager.h"
#import "InsightView.h"
#import "PatientUpdateListLogic.h"
#import "Java/util/Iterator.h"
#import "Platform.h"
@interface PraHomeViewController ()<ChartViewDataSource,ChartViewDelegate,ComFqHalcyonLogic2HomeGetChartDataLogic_GetChartDatCallBack,
            ComFqHalcyonLogicPracticePatientUpdateListLogic_PatientListCallback,InsightViewDelegate>
{
    ExplorationView* _explorationView;
    NSMutableArray* data;
    NSMutableArray* showData;
    NSInteger showIndexInData;
    int currentChartViewType;//病例总量和每日上传的两个类型。1为病例总量 2为每日上传
    
    ChartViewRefreshDirection direction;
    InsightView* insightView;//第三站图表
    
    int listPage;//下方列表的页数，当列表数据源切换时，listPage会重新从1开始计算，当在Insight表中，选择的数据改变时也会从新开始计算
    
    
    int dataSrcType;//数据源的类型：1为病例总量和每日上传，2为Insight
    JavaUtilHashMap* listData;//下方里边数据
    JavaUtilArrayList* diagnoseResDatas;//请求诊断的数据，主要用于从其他界面回到主页时做数据刷新
    
    ComFqHalcyonLogic2HomeGetChartDataLogic* logic; //第1、2张图表获得图表数据的logic
    ComFqHalcyonLogicPracticePatientUpdateListLogic* patientListlogic; //下方list列表获得数据的logic
    BOOL firstShow;
}
@property (weak, nonatomic) IBOutlet UILabel *chartMonth;
@property (weak, nonatomic) IBOutlet UILabel *chartYear;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIImageView *topBg;

@end

@implementation PraHomeViewController
@synthesize chartViewContainer;


//- (void)badAccess
//{
//    void (*nullFunction)() = NULL;
//    
//    nullFunction();
//}


- (void)viewDidLoad {
    [super viewDidLoad];
//    [Tools Post:^{
//        [self badAccess];
//    } Delay:1];
//    [self performSelector:@selector(badAccess) withObject:nil afterDelay:1.f];
    [UITools setRealmCachePath];
    [[ComFqLibPlatformPlatform getInstance] addOnNetworkChangeListenerWithComFqLibPlatformPlatform_onNetworkChangeListener:[ComFqHalcyonPracticePhotosManager getInstance]];
    showIndexInData = -1;
    currentChartViewType = 1;
    dataSrcType = 1;
    listPage = 1;
    if([MessageTools isExperienceMode]){
        dataSrcType = 2;
    }
 
//    [ComFqHalcyonPracticeReadHistoryManager getInstance];
    
    _explorationView = [[ExplorationView alloc] initWithFrame:CGRectMake(0, 0, _patientListContainer.frame.size.width, _patientListContainer.frame.size.height+20)];
    [FQBaseViewController addChildViewFullInParent:_explorationView parent:_patientListContainer ];
    _explorationView.verLabel.hidden = false;
    _explorationView.isHomePage = true;
    
    chartViewContainer.chartDataSource = self;
    chartViewContainer.chartDelegate = self;
    data = [[NSMutableArray alloc] init];
    logic = [[ComFqHalcyonLogic2HomeGetChartDataLogic alloc] initWithComFqHalcyonLogic2HomeGetChartDataLogic_GetChartDatCallBack:self];
    NSString* endFormat = [ComFqHalcyonLogic2HomeGetChartDataLogic getStartDateFormateWithComFqHalcyonLogic2ChartEntity:nil withInt:0];
    NSString* startFormet = [ComFqHalcyonLogic2HomeGetChartDataLogic getStartDateFormateWithNSString:endFormat withInt:30];
    [logic requireChartDataWithNSString:startFormet withNSString:endFormat withInt:currentChartViewType];
  
    [chartViewContainer showLoading];
//    [self.view makeToast:@"启用随机数据"];
    //    [chartViewContainer moveToIndex:data.count-1 ChartViewAlignment:AlignmentLeft];
    [_btnChartAll setSelected:YES];
    showData = [[NSMutableArray alloc] init];
    chartViewContainer.strokeColor = [UIColor orangeColor];
    
    patientListlogic = [[ComFqHalcyonLogicPracticePatientUpdateListLogic alloc] initWithComFqHalcyonLogicPracticePatientUpdateListLogic_PatientListCallback:self];
    firstShow = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changePage:) name:@"changePage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refurbishBtnClick:) name:@"refurbishBtnClick" object:nil];
    if ([MessageTools isExperienceMode]) {
        [Tools Post:^{
             [self onJieGouHuaBtnClick:_btnChartIn];
        } Delay:.2f];
    }
    
    _environmentLabel.hidden = !ComFqLibToolsUriConstants_Conn_DEBUG_MODE;
}


-(void)viewDidUnload{
    [super viewDidUnload];
     [[NSNotificationCenter defaultCenter] removeObserver:self name:@"changePage" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refurbishBtnClick" object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [logic requireTotalCount];
    
    listPage = 1;
    [self refurbishBtnClick:nil];
}


/**
 * [病案总量]被点击
 */
- (IBAction)onPatientCountBtnClick:(id)sender {
    //游客模式就弹框返回
    if([MessageTools isExperienceMode:self.navigationController])return;
    
    firstShow = YES;
    [_btnChartAll setSelected:YES];
    [_btnChartDay setSelected:NO];
    [_btnChartIn setSelected:NO];
    currentChartViewType = 1;
    direction = DirectionLeft;
    showIndexInData = -1;
    NSString* endFormat = [ComFqHalcyonLogic2HomeGetChartDataLogic getStartDateFormateWithComFqHalcyonLogic2ChartEntity:nil withInt:0];
    NSString* startFormet = [ComFqHalcyonLogic2HomeGetChartDataLogic getStartDateFormateWithNSString:endFormat withInt:30];
    [logic requireChartDataWithNSString:startFormet withNSString:endFormat withInt:currentChartViewType];
    chartViewContainer.strokeColor = [UIColor orangeColor];
    chartViewContainer.hidden = NO;
    if(insightView){
        [insightView removeFromSuperview];
        insightView.hidden = YES;
    }
    
    if (dataSrcType != 1) {
        dataSrcType = 1;
        [self ChangeDataType];
    }
}

/**
 * [每日上传]被点击
 */
- (IBAction)onPerDayCountBtnClick:(id)sender {
    
    //游客模式就弹框返回
    if([MessageTools isExperienceMode:self.navigationController])return;
    
    firstShow = YES;
    [_btnChartDay setSelected:YES];
    [_btnChartAll setSelected:NO];
    [_btnChartIn setSelected:NO];
    currentChartViewType = 2;
    showIndexInData = -1;
    direction = DirectionLeft;
    NSString* endFormat = [ComFqHalcyonLogic2HomeGetChartDataLogic getStartDateFormateWithComFqHalcyonLogic2ChartEntity:nil withInt:0];
    NSString* startFormet = [ComFqHalcyonLogic2HomeGetChartDataLogic getStartDateFormateWithNSString:endFormat withInt:30];
    [logic requireChartDataWithNSString:startFormet withNSString:endFormat withInt:currentChartViewType];
    chartViewContainer.strokeColor = [UIColor blueColor];
    chartViewContainer.hidden = NO;
    if(insightView){
        [insightView removeFromSuperview];
        insightView.hidden = YES;
    }
    
    if (dataSrcType != 1) {
        dataSrcType = 1;
        [self ChangeDataType];
    }
}

/**
 * [Insight]被点击
 */
- (IBAction)onJieGouHuaBtnClick:(id)sender {
    [_btnChartIn setSelected:YES];
    [_btnChartAll setSelected:NO];
    [_btnChartDay setSelected:NO];
    [logic requireInsight];
    if(!insightView) {
        insightView = [[InsightView alloc] initWithFrame:_topView.bounds];
        insightView.insightViewDelegate = self;
    }
    chartViewContainer.hidden = YES;
    [_topView insertSubview:insightView aboveSubview:_topBg];
    insightView.hidden = NO;
    
    if (dataSrcType != 2) {
        dataSrcType = 2;
        [self ChangeDataType];
    }
}

-(void)setChartViewData
{
    [showData removeAllObjects];
    NSInteger num = [chartViewContainer cellCountOnePage];
    if(data.count > num){
        NSInteger startIndex = 0;
        if(showIndexInData < 0){ //当前数据的第一次显示
            if(direction == DirectionLeft)startIndex = data.count - num;
        }else{
            startIndex = showIndexInData;
        }
        for (NSInteger i = startIndex; i < startIndex + num; i++) {
            [showData addObject:[data objectAtIndex:i]];
        }
        showIndexInData = startIndex;
    }
    [chartViewContainer reloadData];
    if(firstShow){
        [Tools Post:^{
              [self chartView:self.chartViewContainer firstCellShowIndex:[showData count]-1];
        } Delay:.2f];
        firstShow = NO;
    }
}

-(void)chartView:(ChartView*)view didClickedAtIndex:(NSInteger)index
{
    ComFqHalcyonLogic2ChartEntity* item = [showData objectAtIndex:index];
    _chartMonth.text = [item getChineseDescriptionMM];
    _chartYear.text = [item getChineseDescriptionYYYY];
}

-(void)chartView:(ChartView*)view firstCellShowIndex:(NSInteger)index
{
    ComFqHalcyonLogic2ChartEntity* item = [showData objectAtIndex:index];
    _chartMonth.text = [item getChineseDescriptionMM];
    _chartYear.text = [item getChineseDescriptionYYYY];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(NSInteger)numberOfCellInChartView:(ChartView *)chartView
{
    return showData.count;
}

-(CGFloat)chartView:(ChartView *)view dataForIndex:(NSInteger)index
{
    ComFqHalcyonLogic2ChartEntity* item = [showData objectAtIndex:index];
    return item->copies_;
}

-(NSString*)chartView:(ChartView *)view titleForCell:(NSInteger)index
{
    ComFqHalcyonLogic2ChartEntity* item = [showData objectAtIndex:index];
    return [NSString stringWithFormat:@"%d日",item->dayInMonth_];
}

- (void)onGetChartDataWithJavaUtilArrayList:(JavaUtilArrayList *)pdata
                                    withInt:(int)type
{
    [chartViewContainer refreshCompleted];
    data = [Tools toNSarray:pdata];
    if(currentChartViewType == 1){
        chartViewContainer.strokeColor = [UIColor orangeColor];
    }else{
        chartViewContainer.strokeColor = [UIColor blueColor];
    }
    [self setChartViewData];
}

- (void)onGetTotalCountWithFQJSONObject:(FQJSONObject *)returnData
{
    _labelPatientCount.text = [NSString stringWithFormat:@"%d",[returnData optIntWithNSString:@"patient_count"]];
    _labelRecordCount.text = [NSString stringWithFormat:@"%d",[returnData optIntWithNSString:@"record_count"]];
}

- (void)onInsightDataReturnWithFQJSONObject:(FQJSONObject *)returnData
{
    if(insightView)[insightView setData:[returnData description]];
}

-(BOOL)chartView:(ChartView *)view canRefresh:(ChartViewRefreshDirection)pDirection
{
    if(pDirection == DirectionRight){
        ComFqHalcyonLogic2ChartEntity* item = [showData lastObject];
        return [item beforeToday];
    }else{
        return YES;
    }
}

///**
// *是否更改园的颜色
// */
//-(BOOL)chartView:(ChartView*)view changeCicleColor:(NSInteger)index
//{
//    ComFqHalcyonLogic2ChartEntity* item = [showData objectAtIndex:index];
//    if([item isToday]){
//        return YES;
//    }
//    return NO;
//}
//
//
///**
// *每个cell的宽度，不要去重载，还没测试
// */
//-(UIColor*)chartViewCicleColor:(ChartView*)view
//{
//    return [UIColor redColor];
//}

-(BOOL)chartView:(ChartView*)view isTodayIndex:(NSInteger)index
{
    ComFqHalcyonLogic2ChartEntity* item = [showData objectAtIndex:index];
    return [item isToday];
}

-(void)chartView:(ChartView *)view onRefresh:(ChartViewRefreshDirection)pDirection
{
    NSInteger num = [chartViewContainer cellCountOnePage];
    direction = pDirection;
    if(direction == DirectionLeft){
        if(showIndexInData - num < 0){
            [chartViewContainer showLoading];
            ComFqHalcyonLogic2ChartEntity* item = [showData objectAtIndex:0];
            NSString* endFormat = item->date_;
            NSString* startFormet = [ComFqHalcyonLogic2HomeGetChartDataLogic getStartDateFormateWithNSString:endFormat withInt:30];
            showIndexInData = -1;
            [logic requireChartDataWithNSString:startFormet withNSString:endFormat withInt:currentChartViewType];
            return;
        };
        showIndexInData -= num;
        [self setChartViewData];
    }else{
        if(showIndexInData + num > data.count- num){
            [chartViewContainer showLoading];
            ComFqHalcyonLogic2ChartEntity* item = [showData lastObject];
            NSString* startFormet = item->date_;
            NSString* endFormet = [ComFqHalcyonLogic2HomeGetChartDataLogic getEndDateFormateWithNSString:startFormet withInt:30];
            showIndexInData = -1;
            [logic requireChartDataWithNSString:startFormet withNSString:endFormet withInt:currentChartViewType];
            return;
        };
        showIndexInData += num;
        [self setChartViewData];
    }
}

- (void)onErrorWithInt:(int)code
          withNSString:(NSString *)msg
{
//    [chartViewContainer refreshCompleted];
    NSLog(@"%@",msg);
    [self.chartViewContainer refreshCompleted];
//    NSString* endFormat = [ComFqHalcyonLogic2HomeGetChartDataLogic getStartDateFormateWithComFqHalcyonLogic2ChartEntity:nil withInt:0];
//    NSString* startFormet = [ComFqHalcyonLogic2HomeGetChartDataLogic getStartDateFormateWithNSString:endFormat withInt:30];
//    data = (NSMutableArray*)[Tools toNSarray:[ComFqHalcyonLogic2HomeGetChartDataLogic getRandomChartEntitiesWithNSString:startFormet withNSString:endFormat]];
//    [chartViewContainer reloadData];
//    [chartViewContainer moveToIndex:data.count-1 ChartViewAlignment:AlignmentLeft];
}

/**
 *探索按钮被点击
 */
- (IBAction)onExploreClick:(id)sender {
//    [self.navigationController pushViewController:[[ExplorationViewController alloc] init] animated:YES];
    [self.navigationController pushViewController:[[PatientViewController alloc] init] animated:YES];
}


/**
 *获得到数据失败
 */
-(void)loadPatientErrorWithInt:(int)code withNSString:(NSString *)msg{
    if(listData&&![listData isEmpty]){
        return;
    }
    [_explorationView setViewShowOrHidden:_explorationView.SHOW_REFURBISH_BUTTON];
    [self.view makeToast:msg];
//    [[UIAlertViewTool getInstance] showAutoDismisDialog:msg width:[[UIScreen mainScreen] bounds].size.width-100 height:100];
}

/**
 * 切换数据类型时调用的方法<br/>
 * 第1、2张表和第3张表相互切换时调用的方法（即：[病例总量]、[每日上传]和[Insight]按钮点击切换时）
 * @pramas isInsight 是不是isInsight类型的图表
 */
-(void)ChangeDataType{
    listPage = 1;
    [_explorationView cleanDatas];
    if(dataSrcType == 1){
        [patientListlogic requestPatientListWithInt:listPage withInt:20];
    }else{
        if(diagnoseResDatas){
            [patientListlogic requestDiagnoseWithInt:listPage withInt:20 withJavaUtilArrayList:diagnoseResDatas];
        }
    }
}


//获得病案列表成功
-(void)loadPatientSuccessWithJavaUtilHashMap:(JavaUtilHashMap *)map{
     [_explorationView setViewShowOrHidden:_explorationView.SHOW_TABLE];
    
    if (listPage == 1) {
        listData = map;
        [_explorationView cleanDatas];
//    }else{
//        if(!listData){
//            listData = map;
//        }else{
//            [listData putAllWithJavaUtilMap:map];
//        }        
    }
    
    if ([map size]> 0) {
        listPage++;
        if(!listData){
             listData = map;
         }else{
              [listData putAllWithJavaUtilMap:map];
         }
        [_explorationView setListDatas:map];
    }
}


//Insight上某个选项被点击点击回调
-(void)onLegendChanged:(FQJSONObject*)json{
    JavaUtilArrayList* list = [[JavaUtilArrayList alloc] init];
    
    id<JavaUtilIterator> itor = [json keys];
    while ([itor hasNext]) {
        NSString* key = [itor next];
        BOOL value  = [json optBooleanWithNSString:key];
        if(value){
            [list addWithId:key];
        }
    }
    listPage = 1;
    diagnoseResDatas = list;
    [patientListlogic requestDiagnoseWithInt:listPage withInt:20 withJavaUtilArrayList:diagnoseResDatas];
}

//Insight第一次请求数据时返回的参数，用来请求下面列表数据
-(void)onDataRealy:(FQJSONArray*)json{
    if(diagnoseResDatas)return;
    diagnoseResDatas = [[JavaUtilArrayList alloc] init];
    for (int i = 0; i < [json length]; i++) {
        [diagnoseResDatas addWithId:[json optStringWithInt:i]];
    }
    [patientListlogic requestDiagnoseWithInt:listPage withInt:20 withJavaUtilArrayList:diagnoseResDatas];
}

//上拉分页
-(void)changePage:(NSNotification* )notification{
    if (dataSrcType == 1) {
        [patientListlogic requestPatientListWithInt:listPage withInt:20];
    }else{
        [patientListlogic requestDiagnoseWithInt:listPage withInt:20 withJavaUtilArrayList:diagnoseResDatas];
    }
}

//刷新按钮被点击
-(void)refurbishBtnClick:(NSNotification* )notification{
    if(dataSrcType == 1){
        [patientListlogic requestPatientListWithInt:listPage withInt:20];
    }else{
        if(!diagnoseResDatas || [diagnoseResDatas size] == 0)return;
        [patientListlogic requestDiagnoseWithInt:listPage withInt:20 withJavaUtilArrayList:diagnoseResDatas];
    }
    
    if(!listData || listPage == 1){
        [_explorationView setViewShowOrHidden:_explorationView.SHOW_ACTIVITY_IND_VIEW];
    }
}


-(void)showToast:(NSString*)msg{
    [self.view makeToast:msg];
//    [_patientListContainer makeToast:msg];
}

@end
