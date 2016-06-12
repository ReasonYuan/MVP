//
//  SearchViewController.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/7/23.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class SearchViewController: BaseViewController,UITableViewDataSource,UITableViewDelegate,ComFqHalcyonLogicPracticeSearchLogic_SearchCallBack,RecordPatientEvent,UISearchBarDelegate,ComFqHalcyonLogicPracticeSendPatientLogic_SendRecordInterface,ComFqHalcyonLogicPracticeSendPatientLogic_SendPatientInterface{
    @IBOutlet var subTableView: UITableView!
    
    @IBOutlet weak var searchView: UISearchBar!
    //loading框
    var loadingDialog:CustomIOS7AlertView?
    
    //搜索页数
    var page:Int32! = 1
    
    //搜索关键字
    var searchKey:String! = ""
    
    //搜索参数
    var params:ComFqHalcyonEntityPracticeSearchParams!
    
    //搜索逻辑
    var searchLogic: ComFqHalcyonLogicPracticeSearchLogic!
    
    //病案列表
    var patientsList: JavaUtilArrayList!
    
    //病历记录列表
    var recordsList: JavaUtilArrayList!
    
    //筛选列表
    var filtersList: JavaUtilArrayList! = JavaUtilArrayList()
    
    //历史关键字列表
    var historyKeys: JavaUtilArrayList! = JavaUtilArrayList()
    
    var isFilter = false //是否是进行筛选的搜索
    
    var filterStartTime = ""
    var filterEndTime = ""
    
    @IBOutlet var sendBtn: UIButton!
    @IBOutlet weak var contentTableView: UITableView!
    @IBOutlet weak var titleTableView: UITableView!
    var isEditStatus = false
    var selectedItem = -1
    var selectedSection = -1
    var isFromChart = false
    var shareRecord:ComFqHalcyonEntityPracticeRecordAbstract?
    var sharePatient:ComFqHalcyonEntityPracticePatientAbstract?
    
    var selectItem = -1
    var sectionCount = 0
    
    
    //去身份化
    var didSendInfo:Bool = true
    var dialog1 = CustomIOS7AlertView()
    var imgView:UIImageView!
    
    var count:Int32 = 0
    var saveloadingDialog:CustomIOS7AlertView!
    override func viewDidLoad() {
        super.viewDidLoad()
        imgView = UIImageView()
        titleTableView.scrollEnabled = false
        setTittle("搜索")
        setRightBtnTittle("筛选")
        if(isFromChart){
            contentTableView.frame = CGRectMake(80, 44, ScreenWidth - 80 , 506)
            titleTableView.frame = CGRectMake(0, 44, 80, 506)
        }else{
            sendBtn.hidden = true
        }
        contentTableView.registerNib(UINib(nibName: "PatientViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PatientViewCell")
        contentTableView.registerNib(UINib(nibName: "RecordViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "RecordViewCell")
        titleTableView.registerNib(UINib(nibName: "CheckTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "CheckTableViewCell")
        searchView.text = searchKey
        patientsList = JavaUtilArrayList()
        recordsList = JavaUtilArrayList()
        
        historyKeys = ComFqHalcyonPracticeSearchHistoryManager.getInstance().getKeys()
        count = historyKeys.size() < 5 ? historyKeys.size(): 5
        subTableView.frame = CGRectMake(0, 114, ScreenWidth, (ScreenHeight / 22.5) * CGFloat(count))
        subTableView.backgroundColor = UIColor.lightGrayColor()
        //调用搜索接口
        startSearchLogic(1,searchKey: searchKey)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "getFilterResult:", name: "GetFilterResult", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "dataHasChanged:", name: "DataHasChanged", object: nil)
        isFromSearch = true
    }
    
    override func viewWillAppear(animated: Bool) {
        isFromSearch = true
    }
    
    override func onRightBtnOnClick(sender: UIButton) {
        let control = FilterViewController()
        control.filtersList = self.filtersList
        control.filterStartTime = filterStartTime
        control.filterEndTime = filterEndTime
        self.navigationController?.pushViewController(control, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func getXibName() -> String {
        return "SearchViewController"
    }
    
    override func viewDidAppear(animated: Bool) {
        subTableView.frame = CGRectMake(0, 114, ScreenWidth, (ScreenHeight / 22.5) * CGFloat(count))
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == titleTableView || tableView == contentTableView {
            if sectionCount == 2{
                if section == 0{
                    return Int(patientsList.size()) > 5 ? 5 : Int(patientsList.size())
                }else{
                    return Int(recordsList.size()) > 5 ? 5 : Int(recordsList.size())
                }
            }else if sectionCount == 1{
                if patientsList.size() > 0{
                    return Int(patientsList.size()) > 5 ? 5 : Int(patientsList.size())
                }else if recordsList.size() > 0{
                    return Int(recordsList.size()) > 5 ? 5 : Int(recordsList.size())
                }
            }
        }
        return Int(count)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == contentTableView {
            if indexPath.section == 0 {
                let contentCell = tableView.dequeueReusableCellWithIdentifier("PatientViewCell") as! PatientViewCell
                contentCell.setFromChart(isFromChart)
                if(patientsList != nil){
                    if(indexPath.row < (Int(patientsList.size()) > 5 ? 5 : Int(patientsList.size()))){
                        contentCell.initData(patientsList.getWithInt(Int32(indexPath.row)) as! ComFqHalcyonEntityPracticePatientAbstract, indexPath: indexPath, event: self, isCanSliding: !isFromChart)
                        
                        _ = patientsList.getWithInt(Int32(indexPath.row)).getPatientId()
                        _ = patientsList.getWithInt(Int32(indexPath.row)).getUpdateTime()
                        //                        var isOffline = false
                        //                        var status = OfflineManager.instance.getPatientStatus(Int64(patientId), updateTime: updateTime)
                        //
                        //                        if status == OfflineStats.Updated {
                        //                            isOffline = true
                        //                        }
                        //                        contentCell.hiddenBtnDown(isOffline)
                        
                        return contentCell
                    }
                    
                }
                
                
                let contentCell1 = tableView.dequeueReusableCellWithIdentifier("RecordViewCell") as! RecordViewCell
                if(recordsList != nil){
                    if(indexPath.row < (Int(recordsList.size()) > 5 ? 5 : Int(recordsList.size()))){
                        contentCell1.initData(recordsList.getWithInt(Int32(indexPath.row)) as! ComFqHalcyonEntityPracticeRecordAbstract, indexPath: indexPath, event: self, isCanSliding: !isFromChart)
                        let RecordId = (recordsList.getWithInt(Int32(indexPath.row)) as! ComFqHalcyonEntityPracticeRecordAbstract).getRecordItemId()
                        print("\(RecordId)")
                        return contentCell1
                    }
                }
                
            }else {
                let contentCell = tableView.dequeueReusableCellWithIdentifier("RecordViewCell") as! RecordViewCell
                if(recordsList != nil){
                    if(indexPath.row < (Int(recordsList.size()) > 5 ? 5 : Int(recordsList.size()))){
                        contentCell.initData(recordsList.getWithInt(Int32(indexPath.row)) as! ComFqHalcyonEntityPracticeRecordAbstract, indexPath: indexPath, event: self, isCanSliding: !isFromChart)
                        let RecordId = (recordsList.getWithInt(Int32(indexPath.row)) as! ComFqHalcyonEntityPracticeRecordAbstract).getRecordItemId()
                        print("\(RecordId)")
                    }
                }
                return contentCell
            }
            return UITableViewCell()
            
        }
        else if tableView == titleTableView{
            let cells = tableView.dequeueReusableCellWithIdentifier("CheckTableViewCell") as! CheckTableViewCell
            if isFromChart {
                cells.iconBtn.hidden = false
                if(indexPath.row == selectedItem && indexPath.section == selectedSection){
                    cells.iconBtn.image = UIImage(named: "friend_select.png")
                }else{
                    cells.iconBtn.image = UIImage(named: "friend_unselect.png")
                }
            }else{
                cells.iconBtn.hidden = true
            }
            
            return cells
        }else  {
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
        
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRectMake(2, 0, 60, tableView.sectionHeaderHeight))
        let icon = UIImageView(frame: CGRectMake(10, 9, 25, 25))
        let label = UILabel(frame: CGRectMake(37, 7, 120, 30))
        if(tableView == titleTableView){
            if sectionCount == 2 {
                if section == 0 {
                    label.text = "病案"
                    icon.image = UIImage(named: "ic_patient.png")
                }else if section == 1 {
                    label.text = "记录"
                    icon.image = UIImage(named: "ic_record_item.png")
                }
            }else{
                if patientsList.size() > 0 {
                    label.text = "病案"
                    icon.image = UIImage(named: "ic_patient.png")
                }else if recordsList.size() > 0{
                    label.text = "记录"
                    icon.image = UIImage(named: "ic_record_item.png")
                }
            }
            view.addSubview(icon)
            view.addSubview(label)
            return view
        }
        let norView = UIView(frame: CGRectMake(0, 0, ScreenWidth, tableView.sectionHeaderHeight))
        return norView
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = PatientSearchCellFooterView(frame: CGRectMake(0, 0, ScreenWidth, tableView.sectionFooterHeight))
        view.tag = section
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "footTapGesture:"))
        
        if(tableView == contentTableView){
            if sectionCount == 2 {
                if section == 0 {
                    if patientsList.size() > 5 {
                        view.hidden = false
                    }else{
                        view.hidden = true
                    }
                }else{
                    if recordsList.size() > 5 {
                        view.hidden = false
                    }else{
                        view.hidden = true
                    }
                }
            }else{
                if patientsList.size() != 0 {
                    if patientsList.size() > 5 {
                        view.hidden = false
                    }else{
                        view.hidden = true
                    }
                }else{
                    if recordsList.size() > 5 {
                        view.hidden = false
                    }else{
                        view.hidden = true
                    }
                }
            }
            return view
        }else{
            let titleView = UIView(frame: CGRectMake(0, 0, ScreenWidth, tableView.sectionFooterHeight))
            return titleView
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tableView == subTableView {
            return ScreenHeight/22.5
        }
        return 105
    }
    
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if tableView == subTableView {
            return 0
        }
        return 24
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if(tableView == subTableView){
            return 1
        }
        sectionCount = 0
        
        if patientsList.size() > 0 {
            sectionCount += 1
        }
        if recordsList.size() > 0 {
            sectionCount += 1
        }
        return sectionCount
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if(tableView == subTableView){
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            searchView.text =  cell?.textLabel!.text
            subTableView.removeFromSuperview()
            searchView.endEditing(true)
            startSearchLogic(1,searchKey: searchKey)
        }
        
        if(tableView == titleTableView){
            selectedSection = indexPath.section
            selectedItem = indexPath.row
            titleTableView.reloadData()
        }
    }
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == subTableView {
            return 0
        }else {
            return 44
        }
    }
    
    func footTapGesture(tapGesture:UITapGestureRecognizer){
        let curView = tapGesture.view
        let tag = curView!.tag as Int
        let control = MorePatientViewController()
        control.searchKey = self.searchKey
        if tag == 0 && patientsList.size() > 0{
            /**病案查看更多**/
            print(tag)
            if(self.isFromChart){
                control.isFromChart = self.isFromChart
            }
            control.isPatient = true
            control.patientsList = self.patientsList
            self.navigationController?.pushViewController(control, animated: true)
        }else {
            /**记录查看更多**/
            print(tag)
            if(self.isFromChart){
                control.isFromChart = self.isFromChart
            }
            control.recordsList = self.recordsList
            control.isPatient = false
            self.navigationController?.pushViewController(control, animated: true)
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if scrollView == contentTableView {
            self.titleTableView.setContentOffset(self.contentTableView.contentOffset, animated: false)
        }
    }
    
    
    
    /**弹出去身份化dialog   在xib里连接**/
    @IBAction func showCheckDialog(sender:AnyObject?){
        if(selectedItem != -1){
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
        if  patientsList.size() == 0 {
            shareRecord = recordsList.getWithInt(Int32(selectedItem)) as? ComFqHalcyonEntityPracticeRecordAbstract
            
            
            if shareIsGroup {
                let sendPatientLogic = ComFqHalcyonLogicPracticeSendPatientLogic()
                sendPatientLogic.sendRecordToGroupWithComFqHalcyonLogicPracticeSendPatientLogic_SendRecordInterface(self, withNSString: shareGroupId, withInt: shareRecord!.getRecordItemId(),withComFqHalcyonEntityPracticeRecordAbstract:shareRecord,withInt:isRemoveIdentity)
            }else {
                let sendPatientLogic = ComFqHalcyonLogicPracticeSendPatientLogic()
                sendPatientLogic.sendRecordToUserWithComFqHalcyonLogicPracticeSendPatientLogic_SendRecordInterface(self, withInt: shareUserId, withInt: shareRecord!.getRecordItemId(),withComFqHalcyonEntityPracticeRecordAbstract:shareRecord,withInt:isRemoveIdentity)
            }
            
            
        }else{
            if selectedSection == 0 {
                sharePatient = patientsList.getWithInt(Int32(selectedItem)) as? ComFqHalcyonEntityPracticePatientAbstract
                
                if shareIsGroup {
                    let sendPatientLogic = ComFqHalcyonLogicPracticeSendPatientLogic()
                    sendPatientLogic.sendPatientToGroupWithComFqHalcyonLogicPracticeSendPatientLogic_SendPatientInterface(self, withNSString: shareGroupId, withInt: sharePatient!.getPatientId(),withComFqHalcyonEntityPracticePatientAbstract:sharePatient,withInt:isRemoveIdentity)
                }else{
                    let sendPatientLogic = ComFqHalcyonLogicPracticeSendPatientLogic()
                    sendPatientLogic.sendPatientToUserWithComFqHalcyonLogicPracticeSendPatientLogic_SendPatientInterface(self, withInt: shareUserId, withInt: sharePatient!.getPatientId(),withComFqHalcyonEntityPracticePatientAbstract:sharePatient,withInt:isRemoveIdentity)
                }
                
                
            }else{
                shareRecord = recordsList.getWithInt(Int32(selectedItem)) as? ComFqHalcyonEntityPracticeRecordAbstract
                
                
                if shareIsGroup {
                    let sendPatientLogic = ComFqHalcyonLogicPracticeSendPatientLogic()
                    sendPatientLogic.sendRecordToGroupWithComFqHalcyonLogicPracticeSendPatientLogic_SendRecordInterface(self, withNSString: shareGroupId, withInt: shareRecord!.getRecordItemId(),withComFqHalcyonEntityPracticeRecordAbstract:shareRecord,withInt:isRemoveIdentity)
                }else {
                    let sendPatientLogic = ComFqHalcyonLogicPracticeSendPatientLogic()
                    sendPatientLogic.sendRecordToUserWithComFqHalcyonLogicPracticeSendPatientLogic_SendRecordInterface(self, withInt: shareUserId, withInt: shareRecord!.getRecordItemId(),withComFqHalcyonEntityPracticeRecordAbstract:shareRecord,withInt:isRemoveIdentity)
                }
                
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
        
        var chartEntity = ComFqHalcyonEntityChartEntity()
        chartEntity = ComFqHalcyonEntityChartEntity()
        chartEntity.setSharePatientEntityWithComFqHalcyonEntityPracticePatientAbstract(obj, withInt: sharePatientId, withInt: shareMessageId)
        shareChatEntityList.addWithId(chartEntity)
        saveloadingDialog?.close()
        let index = self.navigationController?.viewControllers.count
        self.navigationController?.viewControllers.removeAtIndex( index! - 2 )
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
        obj.setIsShowIdentityWithBoolean(didSendInfo)
        for m in 0..<shareRecordInfIds.length() {
            let chartEntity = ComFqHalcyonEntityChartEntity()
            chartEntity.setRecordInfoIdWithInt(shareRecordInfIds.optIntWithInt(m))
            
            chartEntity.setShareRecordEntityWithComFqHalcyonEntityPracticeRecordAbstract(obj, withInt: shareRecordItemId, withInt: shareMessageId)
            shareChatEntityList.addWithId(chartEntity)
        }
        saveloadingDialog?.close()
        
        let index = self.navigationController?.viewControllers.count
        self.navigationController?.viewControllers.removeAtIndex( index! - 2 )
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    
    //调用搜索接口的方法
    func startSearchLogic(page:Int32,searchKey:String){
        setParams(page, searchKey: searchKey, searchFilter: nil,isFilter:false)
    }
    
    
    func setParams(page:Int32,searchKey:String,searchFilter:JavaUtilArrayList?,isFilter:Bool){
        params = ComFqHalcyonEntityPracticeSearchParams()
        self.isFilter = isFilter
        if isFilter {
            params.setNeedFiltersWithInt(1)
            if filterStartTime != "" {
                let start = changeDateFormat(filterStartTime)
                params.setFromDataWithNSString(start)
            }else{
                params.setFromDataWithNSString("")
            }
            
            if filterEndTime != "" {
                let end = changeDateFormat(filterEndTime)
                params.setToDataWithNSString(end)
            }else{
                params.setToDataWithNSString("")
            }
            
        }else{
            params.setNeedFiltersWithInt(0)
        }
        params.setResponseTypeWithInt(0)
        params.setKeyWithNSString(searchKey)
        params.setPageWithInt(page)
        params.setPageSizeWithInt(20)
        if(searchFilter != nil){
            params.setFiltersWithJavaUtilArrayList(searchFilter)
        }
        searchLogic = ComFqHalcyonLogicPracticeSearchLogic(comFqHalcyonLogicPracticeSearchLogic_SearchCallBack: self)
        loadingDialog = UIAlertViewTool.getInstance().showLoadingDialog("搜索中...")
        searchLogic.searchWithComFqHalcyonEntityPracticeSearchParams(params)
    }
    
    
    //搜索成功的回调
    func searchRetrunDataWithJavaUtilArrayList(patients: JavaUtilArrayList!, withJavaUtilArrayList records: JavaUtilArrayList!, withJavaUtilArrayList filters: JavaUtilArrayList!) {
        patientsList = patients
        recordsList = records
        
        if !isFilter {
            filtersList = filters
        }
        
        selectedItem = -1
        selectedSection = -1
        loadingDialog?.close()
        historyKeys = ComFqHalcyonPracticeSearchHistoryManager.getInstance().getKeys()
        count = historyKeys.size() < 5 ? historyKeys.size(): 5
        subTableView.frame = CGRectMake(0, 114, ScreenWidth, (ScreenHeight / 22.5) * CGFloat(count))
        subTableView.reloadData()
        contentTableView.reloadData()
        titleTableView.reloadData()
        searchView.endEditing(true)
    }
    
    //搜索失败的回调
    func searchErrorWithInt(code: Int32, withNSString msg: String!) {
        loadingDialog?.close()
//        self.view.makeToast("搜索病案/病历记录失败！")
        FQToast.makeError().show("搜索病案/病历记录失败！", superview: self.view)
        
    }
    
    /*实现RecordPatientEvent方法*/
    
    func onRPItemStruct(indexPath: NSIndexPath!) {
        
    }
    
    func onRPItemShare(indexPath: NSIndexPath!) {
        
    }
    
    func onRPItemRemove(indexPath: NSIndexPath!) {
        let sectionNum = indexPath.section
        let rowNum = indexPath.row
        
        if sectionNum == 0 {
            patientsList.removeWithInt(Int32(rowNum))
        }else if sectionNum == 1 {
            recordsList.removeWithInt(Int32(rowNum))
        }
        contentTableView.reloadData()
        titleTableView.reloadData()
    }
    
    func onRPItemRecover(indexPath: NSIndexPath!) {
        
    }
    
    func onRPItemCloud(indexPath: NSIndexPath!) {
        
    }
    
    func onRPItemClick(indexPath: NSIndexPath!) {
        
    }
    
    func onRPItemClear(indexPath: NSIndexPath!) {
        
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
    
    //搜索框search事件
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.endEditing(true)
        if searchBar.text!.isEmpty {
            return
        }
        searchKey = searchBar.text
        startSearchLogic(1,searchKey: searchKey)
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.view.addSubview(subTableView)
        subTableView.reloadData()
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        subTableView.removeFromSuperview()
    }
    
    /**用于接受过滤条件*/
    func getFilterResult(notify:NSNotification) {
        let filterResult = notify.object as! JavaUtilArrayList
        let userInfo:Dictionary<String,String!> = notify.userInfo as! Dictionary<String,String!>
        let startTime = userInfo["startTime"]
        let endTime = userInfo["endTime"]
        self.filterStartTime = startTime ?? ""
        self.filterEndTime = endTime ?? ""
        setParams(1, searchKey: searchKey, searchFilter: filterResult,isFilter:true)
    }
    
    //当查看更多的界面有删除操作时执行
    func dataHasChanged(notification:NSNotification){
        let hasModify = notification.object as! Bool
        if hasModify {
            patientsList.clear()
            recordsList.clear()
            startSearchLogic(1,searchKey: searchKey)
        }
    }
    
    //转换时间格式
    func changeDateFormat(date:String) -> String{
        var time = (date as NSString).substringToIndex(4)
        time += "-"
        time += (date as NSString).substringWithRange(NSMakeRange(5, 2))
        time += "-"
        time += (date as NSString).substringWithRange(NSMakeRange(8, 2))
        time += " 00"
        return time
    }
}


