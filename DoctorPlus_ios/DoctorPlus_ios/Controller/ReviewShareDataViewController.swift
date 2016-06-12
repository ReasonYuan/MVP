//
//  ReviewShareDataViewController.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/5/20.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class ReviewShareDataViewController: BaseViewController,UITableViewDataSource,UITableViewDelegate,ComFqHalcyonLogic2GetRecordListLogic_GetRecordListCallBack {

    var mShareType:Int!
    var mShareRecord:ComFqHalcyonEntityRecord?
    var mSharePatient:ComFqHalcyonEntityPatient?
    var mRecords:JavaUtilArrayList! = JavaUtilArrayList()
   
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTittle("查看去身份化数据")
        hiddenRightImage(true)
        if mShareType == SHARE_PATIENT{
            getShareRecordList(mSharePatient!.getMedicalId())
        }else if mShareType == SHARE_RECORD{
            mRecords.addWithId(mShareRecord)
            tableView.reloadData()
        }
    }
    /**获取需要分享的病历列表*/
    func getShareRecordList(patientId:Int32){
        let logic:ComFqHalcyonLogic2GetRecordListLogic! = ComFqHalcyonLogic2GetRecordListLogic(comFqHalcyonLogic2GetRecordListLogic_GetRecordListCallBack: self)
        logic.getRecordListWithInt(patientId)
        
    }
    
    func onGetRecordListErrorWithInt(code: Int32, withNSString msg: String!) {
        UIAlertViewTool.getInstance().showAutoDismisDialog("获取数据失败", width: 210, height: 120)
    }
    func onGetRecordListWithJavaUtilArrayList(mRecordList: JavaUtilArrayList!) {
        mRecords = mRecordList
        tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("RecordTableViewCell") as? RecordTableViewCell
        
        if cell == nil {
            let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("RecordTableViewCell", owner: self, options: nil)
            cell = nibs.lastObject as? RecordTableViewCell
        }
        
        
        let record:ComFqHalcyonEntityRecord! = mRecords.getWithInt(Int32(indexPath.row)) as! ComFqHalcyonEntityRecord
        cell?.recordFolderName.text = record.getFolderName()
        cell?.shareFrom.hidden = true
        cell?.fromLine.hidden = true
        cell?.unRecongLabel.hidden = true
        cell?.shareFrom.text = ""
//        cell?.imgBg.image = UIImage(named: "record_no_unrec.png")
        cell?.imgBg.image  = Tools.createNinePathImageForImage(UIImage(named: "record_no_unrec.png"), leftMargin: 40, rightMargin: 40, topMargin: 50, bottomMargin: 10)
        
        if(record.getFolderType() == ComFqLibRecordRecordConstants_RECORD_TYPE_ADMISSION){
            //住院
            cell?.recordType.image = UIImage(named: "record_type_zy.png")
        }else if(record.getFolderType() == ComFqLibRecordRecordConstants_RECORD_TYPE_DOORCASE){
            //门诊
            cell?.recordType.image = UIImage(named: "record_type_mz.png")
        }
        
        cell?.timeLabel.text = ComFqLibToolsTimeFormatUtils.getTimeByStrWithNSString(record.getCreateTime(), withNSString: "yyyy/MM/dd")
        cell?.surveyRecord.enabled = false
//        cell?.surveyRecord.tag = indexPath.row
//        cell?.surveyRecord.addTarget(self, action: "survey:", forControlEvents: UIControlEvents.TouchUpInside)
        return cell!

    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(mRecords.size())
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 97
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let controller = BrowRecordViewController()
        controller.isShareModel = true
        let record = mRecords.getWithInt(Int32(indexPath.row)) as? ComFqHalcyonEntityRecord
        controller.mRecord = record
        self.navigationController?.pushViewController(controller, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func getXibName() -> String {
        return "ReviewShareDataViewController"
    }

}
