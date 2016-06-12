//
//  VisualChoosePatientViewController.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/5/21.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class VisualChoosePatientViewController: BaseViewController ,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,MGSwipeTableCellDelegate,ComFqHalcyonLogic2SearchPatientLogic_SearchMedicalCallBack,ComFqHalcyonLogic2SurveyPatientLogic_SurveyPatientCallBack{
    
    var data:ComFqHalcyonEntityVisualizeVisualData!
    var patientList = [ComFqHalcyonEntityPatient]()
    @IBOutlet weak var patientTableView: UITableView!
    var loadingDialog:CustomIOS7AlertView?
    var viewHeight = CGFloat(80)
    var viewWidth = ScreenWidth
    
    var selectedPosition = -1
    var selectedPatient:ComFqHalcyonEntityPatient?
    
    var surveyPatientList = [ComFqHalcyonEntitySurveyPatientItem]()
    var surveyPatientAlertView:CustomIOS7AlertView?
    @IBOutlet var surveyDialog: UIView!
    @IBOutlet weak var surveyPatientTableView: UITableView!
    @IBOutlet weak var surveyNotice: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTittle("请选择病案")
        hiddenRightImage(true)
        getPatientList()
        setTableViewRefresh()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func getXibName() -> String {
        return "VisualChoosePatientViewController"
    }
    
    /**设置tabview 上拉下拉**/
    func setTableViewRefresh(){
        patientTableView.headerBeginRefreshing()
        patientTableView.addHeaderWithTarget(self, action: "headerRereshing")
        patientTableView.addFooterWithTarget(self, action: "footerRereshing")
    }
    
    /**下拉事件处理**/
    func headerRereshing(){
        // 刷新表格
        patientTableView.reloadData()
        // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
        patientTableView.headerEndRefreshing()
    }
    
    /**上拉事件处理**/
    func footerRereshing(){
        // 刷新表格
        patientTableView.reloadData()
        // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
        patientTableView.footerEndRefreshing()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let patient = patientList[indexPath.row]
        let time = ComFqLibToolsTimeFormatUtils.getTimeByStrWithNSString(patient.getCreateTime(), withNSString: "yyyy/MM/dd")
        if tableView.tag == 1 {
            var cell:UITableViewCell?
            if patient.getMedicalFromType() == ComFqLibRecordRecordConstants_MEDICAL_FROM_OWN {
                cell = tableView.dequeueReusableCellWithIdentifier("PatientNormalTableViewCell") as? PatientNormalTableViewCell
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier("PatientShareTableViewCell") as? PatientShareTableViewCell
            }
            
            if cell == nil {
                if patient.getMedicalFromType() == ComFqLibRecordRecordConstants_MEDICAL_FROM_OWN {
                    let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("PatientNormalTableViewCell", owner: self, options: nil)
                    cell = nibs.lastObject as? PatientNormalTableViewCell
                } else {
                    let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("PatientShareTableViewCell", owner: self, options: nil)
                    cell = nibs.lastObject as? PatientShareTableViewCell
                }
            }
            
            if patient.getMedicalFromType() == ComFqLibRecordRecordConstants_MEDICAL_FROM_OWN {
                let normalCell = cell as! PatientNormalTableViewCell
                normalCell.bgImg.highlighted = false
                normalCell.cutLineLabel.backgroundColor = Color.color_grey
                if selectedPosition == indexPath.row {
                    normalCell.bgImg.highlighted = true
                    normalCell.cutLineLabel.backgroundColor = Color.color_emerald
                }
                normalCell.patientName.text = patient.getMedicalName()
                normalCell.patientTime.text = time
                normalCell.recordCount.text = "(\(patient.getRecordCount()))"
                normalCell.overviewBtn.tag = indexPath.row
                normalCell.overviewBtn.addTarget(self, action: Selector("overviewBtnClick:"), forControlEvents: UIControlEvents.TouchUpInside)
                return normalCell
            } else {
                let shareCell = cell as! PatientShareTableViewCell
                shareCell.bgImg.highlighted = false
                shareCell.cutLineLabel.backgroundColor = Color.color_grey
                if selectedPosition == indexPath.row {
                    shareCell.bgImg.highlighted = true
                    shareCell.cutLineLabel.backgroundColor = Color.color_emerald
                }
                shareCell.patientName.text = patient.getMedicalName()
                shareCell.patientTime.text = time
                shareCell.patientFrom.lineBreakMode = NSLineBreakMode.ByTruncatingMiddle
                if patient.getFromUserType() == ComFqLibToolsConstants_ROLE_DOCTOR {
                    shareCell.patientFrom.text = "\(patient.getMedicalFrom())医生分享"
                }else{
                    shareCell.patientFrom.text = "\(patient.getMedicalFrom())病人分享"
                }
                shareCell.overviewBtn.tag = indexPath.row
                shareCell.overviewBtn.addTarget(self, action: Selector("overviewBtnClick:"), forControlEvents: UIControlEvents.TouchUpInside)
                shareCell.recordCount.text = "(\(patient.getRecordCount()))"
                return shareCell
            }
        }else if tableView.tag == 2 {
            var cell:PatientSurveyTableViewCell? = tableView.dequeueReusableCellWithIdentifier("PatientSurveyTableViewCell") as? PatientSurveyTableViewCell
            
            if cell == nil {
                let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("PatientSurveyTableViewCell", owner: self, options: nil)
                cell = nibs.lastObject as? PatientSurveyTableViewCell
            }
            let surveyItem = surveyPatientList[indexPath.row]
            cell?.patientName.text = surveyItem.getPatientName()
            cell?.tentativeDiag.text = surveyItem.getTentativeDiag()
            return cell!
        }
        
        return UITableViewCell()
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 1 {
            tableView.rowHeight = 100
            return patientList.count
        }else if tableView.tag == 2 {
            tableView.rowHeight = 60
            return surveyPatientList.count
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.tag == 1 {
            let index = indexPath.row
            let controller = ChoseRecordViewController()
            controller.patient = patientList[index]
            controller.data = data
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    /**
    获取病历列表
    */
    func getPatientList(){
        loadingDialog = UIAlertViewTool.getInstance().showLoadingDialog("获取病案...")
        let logic = ComFqHalcyonLogic2SearchPatientLogic(comFqHalcyonLogic2SearchPatientLogic_SearchMedicalCallBack: self)
        logic.searchMedicalWithNSString("")
    }
    
    /**
    获取病历列表错误的回调
    */
    func onSearchMedicalErrorWithInt(code: Int32, withNSString msg: String!) {
        loadingDialog?.close()
        UIAlertViewTool.getInstance().showAutoDismisDialog("获取病案失败", width: 210, height: 120)
    }
    
    /**
    获取病历列表成功的回调
    */
    func onSearchMedicalResultWithJavaUtilArrayList(medicalList: JavaUtilArrayList!) {
        for var i:Int32 = 0 ; i < medicalList.size() ; i++ {
            patientList.append(medicalList.getWithInt(i) as! ComFqHalcyonEntityPatient)
        }
        patientTableView.reloadData()
        loadingDialog?.close()
    }
    
    /**
    概览按钮的点击事件
    */
    @IBAction func overviewBtnClick(sender:UIButton){
        UITools.setRoundBounds(9, view: surveyDialog)
        surveyPatientAlertView = CustomIOS7AlertView()
        surveyPatientAlertView?.setCancelonTouch(true)
        surveyPatientAlertView?.containerView = surveyDialog
        let patientId = patientList[sender.tag].getMedicalId()
        getSurveyPatientList(patientId)
    }
    
    /**
    获取病案概览
    */
    func getSurveyPatientList(patientId:Int32){
        loadingDialog = UIAlertViewTool.getInstance().showLoadingDialog("")
        let logic = ComFqHalcyonLogic2SurveyPatientLogic(comFqHalcyonLogic2SurveyPatientLogic_SurveyPatientCallBack: self)
        logic.surveyPatientWithInt(patientId)
    }
    
    /**
    获取概览信息失败的回调
    */
    func onSurveyErrorWithInt(code: Int32, withNSString msg: String!) {
        loadingDialog?.close()
        surveyPatientTableView.hidden = true
        surveyNotice.hidden = false
        surveyNotice.text = "获取概览信息失败！"
        surveyPatientAlertView?.show()
    }
    
    /**
    获取概览信息成功的回调
    */
    func onSurveyResultWithInt(code: Int32, withJavaUtilArrayList surItemList: JavaUtilArrayList!) {
        loadingDialog?.close()
        surveyPatientList = [ComFqHalcyonEntitySurveyPatientItem]()
        for var i:Int32 = 0; i < surItemList.size(); i++ {
            let item: ComFqHalcyonEntitySurveyPatientItem! = surItemList.getWithInt(i) as! ComFqHalcyonEntitySurveyPatientItem
            surveyPatientList.append(item)
        }
        if surveyPatientList.count == 0 {
            surveyPatientTableView.hidden = true
            surveyNotice.hidden = false
            surveyNotice.text = "没有概览信息！"
        }else {
            surveyPatientTableView.hidden = false
            surveyNotice.hidden = true
            surveyPatientTableView.reloadData()
        }
        surveyPatientAlertView?.show()
    }
    
    /**
    搜索事件
    */
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.endEditing(true)
        if searchBar.text!.isEmpty {
            return
        }
        var controller = VisualSearchPatientViewController()
        controller.searchKey = searchBar.text!
        controller.data = data
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

