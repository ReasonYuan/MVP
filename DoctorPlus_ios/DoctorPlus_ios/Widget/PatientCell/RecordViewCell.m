//
//  RecordViewCell.m
//  DoctorPlus_ios
//
//  Created by reason on 15-7-20.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

#import "RecordViewCell.h"
#import "PraHomeViewController.h"
#import "DoctorPlus_ios-Swift.h"

@implementation RecordViewCell
{
    ComFqHalcyonLogicPracticeRecognitionLogic* cloudLogic;
    ComFqHalcyonLogicPracticeRecycleLogic* recycleLogic;
    MGSwipeTableCell* swipe;

    
    BOOL isCanSliding;//是不是允许侧滑出菜单
    BOOL isClicked;
    IndetifyDialog *indetifyDialog;
    BOOL didSendInfo;
}
/**
 *初始化时
 */
- (void)awakeFromNib {
//    swipeWidth = [[UIScreen mainScreen] bounds].size.width-100;
//    self.contentContainer.frame = CGRectMake(0, 0, swipeWidth, 90);
    isCanSliding = true;
    didSendInfo = YES;
}

-(void)setCanSliding:(BOOL) iscanSliding{
    [swipe setEditing:!iscanSliding animated:NO];
}

/**
 * 初始化数据,UI显示为回收站类型
 */
-(void)initDataForRecycle:(ComFqHalcyonEntityPracticeRecordAbstract*)data IndexPath:(NSIndexPath*)dexPath Event:(id<RecordPatientEvent>)et{
    isRecycle = true;
    [self initData:data IndexPath:dexPath Event:et];
}

/**
 * 初始化数据,侧滑菜单是否可滑动
 */
-(void)initData:(ComFqHalcyonEntityPracticeRecordAbstract*)data IndexPath:(NSIndexPath*)dexPath Event:(id<RecordPatientEvent>)et isCanSliding:(BOOL)iscanSliding{
    isCanSliding = iscanSliding;
    [self initData:data IndexPath:dexPath Event:et];
}

/**
 * 初始化数据,默认普通情况即不是回收站页面的Cell
 */
-(void)initData:(ComFqHalcyonEntityPracticeRecordAbstract*)data IndexPath:(NSIndexPath*)dexPath Event:(id<RecordPatientEvent>)et{
    recordEntity = data;
    indexPath = dexPath;
    _event = et;

    int uiType = 0;
    if([recordEntity getRecStatus] > ComFqLibRecordRecordConstants_CLOUD_REC_ING){//大于ING为识别完成或识别失败
        uiType = 1;
    }
    //uiType = 1;
    
    
    if(swipe){
        [swipe removeFromSuperview];
        swipe = nil;
    }
    
    if(!swipe){
        [self initSwipe];
        
        UIView* view = [[NSBundle mainBundle] loadNibNamed:@"RecordViewCellAlpha" owner:self options:nil][uiType];
//        view.frame = CGRectMake(0, 0, swipeWidth, 90);
//        view.tag = 220;
//        [swipe.contentView addSubview:view];
        //如果用约束会有各种异常
        [FQBaseViewController addChildViewFullInParent:view parent:swipe.contentView ];
        
        //找到需要填充的控件
        labelAbstract = (UILabel*)[view viewWithTag:80];
        imgRecordStatus = (UIImageView*)[view viewWithTag:87];
        labelRecordStatus = (UILabel*)[view viewWithTag:88];
        
        if (uiType == 1) {
            labelRecordType = (UILabel*)[view viewWithTag:81];
            labelRecordTime = (UILabel*)[view viewWithTag:82];
            labelRecordName = (UILabel*)[view viewWithTag:83];
        }
        
        if([recordEntity getRecordType] == ComFqLibRecordRecordConstants_CLOUD_REC_ING){
            [[view viewWithTag:90] setHidden:NO];
        }
    }
    
    [self fillViewByUIType:uiType];
}


