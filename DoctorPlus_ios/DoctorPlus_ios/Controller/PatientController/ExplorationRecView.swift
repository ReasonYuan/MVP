//
//  ExplorationRecView.swift
//  DoctorPlus_ios
//
//  Created by monkey on 15-7-19.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class ExplorationRecView: UIView,UITableViewDelegate,UITableViewDataSource,ComFqHalcyonLogicPracticeRecognitionLogic_RecognitionCallBack,ComFqHalcyonLogicPracticeRecycleLogic_RecycleCallBack,RecordPatientEvent,ComFqHalcyonLogicPracticeRecycleLogic_Remove2RecycleCallBack,ComFqHalcyonLogicPracticeRecordListLogic_RecordListCallBack,ComFqHalcyonLogicPracticeRecognitionLogic_ApplyRecognizeCallBack,ComFqHalcyonLogicPracticeSendPatientLogic_SendRecordInterface,ComFqHalcyonLogicPracticeSuffererListLogic_SuffererListCallBack{
    
    @IBOutlet weak var timeTableView: UITableView!
    @IBOutlet weak var contentTableView: UITableView!
    @IBOutlet weak var activityIndView: UIActivityIndicatorView!
    @IBOutlet weak var refurbishBtn: UIButton!
    @IBOutlet weak var scrollToUpBtn: UIButton!
    @IBOutlet weak var scrollToBottomBtn: UIButton!
    
    var countOfTable = 0
    var tableKeys = Array<String>()
    var tableDatas = Dictionary<String,Array<ComFqHalcyonEntityPracticeRecordAbstract>>()
    var trashDatas = Dictionary<String,Array<ComFqHalcyonEntityPracticeRecordData>>()
    
    var myPatientDatas = Dictionary<String,Array<ComFqHalcyonEntityPracticeSuffererAbstract>>()
    
    var isEditStatus = false //判断当前是否是编辑状态
    
    var isTrash = false //判断当前是否是回收站
    
    var recgnizeStatus:Int32 = 0 //识别状态，用于接口请求不同状态的数据
    
    var page = 1
    var pageSize = 20
    
    var patientItem:ComFqHalcyonEntityPracticePatientAbstract!
    var recordType:Int32 = 0 //当获取记录列表时判断当前选中的记录类型是什么
    
    var isPatientRecordList = false //判断是否是查看病例记录列表
    
    var isAddToHistory = false//判读是否在浏览记录时将这个病案添加进浏览历史记录
    var isShare = false //判断是否是分享界面过来的
    var isFromChart = false //判断是否是聊天界面点击分享过来的
    var SHOW_TABLE = 0;
    var SHOW_ACTIVITY_IND_VIEW = 1;
    var SHOW_REFURBISH_BUTTON = 2;
    
    
    var indetifyDialog:IndetifyDialog!
    var didSendInfo = true //是否发送身份信息
    
    var saveloadingDialog:CustomIOS7AlertView!
    var shareRecord:ComFqHalcyonEntityPracticeRecordAbstract?
    
    var isTop = true
    
    var isGetPatientName = false //判断是否已经获取过了病案的名字
    
    var isMyPatient = false //判断是不是我得患者（用于行医生涯中得显示做判断）
    var isMyPatientRecord = false //用于判断是否是查看我得患者的病例记录
    
    var isOfflinePatient = false  //判断是否是离线的病案
    
    //获取记录的逻辑
    var recordLogic:ComFqHalcyonLogicPracticeRecordListLogic?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("ExplorationRecView", owner: self, options: nil)
        let view = nibs.lastObject as! UIView
        view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height)
        self.addSubview(view)
        
        contentTableView.registerNib(UINib(nibName: "RecordViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "RecordViewCell")
        contentTableView.registerNib(UINib(nibName: "PatientViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PatientViewCell")
        contentTableView.registerNib(UINib(nibName: "SuffererViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "SuffererViewCell")
        timeTableView.registerNib(UINib(nibName: "CheckboxTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "CheckboxTableViewCell")
        timeTableView.scrollEnabled = false
        setTableViewRefresh()
        scrollToUpBtn.setBackgroundImage(UIImage(named: "pull_up_pressed_btn.png"), forState: UIControlState.Selected)
        scrollToUpBtn.setBackgroundImage(UIImage(named: "pull_up_unpressed_btn.png"), forState: UIControlState.Normal)
        scrollToBottomBtn.setBackgroundImage(UIImage(named: "pull_down_pressed_btn.png"), forState: UIControlState.Selected)
        scrollToBottomBtn.setBackgroundImage(UIImage(named: "pull_down_unpressed_btn.png"), forState: UIControlState.Normal)
        scrollToUpBtn.hidden = true
        scrollToBottomBtn.hidden = true
        setViewShowOrHidden(SHOW_TABLE)
        
        recordLogic = ComFqHalcyonLogicPracticeRecordListLogic(comFqHalcyonLogicPracticeRecordListLogic_RecordListCallBack: self)
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
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == contentTableView {
            if isTrash {
                
                let item = trashDatas[tableKeys[indexPath.section]]![indexPath.row] as ComFqHalcyonEntityPracticeRecordData
                if item.getCategory() == ComFqHalcyonEntityPracticeRecordData_CATEGORY_RECORD {
                    let contentCell = tableView.dequeueReusableCellWithIdentifier("RecordViewCell") as! RecordViewCell
                    contentCell.initDataForRecycle(item as! ComFqHalcyonEntityPracticeRecordAbstract, indexPath: indexPath, event: self)
                    contentCell.setCanSliding(!isEditStatus)
                    return contentCell
                }else if item.getCategory() == ComFqHalcyonEntityPracticeRecordData_CATEGORY_PATIENT {
                    let cell = tableView.dequeueReusableCellWithIdentifier("PatientViewCell") as! PatientViewCell
                    cell.initDataForRecycle(item as! ComFqHalcyonEntityPracticePatientAbstract, indexPath: indexPath, event: self)
                    cell.setCanSliding(!isEditStatus)
                    return cell
                }
                let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
                return cell
            }else{
                
                if isMyPatient {
                    let contentCell = tableView.dequeueReusableCellWithIdentifier("SuffererViewCell") as! SuffererViewCell
//                    contentCell.initData(data: ComFqHalcyonEntityPracticeRecordData, dexPath: <#NSIndexPath#>, event: nil)
                    contentCell.initData(myPatientDatas[tableKeys[indexPath.section]]![indexPath.row], dexPath:indexPath, event: nil)
                    contentCell.setCanSliding(false)
                    return contentCell
                }else{
                    let contentCell = tableView.dequeueReusableCellWithIdentifier("RecordViewCell") as! RecordViewCell
                    
                    if isMyPatientRecord {
                        contentCell.initData(tableDatas[tableKeys[indexPath.section]]![indexPath.row], indexPath: indexPath, event: self,isCanSliding:!isMyPatientRecord)
                    }else{
                        contentCell.initData(tableDatas[tableKeys[indexPath.section]]![indexPath.row], indexPath: indexPath, event: self,isCanSliding:!isShare)
                    }
                    if isEditStatus {
                        contentCell.setCanSliding(false)
                    }else if !isEditStatus && !isShare {
                        contentCell.setCanSliding(true)
                    }
                    contentCell.setOfflineStatus(isOfflinePatient)
                    return contentCell
                }
            }
            
        }else if tableView == timeTableView{
            let cell = tableView.dequeueReusableCellWithIdentifier("CheckboxTableViewCell") as! CheckboxTableViewCell
            
            if isEditStatus {
                cell.checkboxImage.hidden = false
                if isTrash {
                    let item = trashDatas[tableKeys[indexPath.section]]![indexPath.row]
                    setCheckBoxStyle(item.isSelected(), cell: cell)
                }else{
                    if isMyPatient {
                        let item = myPatientDatas[tableKeys[indexPath.section]]![indexPath.row]
                        setCheckBoxStyle(item.isSelected(), cell: cell)
                    }else{
                        let item = tableDatas[tableKeys[indexPath.section]]![indexPath.row]
                        setCheckBoxStyle(item.isSelected(), cell: cell)
                    }
                }
            }else{
                cell.checkboxImage.hidden = true
            }
            
            return cell
        }
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
        return cell
    }
    
    //设置checkboxCell选中和未选中时的显示
    func setCheckBoxStyle(isSelected:Bool,cell:CheckboxTableViewCell){
        
        if isSelected {
            if isFromChart {
                cell.checkboxImage.image = UIImage(named: "select_dot.png")
            }else{
                cell.checkboxImage.image = UIImage(named: "friend_select.png")
            }
            
        }else{
            if isFromChart {
                cell.checkboxImage.image = UIImage(named: "unselect_dot.png")
            }else{
                cell.checkboxImage.image = UIImage(named: "friend_unselect.png")
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isTrash {
            countOfTable = trashDatas[tableKeys[section]]!.count
            return trashDatas[tableKeys[section]]!.count
        }else{
            if isMyPatient {
                countOfTable = myPatientDatas[tableKeys[section]]!.count
                return myPatientDatas[tableKeys[section]]!.count
            }else{
                countOfTable = tableDatas[tableKeys[section]]!.count
                return tableDatas[tableKeys[section]]!.count
            }
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == timeTableView {
            if tableView.headerViewForSection(section) == nil {
                let view = ExplorationRecTimeCellHeadView(frame: CGRectMake(0, 0, tableView.frame.size.width, tableView.sectionHeaderHeight))
                let timeStr = tableKeys[section]
                if (timeStr as NSString).length >= 8 {
                    let year = timeStr.substringToIndex(timeStr.startIndex.advancedBy(4))
                    let month = (timeStr as NSString).substringWithRange(NSMakeRange(4, 2))
                    let day = (timeStr as NSString).substringWithRange(NSMakeRange(6, 2))
                    view.yearLabel.text = year
                    view.dayLabel.text = "\(month)/\(day)"
                }
                tableView.headerViewForSection(section)
                return view
            }else{
                return tableView.headerViewForSection(section)
            }
        }
        
        return UIView()
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.frame.height/55
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 100
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tableKeys.count
    }
    
    /**tableview滑动处理*/
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if scrollView == contentTableView {
            self.timeTableView.setContentOffset(self.contentTableView.contentOffset, animated: false)
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == timeTableView {
            if isEditStatus {
                var cell = tableView.dequeueReusableCellWithIdentifier("CheckboxTableViewCell") as! CheckboxTableViewCell
                if isTrash {
                    let item = trashDatas[tableKeys[indexPath.section]]![indexPath.row]
                    setItemStatus(item.isSelected(), item: item)
                }else{
                    if isMyPatient {
                        let item = myPatientDatas[tableKeys[indexPath.section]]![indexPath.row]
                        setItemStatus(item.isSelected(), item: item)
                    }else{
                        let item = tableDatas[tableKeys[indexPath.section]]![indexPath.row]
                        setItemStatus(item.isSelected(), item: item)
                    }
                }
                timeTableView.reloadData()
            }
        }
    }
    
    /**设置是否选中的状态*/
    func setItemStatus(isSelected:Bool,item:AnyObject){
        if isFromChart {
            cleanAllSelectedStatus()
        }
        if isSelected {
            item.setSelectedWithBoolean(false)
        }else{
            item.setSelectedWithBoolean(true)
        }
    }
    
    func cleanDatas(){
        page = 1
        tableKeys = Array<String>()
        tableDatas = Dictionary<String,Array<ComFqHalcyonEntityPracticeRecordAbstract>>()
        trashDatas = Dictionary<String,Array<ComFqHalcyonEntityPracticeRecordData>>()
        myPatientDatas = Dictionary<String,Array<ComFqHalcyonEntityPracticeSuffererAbstract>>()
        timeTableView.reloadData()
        contentTableView.reloadData()
    }
    
    func setDataKeys(keys:JavaUtilArrayList){
        for var i:Int32 = 0 ; i < keys.size() ; i++ {
            var isExist = false
            for item in tableKeys {
                if item == keys.getWithInt(i) as! String {
                    isExist = true
                    break
                }
            }
            if !isExist {
                tableKeys.append(keys.getWithInt(i) as! String)
            }
        }
    }
    
    /**设置非回收站数据*/
    func setDatas(keys:JavaUtilArrayList,datas:JavaUtilHashMap){
        
        setDataKeys(keys)
        
        for item in tableKeys {
            if datas.containsKeyWithId(item) {
                let array = datas.getWithId(item) as! JavaUtilArrayList
                var tmpArray = Array<ComFqHalcyonEntityPracticeRecordAbstract>()
                for var i:Int32 = 0 ; i < array.size() ; i++ {
                    tmpArray.append(array.getWithInt(i) as! ComFqHalcyonEntityPracticeRecordAbstract)
                }
                if let tDatas = tableDatas[item] {
                    var notExistArray = Array<ComFqHalcyonEntityPracticeRecordAbstract>()
                    for tmpItem in tmpArray {
                        var isExist = false
                        for (i,td) in tDatas.enumerate() {
                            if td.getRecordItemId() == tmpItem.getRecordItemId() {
                                isExist = true
                                tableDatas[item]![i] = tmpItem
                                break
                            }
                        }
                        if !isExist {
                            notExistArray.append(tmpItem)
                        }
                    }
                    tableDatas[item]! += notExistArray
                }else{
                    
                    tableDatas[item] = tmpArray
                }
            }
        }
        timeTableView.reloadData()
        contentTableView.reloadData()
    }
    
    /**设置我得患者数据*/
    func setMyPatientDatas(keys:JavaUtilArrayList,datas:JavaUtilHashMap){
        
        setDataKeys(keys)
        
        for item in tableKeys {
            if datas.containsKeyWithId(item) {
                let array = datas.getWithId(item) as! JavaUtilArrayList
                var tmpArray = Array<ComFqHalcyonEntityPracticeSuffererAbstract>()
                for var i:Int32 = 0 ; i < array.size() ; i++ {
                    tmpArray.append(array.getWithInt(i) as! ComFqHalcyonEntityPracticeSuffererAbstract)
                }
                if myPatientDatas[item] == nil {
                    myPatientDatas[item] = tmpArray
                }else{
                    myPatientDatas[item] = myPatientDatas[item]! + tmpArray
                }
            }
        }
        timeTableView.reloadData()
        contentTableView.reloadData()
    }
    
    /**设置回收站数据*/
    func setTrashDatas(keys: JavaUtilArrayList!, withJavaUtilHashMap datas: JavaUtilHashMap!){
        
        setDataKeys(keys)
        
        for item in tableKeys {
            if datas.containsKeyWithId(item) {
                let array = datas.getWithId(item) as! JavaUtilArrayList
                var tmpArray = Array<ComFqHalcyonEntityPracticeRecordData>()
                for var i:Int32 = 0 ; i < array.size() ; i++ {
                    tmpArray.append(array.getWithInt(i) as! ComFqHalcyonEntityPracticeRecordData)
                }
                if trashDatas[item] == nil {
                    trashDatas[item] = tmpArray
                }else{
                    trashDatas[item] = trashDatas[item]! + tmpArray
                }
            }
        }
        
        timeTableView.reloadData()
        contentTableView.reloadData()
    }
    
    
    /**得到选中的记录*/
    func getSelectedDatas() -> JavaUtilArrayList {
        
        let selectedArray = JavaUtilArrayList()
        if isTrash {
            for (key,itemList) in trashDatas {
                for item in itemList {
                    if item.isSelected() {
                        selectedArray.addWithId(item)
                    }
                }
            }
        }else{
            
            if isMyPatient {
                for (key,itemList) in myPatientDatas {
                    for item in itemList {
                        if item.isSelected() {
                            selectedArray.addWithId(item)
                        }
                    }
                }
            }else{
                for (key,itemList) in tableDatas {
                    for item in itemList {
                        if item.isSelected() {
                            selectedArray.addWithId(item)
                        }
                    }
                }
            }
        }
        return selectedArray
    }
    
    /**清除所有的选中状态*/
    func cleanAllSelectedStatus(){
        
        if isMyPatient {
            for (key,itemList) in myPatientDatas {
                for item in itemList {
                    if item.isSelected() {
                        item.setSelectedWithBoolean(false)
                    }
                }
            }
        }else{
            for (key,itemList) in tableDatas {
                for item in itemList {
                    if item.isSelected() {
                        item.setSelectedWithBoolean(false)
                    }
                }
            }
        }
    }
    
    /**批量删除数据*/
    func delDatas(){
        if getSelectedDatas().size() == 0 {
            return
        }
        if isTrash {
            let logic = ComFqHalcyonLogicPracticeRecycleLogic(comFqHalcyonLogicPracticeRecycleLogic_RecycleCallBack: self)
            logic.clearDataWithJavaUtilArrayList(getSelectedDatas())
        }else{
            
            if isOfflinePatient {
                let list = getSelectedDatas()
                for var i:Int32 = 0 ; i < list.size() ; i++ {
                    let id = list.getWithInt(i).getRecordItemId()
                    OfflineManager.instance.delete(CacheType.Records, id: Int64(id))
                }
                delTableDatas()
            }else{
                let logic = ComFqHalcyonLogicPracticeRecycleLogic(comFqHalcyonLogicPracticeRecycleLogic_Remove2RecycleCallBack: self)
                logic.removeRecordDataWithJavaUtilArrayList(getSelectedDatas())
            }
        }
    }
    
    /**批量分享数据*/
    func shareDatas(){
        
        if getSelectedDatas().size() == 0 {
//            self.makeToast("请选择需要分享的记录")
             FQToast.makeSystem().show("请选择需要分享的记录", superview: Tools.getCurrentViewController().view)
            return
        }
        
        if isFromChart {
            indetifyDialog = UIAlertViewTool.getInstance().showRemoveIndetifyDialog(didSendInfo, target: self, actionOk: "sendClick", actionCancle: "dialogCancle", actionRemoveIndentify: "xieyi", selecBtn: "click")
        }else{
            indetifyDialog = UIAlertViewTool.getInstance().showRemoveIndetifyDialog(didSendInfo, target: self, actionOk: "dialogOk", actionCancle: "dialogCancle", actionRemoveIndentify: "xieyi", selecBtn: "click")
        }
        
        
    }
    
    func sendClick(){
        
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
        let shareRecordList = getSelectedDatas()
        if shareRecordList.size() > 0 {
            shareRecord = shareRecordList.getWithInt(Int32(0)) as? ComFqHalcyonEntityPracticeRecordAbstract
            let sendPatientLogic = ComFqHalcyonLogicPracticeSendPatientLogic()
            if !shareIsGroup {
                sendPatientLogic.sendRecordToUserWithComFqHalcyonLogicPracticeSendPatientLogic_SendRecordInterface(self, withInt: shareUserId, withInt: shareRecord!.getRecordItemId(),withComFqHalcyonEntityPracticeRecordAbstract:shareRecord,withInt:isRemoveIdentity)
            }else {
                sendPatientLogic.sendRecordToGroupWithComFqHalcyonLogicPracticeSendPatientLogic_SendRecordInterface(self, withNSString: shareGroupId, withInt: shareRecord!.getRecordItemId(), withComFqHalcyonEntityPracticeRecordAbstract: shareRecord, withInt: isRemoveIdentity)
            }
        }
    }
    
    
    //确认分享
    func dialogOk(){
        let controller = MoreChatListViewController()
        controller.type = 3
        controller.recordList = getSelectedDatas()
        controller.didSendInfo = didSendInfo;
        Tools.getCurrentViewController(self).navigationController?.pushViewController(controller, animated: true)
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
    
    
    
    /**批量云识别数据*/
    func ocrDatas(){
        let logic = ComFqHalcyonLogicPracticeRecognitionLogic(comFqHalcyonLogicPracticeRecognitionLogic_ApplyRecognizeCallBack: self)
        logic.applyRecognizeWithJavaUtilArrayList(getSelectedDatas())
    }
    
    /**批量恢复数据*/
    func huifuDatas(){
        if getSelectedDatas().size() == 0 {
            return
        }
        let logic = ComFqHalcyonLogicPracticeRecycleLogic(comFqHalcyonLogicPracticeRecycleLogic_RecycleCallBack: self)
        logic.retoreDataWithJavaUtilArrayList(getSelectedDatas())
    }
    
    /**获取云识别或者等待云识别的数据
    recgnizeStatus:
    ComFqHalcyonLogicPracticeRecognitionLogic_REQUEST_RECGN_END：识别完成
    ComFqHalcyonLogicPracticeRecognitionLogic_REQUEST_RECGN_ING：识别中
    ComFqHalcyonLogicPracticeRecognitionLogic_REQUEST_RECGN_WAIT：等待识别
    ComFqHalcyonLogicPracticeRecognitionLogic_REQUEST_RECGN_ALL:请求全部
    isTrash:
    判断是否是回收站
    */
    func getRecRecordLogic(recgnizeStatus:Int32 = 0,isTrash:Bool = false,isMyPatient:Bool = false){
        self.isTrash = isTrash
        self.isMyPatient = isMyPatient
        if isTrash {
            getTrashItemLogic()
        }else{
            
            if isMyPatient {
                getMyPatientLogic()
            }else{
                self.recgnizeStatus = recgnizeStatus
                getrecordItemLogic()
            }
        }
        
    }
    
    /**获取我得患者列表的逻辑*/
    func getMyPatientLogic(){
        if page == 1 {
            setViewShowOrHidden(SHOW_ACTIVITY_IND_VIEW)
        }
        
        //TODO   暂未写获取患者列表的逻辑
        let logic = ComFqHalcyonLogicPracticeSuffererListLogic(comFqHalcyonLogicPracticeSuffererListLogic_SuffererListCallBack: self)
        logic.loadSufferersListWithInt(0)
    }
    
    //获取我得患者列表成功
    func suffererListCallbackWithJavaUtilArrayList(keys: JavaUtilArrayList!, withJavaUtilHashMap map: JavaUtilHashMap!) {
        if page == 1 {
            if map.size() > 0 {
                setViewShowOrHidden(SHOW_TABLE)
            }else{
                setViewShowOrHidden(SHOW_REFURBISH_BUTTON)
                refurbishBtn.setTitle("暂无数据，点击刷新", forState: UIControlState.Normal)
            }
            
        }
        if map.size() > 0 {
            setMyPatientDatas(keys,datas: map)
            page += 1
        }
    }
    
    //获取我得患者列表失败
    func suffererListCallbackErrorWithInt(code: Int32, withNSString msg: String!) {
        if page == 1 {
            setViewShowOrHidden(SHOW_REFURBISH_BUTTON)
            refurbishBtn.setTitle("获取失败，点击刷新", forState: UIControlState.Normal)
        }
    }
    
    /**获取非回收站的数据逻辑*/
    func getrecordItemLogic(){
        let logic = ComFqHalcyonLogicPracticeRecognitionLogic(comFqHalcyonLogicPracticeRecognitionLogic_RecognitionCallBack: self)
        logic.loadRecognitionListWithInt(recgnizeStatus, withInt: Int32(page), withInt: Int32(pageSize))
        if page == 1 {
            setViewShowOrHidden(SHOW_ACTIVITY_IND_VIEW)
        }
    }
    
    /**获取回收站的数据逻辑*/
    func getTrashItemLogic(){
        let logic = ComFqHalcyonLogicPracticeRecycleLogic(comFqHalcyonLogicPracticeRecycleLogic_RecycleCallBack: self)
        logic.loadRecyleListWithInt(Int32(page), withInt: Int32(pageSize))
        if page == 1 {
            setViewShowOrHidden(SHOW_ACTIVITY_IND_VIEW)
        }
    }
    
    /**获取云识别数据错误的回调*/
    func recognzeErrorWithInt(code: Int32, withNSString msg: String!) {
        if page == 1 {
            setViewShowOrHidden(SHOW_REFURBISH_BUTTON)
            refurbishBtn.setTitle("获取失败，点击刷新", forState: UIControlState.Normal)
        }
    }
    
    /**获取非回收站数据成功的回调*/
    func recognzeReturnDataWithJavaUtilArrayList(keys: JavaUtilArrayList!, withJavaUtilHashMap recordMap: JavaUtilHashMap!) {
        
        if page == 1 {
            if recordMap.size() > 0 {
                setViewShowOrHidden(SHOW_TABLE)
            }else{
                setViewShowOrHidden(SHOW_REFURBISH_BUTTON)
                refurbishBtn.setTitle("暂无数据，点击刷新", forState: UIControlState.Normal)
            }
            
        }
        if keys.size() > 0 {
            setDatas(keys,datas: recordMap)
            page += 1
        }
        
    }
    
    /**回收站item被删除*/
    func onRPItemClear(indexPath: NSIndexPath!) {
        delOneData(indexPath)
    }
    
    /**点击某个item的回调*/
    func onRPItemClick(indexPath: NSIndexPath!) {
        let item = tableDatas[tableKeys[indexPath.section]]![indexPath.row]
        //现在不用历史记录了，所以注销掉
        //        if(isPatientRecordList && !isAddToHistory){
        //            isAddToHistory = true
        //            var history = ComFqHalcyonPracticeReadHistoryManager.getInstance()
        //            history.addPatientAbsWithComFqHalcyonEntityPracticePatientAbstract(patientItem)
        //        }
        print("\(item.getRecordInfoId())")
    }
    
    /**回收站item被恢复*/
    func onRPItemRecover(indexPath: NSIndexPath!) {
        delOneData(indexPath)
    }
    
    /**删除某个item的回调*/
    func onRPItemRemove(indexPath: NSIndexPath!) {
        delOneData(indexPath)
    }
    
    /**分享某个item的回调*/
    func onRPItemShare(indexPath: NSIndexPath!) {
        
    }
    
    /**结构化某个item的回调*/
    func onRPItemStruct(indexPath: NSIndexPath!) {
        
    }
    
    /**云识别某个ITEM的回调*/
    func onRPItemCloud(indexPath: NSIndexPath!) {
        delOneData(indexPath)
    }
    
    /**获取回收站数据成功的回调*/
    func recycleDatasWithJavaUtilArrayList(keys: JavaUtilArrayList!, withJavaUtilHashMap recyDataMap: JavaUtilHashMap!) {
        if page == 1 {
            if recyDataMap.size() > 0 {
                setViewShowOrHidden(SHOW_TABLE)
            }else{
                setViewShowOrHidden(SHOW_REFURBISH_BUTTON)
                refurbishBtn.setTitle("暂无数据，点击刷新", forState: UIControlState.Normal)
            }
        }
        if keys.size() > 0 {
            setTrashDatas(keys,withJavaUtilHashMap: recyDataMap)
            page = page + 1
        }
    }
    
    /**
    * 从回收站清除数据成功后的回调方法
    */
    func recycelClearDataSuccess() {
        delTableDatas()
    }
    
    /**
    * 从回收站恢复数据成功后的回调方法
    */
    func recycelRestoreDataSuccess() {
        delTableDatas()
    }
    
    /**请求回收站操作服务器出错的回调*/
    func recycleErrorWithInt(code: Int32, withNSString msg: String!) {
        if page == 1 {
            setViewShowOrHidden(SHOW_REFURBISH_BUTTON)
            refurbishBtn.setTitle("获取失败，点击刷新", forState: UIControlState.Normal)
        }
    }
    
    /**删除记录到回收站成功的回调*/
    func removeSuccess() {
        delTableDatas()
    }
    
    /**删除记录到回收站失败的回调*/
    func removeErrorWithInt(code: Int32, withNSString msg: String!) {
//        self.makeToast("删除失败")
        FQToast.makeError().show("删除失败", superview: Tools.getCurrentViewController().view)
    }
    
    /**从array中删除选中的数据并跟新UI*/
    func delTableDatas(){
        if getSelectedDatas().size() == 0 {
            return
        }
        let selectedCount = getSelectedDatas().size()
        let array = getSelectedDatas()
        for var i:Int32 = 0 ; i < selectedCount; i++ {
            let tmp: ComFqHalcyonEntityPracticeRecordData! = array.getWithInt(i) as! ComFqHalcyonEntityPracticeRecordData
            for key in tableKeys {
                if isTrash {
                    let itemArray = trashDatas[key]!
                    for (index,item) in itemArray.enumerate() {
                        if tmp.getCategory() == ComFqHalcyonEntityPracticeRecordData_CATEGORY_RECORD{
                            let tmp = array.getWithInt(i) as! ComFqHalcyonEntityPracticeRecordAbstract
                            if item.getCategory() == ComFqHalcyonEntityPracticeRecordData_CATEGORY_RECORD {
                                if (item as! ComFqHalcyonEntityPracticeRecordAbstract).getRecordItemId() == tmp.getRecordItemId(){
                                    trashDatas[key]?.removeAtIndex(index)
                                    setKeyAndDatas(key)
                                    break
                                }
                            }
                        }else if tmp.getCategory() == ComFqHalcyonEntityPracticeRecordData_CATEGORY_PATIENT{
                            let tmp = array.getWithInt(i) as! ComFqHalcyonEntityPracticePatientAbstract
                            if item.getCategory() == ComFqHalcyonEntityPracticeRecordData_CATEGORY_PATIENT {
                                if (item as! ComFqHalcyonEntityPracticePatientAbstract).getPatientId() == tmp.getPatientId(){
                                    trashDatas[key]?.removeAtIndex(index)
                                    setKeyAndDatas(key)
                                    break
                                }
                            }
                        }
                    }
                }else{
                    if isMyPatient {
                        let itemArray = myPatientDatas[key]!
                        for (index,item) in itemArray.enumerate() {
                            if (tmp as! ComFqHalcyonEntityPracticeSuffererAbstract).getSuffererId() == item.getSuffererId() {
                                myPatientDatas[key]!.removeAtIndex(index)
                                setKeyAndDatas(key)
                                break
                            }
                        }
                    }else{
                        let itemArray = tableDatas[key]!
                        for (index,item) in itemArray.enumerate() {
                            if (tmp as! ComFqHalcyonEntityPracticeRecordAbstract).getRecordItemId() == item.getRecordItemId() {
                                tableDatas[key]!.removeAtIndex(index)
                                setKeyAndDatas(key)
                                break
                            }
                        }
                    }
                }
            }
            
        }
        timeTableView.reloadData()
        contentTableView.reloadData()
    }
    
    /**当某个array数据删除到0时，从字典中清除*/
    func setKeyAndDatas(key:String){
        if isTrash {
            if trashDatas[key]!.count == 0 {
                self.trashDatas[key] = nil
                for (index,item) in tableKeys.enumerate() {
                    if item == key {
                        tableKeys.removeAtIndex(index)
                        break
                    }
                }
            }
        }else{
            
            if isMyPatient {
                if myPatientDatas[key]!.count == 0 {
                    self.myPatientDatas[key] = nil
                    for (index,item) in tableKeys.enumerate() {
                        if item == key {
                            tableKeys.removeAtIndex(index)
                            break
                        }
                    }
                }
            }else{
                if tableDatas[key]!.count == 0 {
                    self.tableDatas[key] = nil
                    for (index,item) in tableKeys.enumerate() {
                        if item == key {
                            tableKeys.removeAtIndex(index)
                            break
                        }
                    }
                }
            }
        }
        
    }
    
    /**删除某个一数据*/
    func delOneData(indexPath: NSIndexPath!){
        let key = tableKeys[indexPath.section]
        let index = indexPath.row
        if isTrash {
            trashDatas[key]!.removeAtIndex(index)
        }else{
            if isMyPatient {
                myPatientDatas[key]!.removeAtIndex(index)
            }else{
                tableDatas[key]!.removeAtIndex(index)
            }
        }
        setKeyAndDatas(key)
        timeTableView.reloadData()
        contentTableView.reloadData()
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
        if isTrash {
            getTrashItemLogic()
        }else{
            if isMyPatient {
                //TODO 暂无分页处理
                //                getMyPatientLogic()
            }else{
                
                if isPatientRecordList {
                    if !OfflineManager.instance.isExists(CacheType.Patients, id: Int64(patientItem.getPatientId())) {
                        getRecordList(recordType)
                    }
                }else{
                    getrecordItemLogic()
                }
            }
        }
        // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
        contentTableView.footerEndRefreshing()
    }
    
    /**
    获取病案下的记录列表的逻辑
    */
    func getRecordList(recordType:Int32){
        
        if page == 1 {
            setViewShowOrHidden(SHOW_ACTIVITY_IND_VIEW)
        }
        
        self.recordType = recordType
        var patientId = Int64(patientItem.getPatientId())
        
        recordLogic!.loadRecordListWithInt(patientItem.getPatientId(), withInt: recordType, withInt: Int32(page), withInt: Int32(pageSize))
        
    }
    
    func recordTypeListCallbackWithJavaUtilArrayList(keys: JavaUtilArrayList!, withJavaUtilHashMap map: JavaUtilHashMap!) {

    }
    
    /**获取病案下记录列表成功的回调*/
    func recordTimeListCallbackWithJavaUtilArrayList(keys: JavaUtilArrayList!, withJavaUtilHashMap map: JavaUtilHashMap!) {
        var dataHeight:CGFloat = 0.0
        
        if recordType == 0 && !isGetPatientName {
            isGetPatientName = true
            if map.size() > 0 {
                let array = map.getWithId(keys.getWithInt(0)) as! JavaUtilArrayList
                let record = array.getWithInt(0) as! ComFqHalcyonEntityPracticeRecordAbstract;
                NSNotificationCenter.defaultCenter().postNotificationName("GetPatientName", object: record.getPatientName())
            }
        }
        
        if page == 1 {
            if map.size() > 0 {
                setViewShowOrHidden(SHOW_TABLE)
                
                for var i:Int32 = 0; i < keys.size();i++ {
                    dataHeight += 50
                    dataHeight += CGFloat(((map.getWithId(keys.getWithInt(i)) as! JavaUtilArrayList).size()) * 110)
                }
                
                //判断是否让置顶置底按钮消失
                if dataHeight < contentTableView.frame.height {
                    scrollToUpBtn.hidden = true
                    scrollToBottomBtn.hidden = true
                }else{
                    scrollToUpBtn.hidden = false
                    scrollToBottomBtn.hidden = false
                }
            }else{
                setViewShowOrHidden(SHOW_REFURBISH_BUTTON)
                scrollToUpBtn.hidden = true
                scrollToBottomBtn.hidden = true
                refurbishBtn.setTitle("暂无数据，点击刷新", forState: UIControlState.Normal)
            }
        }
        if keys.size() > 0 {
            setDatas(keys, datas: map)
            page = Int(recordLogic!.getPage()) + 1
        }
        
    }
    
    
    /**获取病案下记录列表失败的回调*/
    func errorWithInt(code: Int32, withNSString msg: String!) {
        
        if tableDatas.count > 0 {
            setViewShowOrHidden(SHOW_TABLE)
            return
        }
        
        if page == 1 {
            setViewShowOrHidden(SHOW_REFURBISH_BUTTON)
            refurbishBtn.setTitle("获取失败，点击刷新", forState: UIControlState.Normal)
        }
    }
    
    /**
    * 接口访问成功的回调方法。
    */
    func applyRecognizeSuccess() {
        delTableDatas()
    }
    
    /**
    * 请求错误的回调(包括访问出错和服务器出错)。
    */
    func applyErrorWithInt(code: Int32, withNSString msg: String!) {
        UIAlertViewTool.getInstance().showAutoDismisDialog("分享失败！")
    }
    
    @IBAction func refurbishBtnClick(sender: AnyObject) {
        if isTrash {
            getTrashItemLogic()
        }else{
            
            if isMyPatient {
                getMyPatientLogic()
            }else{
                if isPatientRecordList {
                    getRecordList(recordType)
                }else{
                    getrecordItemLogic()
                }
            }
        }
    }
    
    /**设置是否是分享状态*/
    func setShareStatus(isShare:Bool){
        self.isShare = isShare
        timeTableView.reloadData()
        contentTableView.reloadData()
    }
    
    func reloadTable(){
        timeTableView.reloadData()
        contentTableView.reloadData()
    }
    
    func onSendRecordErrorWithInt(errorCode: Int32, withNSString msg: String!) {
        saveloadingDialog?.close()
//        Tools.getCurrentViewController(self).view.makeToast("获取数据失败，请重试。")
        FQToast.makeError().show("获取数据失败，请重试。", superview: Tools.getCurrentViewController().view)
    }
    
    func onSendRecordSuccessWithInt(shareMessageId: Int32, withInt shareRecordItemId: Int32, withFQJSONArray shareRecordInfIds: FQJSONArray!, withComFqHalcyonEntityPracticeRecordAbstract obj: ComFqHalcyonEntityPracticeRecordAbstract!) {
        obj.setIsShowIdentityWithBoolean(didSendInfo)
        for m in 0..<shareRecordInfIds.length() {
            let chartEntity = ComFqHalcyonEntityChartEntity()
            chartEntity.setRecordInfoIdWithInt(shareRecordInfIds.optIntWithInt(m))
            chartEntity.setShareRecordEntityWithComFqHalcyonEntityPracticeRecordAbstract(obj, withInt: shareRecordItemId, withInt: shareMessageId)
            shareChatEntityList.addWithId(chartEntity)
        }
        saveloadingDialog?.close()
        if shareIsGroup && MoreChatViewControllerInstance != nil {
            Tools.getCurrentViewController(self).navigationController?.popToViewController(MoreChatViewControllerInstance!, animated: true)
        }else if !shareIsGroup && SimpleChatViewControllerInstance != nil {
            Tools.getCurrentViewController(self).navigationController?.popToViewController(SimpleChatViewControllerInstance!, animated: true)
        }
        
    }
    
    @IBAction func scrollToUpClicked(sender: AnyObject) {
        scrollToUpBtn.selected = true
        scrollToBottomBtn.selected = false
        let topRow = NSIndexPath(forRow: 0, inSection: 0)
        self.contentTableView.scrollToRowAtIndexPath(topRow, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
    }
    
    @IBAction func scrollToBottomClicked(sender: AnyObject) {
        scrollToUpBtn.selected = false
        scrollToBottomBtn.selected = true
        self.contentTableView.setContentOffset(CGPointMake(0, self.contentTableView.contentSize.height - self.contentTableView.bounds.size.height), animated: true)
    }
    
    
}
