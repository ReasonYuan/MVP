//
//  SearchPatientViewController.swift
//  DoctorPlus_ios
//
//  Created by sunning on 15/12/4.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import UIKit

class SearchPatientController: BaseViewController ,ButtonCollectionDelegate,ComFqHalcyonLogicPracticeSendPatientLogic_SendRecordInterface,ComFqHalcyonLogicPracticeSendPatientLogic_SendPatientInterface,ComFqHalcyonLogicPracticeSearchCriteriaLogic_SaveSearchCriteriaInterface{
    
    var params:ComFqHalcyonEntityPracticeSearchParams?
    var isFromFilter = false
    var delegate:SearchPatientHeadViewDelegate!
    var isFromChart = false
    var isExpanded:Bool = false
    var keys:String = ""
    var filters:JavaUtilArrayList?
    //去身份化
    var didSendInfo:Bool = true
    var indetifyDialog:IndetifyDialog!
    var saveloadingDialog:CustomIOS7AlertView!
    @IBOutlet weak var moreFilterButton: UIButton!
    @IBOutlet weak var moreFilterBtn: UIButton!
    @IBOutlet weak var headLine: UILabel!
    var mySearchView : MySearchContentsView!
    var saveDialog:CustomIOS7AlertView?
    var saveTextField:UITextField?
    var structDialog:CustomIOS7AlertView?
    var structTextField:UITextField?
    func setParams(params:ComFqHalcyonEntityPracticeSearchParams,isFromFilter:Bool){
        self.params = params
        self.isFromFilter = isFromFilter
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTittle("关键词")
        setRightBtnTittle("")
        UITools.setRoundBounds(4, view: moreFilterButton)
        mySearchView = MySearchContentsView()
        setContentView(mySearchView)
        mySearchView.isFromChart = self.isFromChart
        setMySearchAdapter()
        
        let sendBtn = UIButton(frame: CGRectMake(0, ScreenHeight - 50  , ScreenWidth, 50))
        sendBtn.backgroundColor = UIColor.blackColor()
        sendBtn.setTitle("发送", forState: UIControlState.Normal)
        sendBtn.addTarget(self, action: "sendClicked", forControlEvents: UIControlEvents.TouchUpInside)
        var button:UIView!
        if isFromChart {
            button = ButtonCollection(frame: CGRectMake((ScreenWidth - 50 ) / 2 , ScreenHeight - 100, 50, 50) , btnCount: 3, centerBtnImageList: ["show_menu.png","close_menu.png"], btnNormalList: ["xz.png","struct_mode.png","sq.png"], superView: self.view, delegate: self )
            self.view.addSubview(sendBtn)
        }else{
            button = ButtonCollection(frame: CGRectMake((ScreenWidth - 50 ) / 2 , ScreenHeight - 50, 50, 50) , btnCount: 3, centerBtnImageList: ["show_menu.png","close_menu.png"], btnNormalList: ["xz.png","struct_mode.png","sq.png"], superView: self.view, delegate: self )
        }
        self.view.addSubview(button)
    }
    
    //发送点击
    func sendClicked(){
        if !(mySearchView.sectionSelectedIndex == -1 && mySearchView.itemSelectedSection == -1 && mySearchView.itemSelectedIndex == -1){
            indetifyDialog = UIAlertViewTool.getInstance().showRemoveIndetifyDialog(didSendInfo, target: self, actionOk: "sendClick", actionCancle: "cancel", actionRemoveIndentify: "secretProtocolClick", selecBtn: "withInfoBtnClick")
            
        }else{
            FQToast.makeError().show("请选择病案或病历", superview: self.view)
        }
    }
    
    //确认分享
    func sendClick(){
        indetifyDialog.alertView?.close()
        sendClick(nil)
    }
    
