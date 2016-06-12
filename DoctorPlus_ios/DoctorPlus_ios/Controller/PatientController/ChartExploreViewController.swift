//
//  ChartExploreViewController.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/7/16.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class ChartExploreViewController: BaseViewController,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,ComFqHalcyonLogicPracticePatientUpdateListLogic_PatientLineListCallback,ComFqHalcyonLogicPracticeSendPatientLogic_SendPatientInterface,SelectPatientTableViewCellDelegate{
    var dialog2:IndetifyDialog!
    
    typealias sendValueClosure = (bool:Bool)->Void
    var myClosure:sendValueClosure?
    
    @IBAction func sureClicked(sender: AnyObject) {
        
        if  sharePatient == nil {
//            self.view.makeToast("请选择需要分享的病案")
             FQToast.makeSystem().show("请选择需要分享的病案", superview: self.view)
            return
        }
        

        dialog2 = UIAlertViewTool.getInstance().showRemoveIndetifyDialog(didSendInfo, target: self, actionOk: "sendClick:", actionCancle: "cancel:", actionRemoveIndentify: "secretProtocolClick:", selecBtn: "withInfoBtnClick:")

    }
    //取消发送
    func cancel(sender:AnyObject?){
        dialog2.alertView!.close()
    }
    
    //供选择的btn点击事件
    func withInfoBtnClick(sender:AnyObject?){
        if didSendInfo{
            didSendInfo = false
            dialog2.selectBtn!.setBackgroundImage(UIImage(named: "icon_circle_no.png"), forState: UIControlState.Normal)
            print("去身份化")
        }else{
            didSendInfo = true
            dialog2.selectBtn!.setBackgroundImage(UIImage(named: "icon_circle_yes.png"), forState: UIControlState.Normal)
            print("不去身份化")
        }
    }
    //隐私协议
    func secretProtocolClick(sender:AnyObject?){
        dialog2.alertView!.close()
        self.navigationController?.pushViewController(ProtocolViewController(),animated:true)
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var contentTableView: UITableView!
    @IBOutlet weak var tableview: UITableView!
    var selectedItem = -1
    //loading框
    var loadingDialog:CustomIOS7AlertView?
    
    //去身份化
    var didSendInfo:Bool = true
//    var dialog1 = CustomIOS7AlertView()
    var imgView:UIImageView!
    var saveloadingDialog:CustomIOS7AlertView!
    //搜索页数
    var page = 1
    
    //搜索关键字
    var searchKey:String! = ""
    
    var alert:CustomIOS7AlertView?
    var textAlert:(CustomIOS7AlertView?,UITextView?)
    var isMenuShow:Bool = false
    var selectedNumber = 0
    
    var index = -1
    var textView:UITextView?
    var dialog:CustomIOS7AlertView?
    var patientListlogic : ComFqHalcyonLogicPracticePatientUpdateListLogic!
    var datas:JavaUtilArrayList! = JavaUtilArrayList()
    var photoImages:JavaUtilArrayList!
    var sharePatient:ComFqHalcyonEntityPracticePatientAbstract?
    override func viewDidLoad() {
        super.viewDidLoad()
        imgView = UIImageView()
        setTittle("搜索")
        setRightBtnTittle("")
        setLeftTextString("返回")
        tableview.registerNib(UINib(nibName: "SelectPatientTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "SelectPatientTableViewCell")
        setTableViewRefresh()
        searchBar.text = searchKey
        patientListlogic = ComFqHalcyonLogicPracticePatientUpdateListLogic(comFqHalcyonLogicPracticePatientUpdateListLogic_PatientListCallback: self)
        patientListlogic.requestPatientListWithInt(Int32(page), withInt: Int32(0), withBoolean:false)
        loadingDialog = UIAlertViewTool.getInstance().showLoadingDialog("加载中...")

    }
    

    //点击发送
    func sendClick(sender:AnyObject?){
        dialog2.alertView!.close()
        
        var isRemoveIdentity:Int32 = 0
        if didSendInfo{
            print("不去身份化")
            isRemoveIdentity = 0
        }else{
            print("去身份化")
            isRemoveIdentity = 1
        }
        saveloadingDialog = UIAlertViewTool.getInstance().showLoadingDialog("发送中,请耐心等待...")
        
        if shareIsGroup {
            let sendPatientLogic = ComFqHalcyonLogicPracticeSendPatientLogic()
            sendPatientLogic.sendPatientToGroupWithComFqHalcyonLogicPracticeSendPatientLogic_SendPatientInterface(self, withNSString: shareGroupId, withInt: sharePatient!.getPatientId(),withComFqHalcyonEntityPracticePatientAbstract:sharePatient,withInt:isRemoveIdentity)
        }else{
            let sendPatientLogic = ComFqHalcyonLogicPracticeSendPatientLogic()
            sendPatientLogic.sendPatientToUserWithComFqHalcyonLogicPracticeSendPatientLogic_SendPatientInterface(self, withInt: shareUserId, withInt: sharePatient!.getPatientId(),withComFqHalcyonEntityPracticePatientAbstract:sharePatient,withInt:isRemoveIdentity)
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
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    

    
    override func viewWillDisappear(animated: Bool) {
        tableview.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func getXibName() -> String {
        return "ChartExploreViewController"
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:SelectPatientTableViewCell = tableView.dequeueReusableCellWithIdentifier("SelectPatientTableViewCell") as! SelectPatientTableViewCell
        if indexPath.row == index {
            ((cell as SelectPatientTableViewCell).iconBtn).image = UIImage(named: "select_dot.png")
        }else{
            ((cell as SelectPatientTableViewCell).iconBtn).image = UIImage(named: "unselect_dot.png")
        }
        let patient:ComFqHalcyonEntityPracticePatientAbstract = datas.getWithInt(Int32(indexPath.row)) as! ComFqHalcyonEntityPracticePatientAbstract
        
        cell.tag = indexPath.row
        cell.delegate = self
        
        UITools.setRoundBounds(17.0, view: (cell as SelectPatientTableViewCell).headIcon)
        (cell as SelectPatientTableViewCell).numberLabel.text = "\(patient.getRecordCount())记录"
        (cell as SelectPatientTableViewCell).firstShowLabel.text = patient.getShowName()
        (cell as SelectPatientTableViewCell).secondShowLabel.text = patient.getShowSecond()
        (cell as SelectPatientTableViewCell).thirdShowLabel.text = patient.getShowThrid()
        (cell as SelectPatientTableViewCell).headIcon.downLoadImageWidthImageId(patient.getUserImageId(), callback: { (view, path) -> Void in
            let tmpImg = view as! UIImageView
            tmpImg.image = UITools.getImageFromFile(path)
        })
        return cell
    }
    
    func onCheckboxClick(cell:SelectPatientTableViewCell)
    {
        index = cell.tag
        sharePatient = datas.getWithInt(Int32(index)) as? ComFqHalcyonEntityPracticePatientAbstract
        tableview.reloadData()
    }
    
    func taped(sender:UIGestureRecognizer){
   
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if datas == nil {return 0};
        return Int(datas.size())
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let patient:ComFqHalcyonEntityPracticePatientAbstract = datas.getWithInt(Int32(indexPath.row)) as! ComFqHalcyonEntityPracticePatientAbstract
        let control = ExplorationRecordListViewController()
        control.patientItem = patient
        control.isFromChart = true
        self.navigationController?.pushViewController(control, animated: true)
    }
    
    //搜索框search事件
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.endEditing(true)
        if searchBar.text!.isEmpty {
            return
        }
        searchKey = searchBar.text
        page = 1
        datas.clear()
        var controller = SearchViewController()
        controller.searchKey = self.searchKey
        controller.isFromChart = true
        self.navigationController?.pushViewController(controller, animated: true)
    }

    
    
    /**获取病案列表失败的回调*/
    func loadPatientErrorWithInt(code: Int32, withNSString msg: String!) {
        loadingDialog?.close()
        UIAlertViewTool.getInstance().showAutoDismisDialog(msg)
    }
    
    //下载病历列表的回调
    func loadPatientLineListSuccessWithJavaUtilArrayList(list: JavaUtilArrayList!) {
        for var i :Int32 = 0; i < list.size(); i++ {
            datas.addWithId(list.getWithInt(i))
        }
        page++
        loadingDialog?.close()
        tableview.reloadData()
    }
    
    func loadPatientSuccessWithJavaUtilArrayList(keys: JavaUtilArrayList!, withJavaUtilHashMap map: JavaUtilHashMap!) {
        
    }
    
    /**设置tabview 上拉下拉**/
    func setTableViewRefresh(){
        contentTableView.headerBeginRefreshing()
        //        patientTableView.addHeaderWithTarget(self, action: "headerRereshing")
        contentTableView.addFooterWithTarget(self, action: "footerRereshing")
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
        patientListlogic.requestPatientListWithInt(Int32(page), withInt: Int32(0), withBoolean:false)
        
        // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
        contentTableView.footerEndRefreshing()
    }
    
    func setClosure(closure:sendValueClosure?){
        myClosure = closure
    }
}
