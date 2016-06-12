//
//  StructuredViewController.m
//  DoctorPlus_ios
//
//  Created by 廖敏 on 15/7/23.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

#import "StructuredViewController.h"
#import "SymptomsViewCell.h"
#import "StructuredLogic.h"
#import "DoctorPlus_ios-Swift.h"
#import "JSONObject.h"
#import "JSONArray.h"
#import "Java/util/Iterator.h"
#import "StructuredTimeScrollView.h"
#import "AFNetworking.h"
#import "ScannerViewController.h"
#import "UriConstants.h"

@interface StructuredViewController () <UICollectionViewDataSource,UICollectionViewDelegate,HalcyonHttpResponseHandle_HalcyonHttpHandleDelegate>
{
    ComFqHalcyonLogicPracticeStructuredLogic* logic;
    FQJSONArray* data;
    LoadingView* loadingView;
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet StructuredTimeScrollView *leftScrollView;

@end

@implementation StructuredViewController


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)requireData:(NSInteger)patient_id
{
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.securityPolicy.allowInvalidCertificates = YES;
//    manager.requestSerializer = [AFJSONRequestSerializer serializer];   //json请求
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer]; //json返回
//    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
//    NSMutableDictionary* parameter = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:patient_id],@"patient_id", nil];
//    NSLog(@"%@",parameter);
//    NSString* url = [NSString stringWithFormat:@"%@/patientInfo/event_list.do",ComFqLibToolsUriConstants_Conn_get_URL_PUB_()];
//    [manager POST:url parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSString* returnData = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        [logic paserJsonWithNSString:returnData];
//        NSLog(@"JSON: %@",returnData);
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"JSON: %@",error);
//    }];
    [self showLoadingView];
    [logic requireDataWithInt:patient_id];

}

- (void)handleErrorWithInt:(int)errorCode
     withJavaLangThrowable:(JavaLangThrowable *)e
{
    [self.view makeToast:@"获取结构化数据错误"];
//    NSString* jsonPath = [[NSBundle mainBundle].bundlePath stringByAppendingPathComponent:@"strut.txt"];
//    NSString* json = [NSString stringWithContentsOfFile:jsonPath encoding:NSUTF8StringEncoding error:nil];
//    [logic paserJsonWithNSString:json];
    [self dismissLoadingView];
}

