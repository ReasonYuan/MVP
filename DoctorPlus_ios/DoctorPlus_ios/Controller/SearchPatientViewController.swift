//
//  SearchPatientViewController.swift
//  DoctorPlus_ios
//
//  Created by monkey on 15-5-12.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class SearchPatientViewController: BaseViewController,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,ComFqHalcyonLogic2SearchPatientLogic_SearchMedicalCallBack,ComFqHalcyonLogic2SurveyPatientLogic_SurveyPatientCallBack ,UIGestureRecognizerDelegate,FQControllerViewDelegate,ComFqHalcyonLogic2DelPatientLogic_DelMedicalCallBack,ComFqHalcyonLogic2ModifyPatientNameLogic_ModifyPatientNameCallBack{

    var viewHeight = CGFloat(80)
    var viewWidth = ScreenWidth
    var longPress:UILongPressGestureRecognizer?
    var controllerView:FQControllerView?
    var selectedPosition = -1
    var selectedPatient:ComFqHalcyonEntityPatient?
    var isMenuShow:Bool = false
    var searchKey:String = ""
    var patientList = [ComFqHalcyonEntityPatient]()
    var delDialog:CustomIOS7AlertView?
    var renameDialog:CustomIOS7AlertView?
    var tempRename:String?
    var edtRename:UITextField?
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
        
        controllerView = FQControllerView.getInstance()
        controllerView?.delegate = self
        controllerView!.frame = CGRectMake(0, ScreenHeight + 80, ScreenWidth, 80)
        self.view.addSubview(controllerView!)
        initLongClick()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func getXibName() -> String {
        return "SearchPatientViewController"
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
            let controller = RecordListViewController()
            controller.patient = patientList[index]
            if isMenuShow {
                setControllerShow()
                return
            }
            if patientList[index].getRecordCount() == 0 {
                controller.isNewPatient = controller.IS_NEW_PATIENT
            }else {
                controller.isNewPatient = controller.ISNOT_NEW_PATIENT
            }
            
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
//        UITools.setRoundBounds(9, view: surveyDialog)
//        surveyPatientAlertView = CustomIOS7AlertView()
//        surveyPatientAlertView?.setCancelonTouch(true)
//        surveyPatientAlertView?.containerView = surveyDialog
//        var patientId = patientList[sender.tag].getMedicalId()
//        getSurveyPatientList(patientId)
//        surveyPatientAlertView?.show()
        self.navigationController?.pushViewController(TakePhotoViewController(), animated: true)
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
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.endEditing(true)
        if !searchBar.text!.isEmpty {
            searchPatient(searchBar.text!)
        }
    }
    
    /**
    初始化长按点击事件
    */
    func initLongClick(){
        
        longPress = UILongPressGestureRecognizer(target: self, action: Selector("patientTAbleCellLongPressed:"))
        longPress?.minimumPressDuration = 1.0
        longPress?.delegate = self
        patientTableView.addGestureRecognizer(longPress!)
    }
    
    /**
    tableCell的长按点击事件
    */
    func patientTAbleCellLongPressed(gestureRecognizer:UILongPressGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            let point = gestureRecognizer.locationInView(self.patientTableView)
            let indexPath = self.patientTableView.indexPathForRowAtPoint(point)
            if indexPath == nil {
                return
            }
            if isMenuShow {
                return
            }
            setControllerShow()
            selectedPosition = indexPath!.row
            selectedPatient = patientList[selectedPosition]
            patientTableView.reloadData()
        }
    }
    
    /**
    view出现和隐藏的动画
    */
    func setControllerShow(){
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.25)
        UIView.setAnimationDelegate(self)
        UIView.setAnimationCurve(UIViewAnimationCurve.EaseInOut)
        
        if isMenuShow {
            isMenuShow = false
            selectedPosition = -1
            patientTableView.reloadData()
            controllerView!.frame = CGRectMake(0, ScreenHeight + 80, viewWidth, viewHeight)
        }else{
            isMenuShow = true
            controllerView!.frame = CGRectMake(0, ScreenHeight - 80, viewWidth, viewHeight)
        }
        UIView.commitAnimations()
    }
    
    /**
    分享病案的操作
    */
    func onShareBtnClickListener() {
        setControllerShow()
        let controller = ChoseSharePeopleViewController()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    /**
    重命名病案的操作
    */
    func onRenameBtnClickListener() {
        setControllerShow()
//        (renameDialog,edtRename) = UIAlertViewTool.getInstance().showNewTextFieldDialog("重命名", hint: "", target: self, actionOk: "sureRenameBtnClick", actionCancle: "cancelRenameBtnClick")
//        edtRename?.text = selectedPatient?.getMedicalName()
    }
    
    /**
    确认重命名按钮的点击事件
    */
    func sureRenameBtnClick(){
        
        if edtRename!.text!.isEmpty || edtRename!.text == selectedPatient!.getMedicalName() {
            renameDialog?.close()
        }else{
            tempRename = edtRename!.text
            renameLogic(tempRename!)
            renameDialog?.close()
        }
        
    }
    
    /**
    取消重命名按钮的点击事件
    */
    func cancelRenameBtnClick(){
        renameDialog?.close()
    }
    
    /**
    重命名的逻辑
    */
    func renameLogic(name:String){
        let logic = ComFqHalcyonLogic2ModifyPatientNameLogic(comFqHalcyonLogic2ModifyPatientNameLogic_ModifyPatientNameCallBack: self)
        logic.modifyNameWithInt(selectedPatient!.getMedicalId(), withNSString: name)
    }
    
    /**
    重命名失败的回调
    */
    func modifyNameErrorWithInt(code: Int32, withNSString msg: String!) {
        
    }
    
    /**
    重命名成功的回调
    */
    func modifyNameSuccessWithInt(code: Int32, withNSString msg: String!) {
        for var i:Int = 0; i < patientList.count; i++ {
            let item = patientList[i]
            if item.getMedicalId() == selectedPatient?.getMedicalId() {
                patientList[i].setMedicalNameWithNSString(tempRename)
                patientTableView.reloadData()
                return
            }
        }
    }
    
    /**
    删除病案的操作
    */
    func onDelBtnClickListener() {
        setControllerShow()
        delDialog = UIAlertViewTool.getInstance().showNewDelDialog("确认删除？", target: self, actionOk: "sureDelPatientClick", actionCancle: "cancelDelPatientClick")
    }
    
    /**
    删除病案的确认按钮点击事件
    */
    func sureDelPatientClick(){
        delPatientLogic()
        delDialog?.close()
    }
    
    /**
    取消删除病案的按钮点击事件
    */
    func cancelDelPatientClick(){
        delDialog?.close()
    }

    /**
    删除病案的逻辑
    */
    func delPatientLogic(){
        let delLogic = ComFqHalcyonLogic2DelPatientLogic(comFqHalcyonLogic2DelPatientLogic_DelMedicalCallBack: self)
        delLogic.delMedicalWithInt(selectedPatient!.getMedicalId())
    }
    
    /**
    删除病案失败的回调
    */
    func onDelMedicalErrorWithInt(code: Int32, withNSString msg: String!) {
        
    }
    
    /**
    删除病案成功的回调
    */
    func onDelMedicalSuccessWithInt(code: Int32, withNSString msg: String!) {
        
        for var i : Int = 0 ; i < patientList.count ; i++ {
            let item = patientList[i]
            if item.getMedicalId() == selectedPatient?.getMedicalId() {
                patientList.removeAtIndex(i)
                patientTableView.reloadData()
                return
            }
        }
    }
    
    @IBAction func filterPatientClickListener() {
        self.navigationController?.pushViewController(FilterPatientViewController(), animated: true)
    }
    
}
