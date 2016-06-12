//
//  RecordListViewController.swift
//  DoctorPlus_ios
//
//  Created by monkey on 15-5-12.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

protocol RecordListDelegate:NSObjectProtocol{
    
    func getRecordListCount(isModify:Bool,listCount:Int,patientId:Int32)
}

class RecordListViewController: BaseViewController ,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,ComFqHalcyonLogic2GetRecordListLogic_GetRecordListCallBack,ComFqHalcyonLogic2SurveyRecordLogic_SurveyRecordCallBack,ComFqHalcyonLogic2CreateRecordLogic_CreateRecordFolderCallBack,ComFqHalcyonLogic2DelRecordLogic_DelRecordFolderCallBack,FQControllerViewDelegate,UIGestureRecognizerDelegate,ComFqHalcyonLogic2ModifyRecordNameLogic_ModifyRecordNameCallBack{
    
    var recordList:JavaUtilArrayList! = JavaUtilArrayList()
    var mSurItemList:JavaUtilArrayList! = JavaUtilArrayList()
    var patient:ComFqHalcyonEntityPatient?
    var newRecord:ComFqHalcyonEntityRecord!
    var page:Int32 = 1
    var pagesize:Int32 = 20
    var mOldRecordCount:Int32!
    var mCtrlPosition = -1//当前长按位置
    var longPress:UILongPressGestureRecognizer?
    var isModifty = false
    
    
    var isNewPatient:Int?
    let ISNOT_NEW_PATIENT:Int = 1
    let IS_NEW_PATIENT:Int = 2
    
    var viewHeight = CGFloat(80)
    var viewWidth = ScreenWidth
    var controllerView:FQControllerView?
    var renameEdt:UITextField?
    var renameDialog:CustomIOS7AlertView?
    var delDialog:CustomIOS7AlertView?
    var surveyRecordDialog:CustomIOS7AlertView?
    var loadingDialog:CustomIOS7AlertView?
    var createRecordDialog:CustomIOS7AlertView?
    @IBOutlet weak var dialogTableView: UITableView!
    @IBOutlet var surveyAlertView: UIView!
    @IBOutlet weak var _tableView: UITableView!
    @IBOutlet var alertView: UIView!
    @IBOutlet weak var edtRecord: UITextField!
    @IBOutlet weak var menzhengBtn: UIButton!
    @IBOutlet weak var zhuyuanBtn: UIButton!
    @IBOutlet weak var createRecordBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var surveyLabel: UILabel!
    
    @IBOutlet weak var recordTableView: UITableView!
    
    weak var recordListDelegate:RecordListDelegate?
    var newRecordListCount = Int32(0)
    var oldRecordListCount = Int32(0)
    override func viewDidLoad() {
        super.viewDidLoad()
        if patient == nil {
            patient = ComFqHalcyonEntityPatient()
        }
        setTittle(patient!.getMedicalName())
        
        if isNewPatient == ISNOT_NEW_PATIENT{
            //如果是新创建的病案，则不调用接口获取数据
            getRecordList()
        }else{
            page = 2
        }
        edtRecord.delegate = self
        setTableViewRefresh()
        
        controllerView = FQControllerView.getInstance()
        controllerView?.delegate = self
        controllerView!.frame = CGRectMake(0, ScreenHeight + 80, ScreenWidth, 80)
        self.view.addSubview(controllerView!)
        initLongClick()
        newRecordListCount = patient!.getRecordCount()
        oldRecordListCount = patient!.getRecordCount()
    }
    
