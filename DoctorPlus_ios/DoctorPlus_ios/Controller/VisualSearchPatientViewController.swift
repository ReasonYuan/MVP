//
//  VisualSearchPatientViewController.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/5/21.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class VisualSearchPatientViewController: BaseViewController,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,ComFqHalcyonLogic2SearchPatientLogic_SearchMedicalCallBack,ComFqHalcyonLogic2SurveyPatientLogic_SurveyPatientCallBack {
    
    var data:ComFqHalcyonEntityVisualizeVisualData!
    var viewHeight = CGFloat(80)
    var viewWidth = ScreenWidth
    var selectedPosition = -1
    var selectedPatient:ComFqHalcyonEntityPatient?
    var searchKey:String = ""
    var patientList = [ComFqHalcyonEntityPatient]()
    var surveyPatientList = [ComFqHalcyonEntitySurveyPatientItem]()
    var surveyPatientAlertView:CustomIOS7AlertView?
    @IBOutlet var surveyDialog: UIView!
    @IBOutlet weak var surveyPatientTableView: UITableView!
    @IBOutlet weak var surveyNotice: UILabel!
    @IBOutlet weak var patientTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTittle("搜索病案")
        hiddenRightImage(true)
        
        if !searchKey.isEmpty {
            searchPatient(searchKey)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func getXibName() -> String {
        return "VisualSearchPatientViewController"
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
    搜索病案
    */
    func searchPatient(key:String){
        let logic = ComFqHalcyonLogic2SearchPatientLogic(comFqHalcyonLogic2SearchPatientLogic_SearchMedicalCallBack: self)
        logic.searchMedicalWithNSString(key)
    }
    
    /**
    获取病历列表错误的回调
    */
    func onSearchMedicalErrorWithInt(code: Int32, withNSString msg: String!) {
        
    }
    
    /**
    获取病历列表成功的回调
    */
    func onSearchMedicalResultWithJavaUtilArrayList(medicalList: JavaUtilArrayList!) {
        patientList = [ComFqHalcyonEntityPatient]()
        for var i:Int32 = 0 ; i < medicalList.size() ; i++ {
            patientList.append(medicalList.getWithInt(i) as! ComFqHalcyonEntityPatient)
        }
        patientTableView.reloadData()
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
        let logic = ComFqHalcyonLogic2SurveyPatientLogic(comFqHalcyonLogic2SurveyPatientLogic_SurveyPatientCallBack: self)
        logic.surveyPatientWithInt(patientId)
    }
    
    /**
    获取概览信息失败的回调
    */
    func onSurveyErrorWithInt(code: Int32, withNSString msg: String!) {
        surveyPatientTableView.hidden = true
        surveyNotice.hidden = false
        surveyNotice.text = "获取概览信息失败！"
        surveyPatientAlertView?.show()
    }
    
    /**
    获取概览信息成功的回调
    */
    func onSurveyResultWithInt(code: Int32, withJavaUtilArrayList surItemList: JavaUtilArrayList!) {
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
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.endEditing(true)
        if !searchBar.text!.isEmpty {
            searchPatient(searchBar.text!)
        }
    }

}
