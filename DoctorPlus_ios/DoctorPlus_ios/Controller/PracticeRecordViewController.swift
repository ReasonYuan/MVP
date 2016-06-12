//
//  PracticeRecordViewController.swift
//  DoctorPlus_ios
//
//  Created by monkey on 15-7-3.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class PracticeRecordViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,ComFqHalcyonLogic2GetRecordTypeListLogic_LoadRecordTypesCallBack,ComFqHalcyonLogic2GetRecordListLogic_GetRecordListCallBack{

    
    @IBOutlet weak var recordTableView: UITableView!
    var patientId:Int32 = 0
    var recordTypeArray = Array<ComFqHalcyonEntityRecordType>()
    var recordItemArray = Array<ComFqHalcyonEntityRecordItemSamp>()
    
    var recordTypes = JavaUtilArrayList()
    var messageEntity:ComFqHalcyonEntityChartEntity?
    override func viewDidLoad() {
        super.viewDidLoad()
        setTittle("病例记录")
        recordTableView.registerNib(UINib(nibName: "PracticeRecordTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PracticeRecordTableViewCell")
        if patientId != 0 {
            getRecordList(patientId)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordItemArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PracticeRecordTableViewCell") as! PracticeRecordTableViewCell
        let item = recordItemArray[indexPath.row]
        cell.recordTypeName.text = ComFqLibRecordRecordConstants.getTypeNameByRecordTypeWithInt(item.getRecordType())
        if item.getRecStatus() == ComFqHalcyonEntityRecordItemSamp_REC_ING {
            cell.abstruteLabel.text = "识别中"
        }else if item.getRecStatus() == ComFqHalcyonEntityRecordItemSamp_REC_FAIL {
            cell.abstruteLabel.text = "识别失败"
        }else{
            cell.abstruteLabel.text = item.getInfoAbstract()
        }
        cell.timeLabel.text = item.getUploadTime()
        return cell
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let recordItemSamp = recordItemArray[indexPath.row]
        if messageEntity != nil {
//            messageEntity?.setOtherIdWithNSString("\(recordItemSamp.getRecordInfoId())")
//            messageEntity?.setOtherNameWithNSString(ComFqLibRecordRecordConstants.getTypeNameByRecordTypeWithInt(recordItemSamp.getRecordType()))
            
             let itemList = ComFqLibRecordRecordTool.getAllRecRecordWithJavaUtilArrayList(recordTypes) as JavaUtilArrayList
             let item = itemList.getWithInt(Int32(indexPath.row)) as! ComFqHalcyonEntityRecordItemSamp
            messageEntity?.setRecordTypeWithInt(item.getRecordType())
            NSNotificationCenter.defaultCenter().postNotificationName("sendRecord", object: self, userInfo: ["sendmessage":messageEntity!])
            let index:Int! = self.navigationController?.viewControllers.count
            print(index)
            let controller: UIViewController? = self.navigationController!.viewControllers[index - 3]
            self.navigationController?.popToViewController(controller!, animated: true)
            
        }else{
            //        if recordItemSamp.getRecStatus() == ComFqHalcyonEntityRecordItemSamp_REC_ING {
            //
            //            var imageTittle = "浏览识别中病历"
            //            var recordItemId = recordItemSamp.getRecordItemId()
            //            var controller = BrowRecordRecogzingImageViewController()
            //            controller.tittleStr = imageTittle
            //            controller.recordItemId = recordItemId
            //            self.navigationController?.pushViewController(controller, animated: true)
            //
            //        }else
            if recordItemSamp.getRecStatus() == ComFqHalcyonEntityRecordItemSamp_REC_FAIL {
                
                let controller = BrowRecordFailImageViewController()
                controller.itemSamp = recordItemSamp
                self.navigationController?.pushViewController(controller, animated: true)
                
                //        }else if recordItemSamp.getRecStatus() == ComFqHalcyonEntityRecordItemSamp_REC_SUCC{
                //
                //            var itemList = ComFqLibRecordRecordTool.getAllRecRecordWithJavaUtilArrayList(recordTypes) as JavaUtilArrayList
                //            var controller = BrowRecordItemViewController()
                //            controller.isShareModel = false
                //            controller.clickPosition = Int32(itemList.indexOfWithId(recordItemSamp))
                //            controller.itemList = itemList
                //            self.navigationController?.pushViewController(controller, animated: true)
                //
                //        }
            }else{
//                                var itemList = ComFqLibRecordRecordTool.getAllRecRecordWithJavaUtilArrayList(recordTypes) as JavaUtilArrayList
                let itemList = ComFqLibRecordRecordTool.getAllRecordItemWithJavaUtilArrayList(recordTypes) as JavaUtilArrayList
                let controller = BrowRecordItemViewController()
                controller.isShareModel = false
                controller.clickPosition = Int32(itemList.indexOfWithId(recordItemSamp))
                controller.patientId = patientId
                controller.itemList = itemList
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }

    }
    
    override func getXibName() -> String {
        return "PracticeRecordViewController"
    }
    
    
    func getRecordItemList(recordId:Int32){
        let logic = ComFqHalcyonLogic2GetRecordTypeListLogic(comFqHalcyonLogic2GetRecordTypeListLogic_LoadRecordTypesCallBack: self)
        logic.loadRecordTypesWithInt(recordId, withBoolean: false)
    }
    
    func loadRecordTypesErrorWithInt(code: Int32, withNSString msg: String!) {
        
    }
    
    func loadRecordTypesResultWithInt(code: Int32, withJavaUtilArrayList mResultList: JavaUtilArrayList!) {
        
        for var i:Int32 = 0 ; i < mResultList.size() ; i++ {
            recordTypeArray.append(mResultList.getWithInt(i) as! ComFqHalcyonEntityRecordType)
        }
        for item in recordTypeArray {
            for var i:Int32 = 0 ; i < item.getItemList().size() ; i++ {
                recordItemArray.append(item.getItemList().getWithInt(i) as! ComFqHalcyonEntityRecordItemSamp)
            }
        }
        recordTypes = mResultList
        recordTableView.reloadData()
    }
    
    func getRecordList(patientId:Int32){
        let logic = ComFqHalcyonLogic2GetRecordListLogic(comFqHalcyonLogic2GetRecordListLogic_GetRecordListCallBack: self)
        logic.getRecordListWithInt(patientId)
    }
    
    func onGetRecordListErrorWithInt(code: Int32, withNSString msg: String!) {
        
    }
    
    func onGetRecordListWithJavaUtilArrayList(mRecordList: JavaUtilArrayList!) {
        if mRecordList.size() > 0 {
            let item = mRecordList.getWithInt(0) as! ComFqHalcyonEntityRecord
            getRecordItemList(item.getFolderId())
            ComFqLibRecordRecordCache.initCacheWithInt(item.getFolderId(), withInt: item.getFolderType())
            ComFqLibRecordRecordUploadNotify.inistance()
        }
    }
    
    override func onRightBtnOnClick(sender: UIButton) {
        let controller = TakePhotoViewController()
        controller.isEnterByParcticeRecord = true
        self.navigationController?.pushViewController(controller, animated: true)
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.navigationController?.pushViewController(SearchRecordItemViewController(), animated: true)
    }
}
