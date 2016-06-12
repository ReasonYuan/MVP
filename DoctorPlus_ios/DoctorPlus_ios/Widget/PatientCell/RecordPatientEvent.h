//
//  RecordPatientEvent.h
//  DoctorPlus_ios
//
//  Created by reason on 15-7-23.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

#ifndef DoctorPlus_ios_RecordPatientEvent_h
#define DoctorPlus_ios_RecordPatientEvent_h


#endif
@protocol RecordPatientEvent  <NSObject>

/**子项整个被点击*/
-(void)onRPItemClick:(NSIndexPath*)indexPath;
/**子项[结构化]被点击*/
-(void)onRPItemStruct:(NSIndexPath*)indexPath;
/**子项[分享]被点击*/
-(void)onRPItemShare:(NSIndexPath*)indexPath;
/**子项[删除]被点击*/
-(void)onRPItemRemove:(NSIndexPath*)indexPath;
/**子项[清除]被点击*/
-(void)onRPItemClear:(NSIndexPath*)indexPath;
/**子项[恢复]被点击*/
-(void)onRPItemRecover:(NSIndexPath*)indexPath;
/**子项[云识别]被点击*/
-(void)onRPItemCloud:(NSIndexPath*)indexPath;

@end