//
//  MorePatientViewController.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/7/19.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class MorePatientViewController: BaseViewController ,UITableViewDataSource ,UITableViewDelegate ,UISearchBarDelegate,RecordPatientEvent,ComFqHalcyonLogicPracticeSearchLogic_SearchCallBack,ComFqHalcyonLogicPracticeSendPatientLogic_SendRecordInterface,ComFqHalcyonLogicPracticeSendPatientLogic_SendPatientInterface{
    
    //loading框
    var loadingDialog:CustomIOS7AlertView?
    
    //搜索页数
    var page = 1
    
    //搜索关键字
    var searchKey:String! = ""
    
    //搜索参数
    var params:ComFqHalcyonEntityPracticeSearchParams!
    
    //搜索逻辑
    var searchLogic: ComFqHalcyonLogicPracticeSearchLogic!
    
    //历史关键字列表
    var historyKeys: JavaUtilArrayList! = JavaUtilArrayList()
    
    var shareRecord:ComFqHalcyonEntityPracticeRecordAbstract?
    var sharePatient:ComFqHalcyonEntityPracticePatientAbstract?
    
    var isMenuShow = false
    var isPatient = true
    var selectItem = -1
    var isFromChart = false
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var leftTableView: UITableView!
    //从上个页面传过来的数据
    var patientsList: JavaUtilArrayList! = JavaUtilArrayList()
    var recordsList: JavaUtilArrayList! = JavaUtilArrayList()
    
    var datas: JavaUtilArrayList! = JavaUtilArrayList()
    //去身份化
    var didSendInfo:Bool = true
    var dialog1 = CustomIOS7AlertView()
    var imgView:UIImageView!
    var saveloadingDialog:CustomIOS7AlertView!
    
    var hasModify = false //判断是否有数据删除
    
    @IBOutlet weak var searchView: UISearchBar!
    @IBOutlet var subTableView: UITableView!
    @IBOutlet weak var contentTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        hiddenRightImage(true)
        searchView.text = searchKey
        if(isPatient == true){
            contentTableView.registerNib(UINib(nibName: "PatientViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PatientViewCell")
        }else if (isPatient == false){
            contentTableView.registerNib(UINib(nibName: "RecordViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "RecordViewCell")
        }
        leftTableView.registerNib(UINib(nibName: "CheckTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "CheckTableViewCell")
        historyKeys = ComFqHalcyonPracticeSearchHistoryManager.getInstance().getKeys()
        let count = historyKeys.size() < 5 ? historyKeys.size(): 5
        subTableView.frame = CGRectMake(0, 114, ScreenWidth, (ScreenHeight / 22.5) * CGFloat(count))
        subTableView.backgroundColor = UIColor.lightGrayColor()
        if isFromChart {
            sendBtn.hidden = false
        }else {
            sendBtn.hidden = true
        }
        if isPatient {
            startSearchLogic(page, searchKey: searchKey, responseType: 1)
        }else {
            startSearchLogic(page, searchKey: searchKey, responseType: 2)
        }
        setTableViewRefresh()
        imgView = UIImageView()
    }
    
    //调用搜索接口的方法
    func startSearchLogic(page:Int,searchKey:String,responseType:Int32){
        params = ComFqHalcyonEntityPracticeSearchParams()
        params.setNeedFiltersWithInt(0)
        params.setKeyWithNSString(searchKey)
        params.setPageWithInt(Int32(page))
        params.setResponseTypeWithInt(responseType)
        params.setPageSizeWithInt(20)
        searchLogic = ComFqHalcyonLogicPracticeSearchLogic(comFqHalcyonLogicPracticeSearchLogic_SearchCallBack: self)
        loadingDialog = UIAlertViewTool.getInstance().showLoadingDialog("搜索中...")
        searchLogic.searchWithComFqHalcyonEntityPracticeSearchParams(params)
    }
    
    //搜索成功的回调
    func searchRetrunDataWithJavaUtilArrayList(patients: JavaUtilArrayList!, withJavaUtilArrayList records: JavaUtilArrayList!, withJavaUtilArrayList filters: JavaUtilArrayList!) {
        if isPatient {
            for var i:Int32 = 0; i < patients.size(); i++ {
                datas.addWithId(patients.getWithInt(i))
            }
        }else{
            for var i:Int32 = 0; i < records.size(); i++ {
                datas.addWithId(records.getWithInt(i))
            }
        }
        selectItem = -1
        page++
        loadingDialog?.close()
        contentTableView.reloadData()
        leftTableView.reloadData()
        searchView.endEditing(true)
    }
    
    //搜索失败的回调
    func searchErrorWithInt(code: Int32, withNSString msg: String!) {
        loadingDialog?.close()
        searchView.endEditing(true)
        UIAlertViewTool.getInstance().showAutoDismisDialog(msg)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func getXibName() -> String {
        return "MorePatientViewController"
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == contentTableView {
            if(isPatient == true){
                let contentCell = tableView.dequeueReusableCellWithIdentifier("PatientViewCell") as! PatientViewCell
                contentCell.initData(patientsList.getWithInt(Int32(indexPath.row)) as! ComFqHalcyonEntityPracticePatientAbstract, indexPath: indexPath, event: self)
                var patientId = patientsList.getWithInt(Int32(indexPath.row)).getPatientId()
                var updateTime = patientsList.getWithInt(Int32(indexPath.row)).getUpdateTime()
                //                var isOffline = false
                //                var status = OfflineManager.instance.getPatientStatus(Int64(patientId), updateTime: updateTime)
                //
                //                if status == OfflineStats.Updated {
                //                    isOffline = true
                //                }
                //                contentCell.hiddenBtnDown(isOffline)
                return contentCell
            }else{
                let contentCell = tableView.dequeueReusableCellWithIdentifier("RecordViewCell") as! RecordViewCell
                contentCell.initData(recordsList.getWithInt(Int32(indexPath.row)) as! ComFqHalcyonEntityPracticeRecordAbstract, indexPath: indexPath, event: self)
                return contentCell
            }
        }else if tableView == leftTableView {
            let cells = tableView.dequeueReusableCellWithIdentifier("CheckTableViewCell") as! CheckTableViewCell
            if isFromChart {
                cells.iconBtn.hidden = false
                if(indexPath.row == selectItem){
                    cells.iconBtn.image = UIImage(named: "friend_select.png")
                }else{
                    cells.iconBtn.image = UIImage(named: "friend_unselect.png")
                }
            }else{
                cells.iconBtn.hidden = true
            }
            return cells
        }
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
        cell.textLabel!.text = historyKeys.getWithInt(Int32(indexPath.row)) as? String
        cell.textLabel!.font = UIFont.systemFontOfSize(12.0)
        cell.textLabel!.textColor = UIColor.lightGrayColor()
        cell.textLabel!.textAlignment = NSTextAlignment.Center
        cell.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1)
        if indexPath == selectItem {
            searchView.text =  cell.textLabel!.text
        }
        return cell
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if scrollView == contentTableView {
            self.leftTableView.setContentOffset(self.contentTableView.contentOffset, animated: false)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == leftTableView || tableView == contentTableView {
            if isPatient {
                return Int(patientsList.size())
            }else {
                return Int(recordsList.size())
            }
        }else if tableView == subTableView {
            return Int(historyKeys.size())
        }
        return 0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tableView == subTableView {
            return ScreenHeight/22.5
        }
        return 110
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if(tableView == subTableView){
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            searchView.text =  cell?.textLabel!.text
            searchView.endEditing(true)
            searchKey = searchView.text
            if(isPatient){
                startSearchLogic(page,searchKey: searchKey,responseType: 1)
            }else{
                startSearchLogic(page,searchKey: searchKey,responseType: 2)
            }
            subTableView.removeFromSuperview()
        }
        
        if(tableView == leftTableView){
            selectItem = indexPath.row
            leftTableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.endEditing(true)
        if searchBar.text!.isEmpty {
            return
        }
        datas.clear()
        searchKey = searchBar.text
        if(isPatient){
            startSearchLogic(page,searchKey: searchKey,responseType: 1)
        }else{
            startSearchLogic(page,searchKey: searchKey,responseType: 2)
        }
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.view.addSubview(subTableView)
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        subTableView.removeFromSuperview()
    }
    
    //RecordPatientEvent方法
    func onRPItemClear(indexPath: NSIndexPath!) {
        
    }
    
    func onRPItemClick(indexPath: NSIndexPath!) {
        
    }
    
    func onRPItemCloud(indexPath: NSIndexPath!) {
        
    }
    
    func onRPItemRecover(indexPath: NSIndexPath!) {
        
    }
    
    func onRPItemRemove(indexPath: NSIndexPath!) {
        
        let rowNum = indexPath.row
        
        if isPatient {
            patientsList.removeWithInt(Int32(rowNum))
        }else{
            recordsList.removeWithInt(Int32(rowNum))
        }
        contentTableView.reloadData()
        
        hasModify = true
    }
    
    func onRPItemShare(indexPath: NSIndexPath!) {
        
    }
    
    func onRPItemStruct(indexPath: NSIndexPath!) {
        
    }
    
    //发送按钮点击事件
    @IBAction func sendBtnClicked(sender: AnyObject) {
        if(selectItem != -1){
            let str = "发送时包含身份信息"
            let tmpView = UIView(frame: CGRectMake(0, 0, 250, 150))
            //title
            let titleLabel = UILabel(frame: CGRectMake(0, 10, 250, 30))
            titleLabel.textAlignment = NSTextAlignment.Center
            titleLabel.textColor = UIColor.blackColor()
            titleLabel.text = "是否要去身份化？"
            titleLabel.font = UIFont.systemFontOfSize(16)
            //可选择的label
            let label = UILabel(frame: CGRectMake(0, 50, 250, 20))
            label.textAlignment = NSTextAlignment.Center
            label.textColor = UIColor.grayColor()
            label.text = str
            label.font = UIFont.systemFontOfSize(11)
            
            //图标
            let lengthOfString :NSInteger = str.characters.count
            let cg = CGFloat(NSInteger(lengthOfString))
            if didSendInfo{
                imgView.image = UIImage(named: "icon_circle_yes.png")
            }else{
                imgView.image = UIImage(named: "icon_circle_no.png")
            }
            
            imgView.frame = CGRectMake((113-cg*6),54,12,12)
            //供选择的button点击  透明
            let withInfoBtn = UIButton(frame:CGRectMake(50, 40, 150, 40))
            withInfoBtn.addTarget(self,action:Selector("withInfoBtnClick:"),forControlEvents: UIControlEvents.TouchUpInside)
            let clickLabel = UILabel(frame: CGRectMake(15, 75, 220, 35))
            clickLabel.font = UIFont.systemFontOfSize(11)
            clickLabel.textAlignment = NSTextAlignment.Center
            clickLabel.textColor = Color.darkPurple
            clickLabel.text = "请确认发送该记录不会涉及您或者第三方的隐私，详情请查看《隐私条款》"
            clickLabel.numberOfLines = 0
            clickLabel.lineBreakMode = NSLineBreakMode.ByCharWrapping
            let makeSize = CGSizeMake(clickLabel.frame.size.width, CGFloat(MAXFLOAT))
            var size = clickLabel.sizeThatFits(makeSize)
            
            let secretProtocol = UIButton(frame:CGRectMake(15, 75, 220, 35))
            secretProtocol.addTarget(self,action:Selector("secretProtocolClick:"),forControlEvents: UIControlEvents.TouchUpInside)
            
            let labelLine = UILabel(frame: CGRectMake(0, 114, 250, 1))
            labelLine.backgroundColor = UIColor.grayColor()
            //确定btn
            UIButton(type: UIButtonType.Custom)
            let btnSure = UIButton(frame: CGRectMake(0, 115, 125, 35))
            
            btnSure.setTitle("发送", forState: UIControlState.Normal)
            btnSure.titleLabel?.font = UIFont.systemFontOfSize(16)
            btnSure.titleLabel?.textColor = UIColor.whiteColor()
            
            btnSure.setBackgroundImage(UITools.imageWithColor(Color.lightPurple), forState: UIControlState.Normal)
            btnSure.setBackgroundImage(UITools.imageWithColor(Color.purple), forState: UIControlState.Highlighted)
            btnSure.addTarget(self, action: Selector("sendClick:"), forControlEvents: UIControlEvents.TouchUpInside)
            //取消btn
            let btnCancle = UIButton(frame: CGRectMake(125, 115, 125, 35))
            btnCancle.setTitle("取消", forState: UIControlState.Normal)
            btnCancle.titleLabel?.font = UIFont.systemFontOfSize(16)
            
            btnCancle.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            btnCancle.setTitleColor(UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1), forState: UIControlState.Highlighted)
            
            btnCancle.setBackgroundImage(UITools.imageWithColor(UIColor.whiteColor()), forState: UIControlState.Normal)
            btnCancle.setBackgroundImage(UITools.imageWithColor(UIColor(red: 219/255, green: 220/255, blue: 220/255, alpha: 1)), forState: UIControlState.Highlighted)
            
            btnCancle.addTarget(self, action: Selector("cancel:"), forControlEvents: UIControlEvents.TouchUpInside)
            
            UITools.setBtnWithOneRound(btnSure, corners: UIRectCorner.BottomLeft)
            UITools.setBtnWithOneRound(btnCancle, corners: UIRectCorner.BottomRight)
            
            
            tmpView.addSubview(titleLabel)
            tmpView.addSubview(label)
            tmpView.addSubview(imgView)
            tmpView.addSubview(withInfoBtn)
            tmpView.addSubview(secretProtocol)
            tmpView.addSubview(clickLabel)
            tmpView.addSubview(labelLine)
            tmpView.addSubview(btnSure)
            tmpView.addSubview(btnCancle)
            dialog1.containerView = tmpView
            dialog1.show()
        }
    }
    
    //取消发送
    func cancel(sender:AnyObject?){
        dialog1.close()
    }
    //供选择的btn点击事件
    func withInfoBtnClick(sender:AnyObject?){
        if didSendInfo{
            didSendInfo = false
            imgView.image = UIImage(named: "icon_circle_no.png")
            print("去身份化")
        }else{
            didSendInfo = true
            imgView.image = UIImage(named: "icon_circle_yes.png")
            print("不去身份化")
        }
    }
    //隐私协议
    func secretProtocolClick(sender:AnyObject?){
        dialog1.close()
        self.navigationController?.pushViewController(ProtocolViewController(),animated:true)
    }
    
    //点击发送
    func sendClick(sender:AnyObject?){
        dialog1.close()
        var isRemoveIdentity:Int32 = 0
        if didSendInfo{
            print("不去身份化")
            isRemoveIdentity = 0
        }else{
            print("去身份化")
            isRemoveIdentity = 1
        }
        saveloadingDialog = UIAlertViewTool.getInstance().showLoadingDialog("发送中,请耐心等待...")
        if isPatient {
            sharePatient = patientsList.getWithInt(Int32(selectItem)) as? ComFqHalcyonEntityPracticePatientAbstract
            
            if shareIsGroup {
                let sendPatientLogic = ComFqHalcyonLogicPracticeSendPatientLogic()
                sendPatientLogic.sendPatientToGroupWithComFqHalcyonLogicPracticeSendPatientLogic_SendPatientInterface(self, withNSString: shareGroupId, withInt: sharePatient!.getPatientId(),withComFqHalcyonEntityPracticePatientAbstract:sharePatient,withInt:isRemoveIdentity)
            }else{
                let sendPatientLogic = ComFqHalcyonLogicPracticeSendPatientLogic()
                sendPatientLogic.sendPatientToUserWithComFqHalcyonLogicPracticeSendPatientLogic_SendPatientInterface(self, withInt: shareUserId, withInt: sharePatient!.getPatientId(),withComFqHalcyonEntityPracticePatientAbstract:sharePatient,withInt:isRemoveIdentity)
            }
            
            
        }else{
            shareRecord = recordsList.getWithInt(Int32(selectItem)) as? ComFqHalcyonEntityPracticeRecordAbstract
            
            
            if shareIsGroup {
                let sendPatientLogic = ComFqHalcyonLogicPracticeSendPatientLogic()
                sendPatientLogic.sendRecordToGroupWithComFqHalcyonLogicPracticeSendPatientLogic_SendRecordInterface(self, withNSString: shareGroupId, withInt: shareRecord!.getRecordItemId(),withComFqHalcyonEntityPracticeRecordAbstract:shareRecord,withInt:isRemoveIdentity)
            }else {
                let sendPatientLogic = ComFqHalcyonLogicPracticeSendPatientLogic()
                sendPatientLogic.sendRecordToUserWithComFqHalcyonLogicPracticeSendPatientLogic_SendRecordInterface(self, withInt: shareUserId, withInt: shareRecord!.getRecordItemId(),withComFqHalcyonEntityPracticeRecordAbstract:shareRecord,withInt:isRemoveIdentity)
            }
            
        }
        
    }
    
    /**获取病案share数据失败*/
    func onSendPatientErrorWithInt(errorCode: Int32, withNSString msg: String!) {
        saveloadingDialog?.close()
//        self.view.makeToast("获取数据失败，请重试。")
        FQToast.makeError().show("获取数据失败，请重试。", superview: self.view)
    }
    /**获取病案share数据成功*/
    func onSendPatientSuccessWithInt(shareMessageId: Int32, withInt sharePatientId: Int32,withComFqHalcyonEntityPracticePatientAbstract obj: ComFqHalcyonEntityPracticePatientAbstract!) {
        saveloadingDialog?.close()
        var chartEntity = ComFqHalcyonEntityChartEntity()
        chartEntity = ComFqHalcyonEntityChartEntity()
        chartEntity.setSharePatientEntityWithComFqHalcyonEntityPracticePatientAbstract(obj, withInt: sharePatientId, withInt: shareMessageId)
        shareChatEntityList.addWithId(chartEntity)
        
        
        let index = self.navigationController?.viewControllers.count
        self.navigationController?.viewControllers.removeRange(Range(start: index! - 3,end:index! - 1))
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    /**获取记录share数据失败*/
    func onSendRecordErrorWithInt(errorCode: Int32, withNSString msg: String!) {
        saveloadingDialog?.close()
//        self.view.makeToast("获取数据失败，请重试。")
        FQToast.makeError().show("获取数据失败，请重试。", superview: self.view)
    }
    /**获取记录share数据成功*/
    func onSendRecordSuccessWithInt(shareMessageId: Int32, withInt shareRecordItemId: Int32, withFQJSONArray shareRecordInfIds: FQJSONArray!, withComFqHalcyonEntityPracticeRecordAbstract obj: ComFqHalcyonEntityPracticeRecordAbstract!) {
        saveloadingDialog?.close()
        obj.setIsShowIdentityWithBoolean(didSendInfo)
        for m in 0..<shareRecordInfIds.length() {
            let chartEntity = ComFqHalcyonEntityChartEntity()
            chartEntity.setRecordInfoIdWithInt(shareRecordInfIds.optIntWithInt(m))
            chartEntity.setShareRecordEntityWithComFqHalcyonEntityPracticeRecordAbstract(obj, withInt: shareRecordItemId, withInt: shareMessageId)
            shareChatEntityList.addWithId(chartEntity)
        }
        let index = self.navigationController?.viewControllers.count
        self.navigationController?.viewControllers.removeRange(Range(start: index! - 3,end:index! - 1))
        self.navigationController?.popViewControllerAnimated(true)
        
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
        if isPatient {
            startSearchLogic(page, searchKey: searchKey, responseType: 1)
        }else{
            startSearchLogic(page, searchKey: searchKey, responseType: 2)
        }
        
        // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
        contentTableView.footerEndRefreshing()
    }
    
    override func viewDidDisappear(animated: Bool) {
        if hasModify {
            NSNotificationCenter.defaultCenter().postNotificationName("DataHasChanged", object: hasModify)
        }
    }
}