    //取消分享
    func cancel(){
        indetifyDialog.alertView?.close()
    }
    //查看协议
    func secretProtocolClick(){
        indetifyDialog.alertView?.close()
        self.navigationController?.pushViewController(ProtocolViewController() , animated: true)
    }
    //是否包含身份信息
    func withInfoBtnClick(){
        didSendInfo = !didSendInfo;
        
        if didSendInfo{
            indetifyDialog.selectBtn?.setBackgroundImage(UIImage(named: "icon_circle_yes.png"), forState: UIControlState.Normal)
        }else{
            indetifyDialog.selectBtn?.setBackgroundImage(UIImage(named: "icon_circle_no.png"), forState: UIControlState.Normal)
        }
        
    }
    
    
    //点击发送
    func sendClick(sender:AnyObject?){
        indetifyDialog.alertView?.close()
        var isRemoveIdentity:Int32 = 0
        if didSendInfo{
            print("不去身份化")
            isRemoveIdentity = 0
        }else{
            print("去身份化")
            isRemoveIdentity = 1
        }
        saveloadingDialog = UIAlertViewTool.getInstance().showLoadingDialog("发送中,请耐心等待...")
        if mySearchView.sectionSelectedIndex != -1 {
            if shareIsGroup {
                let sendPatientLogic = ComFqHalcyonLogicPracticeSendPatientLogic()
                sendPatientLogic.sendPatientToGroupWithComFqHalcyonLogicPracticeSendPatientLogic_SendPatientInterface(self, withNSString: shareGroupId, withInt: mySearchView.selectedPatient.getPatientId(),withComFqHalcyonEntityPracticePatientAbstract:mySearchView.selectedPatient,withInt:isRemoveIdentity)
            }else{
                let sendPatientLogic = ComFqHalcyonLogicPracticeSendPatientLogic()
                sendPatientLogic.sendPatientToUserWithComFqHalcyonLogicPracticeSendPatientLogic_SendPatientInterface(self, withInt: shareUserId, withInt: mySearchView.selectedPatient.getPatientId(),withComFqHalcyonEntityPracticePatientAbstract:mySearchView.selectedPatient,withInt:isRemoveIdentity)
            }
            
        }else{
            if shareIsGroup {
                let sendPatientLogic = ComFqHalcyonLogicPracticeSendPatientLogic()
                sendPatientLogic.sendRecordToGroupWithComFqHalcyonLogicPracticeSendPatientLogic_SendRecordInterface(self, withNSString: shareGroupId, withInt: mySearchView.selectedRecord.getRecordItemId(),withComFqHalcyonEntityPracticeRecordAbstract:mySearchView.selectedRecord,withInt:isRemoveIdentity)
            }else {
                let sendPatientLogic = ComFqHalcyonLogicPracticeSendPatientLogic()
                sendPatientLogic.sendRecordToUserWithComFqHalcyonLogicPracticeSendPatientLogic_SendRecordInterface(self, withInt: shareUserId, withInt: mySearchView.selectedRecord.getRecordItemId(),withComFqHalcyonEntityPracticeRecordAbstract:mySearchView.selectedRecord,withInt:isRemoveIdentity)
            }
            
        }
        
    }
    
    /**获取病案share数据失败*/
    func onSendPatientErrorWithInt(errorCode: Int32, withNSString msg: String!) {
        saveloadingDialog?.close()
        FQToast.makeError().show("获取数据失败，请重试。", superview: self.view)
    }
    /**获取病案share数据成功*/
    func onSendPatientSuccessWithInt(shareMessageId: Int32, withInt sharePatientId: Int32,withComFqHalcyonEntityPracticePatientAbstract obj: ComFqHalcyonEntityPracticePatientAbstract!) {
        
        let chartEntity = ComFqHalcyonEntityChartEntity()
        chartEntity.setSharePatientEntityWithComFqHalcyonEntityPracticePatientAbstract(obj, withInt: sharePatientId, withInt: shareMessageId)
        shareChatEntityList.addWithId(chartEntity)
        saveloadingDialog?.close()
        self.navigationController?.popToViewController((self.navigationController?.viewControllers[currentControllerIndex])!, animated: true)
        
    }
    
    /**获取记录share数据失败*/
    func onSendRecordErrorWithInt(errorCode: Int32, withNSString msg: String!) {
        saveloadingDialog?.close()
        FQToast.makeError().show("获取数据失败，请重试。", superview: self.view)
    }
    
    
    
    /**获取记录share数据成功*/
    func onSendRecordSuccessWithInt(shareMessageId: Int32, withInt shareRecordItemId: Int32, withFQJSONArray shareRecordInfIds: FQJSONArray!, withComFqHalcyonEntityPracticeRecordAbstract obj: ComFqHalcyonEntityPracticeRecordAbstract!) {
        obj.setIsShowIdentityWithBoolean(didSendInfo)
        for m in 0..<shareRecordInfIds.length() {
            let chartEntity = ComFqHalcyonEntityChartEntity()
            chartEntity.setRecordInfoIdWithInt(shareRecordInfIds.optIntWithInt(m))
            
            chartEntity.setShareRecordEntityWithComFqHalcyonEntityPracticeRecordAbstract(obj, withInt: shareRecordItemId, withInt: shareMessageId)
            shareChatEntityList.addWithId(chartEntity)
        }
        saveloadingDialog?.close()
        
        print(currentControllerIndex)
        self.navigationController?.popToViewController((self.navigationController?.viewControllers[currentControllerIndex])!, animated: true)
        
    }
    
