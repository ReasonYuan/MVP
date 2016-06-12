//
//  SVisualizeRecordViewController.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/5/21.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class SVisualizeRecordViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,ComFqHalcyonLogic2GetRecordListLogic_GetRecordListCallBack,ComFqHalcyonLogic2SurveyRecordLogic_SurveyRecordCallBack{
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var _tableView: UITableView!
    @IBOutlet weak var dialogTableView: UITableView!
    @IBOutlet var surveyAlertView: UIView!
    @IBOutlet weak var surveyLabel: UILabel!
    var loadingDialog:CustomIOS7AlertView?
    var surveyRecordDialog:CustomIOS7AlertView?
    
    //传递数据
    var patient:ComFqHalcyonEntityPatient?
    var data:ComFqHalcyonEntityVisualizeVisualData?
    var searchKey:String!
    
    var recordList:JavaUtilArrayList! = JavaUtilArrayList()
    var mSurItemList:JavaUtilArrayList! = JavaUtilArrayList()
    var mChkStatus:Dictionary<JavaLangInteger,Bool>? = Dictionary()
    var selectedRecords:JavaUtilArrayList! = JavaUtilArrayList()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTittle("请选择病历")
        hiddenRightImage(true)
        getRecordList(searchKey)
    }
    
    /**获取病历列表*/
    func getRecordList(key:String){
        loadingDialog = UIAlertViewTool.getInstance().showLoadingDialog("获取病历列表...")
        let logic:ComFqHalcyonLogic2GetRecordListLogic! = ComFqHalcyonLogic2GetRecordListLogic(comFqHalcyonLogic2GetRecordListLogic_GetRecordListCallBack: self)
        logic.getRecordListWithInt(patient!.getMedicalId(), withNSString: key)
    }
    func onGetRecordListErrorWithInt(code: Int32, withNSString msg: String!) {
        loadingDialog?.close()
        UIAlertViewTool.getInstance().showAutoDismisDialog("获取病历列表失败", width: 210, height: 120)
    }
    func onGetRecordListWithJavaUtilArrayList(mRecordList: JavaUtilArrayList!) {
        
        recordList = mRecordList
        for var i:Int32 = 0; i < recordList.size(); i++ {
            mChkStatus?.updateValue(true, forKey: JavaLangInteger(int:(recordList.getWithInt(i) as! ComFqHalcyonEntityRecord).getFolderId()))
            selectedRecords.addWithId(JavaLangInteger(int:(recordList.getWithInt(i) as! ComFqHalcyonEntityRecord).getFolderId()))
        }
        
        _tableView.reloadData()
        loadingDialog?.close()
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView.tag == 1 {
            var cell = tableView.dequeueReusableCellWithIdentifier("RecordTableViewCell") as? RecordTableViewCell
            
            if cell == nil {
                let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("RecordTableViewCell", owner: self, options: nil)
                cell = nibs.lastObject as? RecordTableViewCell
            }
            
            
            let record:ComFqHalcyonEntityRecord! = recordList.getWithInt(Int32(indexPath.row)) as! ComFqHalcyonEntityRecord
            cell?.recordFolderName.text = record.getFolderName()
            cell?.shareFrom.hidden = true
            cell?.fromLine.hidden = true
            cell?.unRecongLabel.hidden = true
            
            if mChkStatus?[JavaLangInteger(int:record.getFolderId())] == true{
//                cell?.imgBg.image = UIImage(named: "record_normal_select.png")
                 cell?.imgBg.image  = Tools.createNinePathImageForImage(UIImage(named: "record_normal_select.png"), leftMargin: 40, rightMargin: 40, topMargin: 50, bottomMargin: 10)
            }else{
//                cell?.imgBg.image = UIImage(named: "record_no_unrec.png")
                cell?.imgBg.image  = Tools.createNinePathImageForImage(UIImage(named: "record_no_unrec.png"), leftMargin: 40, rightMargin: 40, topMargin: 50, bottomMargin: 10)
            }
            
            
            if(record.getFolderType() == ComFqLibRecordRecordConstants_RECORD_TYPE_ADMISSION){
                //住院
                cell?.recordType.image = UIImage(named: "record_type_zy.png")
            }else if(record.getFolderType() == ComFqLibRecordRecordConstants_RECORD_TYPE_DOORCASE){
                //门诊
                cell?.recordType.image = UIImage(named: "record_type_mz.png")
            }
            
            if record.getSourceFrom() == ComFqLibRecordRecordConstants_RECORD_FROM_OWN{
                cell?.shareFrom.text = ""//自己上传
            }else{
                cell?.shareFrom.hidden = false
                cell?.fromLine.hidden = false
                cell?.shareFrom.text = "\(record.getSharePerson())分享"
            }
            
            cell?.timeLabel.text = ComFqLibToolsTimeFormatUtils.getTimeByStrWithNSString(record.getCreateTime(), withNSString: "yyyy/MM/dd")
            cell?.surveyRecord.tag = indexPath.row
            cell?.surveyRecord.addTarget(self, action: "survey:", forControlEvents: UIControlEvents.TouchUpInside)
            return cell!
        }
        
        if tableView.tag == 2 {//预览
            var cell = tableView.dequeueReusableCellWithIdentifier("SurveyTableViewCell") as? SurveyTableViewCell
            
            if cell == nil {
                let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("SurveyTableViewCell", owner: self, options: nil)
                cell = nibs.lastObject as? SurveyTableViewCell
            }
            
            let surveyRecordItem:ComFqHalcyonEntitySurveyRecordItem! = mSurItemList.getWithInt(Int32(indexPath.row)) as! ComFqHalcyonEntitySurveyRecordItem
            if indexPath.row%2 == 0 {
                cell?.bottomLine.hidden = true
            }else{
                cell?.bottomLine.hidden = false
            }
            cell?.keyLabel.text = surveyRecordItem.getName()
            cell?.valueLabel.text = surveyRecordItem.getContent()
            
            return cell!
        }
        
        
        
        return UITableViewCell()
        
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 1 {
            tableView.rowHeight = 97
            return Int(recordList.size())
        }
        
        if tableView.tag == 2 {
            tableView.rowHeight = 30
            return Int(mSurItemList.size())
        }
        return 0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.tag == 1 {
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! RecordTableViewCell
            let record:ComFqHalcyonEntityRecord! = recordList.getWithInt(Int32(indexPath.row)) as! ComFqHalcyonEntityRecord
            if mChkStatus?[JavaLangInteger(int:record.getFolderId())] == false{
                mChkStatus?.updateValue(true, forKey: JavaLangInteger(int:record.getFolderId()))
                selectedRecords.addWithId(JavaLangInteger(int:record.getFolderId()))
//                cell.imgBg.image = UIImage(named: "record_normal_select.png")
                cell.imgBg.image  = Tools.createNinePathImageForImage(UIImage(named: "record_normal_select.png"), leftMargin: 40, rightMargin: 40, topMargin: 50, bottomMargin: 10)
            }else{
                mChkStatus?.updateValue(false, forKey: JavaLangInteger(int:record.getFolderId()))
                selectedRecords.removeWithId(JavaLangInteger(int:record.getFolderId()))
//                cell.imgBg.image = UIImage(named: "record_no_unrec.png")
                 cell.imgBg.image  = Tools.createNinePathImageForImage(UIImage(named: "record_no_unrec.png"), leftMargin: 40, rightMargin: 40, topMargin: 50, bottomMargin: 10)
            }
        }
    }
    /**概览点击*/
    func survey(sender:UIButton){
        let record:ComFqHalcyonEntityRecord! = recordList.getWithInt(Int32(sender.tag)) as! ComFqHalcyonEntityRecord
        getSurRecordItem(record.getFolderId())
    }
    /**获取病案的概览信息*/
    func getSurRecordItem(recordId:Int32){
        loadingDialog = UIAlertViewTool.getInstance().showLoadingDialog("")
        UITools.setRoundBounds(9,view: surveyAlertView)
        surveyRecordDialog = CustomIOS7AlertView()
        surveyRecordDialog?.setCancelonTouch(true)
        surveyRecordDialog!.containerView = surveyAlertView
        let logic:ComFqHalcyonLogic2SurveyRecordLogic! = ComFqHalcyonLogic2SurveyRecordLogic(comFqHalcyonLogic2SurveyRecordLogic_SurveyRecordCallBack: self)
        logic.surveyRecordWithInt(recordId)
        
    }
    func onSurveyErrorWithInt(code: Int32, withNSString msg: String!) {
        loadingDialog?.close()
        dialogTableView.hidden = true
        surveyLabel.text = "获取概览信息失败"
        surveyRecordDialog!.show()
        
    }
    func onSurveyResultWithInt(code: Int32, withJavaUtilArrayList surItemList: JavaUtilArrayList!) {
        loadingDialog?.close()
        if surItemList.size() == 0 {
            dialogTableView.hidden = true
            surveyLabel.text = "没有概览信息"
            surveyRecordDialog!.show()
            return
        }
        dialogTableView.hidden = false
        mSurItemList = surItemList
        dialogTableView.reloadData()
        surveyRecordDialog!.show()
    }
    
    /**可视化*/
    @IBAction func visualize(sender: AnyObject) {
        
        if selectedRecords.size() == 0 {
            UIAlertViewTool.getInstance().showAutoDismisDialog("请选择病历", width: 210, height: 120)
            return
        }
        let controller:DataVisualizationViewController! = DataVisualizationViewController()
        data?.setRecordIdsWithJavaUtilArrayList(selectedRecords)
        //传值跳转
        controller.entity = data
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    /**搜索*/
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.endEditing(true)
        if searchBar.text!.isEmpty {
            return
        }
        searchKey = searchBar.text
        getRecordList(searchKey)
        print("开始搜索\(searchBar.text)")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func getXibName() -> String {
        return "SVisualizeRecordViewController"
    }
}