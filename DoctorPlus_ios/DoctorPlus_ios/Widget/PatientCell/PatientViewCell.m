//
//  PatientViewCell.m
//  DoctorPlus_ios
//
//  Created by reason on 15-7-16.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

#import "PatientViewCell.h"
#import "Tools.h"
#import "DoctorPlus_ios-Swift.h"
#import "TextViewController.h"
#import "PraHomeViewController.h"

@implementation PatientViewCell
{
    MGSwipeTableCell* swipe;
    ComFqHalcyonLogicPracticeRecycleLogic* recycleLogic;
    
    BOOL isCanSliding;
    BOOL isClicked;
    BOOL isFromChart;
    IndetifyDialog *indetifyDialog;
    BOOL didSendInfo;
}


//-(void)setFrame:(CGRect)frame{
//    self.frame  = CGRectMake(20, 6, [[UIScreen mainScreen] bounds].size.width-100, 90);
//    self.contentContainer.frame = CGRectMake(20, 6, [[UIScreen mainScreen] bounds].size.width-100, 90);
//}


- (void)awakeFromNib {
    isCanSliding = YES;
    didSendInfo = YES;
//    self.backgroundColor = [UIColor clearColor];
}

-(void)setCanSliding:(BOOL)iscanSliding{
    [swipe setEditing:!iscanSliding animated:NO];
}

-(void)setFromChart:(BOOL)fromChart{
    isFromChart = fromChart;
}

