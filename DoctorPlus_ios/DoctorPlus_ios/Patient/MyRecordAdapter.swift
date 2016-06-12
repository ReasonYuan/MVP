//
//  MyRecordAdapter.swift
//  DoctorPlus_ios
//
//  Created by Monkey on 15/12/4.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import Foundation

enum MyRecordAdapterType {
    case TimeAdapter
    case TypeAdapter
}

class MyRecordAdapter:ContentsBaseAdapter,ComFqHalcyonLogicPracticeRecordListLogic_RecordListCallBack{
    
    var recordType = 0
    var patientItem:ComFqHalcyonEntityPracticePatientAbstract!
    var tmpDatas = [Array<Any>]() //可收缩列表改变时的临时数据
    var sectionIsOpen = [Bool]() //记录可收缩列表是否展开
    
    var adapterType:MyRecordAdapterType!
    
    init(patientItem:ComFqHalcyonEntityPracticePatientAbstract!,adapterType:MyRecordAdapterType) {
        self.patientItem = patientItem
        self.adapterType = adapterType
    }
    
    override func fetchData() {
        let recordLogic = ComFqHalcyonLogicPracticeRecordListLogic(comFqHalcyonLogicPracticeRecordListLogic_RecordListCallBack: self)
        recordLogic!.loadRecordListWithInt(patientItem.getPatientId(), withInt: Int32(recordType), withInt: Int32(1), withInt: Int32(20))
    }
    
    func recordTypeListCallbackWithJavaUtilArrayList(keys: JavaUtilArrayList!, withJavaUtilHashMap map: JavaUtilHashMap!) {
        
        if self.adapterType == MyRecordAdapterType.TimeAdapter {
            return
        }
        changeAdapterDatas(.TypeAdapter, keys: keys, withJavaUtilHashMap: map)
    }
    
    func recordTimeListCallbackWithJavaUtilArrayList(keys: JavaUtilArrayList!, withJavaUtilHashMap map: JavaUtilHashMap!) {
        
        if self.adapterType == MyRecordAdapterType.TypeAdapter {
            return
        }
        changeAdapterDatas(.TimeAdapter, keys: keys, withJavaUtilHashMap: map)
    }
    
    func errorWithInt(code: Int32, withNSString msg: String!) {
        
    }
    
    //跳转页面的操作
    func pushController(view:UIView,indexPath: NSIndexPath) {
    
        var controller:UIViewController!
        let recordEntity = getItem(indexPath.section, rowIndex: indexPath.row) as! ComFqHalcyonEntityPracticeRecordAbstract
        
        //病历记录为化验单
        
        if recordEntity.getRecordCagegory() == ComFqLibRecordRecordConstants_PATIENT_CATEGORY_MEDICAL {
            
            
            let item = ComFqHalcyonEntityCareMedicalItem()
            item.setInfoIdWithInt(recordEntity.getRecordInfoId())
            item.setPhotosWithJavaUtilArrayList(recordEntity.getImgPhotos())
            controller = ReportDocumentViewController()
            (controller as! ReportDocumentViewController).medicalItem = item
            Tools.getCurrentViewController().navigationController?.pushViewController(controller, animated: true)
            
        }else{
            if recordEntity.getRecordType() == ComFqLibRecordRecordConstants_TYPE_EXAMINATION {
                
                controller = ExamItemViewController()
                (controller as! ExamItemViewController).recordAbstract = recordEntity
                
            }else{
                
                controller = NonNormalRecordViewController()
                (controller as! NonNormalRecordViewController).recordAbstract = recordEntity;
                
            }
            
            Tools.getCurrentViewController(view).navigationController?.pushViewController(controller, animated: true)
            
        }
        
    }
    
    func setAdapterDatas(keys: JavaUtilArrayList!, withJavaUtilHashMap map: JavaUtilHashMap!) {
    
        var keysList = [String]()
        var contentDic = Dictionary<String,Array<Any>>()
        
        for var i:Int32 = 0 ; i < keys.size() ; i++ {
            keysList.append(keys.getWithInt(i) as! String)
        }
        
        for item in keysList {
            let list = map.getWithId(item) as! JavaUtilArrayList
            var contentList = Array<Any>()
            for var i:Int32 = 0 ; i < list.size() ; i++ {
                contentList.append(list.getWithInt(i) as! ComFqHalcyonEntityPracticeRecordData)
            }
            contentDic[item] = contentList
        }
        
        addItems(keysList, rows: contentDic)
        for _ in rowsInSections {
            tmpDatas.append(Array<Any>())
            sectionIsOpen.append(false)
        }
        protectedNotifyDataChanged()
        
    }
    
    func  changeAdapterDatas(type:MyRecordAdapterType,keys: JavaUtilArrayList!, withJavaUtilHashMap map: JavaUtilHashMap!) {
        setAdapterDatas(keys, withJavaUtilHashMap: map)
    }
    
    /**
     获取所有选中的item
     
     - returns: 返回选中的列表
     */
    func getAllSelectedItem() -> Array<ComFqHalcyonEntityPracticeRecordAbstract>{
        
        var result = Array<ComFqHalcyonEntityPracticeRecordAbstract>()
        
        for items in rowsInSections {
            
            for item in items {
                let tmp = item as! ComFqHalcyonEntityPracticeRecordAbstract
                if tmp.isSelected() {
                    result.append(tmp)
                }
            }
        }
        
        return result
    }
}