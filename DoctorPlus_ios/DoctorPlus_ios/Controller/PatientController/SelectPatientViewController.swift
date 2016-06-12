//
//  SelectPatientViewController.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/7/16.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class SelectPatientViewController: BaseViewController,UITableViewDataSource,UITableViewDelegate,ComFqHalcyonLogic2AddRecordLogic_AddRecordCallBack,UISearchBarDelegate,ComFqHalcyonLogicPracticeSearchLogic_SearchCallBack,ComFqHalcyonLogicPracticePatientUpdateListLogic_PatientLineListCallback,SelectPatientTableViewCellDelegate{
    
    @IBOutlet weak var contentTableView: UITableView!
    @IBOutlet weak var tableview: UITableView!
    //loading框
    var loadingDialog:CustomIOS7AlertView?
    
    var filterResult: JavaUtilArrayList! = JavaUtilArrayList()
    
    var isFilter = false //是否是进行筛选的搜索
    //搜索页数
    var page = 1
    
    //搜索关键字
    var searchKey:String! = ""
    
    //搜索参数
    var params:ComFqHalcyonEntityPracticeSearchParams!
    var isFromFilter = false
    //搜索逻辑
    var searchLogic: ComFqHalcyonLogicPracticeSearchLogic!
    var filterStartTime = ""
    var filterEndTime = ""
    var alert:CustomIOS7AlertView?
    var textAlert:(CustomIOS7AlertView?,UITextField?)
    var isMenuShow:Bool = false
    var selectedNumber = 0
    var cell:UITableViewCell!
    var index = -1
    var textView:UITextField?
    var dialog:CustomIOS7AlertView?
    var logic : ComFqHalcyonLogic2AddRecordLogic!
    var patientListlogic : ComFqHalcyonLogicPracticePatientUpdateListLogic!
    var datas:JavaUtilArrayList! = JavaUtilArrayList()
    var photoImages:JavaUtilArrayList!
    var isSearched = false
    typealias sendValueClosure = (bool:Bool)->Void
    var myClosure:sendValueClosure?
    func setClosure(closure:sendValueClosure?){
        myClosure = closure
    }
    var count:Int32 = 0
    //历史关键字列表
    var historyKeys: JavaUtilArrayList! = JavaUtilArrayList()
    
    @IBOutlet weak var searchView: UISearchBar!
    @IBOutlet var subTableView: UITableView!
    @IBOutlet weak var edtPatientName: UITextView!
    @IBOutlet weak var cancelCreateBtn: UIButton!
    @IBOutlet weak var confirmCreateBtn: UIButton!
    //筛选列表
    var filtersList: JavaUtilArrayList! = JavaUtilArrayList()
    
    var createPatientDialog:CustomIOS7AlertView?
    @IBAction func filterBtn(sender: AnyObject) {
        let contoller = FilterViewController()
        contoller.filtersList = self.filtersList
        contoller.filterStartTime = filterStartTime
        contoller.filterEndTime = filterEndTime
        searchView.endEditing(true)
        self.navigationController?.pushViewController(contoller, animated: true)
    }
    @IBAction func newBtn(sender: AnyObject) {
        textAlert = UIAlertViewTool.getInstance().showCreateTextViewdDialog("", target: self, actionOk: "createConfirm", actionCancle: "createCancel")
        textView = textAlert.1
        dialog = textAlert.0
        searchView.endEditing(true)
        setControllerShow()
        textView?.text = ComFqLibRecordRecordConstants.getCreatePatientName()
    }
    
    
    @IBOutlet var popView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setTittle("归档")