//-(void)willMoveToWindow:(UIWindow *)newWindow{
//    [super willMoveToSuperview:newWindow];
//    
//    if(newWindow){
//        self.contentContainer.frame = CGRectMake(0, 6, self.contentView.frame.size.width-100, 90);
//    }
//}

/**
 * 初始化swipe,因为复用会引起UI上的bug,所以会移除以前的，重新初始化
 */
-(void)initSwipe{
    NSString* cellIdentifier = @"RecordSwipeCell2";
    swipe = [[MGSwipeTableCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    
    swipe.backgroundColor = [UIColor colorWithRed:29/255.f green:31/255.f blue:102/255.f alpha:1];
    
//    swipe.frame = CGRectMake(0, 0, swipeWidth, 90);
//    swipe.contentView.frame = CGRectMake(0, 0, swipeWidth, 90);
//    [self.contentContainer addSubview:swipe];
    
    //如果用约束会有各种异常
    [FQBaseViewController addChildViewFullInParent: swipe parent:self.contentContainer];
    
    swipe.rightSwipeSettings.transition = MGSwipeTransitionStatic;
    swipe.rightExpansion.buttonIndex = -1;
    swipe.rightExpansion.fillOnTrigger = true;
    
    if(isRecycle){
        swipe.rightButtons = [self createRecycleRightButtons];
    }else{
        if(isCanSliding){
            swipe.rightButtons = [self createRightButtons];
        }
        //设置点击手势
        UITapGestureRecognizer*tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(Actiondo:)];
        [swipe addGestureRecognizer:tapGesture];
    }
    if([MessageTools isExperienceMode]){
        [swipe setEditing:YES animated:NO];
    }
}

/**
 * 根据传入的数据来填充
 * uiType contentView的类型，0表示待识别和识别中的，1表示识别完成和识别失败的
 */
-(void)fillViewByUIType:(int)uiType{
    [labelAbstract setText:[recordEntity getInfoAbstract]];
    if(uiType == 1){
        [labelRecordType setText:[recordEntity getTypeName]];
        
        NSString* time = [recordEntity getDeal2Time];
        if (![@"" isEqualToString:time]) {
            [labelRecordTime setText:[NSString stringWithFormat:@" (%@)",time]];
        }
        [labelRecordName setText:[recordEntity getRecordItemName]];
    }else{
        int recStatus = [recordEntity getRecStatus];
        
         NSString* imgName;
        if (recStatus == ComFqLibRecordRecordConstants_CLOUD_REC_ING) {
            imgName = @"photo_status_recording";
        }else if (recStatus == ComFqLibRecordRecordConstants_CLOUD_REC_FAIL) {
            imgName = @"photo_status_failed";
        }
        [labelRecordStatus setText:[ComFqLibRecordRecordConstants getRecSTRByTypeWithInt:[recordEntity getRecStatus]]];
        [imgRecordStatus setImage:[UIImage imageNamed:imgName]];
       
    }
}


/**
 *创建左滑打开的多个按钮
 *
 */
-(NSMutableArray *)createRightButtons{
    NSMutableArray* array = [[NSMutableArray alloc] init];
    NSArray* iconNames;
    
    //因为待云识别会多一个‘云识别’按钮
    if([recordEntity getRecStatus] == ComFqLibRecordRecordConstants_CLOUD_REC_WAIT){
        iconNames = [NSArray arrayWithObjects:@"btn_patient_del.png",@"btn_patient_share.png",@"btn_patient_cloud", nil];
    }else{
        iconNames = [NSArray arrayWithObjects:@"btn_patient_del.png",@"btn_patient_share.png", nil];//一般类型
    }
    
    
    UIColor* color = [UIColor colorWithRed:29/255.f green:31/255.f blue:102/255.f alpha:1];
    
    for(int i = 0; i < [iconNames count]; i++){
        MGSwipeButton* button;
        
        NSString* name = [iconNames objectAtIndex:i];
        button = [MGSwipeButton  buttonWithTitle:nil icon:[UIImage imageNamed:name] backgroundColor:color];
//        button.imageEdgeInsets = UIEdgeInsetsMake(30, 10, 30, 10);
        
        if (i==0) {
            [button addTarget:self action:@selector(remove:) forControlEvents:UIControlEventTouchUpInside];
        }else if(i==1){
            [button addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
        }else{
            [button addTarget:self action:@selector(cloud:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [array addObject:button];
    }
    
    return array;
}

/**
 *创建左滑打开的多个按钮
 *
 */
-(NSMutableArray *)createRecycleRightButtons{
    NSMutableArray* array = [[NSMutableArray alloc] init];
    
    NSArray* iconNames = [NSArray arrayWithObjects:@"btn_patient_del.png",@"btn_patient_restore.png", nil];
    
    
    UIColor* color = [UIColor colorWithRed:29/255.f green:31/255.f blue:102/255.f alpha:1];
    
    for(int i = 0; i < [iconNames count]; i++){
        MGSwipeButton* button;
        button = [MGSwipeButton  buttonWithTitle:nil icon:[UIImage imageNamed:[iconNames objectAtIndex:i]] backgroundColor:color];
//        button.imageEdgeInsets = UIEdgeInsetsMake(30, 10, 30, 10);
        
        if (i == 0) {
            [button addTarget:self action:@selector(clear:) forControlEvents:UIControlEventTouchUpInside];
        }else{
            [button addTarget:self action:@selector(recover:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [array addObject:button];
    }
    return array;
}

//初始化删除接口逻辑
-(void)initRecyLogic{
    if (!recycleLogic) {
        recycleLogic = [[ComFqHalcyonLogicPracticeRecycleLogic alloc] initWithComFqHalcyonLogicPracticeRecycleLogic_Remove2RecycleCallBack:self withComFqHalcyonLogicPracticeRecycleLogic_RecycleCallBack:self];
    }
}

/**
 *  整个cell被点击
 */
-(void)Actiondo:(id)sender{
    if(isRecycle)return;
    
    //已经识别完成的记录
    if ([recordEntity getRecordInfoId] > 0 ) {
        UIViewController* controller = nil;
        //病历记录为化验单
        
        if([recordEntity getRecordCagegory] == ComFqLibRecordRecordConstants_PATIENT_CATEGORY_MEDICAL){
//            ReportChartViewController* controller = [[ReportChartViewController alloc] init];
//            controller.relationShip = [ChooseMemberViewController getRelationShipInstance];
            
            ComFqHalcyonEntityCareMedicalItem* item = [[ComFqHalcyonEntityCareMedicalItem alloc] init];
            [item setInfoIdWithInt:[recordEntity getRecordInfoId]];
            [item setPhotosWithJavaUtilArrayList:[recordEntity getImgPhotos]];
            
            ReportDocumentViewController* controller = [[ReportDocumentViewController alloc] init];
            controller.medicalItem = item;
            
            [[Tools getCurrentViewController:self].navigationController pushViewController:controller animated:YES];
        }else{
            if([recordEntity getRecordType] == ComFqLibRecordRecordConstants_TYPE_EXAMINATION){
                controller = [[ExamItemViewController alloc] init];
                ((ExamItemViewController*)controller).recordAbstract = recordEntity;
            }else{
                controller = [[NonNormalRecordViewController alloc] init];
                ((NonNormalRecordViewController*)controller).recordAbstract = recordEntity;
            }
            [[Tools getCurrentViewController:self].navigationController pushViewController:controller animated:YES];
            if (_event) {
                [_event onRPItemClick:indexPath];
            }
        }
    }else{
        WaitRecDetailViewController* controll = [[WaitRecDetailViewController alloc] init];
        controll.recRecord = recordEntity;
        [[Tools getCurrentViewController:self].navigationController pushViewController:controll animated:YES];
    }
    
//    if([recordEntity getRecStatus] == ComFqLibRecordRecordConstants_CLOUD_REC_END ){
//        UIViewController* controller = nil;
//        
//        //病历记录为化验单
//        if([recordEntity getRecordType] == ComFqLibRecordRecordConstants_TYPE_EXAMINATION){
//            controller = [[ExamItemViewController alloc] init];
//            ((ExamItemViewController*)controller).recordAbstract = recordEntity;
//        }else{
//            controller = [[NewNormalRecordViewController alloc] init];
//            ((NewNormalRecordViewController*)controller).recordAbstract = recordEntity;
//        }
//        [[Tools getCurrentViewController:self].navigationController pushViewController:controller animated:TRUE];
//        if (_event) {
//            [_event onRPItemClick:indexPath];
//        }
//    }else{
//        WaitRecDetailViewController* controll = [[WaitRecDetailViewController alloc] init];
//        controll.recRecord = recordEntity;
//        [[Tools getCurrentViewController:self].navigationController pushViewController:controll animated:TRUE];
//    }
  
}

/**
 * 分享按钮被点击
 */
-(void)share:(id)sender{
    //游客模式就返回
    if([MessageTools isExperienceMode:[Tools getCurrentViewController:self].navigationController])return;
    indetifyDialog =  [[UIAlertViewTool getInstance] showRemoveIndetifyDialog:didSendInfo target:self actionOk:@selector(dialogOk:) actionCancle:@selector(dialogCancle:) actionRemoveIndentify:@selector(xieyi:) selecBtn:@selector(click:)];
}

//确认分享
-(void)dialogOk:(id)sender{
    MoreChatListViewController* controller =  [[MoreChatListViewController alloc] init];
    controller.type = ComFqLibToolsConstants_SHARE_TYPE_RECORD;
    
    JavaUtilArrayList* list = [[JavaUtilArrayList alloc] init];
    [list addWithId:recordEntity];
    controller.recordList = list;
    controller.didSendInfo = didSendInfo;
    [[Tools getCurrentViewController:self].navigationController pushViewController:controller animated:YES];
    [indetifyDialog.alertView close];
    didSendInfo = YES;
}

//取消分享
-(void)dialogCancle:(id)sender{
    [indetifyDialog.alertView close];
}
//查看协议
-(void)xieyi:(id)sender{
    [indetifyDialog.alertView close];
    [[Tools getCurrentViewController:self].navigationController pushViewController:[[ProtocolViewController alloc] init] animated:YES];
}
//是否包含身份信息
-(void)click:(id)sender{
    didSendInfo = !didSendInfo;
    if (didSendInfo) {
        [indetifyDialog.selectBtn setBackgroundImage:[UIImage imageNamed:@"icon_circle_yes.png"] forState:UIControlStateNormal];
    }else{
        [indetifyDialog.selectBtn setBackgroundImage:[UIImage imageNamed:@"icon_circle_no.png"] forState:UIControlStateNormal];
    }
}





/**
 * 云识别按钮被点击
 */
-(void)cloud:(id)sender{
    
    //游客模式就弹框返回
    if([MessageTools isExperienceMode:[Tools getCurrentViewController:self].navigationController])return;
    
    if(!cloudLogic){
        cloudLogic = [[ComFqHalcyonLogicPracticeRecognitionLogic alloc] initWithComFqHalcyonLogicPracticeRecognitionLogic_ApplyRecognizeCallBack:self];
    }
    
    JavaUtilArrayList* list = [[JavaUtilArrayList alloc] init];
    [list addWithId:recordEntity];
    [cloudLogic applyRecognizeWithJavaUtilArrayList:list];
}

/**
 * 删除按钮被点击
 */
-(void)remove:(id)sender{
    if(isClicked)return;
    
    //游客模式就弹框返回
    if([MessageTools isExperienceMode:[Tools getCurrentViewController:self].navigationController])return;
    
    isClicked = YES;
    if (isOffline) {
        [[OfflineManager instance] deleteRecord:[recordEntity getRecordItemId]];
        [self removeSuccess];
    }else{
        [self initRecyLogic];
        
        JavaUtilArrayList* list = [[JavaUtilArrayList alloc] init];
        [list addWithId:recordEntity];
        [recycleLogic removeRecordDataWithJavaUtilArrayList:list];
    }
    
}

/**
 * 清除按钮被点击
 */
-(void)clear:(id)sender{
    
    //游客模式就弹框返回
    if([MessageTools isExperienceMode:[Tools getCurrentViewController:self].navigationController])return;
    
    [self initRecyLogic];
    
    JavaUtilArrayList* list = [[JavaUtilArrayList alloc] init];
    [list addWithId:recordEntity];
    [recycleLogic clearRecordDataWithJavaUtilArrayList:list];
}

/**
 * 恢复按钮被点击
 */
-(void)recover:(id)sender{
    
    //游客模式就弹框返回
    if([MessageTools isExperienceMode:[Tools getCurrentViewController:self].navigationController])return;
    
    
    [self initRecyLogic];
        
    JavaUtilArrayList* list = [[JavaUtilArrayList alloc] init];
    [list addWithId:recordEntity];
    [recycleLogic retoreRecordDataWithJavaUtilArrayList:list];\
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

/**
 * 云识别请求成功
 */
-(void)applyRecognizeSuccess{
    [[Tools getCurrentViewController:self].view makeToast:@"云识别请求已发送"];
    if (_event) {
        [_event onRPItemCloud:indexPath];
    }
//    [UIView animateWithDuration:2.0f delay:0.f options:(UIViewAnimationOptions)UIViewAnimationCurveEaseIn animations:^(void)
//    {
//        self.contentContainer.frame = CGRectMake(500, 0, swipeWidth, self.frame.size.height);
//    } completion:^(BOOL finished){
//        if (_event) {
//            [_event onRPItemCloud:indexPath];
//        }
//    }];
}

//删除记录到回收站成功
-(void)removeSuccess{
    isClicked = NO;
    [[Tools getCurrentViewController:self].view makeToast:@"删除记录成功"];
    if(_event){
        [_event onRPItemRemove:indexPath];
    }
}

//回收站清除数据成功
-(void)recycelClearDataSuccess{
    [[Tools getCurrentViewController:self].view makeToast:@"清除记录成功"];
    if(_event){
        [_event onRPItemClear:indexPath];
    }
}

//回收站还原数据成功
-(void)recycelRestoreDataSuccess{
    [[Tools getCurrentViewController:self].view makeToast:@"还原记录成功"];
    if(_event){
        [_event onRPItemRecover:indexPath];
    }
}

//云识别请求失败
-(void)applyErrorWithInt:(int)code withNSString:(NSString *)msg{
    [self showAlert:msg];
}

//删除记录到回收站失败
-(void)removeErrorWithInt:(int)code withNSString:(NSString *)msg{
    isClicked = NO;
    [self showAlert:msg];
}

//回收站处理事件失败
-(void)recycleErrorWithInt:(int)code withNSString:(NSString *)msg{
    [self showAlert:msg];
}

-(void)showAlert:(NSString*)msg{
    [[Tools getCurrentViewController:self ].view makeToast:msg];
    
//    UIViewController* controller = [Tools getCurrentViewController:self];
//    if([controller isKindOfClass:[PraHomeViewController class]]){
//        [((PraHomeViewController*)controller) showToast:msg];
//    }else{
//        [controller.view makeToast:msg];
//    }
    
//    [[UIAlertViewTool getInstance] showAutoDismisDialog:msg width:[[UIScreen mainScreen] bounds].size.width-100 height:100];
}

-(void)recycleDatasWithJavaUtilArrayList:(JavaUtilArrayList *)keys withJavaUtilHashMap:(JavaUtilHashMap *)recyDataMap{}

-(void)setOfflineStatus:(BOOL)isoffline{
    isOffline = isoffline;
}

@end