- (void)handleSuccessWithId:(id)object
{
    [self dismissLoadingView];
    if([object isKindOfClass:[FQJSONArray class]]){
        data = (FQJSONArray*)object;
        [_collectionView reloadData];
        _leftScrollView.data = data;
        NSLog(@"%@",data);
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self hiddenRightImage:YES];
    [_collectionView registerNib:[UINib nibWithNibName:@"SymptomsViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"SymptomsViewCell"];
    logic = [[ComFqHalcyonLogicPracticeStructuredLogic alloc] init];
    logic->delegate_ = self;
    [self requireData:_patientId]; //672
    [self showLoadingView];
}

-(void)showLoadingView
{
//    if(loadingView) [loadingView removeFromSuperview];
//    loadingView = [[LoadingView alloc] initWithFrame:self.containerView.bounds];
//    [self.containerView addSubview:loadingView];
}

-(void)dismissLoadingView
{
//    if(loadingView) [loadingView removeFromSuperview];
//    loadingView = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if(data){
        int count = 0;
        for (int i = 0; i < [data length]; i++) {
            FQJSONObject* ob = [data optJSONObjectWithInt:i];
            count += [ob optIntWithNSString:@"maxSize"];
        }
        return count;
    }
    return 0;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 4;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    int column = indexPath.row%4;
    int endSection = 0;
    int startSection = 0;
    FQJSONObject* json = nil;
    for (int i = 0; i < [data length]; i++) {
        FQJSONObject* ob = [data optJSONObjectWithInt:i];
        startSection = endSection;
        endSection = startSection + [ob optIntWithNSString:@"maxSize"];
        if(indexPath.section >= startSection && indexPath.section < endSection) {
            json = ob;
            break;
        }
    }
    int index = indexPath.section - startSection;
    switch (column) {
        case 0:
        {
            FQJSONArray* symptoms = [json optJSONArrayWithNSString:@"symptoms"];
            if(symptoms && [symptoms length]>index){
                FQJSONObject* obj = [symptoms optJSONObjectWithInt:index];
                @try {
                    NSString* infoId = [obj optStringWithNSString:@"recordInfoId"];
                    int32_t recordInfoId = [infoId intValue];
                    ComFqHalcyonEntityPracticeRecordAbstract* abs = [[ComFqHalcyonEntityPracticeRecordAbstract alloc] init];
                    [abs setRecordInfoIdWithInt:recordInfoId];
                    NewNormalRecordViewController* controller = [[NewNormalRecordViewController alloc] init];
                    controller.recordAbstract = abs;
                    [self.navigationController pushViewController:controller animated:YES];
                }
                @catch (NSException *exception) {
                    
                }
                @finally {
                    
                }
                
            }
            break;
        }
        case 1:
        {
            FQJSONArray* diagnosis = [json optJSONArrayWithNSString:@"diagnosis"];
            if(diagnosis && [diagnosis length]>index){
                FQJSONObject* obj = [diagnosis optJSONObjectWithInt:index];
                @try {
                    NSString* infoId = [obj optStringWithNSString:@"recordInfoId"];
                    int32_t recordInfoId = [infoId intValue];
                    ComFqHalcyonEntityPracticeRecordAbstract* abs = [[ComFqHalcyonEntityPracticeRecordAbstract alloc] init];
                    [abs setRecordInfoIdWithInt:recordInfoId];
                    NewNormalRecordViewController* controller = [[NewNormalRecordViewController alloc] init];
                    controller.recordAbstract = abs;
                    [self.navigationController pushViewController:controller animated:YES];
                }
                @catch (NSException *exception) {
                    
                }
                @finally {
                    
                }

            }
            break;
        }
        case 2:
        {
            FQJSONArray* checkups = [json optJSONArrayWithNSString:@"checkups"];
            if(checkups && [checkups length]>index){
                FQJSONObject* obj = [checkups optJSONObjectWithInt:index];
                @try {
                    NSString* infoId = [obj optStringWithNSString:@"recordInfoId"];
                    int32_t recordInfoId = [infoId intValue];
                    ComFqHalcyonEntityPracticeRecordAbstract* abs = [[ComFqHalcyonEntityPracticeRecordAbstract alloc] init];
                    [abs setRecordInfoIdWithInt:recordInfoId];
                    NewNormalRecordViewController* controller = [[NewNormalRecordViewController alloc] init];
                    controller.recordAbstract = abs;
                    [self.navigationController pushViewController:controller animated:YES];
                }
                @catch (NSException *exception) {
                    
                }
                @finally {
                    
                }
                
            }

            break;
        }
        case 3:
        {
           
            break;
        }
        default:
            break;
    }
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    StructuredCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SymptomsViewCell" forIndexPath:indexPath];
    int column = indexPath.row%4;
    int endSection = 0;
    int startSection = 0;
    FQJSONObject* json = nil;
    for (int i = 0; i < [data length]; i++) {
        FQJSONObject* ob = [data optJSONObjectWithInt:i];
        startSection = endSection;
        endSection = startSection + [ob optIntWithNSString:@"maxSize"];
        if(indexPath.section >= startSection && indexPath.section < endSection) {
            json = ob;
            break;
        }
    }
    [cell reset];
    int index = indexPath.section - startSection;
    cell.cellStyle = column;
    cell.row = indexPath.row;
    cell.index = index;
    switch (column) {
        case 0:
        {
            FQJSONArray* symptoms = [json optJSONArrayWithNSString:@"symptoms"];
            if([symptoms length]>index){
                FQJSONObject* obj = [symptoms optJSONObjectWithInt:index];
                NSString* text = [NSString stringWithFormat:@"%@(%@)",[obj optStringWithNSString:@"symptomName"],[obj optStringWithNSString:@"bodypart"]];
                cell.text = text;
                cell.empty = NO;
            }
            break;
        }
        case 1:
        {
            FQJSONArray* diagnosis = [json optJSONArrayWithNSString:@"diagnosis"];
            if([diagnosis length]>index){
                FQJSONObject* obj = [diagnosis optJSONObjectWithInt:index];
                NSString* text = [obj optStringWithNSString:@"diagnosis"];
                if([text isEqualToString:@""]){
                    text = [obj optStringWithNSString:@"result"];
                }
                cell.text = text;
                cell.empty = NO;
            }
            break;
        }
        case 2:
        {
            FQJSONArray* checkups = [json optJSONArrayWithNSString:@"checkups"];
            if([checkups length]>index){
                FQJSONObject* obj = [checkups optJSONObjectWithInt:index];
                cell.text = [obj optStringWithNSString:@"checkupName"];
                cell.empty = NO;
            }
            break;
        }
        case 3:
        {
            FQJSONArray* treatments = [json optJSONArrayWithNSString:@"treatments"];
            if([treatments length]>index){
                FQJSONObject* obj = [treatments optJSONObjectWithInt:index];
                cell.text = [obj optStringWithNSString:@"treatment"];
                cell.empty = NO;
            }
            break;
        }
        default:
            break;
    }
    FQJSONArray* discharges = [json optJSONArrayWithNSString:@"discharges"];
    if([discharges length]>index){
        FQJSONObject* obj = [discharges optJSONObjectWithInt:index];
        cell.discharge = YES;
    }
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_leftScrollView setContentOffset:scrollView.contentOffset];
}

@end