    func setContentView(baseView:ContentsBaseView) {
        
        containerView.addSubview(baseView)
        baseView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(headLine).offset(20)
            make.left.equalTo(containerView).offset(8)
            make.right.equalTo(containerView).offset(-8)
            make.bottom.equalTo(containerView).offset(0)
        }
    }
    var adapter:MySearchAdapter?
    func setMySearchAdapter() {
        adapter = MySearchAdapter()
        adapter!.isFromChart = self.isFromChart
        adapter!.searchKey = keys
        adapter!.isFromFilter = isFromFilter
        adapter!.params = params
        mySearchView.setContentsAdapter(adapter!)
        mySearchView.onStartFetchData()
    }
    
    func LeftOnClick(sender: UIButton) {
        let result = UIAlertViewTool.getInstance().showNewTextFieldDialog("保存搜索结果", hint: "请输入名称", sureImage: "dialog_sure.png", target: self, actionOk: "okClicked", actionCancle: "cancelClicked")
        saveDialog = result.alertView
        saveTextField = result.textField
    }
    
    func okClicked(){
        if saveTextField?.text != ""{
            if params == nil {
                params = ComFqHalcyonEntityPracticeSearchParams()
                params?.setKeyWithNSString(keys)
                params?.setFiltersWithJavaUtilArrayList(filters ?? adapter?.filters)
            }
            params?.setNameWithNSString(saveTextField?.text)
            print(params?.getFiltersJson())
            let logic = ComFqHalcyonLogicPracticeSearchCriteriaLogic()
            logic.SaveSearchConditionWithComFqHalcyonEntityPracticeSearchParams(params, withJavaUtilArrayList: getPatientIds(), withComFqHalcyonLogicPracticeSearchCriteriaLogic_SaveSearchCriteriaInterface: self)
            saveDialog?.close()
        }else{
            FQToast.makeError().show("请输入保存结果名", superview: self.view)
        }
    }
    
    func cancelClicked(){
        saveDialog?.close()
    }
    
    func RightOnClick(sender: UIButton) {
        let result = UIAlertViewTool.getInstance().showNewTextFieldDialog("保存搜索结果", hint: "请输入名称", sureImage: "qd2.png", target: self, actionOk: "struct_okClicked", actionCancle: "struct_cancelClicked")
        structDialog = result.alertView
        structTextField = result.textField
    }
    
    func onSaveSuccess() {
        FQToast.makeSystem().show("保存筛选条件成功", superview: self.view)
    }
    
    func onSaveErrorWithInt(code: Int32, withNSString msg: String!) {
        FQToast.makeError().show(msg, superview: self.view)
    }
    
    func UpOnClick(sender: UIButton) {
        if(isExpanded == true){
            sender.setBackgroundImage(UIImage(named: "sq.png"), forState: UIControlState.Normal)
            for var i:Int = 0 ; i < mySearchView.adapter?.sectionsPatient.count; i++ {
                (mySearchView.adapter as! MySearchAdapter).tmpDatas[i] = [Any]()
                (mySearchView.adapter as! MySearchAdapter).sectionIsOpen[i] = false
                mySearchView.contentTableView.deleteRowsAtIndexPaths(mySearchView.getIndexPaths(i), withRowAnimation: UITableViewRowAnimation.Fade)
            }
        }else{
            sender.setBackgroundImage(UIImage(named: "show.png"), forState: UIControlState.Normal)
            for var i:Int = 0 ; i < mySearchView.adapter?.sectionsPatient.count; i++ {
                (mySearchView.adapter as! MySearchAdapter).tmpDatas[i] = (mySearchView.adapter?.rowsInSections[i])!
                (mySearchView.adapter as! MySearchAdapter).sectionIsOpen[i] = true
                mySearchView.contentTableView.insertRowsAtIndexPaths(mySearchView.getIndexPaths(i), withRowAnimation: UITableViewRowAnimation.Fade)
            }
        }
        isExpanded = !isExpanded
    }
    
    func struct_okClicked(){
        if structTextField?.text != ""{
            if params == nil {
                params = ComFqHalcyonEntityPracticeSearchParams()
                params?.setKeyWithNSString(keys)
                params?.setFiltersWithJavaUtilArrayList(filters ?? adapter?.filters)
            }
            print(params?.getFiltersJson())
            params?.setNameWithNSString(structTextField?.text)
            let logic = ComFqHalcyonLogicPracticeSearchCriteriaLogic()
            logic.SaveSearchConditionWithComFqHalcyonEntityPracticeSearchParams(params, withJavaUtilArrayList: getPatientIds(), withComFqHalcyonLogicPracticeSearchCriteriaLogic_SaveSearchCriteriaInterface: self)
//            let controller = self.navigationController?.viewControllers[0] as! MainViewController
//            controller.selectedIndex = 0
//            (controller.viewControllers![0] as! ChartHomeViewController).reloadFilterData(getPatients())
            self.navigationController?.popToRootViewControllerAnimated(true)
            structDialog?.close()
        }else{
            FQToast.makeError().show("请输入保存结果名", superview: self.view)
        }
    }
    
    func struct_cancelClicked(){
        structDialog?.close()
    }
    
    
    @IBAction func moreFilterBtnClicked(sender: AnyObject) {
        let controller = FilterSearchViewController()
        controller.isFromChart = isFromChart
        controller.filters = (mySearchView.adapter as! MySearchAdapter).filters ?? JavaUtilArrayList()
        controller.searchKey = keys
        navigationController?.pushViewController(controller, animated: true)
    }
    
    override func getXibName() -> String {
        return "SearchPatientController"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
     func getPatientIds() -> JavaUtilArrayList{
        let patientIds = JavaUtilArrayList()
        for var i = 0; i < (mySearchView.adapter as! MySearchAdapter).sectionsPatient.count; i++ {
            let patientId = (mySearchView.adapter as! MySearchAdapter).sectionsPatient[i].getPatientId()
            patientIds.addWithId(JavaLangInteger(int: patientId))
        }
        return patientIds
    }
    
}
