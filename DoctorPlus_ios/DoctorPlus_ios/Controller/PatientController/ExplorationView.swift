//
//  ExplorationView.swift
//  DoctorPlus_ios
//
//  Created by monkey on 15-7-16.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class ExplorationView: UIView ,UITableViewDataSource,UITableViewDelegate,RecordPatientEvent,ComFqHalcyonLogicPracticePatientUpdateListLogic_PatientListCallback,ComFqHalcyonLogicPracticeRecycleLogic_Remove2RecycleCallBack{
    
    
    @IBOutlet weak var verLabel: UILabel!
    @IBOutlet weak var timeTableView: UITableView!
    @IBOutlet weak var contentTableView: UITableView!
    @IBOutlet weak var activityIndView: UIActivityIndicatorView!
    @IBOutlet weak var refurbishBtn: UIButton!
    
    
    var tableDatas = Dictionary<String,Array<ComFqHalcyonEntityPracticePatientAbstract>>()
    var timeTitles = ["今日","昨日","一周","更早"]
    var timeTableDatas = Array<String>()
    var isEditStatus = false
    var navigationController:UINavigationController?
    
    var isOutlineDatas = false //判断是否是离线数据
    var isHomePage = false //判断是否是主页加载数据
    var page = 1
    var pageSize = 20
    
    var SHOW_TABLE = 0;
    var SHOW_ACTIVITY_IND_VIEW = 1;
    var SHOW_REFURBISH_BUTTON = 2;
    
    var indetifyDialog:IndetifyDialog!
    var didSendInfo = true
    
    var patientListLogic:ComFqHalcyonLogicPracticePatientUpdateListLogic?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("ExplorationView", owner: self, options: nil)
        let view = nibs.lastObject as! UIView
        contentTableView.registerNib(UINib(nibName: "PatientViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PatientViewCell")
        timeTableView.registerNib(UINib(nibName: "CheckboxTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "CheckboxTableViewCell")
        
        view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height)
        self.addSubview(view)
        
        timeTableView.scrollEnabled = false
        verLabel.hidden = false
        
        if tableDatas.count > 0 {
            isShowNoticeLabel(false)
        }else{
            isShowNoticeLabel(true)
        }
        
        setTableViewRefresh()

        setViewShowOrHidden(SHOW_TABLE)
        
        patientListLogic = ComFqHalcyonLogicPracticePatientUpdateListLogic(comFqHalcyonLogicPracticePatientUpdateListLogic_PatientListCallback: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViewShowOrHidden(ctrlStyle:Int){
        switch ctrlStyle {
        case SHOW_TABLE:
            
            timeTableView.hidden = false
            contentTableView.hidden = false
            activityIndView.hidden = true
            refurbishBtn.hidden = true
            activityIndView.stopAnimating()
            
        case SHOW_ACTIVITY_IND_VIEW:
            
            timeTableView.hidden = true
            contentTableView.hidden = true
            activityIndView.hidden = false
            refurbishBtn.hidden = true
            activityIndView.startAnimating()
            
        case SHOW_REFURBISH_BUTTON:
            
            timeTableView.hidden = true
            contentTableView.hidden = true
            activityIndView.hidden = true
            refurbishBtn.hidden = false
            activityIndView.stopAnimating()
            
        default:
            
            activityIndView.stopAnimating()
            print("out of ctrl!")
        }
    }
    
    /**设置数据*/
    func setDatas(isOutlineDatas:Bool){
        
        self.isOutlineDatas = isOutlineDatas
        getPatientListLogic()
    }
    
    func cleanDatas(){
        page = 1
        tableDatas = Dictionary<String,Array<ComFqHalcyonEntityPracticePatientAbstract>>()
        timeTableDatas = Array<String>()
        timeTableView.reloadData()
        contentTableView.reloadData()
    }
    
    /**设置历史数据*/
    func setListDatas(datas:JavaUtilHashMap){
        for item in timeTitles {
            if datas.containsKeyWithId(item) {
                
                let array = datas.getWithId(item) as! JavaUtilArrayList
                var tmpArray = Array<ComFqHalcyonEntityPracticePatientAbstract>()
                
                for var i:Int32 = 0 ; i < array.size() ; i++ {
                    tmpArray.append(array.getWithInt(i) as! ComFqHalcyonEntityPracticePatientAbstract)
                }
                
                if tmpArray.count > 0 {
                    if let tDatas = tableDatas[item] {
                        var notExistArray = Array<ComFqHalcyonEntityPracticePatientAbstract>()
                        for patient in tmpArray {
                            var isExist = false
                            for (index,data) in tDatas.enumerate() {
                                if data.getPatientId() == patient.getPatientId() {
                                    tableDatas[item]![index] = patient
                                    isExist = true
                                    break
                                }
                            }
                            if !isExist {
                                notExistArray.append(patient)
                            }
                        }
                        tableDatas[item]! += notExistArray
                    }else{
                        tableDatas[item] = tmpArray
                        timeTableDatas.append(item)
                    }
                }
            }
        }
        timeTableView.reloadData()
        contentTableView.reloadData()
    }
    
    /**获取病案列表的逻辑*/
    func getPatientListLogic(){
        if page == 1 {
            setViewShowOrHidden(SHOW_ACTIVITY_IND_VIEW)
        }
        patientListLogic!.requestPatientListWithInt(Int32(page), withInt: Int32(pageSize))
    }
    
    /**删除病案到回收站*/
    func delPatientListLogic(patientList:JavaUtilArrayList?){
        
        if isOutlineDatas {
            //如果是离线数据
            for var i:Int32 = 0 ; i < patientList?.size() ; i++ {
                let id = patientList?.getWithInt(i).getPatientId()
                if let patientId = id {
                    OfflineManager.instance.delete(CacheType.Patients, id: Int64(patientId))
                }
            }
            removeSuccess()
        }else{
            let logic = ComFqHalcyonLogicPracticeRecycleLogic(comFqHalcyonLogicPracticeRecycleLogic_Remove2RecycleCallBack: self)
            logic.removePatientDataWithJavaUtilArrayList(patientList)
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == contentTableView {
            let patient = tableDatas[timeTableDatas[indexPath.section]]![indexPath.row]
            let cell = tableView.dequeueReusableCellWithIdentifier("PatientViewCell") as! PatientViewCell
            
            cell.initData(patient, indexPath: indexPath, event: self,isCanSliding:!isEditStatus)
            
            if isEditStatus {
                cell.setCanSliding(false)
            }else{
                cell.setCanSliding(true)
            }
            
            //TODO==YY==这个挪到cell里面
//            //设置是否有离线数据
//            let hasOffline = isHaveCache(Int(patient.getPatientId()))
//            cell.setOfflineIconVisibly(hasOffline)
//            //设置是否有更新数据
//            let isUpdate = getPatientStatus(Int(patient.getPatientId()), patient.getUpdateTime()) == OfflineStats.Update
//            cell.setUpdateIconVisibly(isUpdate)
            
            return cell
        }else if tableView == timeTableView{
            let cell = tableView.dequeueReusableCellWithIdentifier("CheckboxTableViewCell") as! CheckboxTableViewCell
            
            if isEditStatus {
                cell.checkboxImage.hidden = false
                let item = tableDatas[timeTableDatas[indexPath.section]]![indexPath.row]
                if item.isSelected() {
                    cell.checkboxImage.image = UIImage(named: "friend_select.png")
                }else{
                    cell.checkboxImage.image = UIImage(named: "friend_unselect.png")
                }
            }else{
                cell.checkboxImage.hidden = true
            }
            
            return cell
        }
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tableDatas[timeTableDatas[section]]!.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == self.timeTableView {
            let headView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 30))
            headView.backgroundColor = UIColor.whiteColor()
            let nameLabel = UILabel(frame: CGRectMake(0, 0, tableView.frame.size.width, 30))
            nameLabel.textAlignment = NSTextAlignment.Center
            nameLabel.textColor = Color.color_time_label
            nameLabel.font = UIFont.boldSystemFontOfSize(14)
            headView.addSubview(nameLabel)
            
            nameLabel.text = timeTableDatas[section]
            
            return headView
        }else{
            let headView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 30))
            
            return headView
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tableDatas.count
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if scrollView == contentTableView {
            self.timeTableView.setContentOffset(self.contentTableView.contentOffset, animated: false)
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == timeTableView {
            if isEditStatus {
                var cell = tableView.dequeueReusableCellWithIdentifier("CheckboxTableViewCell") as! CheckboxTableViewCell
                let item = tableDatas[timeTableDatas[indexPath.section]]![indexPath.row]
                if item.isSelected() {
                    item.setSelectedWithBoolean(false)
                }else{
                    item.setSelectedWithBoolean(true)
                }
                timeTableView.reloadData()
            }
        }
    }
    
    
    /**回收站item被删除*/
    func onRPItemClear(indexPath: NSIndexPath!) {
        
    }
    
    /**点击某个item的回调*/
    func onRPItemClick(indexPath: NSIndexPath!) {
        
    }
    
    /**回收站item被恢复*/
    func onRPItemRecover(indexPath: NSIndexPath!) {
        
    }
    
    /**删除某个item的回调*/
    func onRPItemRemove(indexPath: NSIndexPath!) {
        let title = timeTableDatas[indexPath.section]
        tableDatas[title]?.removeAtIndex(indexPath.row)
        
        if tableDatas[title]?.count == 0 {
            tableDatas[title] = nil
            for (index,txt) in timeTableDatas.enumerate() {
                if txt == title {
                    timeTableDatas.removeAtIndex(index)
                    break
                }
            }
        }
        timeTableView.reloadData()
        contentTableView.reloadData()
    }
    
    /**分享某个item的回调*/
    func onRPItemShare(indexPath: NSIndexPath!) {
        
    }
    
    /**结构化某个item的回调*/
    func onRPItemStruct(indexPath: NSIndexPath!) {
        
    }
    
    func onRPItemCloud(indexPath: NSIndexPath!) {
        
    }
    
    /**得到选中的记录*/
    func getSelectedDatas() -> JavaUtilArrayList {
        
        let selectedArray = JavaUtilArrayList()
        
        for (key,itemList) in tableDatas {
            for item in itemList {
                if item.isSelected() {
                    selectedArray.addWithId(item)
                }
            }
        }
        
        return selectedArray
    }
    
    /**批量删除数据*/
    func delDatas(){
        
        let array = getSelectedDatas()
        let count = array.size()
        if count == 0 {
            return
        }
        
        delPatientListLogic(array)
    }
    
    /**批量分享数据*/
    func shareDatas(){
        if getSelectedDatas().size() == 0 {
            return
        }
        indetifyDialog = UIAlertViewTool.getInstance().showRemoveIndetifyDialog(didSendInfo, target: self, actionOk: "dialogOk", actionCancle: "dialogCancle", actionRemoveIndentify: "xieyi", selecBtn: "click")
        
    }
    
    //确认分享
    func dialogOk(){
        let controller = MoreChatListViewController()
        controller.type = 2;
        controller.patientList = getSelectedDatas()
        controller.didSendInfo = didSendInfo;
        Tools.getCurrentViewController(self).navigationController?.pushViewController(controller, animated: true)
        indetifyDialog.alertView?.close()
        didSendInfo = true
        //
    }
    //取消分享
    func dialogCancle(){
        indetifyDialog.alertView?.close()
    }
    //查看协议
    func xieyi(){
        indetifyDialog.alertView?.close()
        Tools.getCurrentViewController(self).navigationController?.pushViewController(ProtocolViewController() , animated: true)
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
    
    
    /**当没有数据时显示提示的label，否则不显示*/
    func isShowNoticeLabel(show:Bool){
        if show {
            timeTableView.hidden = true
            contentTableView.hidden = true
        }else{
            timeTableView.hidden = false
            contentTableView.hidden = false
        }
    }
    
    /**清除所有的选中状态*/
    func cleanAllSelectedStatus(){
        for (key,arrayList) in tableDatas {
            for item in arrayList {
                if item.isSelected() {
                    item.setSelectedWithBoolean(false)
                }
            }
        }
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
        
        if isHomePage {
            NSNotificationCenter.defaultCenter().postNotificationName("changePage", object: nil)
        }else{
            
            if !isOutlineDatas {
                getPatientListLogic()
            }
            
        }
        // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
        contentTableView.footerEndRefreshing()
    }
    
    /**获取病案列表失败的回调*/
    func loadPatientErrorWithInt(code: Int32, withNSString msg: String!) {
        if  tableDatas.count > 0 {
            setViewShowOrHidden(SHOW_TABLE)
            return
        }
        
        if page == 1 && !isHomePage {
            setViewShowOrHidden(SHOW_REFURBISH_BUTTON)
            refurbishBtn.setTitle("获取失败，点击刷新", forState: UIControlState.Normal)
        }
    }
    
    /**获取病案列表成功的回调*/
    func loadPatientSuccessWithJavaUtilArrayList(keys: JavaUtilArrayList!, withJavaUtilHashMap map: JavaUtilHashMap!) {
        if page == 1 && !isHomePage {
            if map.size() > 0 {
                setViewShowOrHidden(SHOW_TABLE)
            }else{
                setViewShowOrHidden(SHOW_REFURBISH_BUTTON)
                refurbishBtn.setTitle("暂无数据，点击刷新", forState: UIControlState.Normal)
            }
        }
        
        if map.size() > 0 {
            let oldPage = patientListLogic?.getPage() ?? Int32(page)
            page = Int(oldPage) + 1
            setListDatas(map)
        }
    }
    
    @IBAction func refurbishBtnClick(sender: AnyObject) {
        if isHomePage {
             NSNotificationCenter.defaultCenter().postNotificationName("refurbishBtnClick", object: nil)
        }else{
            getPatientListLogic()
        }
        
    }
    
    func reloadTable(){
        timeTableView.reloadData()
        contentTableView.reloadData()
    }
    
    //批量删除成功之后更新UI
    func removeSuccess() {
        let array = getSelectedDatas()
        let count = array.size()
        if count == 0 {
            return
        }
        for var i:Int32 = 0 ; i < count; i++ {
            let item = array.getWithInt(i) as! ComFqHalcyonEntityPracticePatientAbstract
            for (key,itemList) in tableDatas {
                var isExist = false
                for (index,value) in itemList.enumerate() {
                    if value.getPatientId() == item.getPatientId() {
                        tableDatas[key]!.removeAtIndex(index)
                        isExist = true
                        break
                    }
                }
                if isExist {
                    break
                }
            }
        }
        for (key,itemList) in tableDatas {
            if tableDatas[key]?.count == 0 {
                tableDatas[key] = nil
                for (index,item) in timeTableDatas.enumerate() {
                    if item == key {
                        timeTableDatas.removeAtIndex(index)
                        break
                    }
                }
            }
        }
        timeTableView.reloadData()
        contentTableView.reloadData()
    }
    
    func removeErrorWithInt(code: Int32, withNSString msg: String!) {
        
    }
}