//        setRightImage(isHiddenBtn:false, image: UIImage(named: "right_dot.png")!)
        setRightBtnTittle("新建")
        setLeftTextString("返回")
        tableview.registerNib(UINib(nibName: "SelectPatientTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "SelectPatientTableViewCell")
        popView.frame = CGRectMake(ScreenWidth - ScreenWidth/4.5 - 15, 78, ScreenWidth/4.5, 70)
        popView.hidden = true
        setTableViewRefresh()
//        self.view.insertSubview(popView, atIndex: 1000)
        popView.layer.zPosition = 100
        self.view.addSubview(popView)
        historyKeys = ComFqHalcyonPracticeSearchHistoryManager.getInstance().getKeys()
        count = historyKeys.size() < 5 ? historyKeys.size(): 5
        subTableView.frame = CGRectMake(0, 114, ScreenWidth, (ScreenHeight / 22.5) * CGFloat(count))
        subTableView.backgroundColor = UIColor.lightGrayColor()
        
        
        params = ComFqHalcyonEntityPracticeSearchParams()
//        datas = ComFqHalcyonPracticeReadHistoryManager.getInstance().getPatientList()
//        datas = ComFqLibToolsConstants_patietnList_
        
        logic = ComFqHalcyonLogic2AddRecordLogic(comFqHalcyonLogic2AddRecordLogic_AddRecordCallBack: self)
        
        patientListlogic = ComFqHalcyonLogicPracticePatientUpdateListLogic(comFqHalcyonLogicPracticePatientUpdateListLogic_PatientListCallback: self)
        patientListlogic.requestPatientListWithInt(Int32(page), withInt: Int32(0), withBoolean:false)
        loadingDialog = UIAlertViewTool.getInstance().showLoadingDialog("加载中...")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "getFilterResult:", name: "GetFilterResult", object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        popView.hidden = true
        isMenuShow = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        tableview.reloadData()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        subTableView.removeFromSuperview()
        if (filterResult != nil && filterResult.size() > 0 ) || (filterStartTime != "" && filterEndTime != ""){
            datas.clear()
            setParams(1, searchKey: searchKey, searchFilter: filterResult,isFilter:true)
        }
    }
    
    override func getXibName() -> String {
        return "SelectPatientViewController"
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == self.tableview {
            cell = tableView.dequeueReusableCellWithIdentifier("SelectPatientTableViewCell") as! SelectPatientTableViewCell
            (cell as! SelectPatientTableViewCell).delegate = self
            cell.tag = indexPath.row
            if indexPath.row == index {
                ((cell as! SelectPatientTableViewCell).iconBtn).image = UIImage(named: "select_dot.png")
            }else{
                ((cell as! SelectPatientTableViewCell).iconBtn).image = UIImage(named: "unselect_dot.png")
            }
            let patient:ComFqHalcyonEntityPracticePatientAbstract = datas.getWithInt(Int32(indexPath.row)) as! ComFqHalcyonEntityPracticePatientAbstract
            UITools.setRoundBounds(17.0, view: (cell as! SelectPatientTableViewCell).headIcon)
            (cell as! SelectPatientTableViewCell).numberLabel.text = "\(patient.getRecordCount())记录"
            (cell as! SelectPatientTableViewCell).firstShowLabel.text = patient.getShowName()
            (cell as! SelectPatientTableViewCell).secondShowLabel.text = patient.getShowSecond()
            (cell as! SelectPatientTableViewCell).thirdShowLabel.text = patient.getShowThrid()
            (cell as! SelectPatientTableViewCell).headIcon.downLoadImageWidthImageId(patient.getUserImageId(), callback: { (view, path) -> Void in
                let tmpImg = view as! UIImageView
                tmpImg.image = UITools.getImageFromFile(path)
            })
            return cell
        }else{
            let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
            cell.textLabel!.text = historyKeys.getWithInt(Int32(indexPath.row)) as? String
            cell.textLabel!.font = UIFont.systemFontOfSize(12.0)
            cell.textLabel!.textColor = UIColor.lightGrayColor()
            cell.textLabel!.textAlignment = NSTextAlignment.Center
            cell.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1)
//            if indexPath == selectItem {
//                searchView.text =  cell.textLabel!.text
//            }
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tableView == subTableView {
            return ScreenHeight/22.5
        }
        return 110
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableview {
            if datas == nil {return 0};
            return Int(datas.size())
        }else{
            return Int(count)
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(tableView == subTableView){
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            searchView.text =  cell?.textLabel!.text
            searchKey = searchView.text
            isSearched = true
            setRightImage(isHiddenBtn:false, image: UIImage(named: "right_dot.png")!)
            subTableView.removeFromSuperview()
            filterStartTime = ""
            filterEndTime = ""
            searchView.endEditing(true)
            page = 1
            datas.clear()
            startSearchLogic(searchKey)
        }
        
        if(tableView == self.tableview){
            index = indexPath.row
            tableView.reloadData()
        }
    }
    
    override func onRightBtnOnClick(sender: UIButton) {
        searchView.endEditing(true)
        if isSearched{
            setControllerShow()
        }else{
            
            textAlert = UIAlertViewTool.getInstance().showCreateTextViewdDialog("", target: self, actionOk: "createConfirm", actionCancle: "createCancel")
            textView = textAlert.1
            dialog = textAlert.0
            textView?.text = ComFqLibRecordRecordConstants.getCreatePatientName()
        }
    }

    
    @IBAction func sureBtnClicked(sender: UIButton) {
        if(index < 0 ){
            self.navigationController?.popViewControllerAnimated(true)
            return
        }
        alert = UIAlertViewTool.getInstance().showNewDelDialog("确认将\(selectedNumber)份移动至当前选中的病案吗？", target: self, actionOk: "sureCollectClick", actionCancle: "cancelCollectClick")
    }
    
    func createConfirm(){
        dialog?.close()
        logic.AddRecordWithNSString(textView?.text, withJavaUtilArrayList: photoImages)
    }
    
    //归档成功回调
    func AddRecordSuccessWithInt(code: Int32, withComFqHalcyonEntityPatient medical: ComFqHalcyonEntityPatient!, withNSString msg: String!) {
//        UIAlertViewTool.getInstance().showAutoDismisDialog("归档成功")
//        self.view.makeToast("归档成功")
        FQToast.makeError().show("归档成功", superview: self.view)
        if (myClosure != nil){
            myClosure!(bool: true)
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //归档失败回调
    func AddRecordErrorWithInt(code: Int32, withNSString msg: String!) {
//        UIAlertViewTool.getInstance().showAutoDismisDialog("无法创建病案，请连接网络")
//        self.view.makeToast("无法创建病案，请连接网络")
        FQToast.makeError().show("无法创建病案，请连接网络", superview: self.view)
    }
    
    func createCancel(){
        dialog?.close()
    }
    
    /**
    view出现和隐藏的动画
    */
    func setControllerShow(){
        if isMenuShow {
            UIView.animateWithDuration(1, animations: { () -> Void in
                self.popView.alpha = 0.0
                }) { (finished) -> Void in
                    if finished {
                        self.popView.hidden = true
                        self.isMenuShow = false
                    }
            }
        }else{
            popView.hidden = false
            UIView.animateWithDuration(1, animations: { () -> Void in
                self.popView.alpha = 1.0
                }) { (finished) -> Void in
                    if finished {
                        self.isMenuShow = true
                    }
            }
        }
    }
    
    
    /**
    归档确认按钮点击事件
    */
    func sureCollectClick(){
        let patient:ComFqHalcyonEntityPracticePatientAbstract = datas.getWithInt(Int32(index)) as! ComFqHalcyonEntityPracticePatientAbstract
//        logic.AddRecordWithNSString(textView?.text, withJavaUtilArrayList: photoImages)
        logic.AddRecordWithNSString(patient.getPatientName(), withInt: patient.getPatientId(), withJavaUtilArrayList: photoImages)
        alert?.close()
    }
    
    /**
    归档取消按钮点击事件
    */
    func cancelCollectClick(){
        alert?.close()
    }
    
    //搜索框search事件
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.endEditing(true)
        if searchBar.text!.isEmpty {
            return
        }
        filterStartTime = ""
        filterEndTime = ""
        isSearched = true
        searchKey = searchBar.text
        page = 1
        datas.clear()
        setRightImage(isHiddenBtn:false, image: UIImage(named: "right_dot.png")!)
//        setRightBtnTittle("")
//        startSearchLogic(1,searchKey: searchKey)
        startSearchLogic(searchKey)
        ComFqHalcyonPracticeSearchHistoryManager.getInstance().addSearchKeyWithNSString(searchKey)
    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        if !isFromFilter {
            subTableView.layer.zPosition = 80
            self.view.addSubview(subTableView)
        }
//        isFromFilter = false
        return true
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
//        self.view.insertSubview(subTableView, atIndex: 0)
        if isMenuShow {
            setControllerShow()
        }
        subTableView.reloadData()
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        subTableView.removeFromSuperview()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" && datas.size() == 0{
            page = 0
            patientListlogic.requestPatientListWithInt(Int32(page), withInt: Int32(0), withBoolean:false)
        }
    }
    
    //调用搜索接口的方法
    func startSearchLogic(searchKey:String){
        params = ComFqHalcyonEntityPracticeSearchParams()
        params.setNeedFiltersWithInt(0)
        params.setKeyWithNSString(searchKey)
        params.setPageWithInt(Int32(page))
        params.setResponseTypeWithInt(1)
        params.setPageSizeWithInt(20)
        searchLogic = ComFqHalcyonLogicPracticeSearchLogic(comFqHalcyonLogicPracticeSearchLogic_SearchCallBack: self)
        searchLogic.searchWithComFqHalcyonEntityPracticeSearchParams(params)
        loadingDialog = UIAlertViewTool.getInstance().showLoadingDialog("搜索中...")
    }
    
    //搜索成功的回调
    func searchRetrunDataWithJavaUtilArrayList(patients: JavaUtilArrayList!, withJavaUtilArrayList records: JavaUtilArrayList!, withJavaUtilArrayList filters: JavaUtilArrayList!) {
        if !isFilter {
            filtersList = filters
        }
        if patients.size() > 0 {
            self.page++
            for var i:Int32 = 0; i < patients.size(); i++ {
                datas.addWithId(patients.getWithInt(i))
            }
            
            
            
        }
        index = -1
        historyKeys = ComFqHalcyonPracticeSearchHistoryManager.getInstance().getKeys()
        count = historyKeys.size() < 5 ? historyKeys.size(): 5
        subTableView.frame = CGRectMake(0, 114, ScreenWidth, (ScreenHeight / 22.5) * CGFloat(count))
        subTableView.reloadData()
//        subTableView.removeFromSuperview()
        tableview.reloadData()
        loadingDialog?.close()
        searchView.endEditing(true)
    }
    
    //搜索失败的回调
    func searchErrorWithInt(code: Int32, withNSString msg: String!) {
        loadingDialog?.close()
        index = -1
//        subTableView.removeFromSuperview()
//        self.view.makeToast(msg)
        FQToast.makeError().show(msg, superview: self.view)
        searchView.endEditing(true)
    }
    
    /**获取病案列表失败的回调*/
    func loadPatientErrorWithInt(code: Int32, withNSString msg: String!) {
        loadingDialog?.close()
//        self.view.makeToast(msg)
        FQToast.makeError().show(msg, superview: self.view)
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
        if isFilter {
            setParams(Int32(page), searchKey: searchKey, searchFilter: self.filterResult,isFilter:true)
        }else{
            if searchKey != "" {
                startSearchLogic(searchKey)
            }else {
                patientListlogic.requestPatientListWithInt(Int32(page), withInt: Int32(0), withBoolean:false)
            }
        }
        // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
        contentTableView.footerEndRefreshing()
    }
    
    
    /**用于接受过滤条件*/
    func getFilterResult(notify:NSNotification) {
        isFilter = true
//        isFromFilter = true
        let filterResult = notify.object as! JavaUtilArrayList
        let userInfo:Dictionary<String,String!> = notify.userInfo as! Dictionary<String,String!>
        let startTime = userInfo["startTime"]
        let endTime = userInfo["endTime"]
        self.filterStartTime = startTime ?? ""
        self.filterEndTime = endTime ?? ""
        params.setFromDataWithNSString(startTime)
        params.setToDataWithNSString(endTime)
        self.filterResult = filterResult
    }
    
    func setParams(page:Int32,searchKey:String,searchFilter:JavaUtilArrayList?,isFilter:Bool){
        
            params.setNeedFiltersWithInt(1)
            if filterStartTime != "" {
                var start = (filterStartTime as NSString).substringToIndex(4)
                start += "-"
                start += (filterStartTime as NSString).substringWithRange(NSMakeRange(5, 2))
                start += "-"
                start += (filterStartTime as NSString).substringWithRange(NSMakeRange(8, 2))
                start += " 00"
                params.setFromDataWithNSString(start)
            }else{
                params.setFromDataWithNSString("")
            }
            
            if filterEndTime != "" {
                var end = (filterEndTime as NSString).substringToIndex(4)
                end += "-"
                end += (filterEndTime as NSString).substringWithRange(NSMakeRange(5, 2))
                end += "-"
                end += (filterEndTime as NSString).substringWithRange(NSMakeRange(8, 2))
                end += " 00"
                params.setToDataWithNSString(end)
            }else{
                params.setToDataWithNSString("")
            }
        params.setResponseTypeWithInt(1)
        params.setKeyWithNSString(searchKey)
        params.setPageWithInt(page)
        params.setPageSizeWithInt(20)
        if(searchFilter != nil){
            params.setFiltersWithJavaUtilArrayList(searchFilter)
        }
        searchLogic = ComFqHalcyonLogicPracticeSearchLogic(comFqHalcyonLogicPracticeSearchLogic_SearchCallBack: self)
        searchLogic.searchWithComFqHalcyonEntityPracticeSearchParams(params)
        loadingDialog = UIAlertViewTool.getInstance().showLoadingDialog("搜索中...")
    }
    
    func onCheckboxClick(cell: SelectPatientTableViewCell) {
        index = cell.tag
        tableview.reloadData()
    }
    
}
