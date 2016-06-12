//
//  RecordViewCell.h
//  DoctorPlus_ios
//
//  Created by reason on 15-7-20.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

//#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RecordPatientEvent.h"
#import "RecordAbstract.h"
#import "RecognitionLogic.h"
#import "RecycleLogic.h"


@interface RecordViewCell:UITableViewCell<ComFqHalcyonLogicPracticeRecognitionLogic_ApplyRecognizeCallBack,ComFqHalcyonLogicPracticeRecycleLogic_Remove2RecycleCallBack,ComFqHalcyonLogicPracticeRecycleLogic_RecycleCallBack>
{

    ComFqHalcyonEntityPracticeRecordAbstract* recordEntity;
    NSIndexPath* indexPath;
    BOOL isRecycle;
    
    UILabel* labelRecordType;
    UILabel* labelRecordTime;
    UILabel* labelRecordName;
    UILabel* labelAbstract;
    UILabel* labelRecordStatus;
    
    UIImageView* imgRecordStatus;
    
    BOOL isOffline;
}

@property (weak, nonatomic) id<RecordPatientEvent> event;

@property (weak, nonatomic) IBOutlet UIView *contentContainer;

/**
 * 初始化数据,通过数据初始化UI
 */
-(void)initData:(ComFqHalcyonEntityPracticeRecordAbstract*)data IndexPath:(NSIndexPath*)indexPath Event:(id<RecordPatientEvent>)et;

-(void)initData:(ComFqHalcyonEntityPracticeRecordAbstract*)data IndexPath:(NSIndexPath*)indexPath Event:(id<RecordPatientEvent>)et isCanSliding:(BOOL)iscanSliding;

/**
 * 初始化数据,通过数据初始化UI
 */
-(void)initDataForRecycle:(ComFqHalcyonEntityPracticeRecordAbstract*)data IndexPath:(NSIndexPath*)indexPath Event:(id<RecordPatientEvent>)et;

-(void)setCanSliding:(BOOL) iscanSliding;

-(void)setOfflineStatus:(BOOL) isOffline;
@end