-(void)initSwipe{
    NSString* cellIdentifier = @"PatientSwipeCell";
    swipe = [[MGSwipeTableCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    swipe.backgroundColor = [UIColor colorWithRed:29/255.f green:31/255.f blue:102/255.f alpha:1];
    //swipe.frame = CGRectMake(0, 0, self.contentContainer.frame.size.width-40, 90);
    //[self.contentContainer addSubview:swipe];
    //如果用约束，会有各种异常
    [FQBaseViewController addChildViewFullInParent:swipe parent:self.contentContainer ];
    
    swipe.rightSwipeSettings.transition = MGSwipeTransitionStatic;
    swipe.rightExpansion.buttonIndex = -1;
    swipe.rightExpansion.fillOnTrigger = true;
    
    if(isRecycle){
        swipe.rightButtons = [self createRecycleRightButtons];
    }else{
        swipe.rightButtons = [self createRightButtons];
        //设置点击手势
        UITapGestureRecognizer*tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(Actiondo:)];
        [swipe addGestureRecognizer:tapGesture];
    }
}




/**
 *创建左滑打开的多个按钮
 *
 */
-(NSMutableArray *)createRightButtons{
    NSMutableArray* array = [[NSMutableArray alloc] init];
    NSArray* iconNames = [NSArray arrayWithObjects:@"btn_patient_jiegou.png",@"btn_patient_share.png",@"btn_patient_del.png", nil];
    
    UIColor* color = [UIColor colorWithRed:29/255.f green:31/255.f blue:102/255.f alpha:1];
    
    for(int i = 0; i < 3; i++){
        MGSwipeButton* button;
        button = [MGSwipeButton  buttonWithTitle:nil icon:[UIImage imageNamed:[iconNames objectAtIndex:i]] backgroundColor:color];
        //        button.imageEdgeInsets = UIEdgeInsetsMake(33, 10, 33, 10);
        
        if (i == 0) {
            [button addTarget:self action:@selector(jiegou:) forControlEvents:UIControlEventTouchUpInside];
        }else if(i == 1){
            [button addTarget:self action:@selector(shared:) forControlEvents:UIControlEventTouchUpInside];
        }else{
            [button addTarget:self action:@selector(remove:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [array addObject:button];
    }
    
    return array;
}


/**
 * 创建回收站时,左滑打开的多个按钮
 *
 */
-(NSMutableArray *)createRecycleRightButtons{
    NSMutableArray* array = [[NSMutableArray alloc] init];
    
    NSArray* iconNames = [NSArray arrayWithObjects:@"btn_patient_del.png",@"btn_patient_restore.png", nil];
    
    
    UIColor* color = [UIColor colorWithRed:29/255.f green:31/255.f blue:102/255.f alpha:1];
    
    for(int i = 0; i < [iconNames count]; i++){
        MGSwipeButton* button;
        button = [MGSwipeButton  buttonWithTitle:nil icon:[UIImage imageNamed:[iconNames objectAtIndex:i]] backgroundColor:color];
        //        button.imageEdgeInsets = UIEdgeInsetsMake(90, 20, 90, 20);
        
        if (i == 0) {
            [button addTarget:self action:@selector(clear:) forControlEvents:UIControlEventTouchUpInside];
        }else{
            [button addTarget:self action:@selector(recover:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [array addObject:button];
    }
    return array;
}

-(void)initDataForRecycle:(ComFqHalcyonEntityPracticePatientAbstract *)data IndexPath:(NSIndexPath *)dexPath Event:(id<RecordPatientEvent>)et{
    isRecycle = true;
    [self initData:data IndexPath:dexPath Event:et];
}

-(void)initData:(ComFqHalcyonEntityPracticePatientAbstract*)data IndexPath:(NSIndexPath*)dexPath Event:(id<RecordPatientEvent>)et isCanSliding:(BOOL)iscanSliding{
    isCanSliding = iscanSliding;
    [self initData:data IndexPath:dexPath Event:et];
}

-(void)initData:(ComFqHalcyonEntityPracticePatientAbstract*)data IndexPath:(NSIndexPath*)dexPath Event:(id<RecordPatientEvent>)et{
    patientEntity = data;
    indexPath = dexPath;
    _event = et;
    
    if(swipe){
        [swipe removeFromSuperview];
        swipe = nil;
    }
    if(!swipe){
        [self initSwipe];
        
        UIView* view = nil;
        
        if (isRecycle) {
            view = [[NSBundle mainBundle] loadNibNamed:@"PatientViewCellAlpha" owner:self options:nil][0];
        }else{
            view = [[NSBundle mainBundle] loadNibNamed:@"PatientViewCellAlpha" owner:self options:nil][1];
        }
        
        
        //view.frame = CGRectMake(0, 0, 100, 90);
        //[swipe.contentView addSubview:view];
        //如果用约束会有各种异常
        [FQBaseViewController addChildViewFullInParent:view parent:swipe.contentView ];
        //cell.delegate = self;
        
        imgUserHeadBtn = (UIButton*)[view viewWithTag:90];
        imgUserHead = (UIImageView*)[view viewWithTag:91];
        labelPatientName = (UILabel*)[view viewWithTag:92];
        labelRecordCount = (UILabel*)[view viewWithTag:93];
        labelDiagnose1 = (UILabel*)[view viewWithTag:94];
        labelDiagnose2 = (UILabel*)[view viewWithTag:95];
        if (!isRecycle) {
            iconOffline = (UIButton*)[view viewWithTag:96];
            iconUpdate = (UIImageView*)[view viewWithTag:97];
//            [btnDownload addTarget:self action:@selector(download:) forControlEvents:UIControlEventTouchUpInside];
            
            //设置是否有离线数据状态
            if( [RecordCacheTool isHaveCache:[patientEntity getPatientId]] ){
                iconOffline.hidden = false;
            }else{
                iconOffline.hidden = true;
            }
            
            //TODO==YY==服务器接口未修改，暂时不要该功能
            //设置是否有更新状态
//            if ([RecordCacheTool getPatientStatus:[patientEntity getPatientId] updateTime:[patientEntity getUpdateTime]]) {
//                iconUpdate.hidden = false;
//            }else{
//                iconUpdate.hidden = true;
//            }
        }
        
        
        imgUserHead.layer.masksToBounds = true;
        imgUserHead.layer.cornerRadius = imgUserHead.frame.size.width/2;
    }
    
    [labelRecordCount setText:[NSString stringWithFormat:@"%d",[patientEntity getRecordCount]]];
    [labelPatientName setText:[patientEntity getShowName]];
    [labelDiagnose1 setText:[patientEntity getShowSecond]];
    [labelDiagnose2 setText:[patientEntity getShowThrid]];
    
    //加载用户头像
    
    int imageId = [patientEntity getUserImageId];
    if (imageId == 0)imageId = [ComFqLibToolsConstants_get_mUser_() getImageId];
    
    if (imageId != 0) {
        OcDownLoadImage * download = [[OcDownLoadImage alloc] init];
        [download downLoadImage:imageId view:imgUserHead];
    }
    
    //数据正确后打开下面的代码
    if (0 == [patientEntity getShareUserId]) {
        imgUserHeadBtn.enabled = NO;
    }else{
        [imgUserHeadBtn addTarget:self action:@selector(friendInfo:) forControlEvents:UIControlEventTouchUpInside];
    }
}


//初始化删除接口逻辑
-(void)initRecyLogic{
    if (!recycleLogic) {
        recycleLogic = [[ComFqHalcyonLogicPracticeRecycleLogic alloc] initWithComFqHalcyonLogicPracticeRecycleLogic_Remove2RecycleCallBack:self withComFqHalcyonLogicPracticeRecycleLogic_RecycleCallBack:self];
    }
}

//头像被点击
-(void)friendInfo:(id)sender{
    UserInfoViewController* controller = [[UserInfoViewController alloc] init];
    controller.scanUrl = [NSString stringWithFormat:@"%@?user_id=%d", [ComFqLibToolsUriConstants getUserURL],[patientEntity getShareUserId]];
    [[Tools getCurrentViewController:self].navigationController pushViewController:controller animated:YES ];
}

//该View被点击
-(void)Actiondo:(id)sender{
    if(isRecycle)return;
    
    ExplorationRecordListViewController* controller = [[ExplorationRecordListViewController alloc] init];
    controller.patientItem = patientEntity;
    controller.isShared = !isCanSliding;
    controller.isFromChart = isFromChart;
    controller.isOfflinePatient = isOffline;
    [[Tools getCurrentViewController:self].navigationController pushViewController:controller animated:true];
    //  [event onPatientItemClick:indexPath];
    
    //==TODO==由于服务器接口未修改，暂时不要new icon功能。保存阅读时间-已病案的updated_time作为阅读时间保存，为了以后比较是否更新,,,
//    [[Platform getInstance] cachePatientUpdatetimeWithInt:[patientEntity getPatientId] withNSString:[patientEntity getUpdateTime]];
    
}

//结构化按钮被点击
-(void)jiegou:(id)sender{
    StructuredViewController* controllr = [[StructuredViewController alloc] init];
    controllr.patientId = [patientEntity getPatientId];
    [[Tools getCurrentViewController:self].navigationController pushViewController:controllr animated:YES];
}

//分享按钮被点击
-(void)shared:(id)sender{
    
    //游客模式就弹框返回
    if([MessageTools isExperienceMode:[Tools getCurrentViewController:self].navigationController])return;
    
    indetifyDialog =  [[UIAlertViewTool getInstance] showRemoveIndetifyDialog:didSendInfo target:self actionOk:@selector(dialogOk:) actionCancle:@selector(dialogCancle:) actionRemoveIndentify:@selector(xieyi:) selecBtn:@selector(click:)];
}

//确认分享
-(void)dialogOk:(id)sender{
    MoreChatListViewController* controller =  [[MoreChatListViewController alloc] init];
    controller.type = ComFqLibToolsConstants_SHARE_TYPE_PATIENT;
    JavaUtilArrayList* list = [[JavaUtilArrayList alloc] init];
    [list addWithId:patientEntity];
    controller.patientList = list;
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


//删除按钮被点击
-(void)remove:(id)sender{
    if(isClicked)return;
    
    //游客模式就弹框返回
    if([MessageTools isExperienceMode:[Tools getCurrentViewController:self].navigationController])return;
    
    isClicked = YES;
    
    if(isOffline){
        [[OfflineManager instance] deletePatient:[patientEntity getPatientId]];
        [self removeSuccess];
    }else{
        [self initRecyLogic];
        
        JavaUtilArrayList* list = [[JavaUtilArrayList alloc] init];
        [list addWithId:patientEntity];
        [recycleLogic removePatientDataWithJavaUtilArrayList:list];
    }
}

//清除按钮被点击
-(void)clear:(id)sender{
    
    //游客模式就弹框返回
    if([MessageTools isExperienceMode:[Tools getCurrentViewController:self].navigationController])return;
    
    [self initRecyLogic];
    
    JavaUtilArrayList* list = [[JavaUtilArrayList alloc] init];
    [list addWithId:patientEntity];
    [recycleLogic clearPatientDataWithJavaUtilArrayList:list];
}

//恢复按钮被点击
-(void)recover:(id)sender{
    
    //游客模式就弹框返回
    if([MessageTools isExperienceMode:[Tools getCurrentViewController:self].navigationController])return;
    
    [self initRecyLogic];
    
    JavaUtilArrayList* list = [[JavaUtilArrayList alloc] init];
    [list addWithId:patientEntity];
    [recycleLogic retorePatientDataWithJavaUtilArrayList:list];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


//回收站清除数据成功
-(void)recycelClearDataSuccess{
//    [[Tools getCurrentViewController:self].view makeToast:@"清除病案成功"];
    if(_event){
        [_event onRPItemClear:indexPath];
    }
}

//回收站还原数据成功
-(void)recycelRestoreDataSuccess{
//    [[Tools getCurrentViewController:self].view makeToast:@"还原病案成功"];
    if(_event){
        [_event onRPItemRecover:indexPath];
    }
}

//删除记录到回收站成功
-(void)removeSuccess{
    isClicked = NO;
//    [[Tools getCurrentViewController:self].view makeToast:@"删除病案成功"];
    if(_event){
        [_event onRPItemRemove:indexPath];
    }
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
//    [[Tools getCurrentViewController:self ].view makeToast:msg];
//    UIViewController* controller = [Tools getCurrentViewController:self];
//    if([controller isKindOfClass:[PraHomeViewController class]]){
//        [((PraHomeViewController*)controller) showToast:msg];
//    }else{
//        [controller.view makeToast:msg];
//    }F
//    [[UIAlertViewTool getInstance] showAutoDismisDialog:msg width:[[UIScreen mainScreen] bounds].size.width-100 height:100];
}

-(void)recycleDatasWithJavaUtilArrayList:(JavaUtilArrayList *)keys withJavaUtilHashMap:(JavaUtilHashMap *)recyDataMap{}


//-(void)hiddenBtnDown:(BOOL)isHidden {
//    [iconOffline setHidden:isHidden];
//}

-(void)setOfflineIconVisibly:(BOOL)isShow{
    [iconOffline setHidden:!isShow];
}

-(void)setUpdateIconVisibly:(BOOL)isShow{
    [iconUpdate setHidden:!isShow];
}


//下载按钮被点击
-(void)download:(id)sender{
    ComFqHalcyonLogicPracticeDownloadPatientLogic * logic = [[ComFqHalcyonLogicPracticeDownloadPatientLogic alloc] initWithComFqHalcyonLogicPracticeDownloadPatientLogic_DownloadPatientCallBack:self];
    [logic downloadPatientWithInt:[patientEntity getPatientId]];
}

-(void)downloadPatientErrorWithInt:(int)code withNSString:(NSString *)error{
//    [self makeToast:@"下载失败"];
}

-(void)downloadPatientSuccessWithNSString:(NSString *)result{
//    [self hiddenBtnDown:TRUE];[[OfflineManager instance] cacheJson:result];
}

-(void)setOffline:(BOOL)isoffline{
    isOffline = isoffline;
}

@end
