//
//  PatientListViewController.swift
//  DoctorPlus_ios
//
//  Created by monkey on 15-5-11.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class SelectPatientListViewController: BaseViewController ,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,MGSwipeTableCellDelegate,ComFqHalcyonLogic2SearchPatientLogic_SearchMedicalCallBack,ComFqHalcyonLogic2SurveyPatientLogic_SurveyPatientCallBack,FQControllerViewDelegate,UIGestureRecognizerDelegate,ComFqHalcyonLogic2CreatePatientLogic_CreateMedicalCallBack,ComFqHalcyonLogic2DelPatientLogic_DelMedicalCallBack,ComFqHalcyonLogic2ModifyPatientNameLogic_ModifyPatientNameCallBack,RecordListDelegate{
    
    
    @IBOutlet var renamePatientView: UIView!
    @IBOutlet weak var renameSureBtn: UIButton!
    @IBOutlet weak var renameCancelBtn: UIButton!
    @IBOutlet weak var renameTableView: UITableView!
    @IBOutlet weak var editRename: UITextField!
    
    @IBOutlet var createPatientView: UIView!
    @IBOutlet weak var edtPatientName: UITextField!
    @IBOutlet weak var createPatientBtn: UIButton!
    @IBOutlet weak var cancelCreateBtn: UIButton!
    var createPatientDialog:CustomIOS7AlertView?
    var loadingDialog:CustomIOS7AlertView?
    var patientList = [ComFqHalcyonEntityPatient]()
    @IBOutlet weak var patientTableView: UITableView!
    
    var viewHeight = CGFloat(80)
    var viewWidth = ScreenWidth
    var longPress:UILongPressGestureRecognizer?
    var controllerView:FQControllerView?
    
    var selectedPosition = -1
    var selectedPosition2 = -1
    var selectedPatient:ComFqHalcyonEntityPatient?
    
    var delDialog:CustomIOS7AlertView?
    var renameDialog:CustomIOS7AlertView?
    
    var isMenuShow:Bool = false
    
    var tempRename:String?
    var edtRename:UITextField?
    
    var surveyPatientList = [ComFqHalcyonEntitySurveyPatientItem]()
    var surveyPatientAlertView:CustomIOS7AlertView?
    @IBOutlet var surveyDialog: UIView!
    @IBOutlet weak var surveyPatientTableView: UITableView!
    @IBOutlet weak var surveyNotice: UILabel!
    
    var page = 1
    var pageSize = 20
    var patientListInTrash = [Int32]()
    var arrayRename = Array<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        patientListInTrash = getTrashList( ComFqHalcyonPracticeTrash_TYPE_MEDICA_RECORD_ )
        patientTableView.registerNib(UINib(nibName: "PatientNormalTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PatientNormalTableViewCell")
        patientTableView.registerNib(UINib(nibName: "PatientShareTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PatientShareTableViewCell")
        patientTableView.registerNib(UINib(nibName: "PatientSurveyTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PatientSurveyTableViewCell")
        renameTableView.registerNib(UINib(nibName: "PatientRenameTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PatientRenameTableViewCell")
        setTittle("云病例库")
        setTableViewRefresh()
        getPatientList(page)
        controllerView = FQControllerView.getInstance()
        controllerView?.delegate = self
        controllerView!.frame = CGRectMake(0, ScreenHeight + 80, ScreenWidth, 80)
        self.view.addSubview(controllerView!)
        initLongClick()
        //        patientTableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tabViewTap:"))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func getXibName() -> String {
        return "SelectPatientListViewController"
    }
    
    func tabViewTap(gestrue:UITapGestureRecognizer){
        if isMenuShow {
            setControllerShow()
        }
    }
    
    /**设置tabview 上拉下拉**/
    func setTableViewRefresh(){
        patientTableView.headerBeginRefreshing()
        //        patientTableView.addHeaderWithTarget(self, action: "headerRereshing")
        patientTableView.addFooterWithTarget(self, action: "footerRereshing")
    }
    
    /**下拉事件处理**/
    /*  func headerRereshing(){
    // 刷新表格
    patientTableView.reloadData()
    // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
    patientTableView.headerEndRefreshing()
    }*/
    
    /**上拉事件处理**/
    func footerRereshing(){
        // 刷新表格
        getPatientList(page)
        // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
        patientTableView.footerEndRefreshing()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var  cell = tableView.dequeueReusableCellWithIdentifier("PatientNormalTableViewCell") as? PatientNormalTableViewCell
        
        if tableView.tag == 1 {
            let patient = patientList[indexPath.row]
            let time = ComFqLibToolsTimeFormatUtils.getTimeByStrWithNSString(patient.getCreateTime(), withNSString: "yyyy/MM/dd")
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
        }else if tableView.tag == 3 {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("PatientRenameTableViewCell") as? PatientRenameTableViewCell
            cell!.renameLabel.text = arrayRename[indexPath.row]
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
        }else if tableView.tag == 3 {
            return arrayRename.count
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var count  = self.navigationController?.viewControllers.count
        var controller = self.navigationController!.viewControllers[count!-3]
//        self.navigationController?.viewControllers.removeRange(Range(start:count! - 2, end: count! - 1))
        self.navigationController?.popToViewController(controller, animated: true)
         ComFqLibRecordRecordCache.clearCache()
    }
    
    /**
    获取病历列表
    */
    func getPatientList(page:Int){
        if( Tools.isNetWorkConnect() ){
            loadingDialog = UIAlertViewTool.getInstance().showLoadingDialog("获取病案...")
        }
        let logic = ComFqHalcyonLogic2SearchPatientLogic(comFqHalcyonLogic2SearchPatientLogic_SearchMedicalCallBack: self)
        logic.searchMedicalWithNSString("", withInt: Int32(page), withInt: Int32(pageSize))
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
            let entity = medicalList.getWithInt(i) as! ComFqHalcyonEntityPatient
            var inTrash = false
            for i in patientListInTrash{
                if (entity.getMedicalId() == i){
                    inTrash = true
                }
            }
            if(!inTrash){
                patientList.append(entity)
            }
        }
        page = page + 1
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
        //        surveyPatientAlertView?.show()
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
        var controller = SearchPatientViewController()
        controller.searchKey = searchBar.text!
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    /**
    右上角按钮点击事件（创建病案）
    */
    override func onRightBtnOnClick(sender: UIButton) {
        setCreateDialogStyle(createPatientView, sureBtn: createPatientBtn, cancelBtn: cancelCreateBtn)
        createPatientDialog = CustomIOS7AlertView()
        createPatientDialog!.containerView = createPatientView
        edtPatientName.text = ""
        createPatientDialog!.show()
    }
    
    /**
    确认创建病案的按钮点击事件
    */
    @IBAction func onCreatePatientClick() {
        if !edtPatientName.text!.isEmpty {
            createPatientLogic(edtPatientName.text!)
        }
        createPatientDialog?.close()
    }
    
    /**
    取消创建病案的按钮点击事件
    */
    @IBAction func onCancelCreateClick() {
        createPatientDialog?.close()
    }
    
    func setCreateDialogStyle(alertView:UIView,sureBtn:UIButton, cancelBtn:UIButton){
        UITools.setButtonStyle(sureBtn, buttonColor: Color.color_emerald, textSize: 24, textColor: Color.color_emerald)
        UITools.setButtonStyle(cancelBtn, buttonColor: Color.color_grey, textSize: 24, textColor: Color.color_grey,isOpposite:true)
        UITools.setBtnWithOneRound(sureBtn, corners: UIRectCorner.BottomLeft)
        UITools.setBtnWithOneRound(cancelBtn, corners: UIRectCorner.BottomRight)
        UITools.setRoundBounds(9,view: alertView)
        UITools.setBorderWithView(1, tmpColor: Color.color_emerald.CGColor, view: cancelBtn)
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
            controllerView!.frame = CGRectMake(0, ScreenHeight + 80, viewWidth, viewHeight)
            patientTableView.reloadData()
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
        controller.mShareType = SHARE_PATIENT
        controller.mSharePatient = selectedPatient
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    /**
    重命名病案的操作
    */
    func onRenameBtnClickListener() {
        //        setControllerShow()
        //        (renameDialog,edtRename) = UIAlertViewTool.getInstance().showTextFieldDialog("重命名", hint: "", target: self, actionOk: "sureRenameBtnClick", actionCancle: "cancelRenameBtnClick")
        setCreateDialogStyle(renamePatientView, sureBtn: renameSureBtn, cancelBtn: renameCancelBtn)
        renameDialog = CustomIOS7AlertView()
        renameDialog!.containerView = renamePatientView
        renameDialog!.show()
        edtRename?.text = selectedPatient?.getMedicalName()
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
//        if gestureRecognizer.state == UIGestureRecognizerState.Began {
//            var point = gestureRecognizer.locationInView(self.patientTableView)
//            var indexPath = self.patientTableView.indexPathForRowAtPoint(point)
//            if indexPath == nil {
//                return
//            }
//            if isMenuShow {
//                return
//            }
//            setControllerShow()
//            selectedPosition = indexPath!.row
//            selectedPosition2 = indexPath!.row
//            selectedPatient = patientList[selectedPosition]
//            patientTableView.reloadData()
//            arrayRename = getRenameArray(selectedPatient!)
//        }
    }
    
    
    /**
    创建病案的逻辑
    */
    func createPatientLogic(name:String){
        if isMenuShow {
            setControllerShow()
        }
        let createLogic = ComFqHalcyonLogic2CreatePatientLogic(comFqHalcyonLogic2CreatePatientLogic_CreateMedicalCallBack: self)
        createLogic.createMedicalWithNSString(name)
    }
    
    /**
    创建病案失败的回调
    */
    func createMedicalErrorWithInt(code: Int32, withNSString msg: String!) {
        
    }
    
    /**
    创建病案成功的回调
    */
    func createMedicalSuccessWithInt(code: Int32, withComFqHalcyonEntityPatient medical: ComFqHalcyonEntityPatient!) {
        patientList.insert(medical, atIndex: 0)
        patientTableView.reloadData()
        let controller = RecordListViewController()
        controller.isNewPatient = controller.IS_NEW_PATIENT
        controller.patient = medical
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    /**
    删除病案的逻辑
    */
    func delPatientLogic(){
        //        var delLogic = ComFqHalcyonLogic2DelPatientLogic(comFqHalcyonLogic2DelPatientLogic_DelMedicalCallBack: self)
        //        delLogic.delMedicalWithInt(selectedPatient!.getMedicalId())
        mTrash.moveToTrashWithNSString(ComFqHalcyonPracticeTrash_TYPE_MEDICA_RECORD_, withInt: selectedPatient!.getMedicalId(), withNSString: "")
        patientList.removeAtIndex(selectedPosition2)
        patientTableView.reloadData()
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
    
    func getRecordListCount(isModify: Bool, listCount: Int, patientId: Int32) {
        if isModify {
            for item in patientList {
                if item.getMedicalId() == patientId {
                    item.setRecordCountWithInt(Int32(listCount))
                    self.patientTableView.reloadData()
                    break
                }
            }
        }
    }
    
    @IBAction func renameSureListener() {
        if editRename!.text!.isEmpty || editRename!.text == selectedPatient!.getMedicalName() {
            renameDialog?.close()
        }else{
            tempRename = editRename!.text
            renameLogic(tempRename!)
            renameDialog?.close()
        }
    }
    
    @IBAction func renameCancelListener() {
        renameDialog?.close()
    }
    
    func getRenameArray(selectPatient:ComFqHalcyonEntityPatient!) -> Array<String>{
        var renameArray = Array<String>();
        let patientName = selectPatient.getMedicalName()
        let time = ComFqLibToolsTimeFormatUtils.getTimeByStrWithNSString(selectPatient.getCreateTime(), withNSString: "yyyy/MM/dd")
        let zhuyuanNum = "123445345"
        
        renameArray.append("\(patientName)-\(time)")
        renameArray.append("\(time)-\(patientName)")
        renameArray.append("\(patientName)-\(zhuyuanNum)")
        renameArray.append("\(patientName)-\(zhuyuanNum)-\(time)")
        
        return renameArray
    }
}