    override func onLeftBtnOnClick(sender: UIButton) {
        if oldRecordListCount == newRecordListCount {
            recordListDelegate?.getRecordListCount(false, listCount: Int(newRecordListCount), patientId: patient!.getMedicalId())
        }else{
            recordListDelegate?.getRecordListCount(true, listCount: Int(newRecordListCount), patientId: patient!.getMedicalId())
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    /**设置tabview 上拉下拉**/
    func setTableViewRefresh(){
        
        _tableView.headerBeginRefreshing()
        //_tableView.addHeaderWithTarget(self, action: "headerRereshing")
        _tableView.addFooterWithTarget(self, action: "footerRereshing")
    }
    
    /**下拉事件处理**/
    //func headerRereshing(){
    // 刷新表格
    //_tableView.reloadData()
    // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
    //_tableView.headerEndRefreshing()
    //    }
    
    /**上拉事件处理**/
    func footerRereshing(){
        if isModifty {
            _tableView.footerEndRefreshing()
            setControllerShow(false)
            
            return
        }
        if mCtrlPosition != -1 {
            _tableView.footerEndRefreshing()
            setControllerShow(false)
            return
        }
        // 刷新表格
        getRecordList()
        // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
        _tableView.footerEndRefreshing()
    }
    
    func getRecordList(){
        loadingDialog = UIAlertViewTool.getInstance().showLoadingDialog("获取病历列表...")
        let logic:ComFqHalcyonLogic2GetRecordListLogic! = ComFqHalcyonLogic2GetRecordListLogic(comFqHalcyonLogic2GetRecordListLogic_GetRecordListCallBack: self)
        logic.getRecordListWithInt(patient!.getMedicalId(), withInt: page, withInt: pagesize)
        
        
    }
    func onGetRecordListErrorWithInt(code: Int32, withNSString msg: String!) {
        loadingDialog?.close()
        UIAlertViewTool.getInstance().showAutoDismisDialog("获取病历列表失败", width: 210, height: 120)
        
    }
    func onGetRecordListWithJavaUtilArrayList(mRecordList: JavaUtilArrayList!) {
        if mRecordList.size() > 0 {
            page++
        }else{
            UIAlertViewTool.getInstance().showAutoDismisDialog("没有更多病历", width: 210, height: 120)
        }
        recordList.addAllWithJavaUtilCollection(mRecordList)
        mOldRecordCount = recordList.size()
        _tableView.reloadData()
        loadingDialog?.close()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func getXibName() -> String {
        return "RecordListViewController"
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
            if record.getUnRecongCount() > 0 {
                
                if mCtrlPosition == indexPath.row {
//                    cell?.imgBg.image = UIImage(named: "record_have_unrec_select.png")
                    cell?.imgBg.image = Tools.createNinePathImageForImage(UIImage(named: "record_have_unrec_select.png"), leftMargin: 40, rightMargin: 40, topMargin: 50, bottomMargin: 10)
                    
                }else{
//                    cell?.imgBg.image = UIImage(named: "record_have_unrec_unselect.png")
                    cell?.imgBg.image  = Tools.createNinePathImageForImage(UIImage(named: "record_have_unrec_unselect.png"), leftMargin: 40, rightMargin: 40, topMargin: 50, bottomMargin: 10)
                }
                UITools.setRoundBounds(5, view: cell!.unRecongLabel)
                cell?.unRecongLabel.hidden = false
                if record.getUnRecongCount() > 99 {
                    cell?.unRecongLabel.text = "99"
                }else{
                    cell?.unRecongLabel.text = "\(record.getUnRecongCount())"
                }
            }else{
                if mCtrlPosition == indexPath.row {
//                    cell?.imgBg.image = UIImage(named: "record_normal_select.png")
                    cell?.imgBg.image = Tools.createNinePathImageForImage(UIImage(named: "record_normal_select.png"), leftMargin: 40, rightMargin: 40, topMargin: 50, bottomMargin: 10)
                    
                    
                }else{
//                    cell?.imgBg.image = UIImage(named: "record_no_unrec.png")
                    cell?.imgBg.image  = Tools.createNinePathImageForImage(UIImage(named: "record_no_unrec.png"), leftMargin: 40, rightMargin: 40, topMargin: 50, bottomMargin: 10)
                }
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
                cell?.shareFrom.lineBreakMode = NSLineBreakMode.ByTruncatingMiddle
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
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.tag == 1 {
            if isModifty {
                setControllerShow(false)
                return
            }
            if mCtrlPosition != -1 {
                setControllerShow(false)
                return
            }
            
            //跳转
            let controller = BrowRecordViewController()
            let record = recordList.getWithInt(Int32(indexPath.row)) as? ComFqHalcyonEntityRecord
            controller.mRecord = record
            controller.patient = patient
            self.navigationController?.pushViewController(controller, animated: true)
        }
        
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var canInput:Bool = true
     
            if range.location > 25 {
                canInput = false
            }
        
        return canInput
    }

    
    func survey(sender:UIButton){
        print(sender.tag)
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
        //        surveyRecordDialog!.show()
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
    
    override func onRightBtnOnClick(sender: UIButton) {
        if isModifty {
            setControllerShow(false)
        }
        newRecord = ComFqHalcyonEntityRecord()
        createRecordDialog = CustomIOS7AlertView()
        setDialogStyle(createRecordBtn,cancelBtn: cancelBtn)
        createRecordDialog!.containerView = alertView
        createRecordDialog!.show()
        
    }
    
    /**
    取消创建的按钮点击事件
    */
    @IBAction func onCancelClick() {
        createRecordDialog?.close()
    }
    
    /**
    创建病案的点击事件
    */
    @IBAction func onCreateClick() {
        createRecordDialog?.close()
        if edtRecord.text != "" {
            newRecord.setFolderNameWithNSString(edtRecord.text)
            createRecord(newRecord)
        }
    }
    
    /**
    设置创建病历的Dialog的样式
    */
    func setDialogStyle(sureBtn:UIButton, cancelBtn:UIButton){
        UITools.setButtonStyle(sureBtn, buttonColor: Color.color_emerald, textSize: 24, textColor: Color.color_emerald)
        UITools.setButtonStyle(cancelBtn, buttonColor: Color.color_grey, textSize: 24, textColor: Color.color_grey,isOpposite:true)
        UITools.setBtnWithOneRound(sureBtn, corners: UIRectCorner.BottomLeft)
        UITools.setBtnWithOneRound(cancelBtn, corners: UIRectCorner.BottomRight)
        UITools.setRoundBounds(9,view: alertView)
        UITools.setRoundBounds(9,view: edtRecord)
        UITools.setBorderWithView(1, tmpColor: Color.color_emerald.CGColor, view: cancelBtn)
        UITools.setSelectBtnStyle(menzhengBtn, selectedColor: Color.color_emerald, unSelectedColor: Color.color_grey)
        UITools.setSelectBtnStyle(zhuyuanBtn, selectedColor: Color.color_emerald, unSelectedColor: Color.color_grey)
        UITools.setViewBorder(1, borderColor: Color.color_grey, backgroundColor: Color.color_ligth_green, view: edtRecord)
        edtRecord.leftView = UIView(frame: CGRectMake(0, 0, 8, 0))
        edtRecord.leftViewMode = UITextFieldViewMode.Always
        edtRecord.text = ""
        zhuyuanBtn.selected = true
        newRecord.setFolderTypeWithInt(ComFqLibRecordRecordConstants_RECORD_TYPE_ADMISSION)
        menzhengBtn.selected = false
        zhuyuanBtn.addTarget(self, action: "zhuyuan", forControlEvents: UIControlEvents.TouchUpInside)
        menzhengBtn.addTarget(self, action: "mengzheng", forControlEvents: UIControlEvents.TouchUpInside)
    }
    func  zhuyuan(){
        newRecord.setFolderTypeWithInt(ComFqLibRecordRecordConstants_RECORD_TYPE_ADMISSION)
        zhuyuanBtn.selected = true
        menzhengBtn.selected = false
    }
    func mengzheng(){
        zhuyuanBtn.selected = false
        menzhengBtn.selected = true
        newRecord.setFolderTypeWithInt(ComFqLibRecordRecordConstants_RECORD_TYPE_DOORCASE)
    }
    
    /**创建病历*/
    func createRecord(record:ComFqHalcyonEntityRecord){
        loadingDialog = UIAlertViewTool.getInstance().showLoadingDialog("创建病历...")
        let logic:ComFqHalcyonLogic2CreateRecordLogic! = ComFqHalcyonLogic2CreateRecordLogic(comFqHalcyonLogic2CreateRecordLogic_CreateRecordFolderCallBack:self)
        logic.createRecordFolderWithNSString(record.getFolderName(), withInt: patient!.getMedicalId(), withInt: record.getFolderType())
    }
    
    func onCreateFolderErrorWithInt(code: Int32, withNSString msg: String!) {
        loadingDialog?.close()
        UIAlertViewTool.getInstance().showAutoDismisDialog("创建病历失败", width: 210, height: 120)
    }
    
    func onCreateFolderSuccessWithInt(code: Int32, withComFqHalcyonEntityRecord record: ComFqHalcyonEntityRecord!) {
        recordList.addWithInt(0, withId: record)
        _tableView.reloadData()
        loadingDialog?.close()
        newRecordListCount += 1
    }
    
    /**删除病历*/
    func delRecord(){
        delDialog = UIAlertViewTool.getInstance().showNewDelDialog("确认删除？", target: self, actionOk: "sureDel", actionCancle: "cancelDel")
    }
    func sureDel(){
        delDialog?.close()
        loadingDialog = UIAlertViewTool.getInstance().showLoadingDialog("删除病历...")
        let logic = ComFqHalcyonLogic2DelRecordLogic(comFqHalcyonLogic2DelRecordLogic_DelRecordFolderCallBack:self)
        logic.delRecordFolderWithInt((recordList.getWithInt(Int32(mCtrlPosition)) as! ComFqHalcyonEntityRecord).getFolderId())
    }
    func cancelDel(){
        delDialog?.close()
    }
    func onDelFolderErrorWithInt(code: Int32, withNSString msg: String!) {
        loadingDialog?.close()
        setControllerShow(false)
        UIAlertViewTool.getInstance().showAutoDismisDialog("删除病历失败", width: 210, height: 120)
        
    }
    func onDelFolderSuccessWithInt(code: Int32, withNSString msg: String!) {
        recordList.removeWithInt(Int32(mCtrlPosition))
        setControllerShow(false)
        loadingDialog?.close()
        newRecordListCount -= 1
    }
    
    /**重命名*/
    func renameRecordName(){
//        let result = UIAlertViewTool.getInstance().showNewTextFieldDialog("重命名", hint: "", target: self, actionOk: "sureRename", actionCancle: "cancelRename")
//        renameDialog = result.alertView
//        renameEdt = result.textField
//        renameEdt?.text = (recordList.getWithInt(Int32(mCtrlPosition)) as! ComFqHalcyonEntityRecord).getFolderName()
//        renameEdt?.delegate = self
    }
    
    func sureRename(){
        
        if renameEdt?.text != "" {
            let logic:ComFqHalcyonLogic2ModifyRecordNameLogic! = ComFqHalcyonLogic2ModifyRecordNameLogic(comFqHalcyonLogic2ModifyRecordNameLogic_ModifyRecordNameCallBack: self)
            logic.modifyNameWithInt((recordList.getWithInt(Int32(mCtrlPosition)) as! ComFqHalcyonEntityRecord).getFolderId(), withNSString: renameEdt?.text)
        }
    }
    func cancelRename(){
        renameDialog?.close()
    }
    func modifyNameErrorWithInt(code: Int32, withNSString msg: String!) {
        UIAlertViewTool.getInstance().showAutoDismisDialog("重命名失败", width: 210, height: 120)
        setControllerShow(false)
        renameDialog?.close()
        
    }
    func modifyNameSuccessWithInt(code: Int32, withNSString msg: String!) {
        (recordList.getWithInt(Int32(mCtrlPosition)) as! ComFqHalcyonEntityRecord).setFolderNameWithNSString(renameEdt?.text)
        setControllerShow(false)
        renameDialog?.close()
    }
    
    
    /**
    是否在修改状态 view出现和隐藏的动画 true出现 false隐藏
    */
    func setControllerShow(b:Bool){
        isModifty = b
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.25)
        UIView.setAnimationDelegate(self)
        UIView.setAnimationCurve(UIViewAnimationCurve.EaseInOut)
        
        if !isModifty {
            mCtrlPosition = -1
            controllerView!.frame = CGRectMake(0, ScreenHeight + 80, viewWidth, viewHeight)
            _tableView.reloadData()
        }else{
            controllerView!.frame = CGRectMake(0, ScreenHeight - 80, viewWidth, viewHeight)
        }
        UIView.commitAnimations()
    }
    
    
    /**
    分享病历的操作
    */
    func onShareBtnClickListener() {
        let controller = ChoseSharePeopleViewController()
        controller.mShareType = SHARE_RECORD
        controller.mShareRecord = recordList.getWithInt(Int32(mCtrlPosition)) as? ComFqHalcyonEntityRecord
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    /**
    重命名病案的操作
    */
    func onRenameBtnClickListener() {
        renameRecordName()
    }
    
    /**
    删除病案的操作
    */
    func onDelBtnClickListener() {
        delRecord()
    }

    /**
    初始化长按点击事件
    */
    func initLongClick(){
        
        longPress = UILongPressGestureRecognizer(target: self, action: Selector("patientTAbleCellLongPressed:"))
        longPress?.minimumPressDuration = 1.0
        longPress?.delegate = self
        _tableView.addGestureRecognizer(longPress!)
    }

    /**
    tableCell的长按点击事件
    */
    func patientTAbleCellLongPressed(gestureRecognizer:UILongPressGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            let point = gestureRecognizer.locationInView(self._tableView)
            let indexPath = self._tableView.indexPathForRowAtPoint(point)
            if indexPath == nil {
                return
            }
            if isModifty {
                setControllerShow(false)
                return
            }
            setControllerShow(true)
            mCtrlPosition = indexPath!.row
            _tableView.reloadData()
        }
    }

    
}
