//
//  ExplorationRecordListViewController.swift
//  DoctorPlus_ios
//
//  Created by monkey on 15-7-19.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class ExplorationRecordListViewController: BaseViewController ,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,ComFqHalcyonLogicPracticePatientNameLogic_PatientNameCalBack,ComFqHalcyonLogicPracticeShareLogic_ShareSavePatientCallBack{
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var patientNameEdit: UITextField! //病案名称的Edit
    @IBOutlet var leftMenu: UIView!
    @IBOutlet var popMenuView: UIView!
    @IBOutlet var ctrlView: UIView!
    @IBOutlet var patientNameView: UIView!
    @IBOutlet weak var patientNameTable: UITableView!
    @IBOutlet weak var sureShareBtn: UIButton!
    
    @IBOutlet weak var allRecordBtn: UIButton!
    @IBOutlet weak var ruyuanBtn: UIButton!
    @IBOutlet weak var shoushuBtn: UIButton!
    @IBOutlet weak var jianchaBtn: UIButton!
    @IBOutlet weak var huayanBtn: UIButton!
    @IBOutlet weak var chuyuanBtn: UIButton!
    @IBOutlet weak var qitaBtn: UIButton!
    var menuBtnArray = [UIButton]()
    
    @IBOutlet var sharePopView: UIView!
    @IBOutlet var myDataPopView: UIView!
    
    var verLine:UILabel!
    var touchView:UIView!
    var isLeftMenuShow = false
    var leftMenuCGPointY:CGFloat!
    var contentViewCGPointY:CGFloat!
    var leftMenuWidth:CGFloat!
    var leftMenuHeight:CGFloat!
    
    var titleLabels = ["全部","入院","手术","检查","化验","出院","其他"]
    var recordType = [0,ComFqLibRecordRecordConstants_TYPE_ADMISSION,ComFqLibRecordRecordConstants_TYPE_SUGERY,ComFqLibRecordRecordConstants_TYPE_MEDICAL_IMAGING,ComFqLibRecordRecordConstants_TYPE_EXAMINATION,ComFqLibRecordRecordConstants_TYPE_DISCHARGE ,ComFqLibRecordRecordConstants_TYPE_OTHERS]
    var contentViewArray = Array<ExplorationRecView>()
    var contentViewFrame:CGRect?
    var showCtrlContentFrame:CGRect!
    var popMenuViewFrame:CGRect?
    var sharePopViewFrame:CGRect?
    var myDataPopViewFrame:CGRect?
    var ctrlviewHiddenFrame:CGRect!
    var ctrlviewShowFrame:CGRect!
    var leftmenuShowFrame:CGRect!
    var leftmenuHiddenFrame:CGRect!
    var selectedLabelPosition = 0
    
    var isPopmenuShow = false
    var isEdit = false
    var isCtrlViewShow = false
    
    var patientNameShowFrame:CGRect!
    var patientNameHiddenFrame:CGRect!
    
    var patientItem:ComFqHalcyonEntityPracticePatientAbstract!
    var shareMassageId:Int32?
    
    var patientNameList = [String]()
    
    var isExperience = false //判断是否是体验账号
    var isShared = false //判断是否是通过别人分享的病案点击进入的
    var isFromChart = false //判断是否是从聊天界面过来的
    var loadingDialog:CustomIOS7AlertView!
    
    var indetifyDialog:IndetifyDialog! //是否去身份化的dialog
    var didSendInfo = true //是否发送身份信息
    
    var isMyPatientRecord = false //用于判断是否是查看我得患者的病例记录
    
    var isOfflinePatient = false //判断是否是离线
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isExperience = MessageTools.isExperienceMode()
        
        if isExperience || isShared {
            patientNameEdit.enabled = false
        }
        
        leftMenuCGPointY = 70
        contentViewCGPointY = patientNameEdit.frame.origin.y + 71 + patientNameEdit.frame.size.height
        leftMenuWidth = 80
        leftMenuHeight = ScreenHeight - leftMenuCGPointY
        
        isFromSearch = false
        
        if isFromChart {
            contentViewFrame = CGRectMake(0, contentViewCGPointY, ScreenWidth, ScreenHeight - contentViewCGPointY - 44)
            leftmenuShowFrame = CGRectMake(0, leftMenuCGPointY, leftMenuWidth, leftMenuHeight - 44)
            leftmenuHiddenFrame = CGRectMake(-leftMenuWidth, leftMenuCGPointY, leftMenuWidth, leftMenuHeight - 44)
            verLine = UILabel(frame: CGRectMake(60 , contentViewCGPointY , 1 , ScreenHeight - contentViewCGPointY - 44))
        }else{
            contentViewFrame = CGRectMake(0, contentViewCGPointY, ScreenWidth, ScreenHeight - contentViewCGPointY)
            leftmenuShowFrame = CGRectMake(0, leftMenuCGPointY, leftMenuWidth, leftMenuHeight)
            leftmenuHiddenFrame = CGRectMake(-leftMenuWidth, leftMenuCGPointY, leftMenuWidth, leftMenuHeight)
            verLine = UILabel(frame: CGRectMake(60 , contentViewCGPointY , 1 , ScreenHeight - contentViewCGPointY))
        }
        
        initView()
        showContentView(0)
        
        setTouchView()
        
        verLine.backgroundColor = Color.color_verline
        self.view.addSubview(verLine)
        
        leftMenu.frame = leftmenuHiddenFrame
        leftMenu.hidden = true
        let recongnizerRight = UISwipeGestureRecognizer(target: self, action: "handleSwipeFrom:")
        self.view.addGestureRecognizer(recongnizerRight)
        self.view.addSubview(leftMenu)
        
        
        if isMyPatientRecord {
            hiddenRightImage(true)
        }else{
            setRightImage(isHiddenBtn: false, image: UIImage(named: "right_dot.png")!)
        }

        setViewFrame()
        initPatientNameTable()
        
        patientNameEdit.delegate = self
        setMenuBtn()
        
        patientNameEdit.text = patientItem.getPatientName()
        getSuggestName()
        
        setPopView()
        setShowFromChart(isFromChart)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "getPatientName:", name: "GetPatientName", object: nil)
    }
    
    func getPatientName(notification:NSNotification){
        if patientItem.getPatientName() == nil || patientItem.getPatientName() == "" {
            let name = notification.object as! String
            patientNameEdit.text = name
        }
    }
    
    func setTouchView(){
        touchView = UIView(frame: CGRectMake(0, 70, ScreenWidth, ScreenHeight))
        let tapGesture = UITapGestureRecognizer(target: self, action: "viewTapListener:")
        let recongnizerLeft = UISwipeGestureRecognizer(target: self, action: "handleSwipeClose:")
        recongnizerLeft.direction = UISwipeGestureRecognizerDirection.Left
        touchView.addGestureRecognizer(tapGesture)
        touchView.addGestureRecognizer(recongnizerLeft)
        self.view.addSubview(touchView)
        touchView.userInteractionEnabled = false
    }
    
    func setShowFromChart(isFromChart:Bool){
        self.isFromChart = isFromChart
        if isFromChart {
            hiddenRightImage(true)
            sureShareBtn.hidden = false
            for item in contentViewArray {
                item.isEditStatus = true
                item.isFromChart = true
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        isPopmenuShow = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func getXibName() -> String {
        return "ExplorationRecordListViewController"
    }
    
    func setPopView(){
        popMenuViewFrame = CGRectMake(ScreenWidth - 130, 76, 120, 70)
        popMenuView.frame = popMenuViewFrame!
        popMenuView.alpha = 0.0
        popMenuView.hidden = true
        self.view.addSubview(popMenuView)
        
        sharePopViewFrame = CGRectMake(ScreenWidth - 130, 76, 120, 96)
        sharePopView.frame = sharePopViewFrame!
        sharePopView.alpha = 0.0
        sharePopView.hidden = true
        self.view.addSubview(sharePopView)
        
        myDataPopViewFrame = CGRectMake(ScreenWidth - 130, 76, 120, 126)
        myDataPopView.frame = myDataPopViewFrame!
        myDataPopView.alpha = 0.0
        myDataPopView.hidden = true
        self.view.addSubview(myDataPopView)
    }
    
    
    func setMenuBtn(){
        menuBtnArray.append(allRecordBtn)
        menuBtnArray.append(ruyuanBtn)
        menuBtnArray.append(shoushuBtn)
        menuBtnArray.append(jianchaBtn)
        menuBtnArray.append(huayanBtn)
        menuBtnArray.append(chuyuanBtn)
        menuBtnArray.append(qitaBtn)
        menuBtnArray[0].backgroundColor = Color.color_violet
    }
    
    func initPatientNameTable(){
        patientNameShowFrame = CGRectMake(0, contentViewCGPointY, ScreenWidth, 0)
        patientNameHiddenFrame = CGRectMake(0, contentViewCGPointY - 200, ScreenWidth, 0)
        patientNameView.frame = patientNameShowFrame
        patientNameView.hidden = true
        patientNameView.alpha = 0.0
        patientNameTable.registerNib(UINib(nibName: "PatientNameTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PatientNameTableViewCell")
        self.view.addSubview(patientNameView)
    }
    
    func setViewFrame(){
        ctrlviewShowFrame = CGRectMake(0, ScreenHeight - 70, ScreenWidth, 70)
        ctrlviewHiddenFrame = CGRectMake(0, ScreenHeight, ScreenWidth, 70)
        showCtrlContentFrame = CGRectMake(0, contentViewCGPointY, ScreenWidth, ScreenHeight - contentViewCGPointY - 70)
        ctrlView.frame = ctrlviewHiddenFrame
        self.view.addSubview(ctrlView)
    }
    
    /**初始化所有的内容view*/
    func initView(){
        for i in 0...titleLabels.count {
            let recView = ExplorationRecView(frame: contentViewFrame!)
            recView.isPatientRecordList = true
            recView.patientItem = self.patientItem
            recView.isShare = self.isShared
            recView.isMyPatientRecord = self.isMyPatientRecord
            recView.isOfflinePatient = isOfflinePatient
            self.view.addSubview(recView)
            contentViewArray.append(recView)
        }
        contentViewArray[0].getRecordList(recordType[0])
    }
    
    func showContentView(position:Int){
        for (index,item) in contentViewArray.enumerate(){
            if position == index {
                item.hidden = false
            }else{
                item.hidden = true
            }
        }
    }
    
    func handleSwipeFrom(recongizer:UISwipeGestureRecognizer){
        patientNameEdit.endEditing(true)
        if recongizer.direction == UISwipeGestureRecognizerDirection.Right {
            if !isCtrlViewShow {
                showLeftMenu()
            }
        }
    }
    
    func handleSwipeClose(recongizer:UISwipeGestureRecognizer){
        patientNameEdit.endEditing(true)
        if recongizer.direction == UISwipeGestureRecognizerDirection.Left {
            if !isCtrlViewShow {
                showLeftMenu()
            }
        }
    }
    
    func viewTapListener(gesture:UITapGestureRecognizer){
        if isLeftMenuShow {
            showLeftMenu()
        }
        if isPopmenuShow {
            showOrHiddenPopmenu()
        }
    }
    
    /**
    显示或者隐藏左侧菜单的动画
    */
    func showLeftMenu(){
        
        if leftMenu.hidden {
            leftMenu.hidden = false
        }
        
        if isLeftMenuShow {
            UIView.animateWithDuration(0.8, animations: { () -> Void in
                self.leftMenu.frame = self.leftmenuHiddenFrame
                }, completion: { (isFinish) -> Void in
                    self.isLeftMenuShow = false
                    self.leftMenu.hidden = true
                    self.touchView.userInteractionEnabled = false
            })
            
        }else{
            
            UIView.animateWithDuration(0.8, animations: { () -> Void in
                self.leftMenu.frame = self.leftmenuShowFrame
                }, completion: { (isFinish) -> Void in
                    self.touchView.userInteractionEnabled = true
                    self.isLeftMenuShow = true
            })
        }
    }
    
    func setCellScroll(isShare:Bool){
        contentViewArray[selectedLabelPosition].setShareStatus(isShare)
    }
    
    /**
    显示或者隐藏底部菜单的动画
    */
    func showOrHiddenCtrlView(){
        
        if leftMenu.hidden {
            leftMenu.hidden = false
        }
        
        if isCtrlViewShow {
            self.contentViewArray[self.selectedLabelPosition].frame = self.contentViewFrame!
            UIView.animateWithDuration(0.8, animations: { () -> Void in
                self.ctrlView.frame = self.ctrlviewHiddenFrame
                }, completion: { (isFinish) -> Void in
                    self.isCtrlViewShow = false
                    self.setCellScroll(false)
            })
            
        }else{
            UIView.animateWithDuration(0.8, animations: { () -> Void in
                self.ctrlView.frame = self.ctrlviewShowFrame
                }, completion: { (isFinish) -> Void in
                    self.isCtrlViewShow = true
                    self.setCellScroll(true)
                    self.contentViewArray[self.selectedLabelPosition].frame = self.showCtrlContentFrame
            })
        }
    }
    
    override func onLeftBtnOnClick(sender: UIButton) {
        leftMenu.hidden = true
        myDataPopView.hidden = true
        saveChangeName()
        isFromSearch = true
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func onRightBtnOnClick(sender: UIButton) {
        if isEdit {
            isEdit = false
            self.setRightImage(isHiddenBtn: false, image: UIImage(named: "right_dot.png")!)
            if isPopmenuShow {
                showOrHiddenPopmenu()
            }
            contentViewArray[selectedLabelPosition].cleanAllSelectedStatus()
            contentViewArray[selectedLabelPosition].isEditStatus = false
            contentViewArray[selectedLabelPosition].timeTableView.reloadData()
            showOrHiddenCtrlView()
        }else{
            showOrHiddenPopmenu()
        }
    }
    
    /**
    左侧菜单按钮点击事件
    */
    @IBAction func menuBtnClickListener(sender: AnyObject) {
        
        if sender.tag == selectedLabelPosition {
            return
        }else{
            selectedLabelPosition = sender.tag
        }
        
        for (index,item) in menuBtnArray.enumerate() {
            if index == sender.tag {
                item.backgroundColor = Color.color_violet
            }else{
                item.backgroundColor = UIColor.clearColor()
            }
        }
        
        titleLabel.text = titleLabels[sender.tag]
        showContentView(sender.tag)
        
        if contentViewArray[sender.tag].tableDatas.count == 0 {
            contentViewArray[sender.tag].getRecordList(recordType[sender.tag])
        }
    }
    
    /**
    显示或者隐藏弹出菜单的动画
    */
    func showOrHiddenPopmenu(){
        
        if isPopmenuShow {
            touchView.userInteractionEnabled = false
            UIView.animateWithDuration(0.6, animations: { () -> Void in
                
                self.sharePopView.alpha = 0.0
                self.myDataPopView.alpha = 0.0
                
                }) { (finished) -> Void in
                    if finished {
                        self.sharePopView.hidden = true
                        self.myDataPopView.hidden = true
                        self.isPopmenuShow = false
                    }
            }
        }else{
            touchView.userInteractionEnabled = true
            if self.isShared {
                self.myDataPopView.hidden = true
                self.sharePopView.hidden = false
            }else{
                self.myDataPopView.hidden = false
                self.sharePopView.hidden = true
            }
            UIView.animateWithDuration(0.6, animations: { () -> Void in
                
                self.myDataPopView.alpha = 1.0
                self.sharePopView.alpha = 1.0
                
                }) { (finished) -> Void in
                    if finished {
                        self.isPopmenuShow = true
                    }
            }
        }
    }
    
    /**编辑钮点击事件或者保存点击事件*/
    @IBAction func editMenuBtnClick() {
        if isShared {
            loadingDialog =  UIAlertViewTool.getInstance().showLoadingDialog("保存中，请耐心等待...")
            let saveShare = ComFqHalcyonLogicPracticeShareLogic(comFqHalcyonLogicPracticeShareLogic_ShareSavePatientCallBack: self)
            saveShare.saveSharedPatientWithInt(shareMassageId!, withInt: patientItem.getPatientId())
            
        }else{
            showOrHiddenPopmenu()
            setRightBtnTittle("完成")
            isEdit = true
            showOrHiddenCtrlView()
            contentViewArray[selectedLabelPosition].isEditStatus = true
            contentViewArray[selectedLabelPosition].timeTableView.reloadData()
        }
    }
    
    /**保存病案的弹出菜单按钮点击事件*/
    @IBAction func savePatientBtnClick(sender: AnyObject) {
        showOrHiddenPopmenu()
        loadingDialog =  UIAlertViewTool.getInstance().showLoadingDialog("保存中，请耐心等待...")
        let saveShare = ComFqHalcyonLogicPracticeShareLogic(comFqHalcyonLogicPracticeShareLogic_ShareSavePatientCallBack: self)
        saveShare.saveSharedPatientWithInt(shareMassageId!, withInt: patientItem.getPatientId())
    }
    
    /**编辑病案的弹出菜单按钮点击事件*/
    @IBAction func editPatientBtnClick(sender: AnyObject) {
        showOrHiddenPopmenu()
        
        if isExperience {
            MessageTools.experienceDialog(self.navigationController!)
            return
        }
        
        setRightBtnTittle("完成")
        isEdit = true
        showOrHiddenCtrlView()
        contentViewArray[selectedLabelPosition].isEditStatus = true
        contentViewArray[selectedLabelPosition].timeTableView.reloadData()
    }
    
    /**分享病案的弹出菜单按钮点击事件*/
    @IBAction func sharePatientBtnClick(sender: AnyObject) {
        
        showOrHiddenPopmenu()
        
        if isExperience {
            MessageTools.experienceDialog(self.navigationController!)
            return
        }
        
        indetifyDialog = UIAlertViewTool.getInstance().showRemoveIndetifyDialog(didSendInfo, target: self, actionOk: "dialogOk", actionCancle: "dialogCancle", actionRemoveIndentify: "xieyi", selecBtn: "click")
        
    }
    
    //确认分享
    func dialogOk(){
        let controller = MoreChatListViewController()
        
        let patientList = JavaUtilArrayList()
        patientList.addWithId(patientItem!)
        controller.patientList = patientList
        controller.type = 2
        controller.didSendInfo = didSendInfo;
        self.navigationController?.pushViewController(controller, animated: true)
        indetifyDialog.alertView?.close()
        didSendInfo = true
    }
    //取消分享
    func dialogCancle(){
        indetifyDialog.alertView?.close()
    }
    //查看协议
    func xieyi(){
        indetifyDialog.alertView?.close()
        self.navigationController?.pushViewController(ProtocolViewController() , animated: true)
    }
    //是否包含身份信息
    func click(){
        didSendInfo = !didSendInfo;
        if didSendInfo{
            indetifyDialog.selectBtn?.setBackgroundImage(UIImage(named: "icon_circle_yes.png"), forState: UIControlState.Normal)
        }else{
            indetifyDialog.selectBtn?.setBackgroundImage(UIImage(named: "icon_circle_no.png"), forState: UIControlState.Normal)
        }
        
    }
    
    /**结构化病案的弹出菜单按钮点击事件*/
    @IBAction func insightBtnClick(sender: AnyObject) {
        showOrHiddenPopmenu()
        let controller = StructuredViewController()
        controller.patientId = Int(patientItem!.getPatientId())
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
     var dialog:CustomIOS7AlertView?
    /**保存分享病案失败回调*/
    func shareErrorWithInt(code: Int32, withNSString msg: String!) {
        loadingDialog.close()
//        self.view.makeToast("保存失败")
        FQToast.makeError().show("保存失败", superview: self.view)
    }
   
    /**保存分享病案成功回调*/
    func shareSavePatientSuccessWithInt(newPatientId: Int32) {
        loadingDialog.close()
//        self.view.makeToast("保存成功")
        FQToast.makeSystem().show("保存成功", superview: self.view)
    }
    
    
    
    /**确认保存成功*/
    func sure(){
        dialog?.close()
        self.navigationController?.popViewControllerAnimated(true)
    }
    func cancel(){
        dialog?.close()
    }
    
    /**弹出菜单过滤按钮点击事件*/
    @IBAction func filterMenuBtnClick() {
        let controller = FilterViewController()
        controller.patientId = patientItem.getPatientId()
        controller.isFromRecordList = true
        self.navigationController?.pushViewController(controller, animated: true)
        showOrHiddenPopmenu()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return patientNameList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PatientNameTableViewCell") as! PatientNameTableViewCell
        cell.patientNameLabel.text = patientNameList[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 30
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var cell = tableView.dequeueReusableCellWithIdentifier("PatientNameTableViewCell") as! PatientNameTableViewCell
        patientNameEdit.text = patientNameList[indexPath.row]
        patientNameEdit.endEditing(true)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        patientNameView.hidden = false
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            self.patientNameView.alpha = 1.0
            }) { (isFinish) -> Void in
                
        }
        
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            self.patientNameView.alpha = 0.0
            }) { (isFinish) -> Void in
                self.patientNameView.hidden = true
        }
        
    }
    
    /**底部删除按钮点击事件*/
    @IBAction func delSelectedItemClick(sender: AnyObject) {
        contentViewArray[selectedLabelPosition].delDatas()
    }
    
    /**底部分享按钮点击事件*/
    @IBAction func shareSelectedItemClick(sender: AnyObject) {
        contentViewArray[selectedLabelPosition].shareDatas()
    }
    
    /**获取推荐名字列表的逻辑*/
    func getSuggestName(){
        let logic = ComFqHalcyonLogicPracticePatientNameLogic(comFqHalcyonLogicPracticePatientNameLogic_PatientNameCalBack: self)
        logic.loadPatientRecommendNamesWithInt(patientItem.getPatientId())
    }
    
    /**保存修改后的病案名称*/
    func saveChangeName(){
        
        if patientItem.getPatientName() != patientNameEdit.text {
            let logic = ComFqHalcyonLogicPracticePatientNameLogic(comFqHalcyonLogicPracticePatientNameLogic_PatientNameCalBack: self)
            logic.renamePatientNameWithInt(patientItem.getPatientId(), withNSString: patientNameEdit.text)
        }
        
    }
    
    /**
    * 获得系统推荐的病案名字列表的回调
    */
    func recommendNameCallbackWithJavaUtilArrayList(names: JavaUtilArrayList!) {
        for var i:Int32 = 0 ; i < names.size() ; i++ {
            let item = names.getWithInt(i) as! ComFqHalcyonEntityPracticePatientRecommendName
            patientNameList.append("\(item.getPatientName())-\(item.getPatientDiagnose())")
        }
        
        let patientTableHeight = patientNameList.count * 30 > 150 ? 150 : patientNameList.count * 30
        
        patientNameShowFrame = CGRectMake(0, contentViewCGPointY, ScreenWidth,CGFloat(patientTableHeight))
        patientNameHiddenFrame = CGRectMake(0, contentViewCGPointY - 200, ScreenWidth,CGFloat(patientTableHeight))
        patientNameView.frame = patientNameShowFrame
        patientNameTable.reloadData()
    }
    
    /**
    * 重命名病案成功的回调
    */
    func renamePatientSuccess() {
        
    }
    
    /**
    * 请求错误的回调(包括访问出错和服务器出错)。
    */
    func patientNameErrorWithInt(code: Int32, withNSString msg: String!) {
        
    }
}
