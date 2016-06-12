//
//  MySearchAdapter.swift
//  DoctorPlus_ios
//
//  Created by sunning on 15/12/9.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import UIKit

class MySearchAdapter: ContentsBaseAdapter,ComFqHalcyonLogicPracticeSearchLogic_SearchCallBack {
    
    var isFromFilter = false
    var isFromChart = false
    var tmpDatas = [Array<Any>]()
    
    var sectionIsOpen = [Bool]()
    
    var filters = JavaUtilArrayList()

    var loadingDialog:CustomIOS7AlertView!
    //搜索逻辑
    var searchLogic: ComFqHalcyonLogicPracticeSearchLogic!
    var params:ComFqHalcyonEntityPracticeSearchParams?
    var searchKey = ""
    var filter:JavaUtilArrayList? = JavaUtilArrayList()
    override func fetchData() {
        searchLogic = ComFqHalcyonLogicPracticeSearchLogic(comFqHalcyonLogicPracticeSearchLogic_SearchCallBack: self)
        if !isFromFilter {
           setParams(1, searchKey: searchKey, searchFilter: filter!, isFilter: false)
        }
        searchLogic.searchWithComFqHalcyonEntityPracticeSearchParams(params)
        loadingDialog = UIAlertViewTool.getInstance().showLoadingDialog("正在搜索...")
    }
    
    
    
    func setParams(page:Int32,searchKey:String,searchFilter:JavaUtilArrayList?,isFilter:Bool){
        self.params = ComFqHalcyonEntityPracticeSearchParams()
            params!.setResponseTypeWithInt(2)
            if isFromChart == false{
                params!.setKeyWithNSString(searchKey)
            }
            params!.setPageWithInt(page)
            params!.setPageSizeWithInt(10)
            params?.setNeedFiltersWithBoolean(isFilter)
    }
      
    
    
    func searchRetrunDataWithJavaUtilArrayList(patients: JavaUtilArrayList!, withJavaUtilArrayList records: JavaUtilArrayList!, withJavaUtilArrayList filters: JavaUtilArrayList!) {
        var contentDic = Dictionary<ComFqHalcyonEntityPracticeRecordAbstract_PatientInfo,Array<Any>>()
        var titleList = [ComFqHalcyonEntityPracticeRecordAbstract_PatientInfo]()
        let recordsList = records
        var tempId:Int32 = 0
        for var i:Int32 = 0; i < recordsList.size() ; i++ {
            var infoRecordList = [Any]()
            let info = recordsList.getWithInt(i).getPatientInfo() as ComFqHalcyonEntityPracticeRecordAbstract_PatientInfo
            let id = info.getPatientId()
            if (id == tempId){
                break
            }
            for var j:Int32 = 0; j < recordsList.size() ; j++ {
                if id == recordsList.getWithInt(j).getPatientInfo().getPatientId() {
                    infoRecordList.append(recordsList.getWithInt(j) as! ComFqHalcyonEntityPracticeRecordAbstract)
                }
            }
            titleList.append(recordsList.getWithInt(i).getPatientInfo())
            contentDic[recordsList.getWithInt(i).getPatientInfo()] = infoRecordList
            tempId = id
        }
        
        addItems(titleList, rows: contentDic)
        for _ in rowsInSections {
            tmpDatas.append(Array<Any>())
            sectionIsOpen.append(false)
        }
        
        self.filters = filters
        
        protectedNotifyDataChanged()
        loadingDialog.close()
    }
    
    func searchErrorWithInt(code: Int32, withNSString msg: String!) {
        loadingDialog.close()
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
    
}
