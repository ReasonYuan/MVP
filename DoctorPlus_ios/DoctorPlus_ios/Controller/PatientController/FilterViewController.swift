//
//  FilterViewController.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/7/16.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class FilterViewController: BaseViewController,UITableViewDataSource,UITableViewDelegate,ComFqHalcyonLogicPracticeSearchLogic_SearchCallBack {
    
    @IBOutlet weak var tableView: UITableView!
    var numberOfRows:Int!
    var isMenuShow = false
    var countsOfItems:Int!
    var isStartDate = true
    
    var filterStartTime = ""
    var filterEndTime = ""
    var patientId:Int32?
    
    var isFromRecordList = false
    
    //loading框
    var loadingDialog:CustomIOS7AlertView?
    
    //搜索页数
    var page:Int32! = 1
    
    //搜索参数
    var params:ComFqHalcyonEntityPracticeSearchParams!
    
    //搜索逻辑
    var searchLogic: ComFqHalcyonLogicPracticeSearchLogic!
    
    //病历记录列表
    var recordsList: JavaUtilArrayList!
    
    @IBAction func onTouched(sender: AnyObject) {
        setControllerShow()
    }

    //筛选列表
    var filtersList: JavaUtilArrayList! = JavaUtilArrayList()
    
    var mengView : UIView!
    @IBOutlet var datePicker: UIDatePicker!
    @IBAction func dateChange(sender: UIDatePicker) {
        let control = sender
        let date = control.date
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd"
        let dateString = dateFormatter.stringFromDate(date)
        
        //字体大小自适应，解决iphone5上日期显示不完而出现省略号的问题
        startTimeBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        endTimeBtN.titleLabel?.adjustsFontSizeToFitWidth = true
        
        if(isStartDate){
            startTimeBtn.setTitle(dateString, forState: UIControlState.Normal)
        }else{
            endTimeBtN.setTitle(dateString, forState: UIControlState.Normal)
        }
    }
    
    //起始时间按钮
    @IBOutlet weak var startTimeBtn: UIButton!
    //终止时间按钮
    @IBOutlet weak var endTimeBtN: UIButton!
    //确认按钮
    @IBOutlet weak var sureBtn: UIButton!
    //点击，选择起始时间
    @IBAction func selectStartDate(sender: AnyObject) {
        isStartDate = true
        
        if endTimeBtN.titleLabel?.text != nil && endTimeBtN.titleLabel?.text != "" {
            if startTimeBtn.titleLabel?.text != nil && startTimeBtn.titleLabel?.text != "" {
                if startTimeBtn.titleLabel?.text != nil && startTimeBtn.titleLabel?.text != "" {
                    let dateFormater = NSDateFormatter()
                    let startTime:String! = startTimeBtn.titleLabel?.text
                    dateFormater.dateFormat = "yyyy年MM月dd"
                    let date = dateFormater.dateFromString(startTime)
                    datePicker.date = date!
                }else{
                    datePicker.date = NSDate()
                }
            }
            let dateFormater = NSDateFormatter()
            let time:String! = endTimeBtN.titleLabel?.text
            dateFormater.dateFormat = "yyyy年MM月dd"
            let date = dateFormater.dateFromString(time)
            datePicker.maximumDate = date!
            datePicker.minimumDate = nil
        }
        
        setControllerShow()
    }
    //点击，选择终止时间
    @IBAction func selectEndDate(sender: AnyObject) {
        isStartDate = false
        if startTimeBtn.titleLabel?.text != nil && startTimeBtn.titleLabel?.text != "" {
            if endTimeBtN.titleLabel?.text != nil && endTimeBtN.titleLabel?.text != ""{
                if endTimeBtN.titleLabel?.text != nil && endTimeBtN.titleLabel?.text != "" {
                    let dateFormater = NSDateFormatter()
                    let endTime:String! = endTimeBtN.titleLabel?.text
                    dateFormater.dateFormat = "yyyy年MM月dd"
                    let date = dateFormater.dateFromString(endTime)
                    datePicker.date = date!
                }else{
                    datePicker.date = NSDate()
                }
            }
            let dateFormater = NSDateFormatter()
            let time:String! = startTimeBtn.titleLabel?.text
            dateFormater.dateFormat = "yyyy年MM月dd"
            let date = dateFormater.dateFromString(time)
            datePicker.minimumDate = date!
            datePicker.maximumDate = nil
        }
        setControllerShow()
    }
    //确认按钮点击事件
    @IBAction func sureBtnOnClick(sender: AnyObject) {
        let resultList = getSelectedItems()
        let startTime = startTimeBtn.currentTitle ?? ""
        let endTime = endTimeBtN.currentTitle ?? ""
        NSNotificationCenter.defaultCenter().postNotificationName("GetFilterResult", object: resultList, userInfo: ["startTime":startTime ?? "","endTime":endTime ?? ""])
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTittle("筛选")
        setRightBtnTittle("重置")
        setLeftTextString("返回")
        tableView.registerNib(UINib(nibName: "FilterTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "FilterTableViewCell")
        
        //字体大小自适应，解决iphone5上日期显示不完而出现省略号的问题
        startTimeBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        endTimeBtN.titleLabel?.adjustsFontSizeToFitWidth = true
        
        startTimeBtn.setTitle(filterStartTime, forState: UIControlState.Normal)
        endTimeBtN.setTitle(filterEndTime, forState: UIControlState.Normal)
        
        mengView = UIView()
        mengView.frame = CGRectMake(0, self.view.frame.origin.y, ScreenWidth, ScreenHeight);
        self.view.addSubview(mengView)
        let tapGesture = UITapGestureRecognizer(target: self, action: "mengTapGesture:")
        mengView.addGestureRecognizer(tapGesture)
        mengView.hidden = true;
        if isFromRecordList{
            setParams(1, searchFilter: nil, isFilter: true)
        }
        datePicker.backgroundColor = UIColor.lightGrayColor()
        self.view.addSubview(datePicker)
        datePicker.frame = CGRectMake(0, ScreenHeight, ScreenWidth, 216)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "filterCellItemClick:", name: "FilterCellNotification", object: nil)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func getXibName() -> String {
        return "FilterViewController"
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return Int(filtersList.size())
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var num = 0
        let count = Int((filtersList.getWithInt(Int32(section)) as! ComFqHalcyonEntityPracticeSearchFilter).getItems().size())
        num = count % 3 == 0 ? count / 3 : count / 3 + 1
        return num
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let title = UILabel(frame: CGRectMake(15, 20, 120, 12))
        title.text = (filtersList.getWithInt(Int32(section)) as! ComFqHalcyonEntityPracticeSearchFilter).getCategory()
        title.textColor = UIColor.darkGrayColor()
        title.font = UIFont.systemFontOfSize(14)
        let label = UILabel(frame: CGRectMake(0, 43, ScreenWidth , 1))
        label.backgroundColor = UIColor.lightGrayColor()
        let view = UIView(frame: CGRectMake(0, 0, ScreenWidth, 44))
        view.addSubview(title)
        view.addSubview(label)
        return view
    }
    
    //把逻辑数据填充到一行最多三个复选框上面
    func createOneLineCells(indexPath:NSIndexPath, cell:FilterTableViewCell, idx:Int){
        let filter = filtersList.getWithInt(Int32(indexPath.section)) as! ComFqHalcyonEntityPracticeSearchFilter
        let item = filter.getItems().getWithInt(Int32(indexPath.row * 3 + idx)) as! ComFqHalcyonEntityPracticeFilterItem
        let isSelected = item.isSelected()
        switch(idx){
        case 0:
            cell.firstLabel.text = item.getItemsName() as String
            if isSelected {
                cell.firstIcon.setBackgroundImage(UIImage(named: "friend_select.png"), forState: UIControlState.Normal)
            }else{
                cell.firstIcon.setBackgroundImage(UIImage(named: "friend_unselect.png"), forState: UIControlState.Normal)
            }
        case 1:
            cell.secondLabel.text = item.getItemsName() as String
            if isSelected {
                cell.secondIcon.setBackgroundImage(UIImage(named: "friend_select.png"), forState: UIControlState.Normal)
            }else{
                cell.secondIcon.setBackgroundImage(UIImage(named: "friend_unselect.png"), forState: UIControlState.Normal)
            }
        case 2:
            cell.thirdLabel.text = item.getItemsName() as String
            if isSelected {
                cell.thirdIcon.setBackgroundImage(UIImage(named: "friend_select.png"), forState: UIControlState.Normal)
            }else{
                cell.thirdIcon.setBackgroundImage(UIImage(named: "friend_unselect.png"), forState: UIControlState.Normal)
            }
        default:
            print("Idx: \(idx) is unknown!")
        }
        
        item.setIndexRowWithInt(Int32(indexPath.row))
        item.setIndexSectionWithInt(Int32(indexPath.section))
        item.setPositionWithInt(Int32(idx))
        
        cell.items.insert(item, atIndex: idx)
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FilterTableViewCell") as! FilterTableViewCell
        cell.items = [ComFqHalcyonEntityPracticeFilterItem]()
        let count = Int((filtersList.getWithInt(Int32(indexPath.section)) as! ComFqHalcyonEntityPracticeSearchFilter).getItems().size())
            if count > 3 {
                if indexPath.row == count/3 {
                    let boxNum = count % 3
                    setCheckBoxStatus(boxNum,cell: cell,indexPath: indexPath)
                }else{
                    setCheckBoxStatus(3,cell: cell,indexPath: indexPath)
                }
            }else{
                let boxNum = count
                setCheckBoxStatus(boxNum,cell: cell,indexPath: indexPath)
            }
        let itemCounts:Int32 = (filtersList.getWithInt(Int32(indexPath.section)) as! ComFqHalcyonEntityPracticeSearchFilter).getItems().size()

        for idx in 0..<3 {
            if((indexPath.row * 3 + idx ) < Int(itemCounts) ){
                createOneLineCells(indexPath, cell: cell, idx: idx)
            }
        }
        return cell
    }
    
    func setCheckBoxStatus(boxNum:Int,cell:FilterTableViewCell,indexPath: NSIndexPath){
        if boxNum == 1 {
            cell.firstIcon.hidden = false
            cell.firstLabel.hidden = false
            cell.secondIcon.hidden = true
            cell.secondLabel.hidden = true
            cell.thirdIcon.hidden = true
            cell.thirdLabel.hidden = true
        }else if boxNum == 2 {
            cell.firstIcon.hidden = false
            cell.firstLabel.hidden = false
            cell.secondIcon.hidden = false
            cell.secondLabel.hidden = false
            cell.thirdIcon.hidden = true
            cell.thirdLabel.hidden = true
        }else{
            cell.firstIcon.hidden = false
            cell.firstLabel.hidden = false
            cell.secondIcon.hidden = false
            cell.secondLabel.hidden = false
            cell.thirdIcon.hidden = false
            cell.thirdLabel.hidden = false
        }
    }
    
    /**
    datePicker出现和隐藏的动画
    */
    func setControllerShow(){
        if !isMenuShow {
            datePicker.frame = CGRectMake(0, ScreenHeight, ScreenWidth, 216)
        }
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.5)
        UIView.setAnimationDelegate(self)
        UIView.setAnimationCurve(UIViewAnimationCurve.EaseInOut)
        if isMenuShow {
            isMenuShow = false
            datePicker.frame.origin.y = ScreenHeight
            datePicker.alpha = 0.0
            mengView.backgroundColor = UIColor(red: 85/255.0, green:  85/255.0, blue:  85/255.0, alpha: 0.0)
            UIView.setAnimationDidStopSelector(Selector("hiddenView"))
        }else{
            isMenuShow = true
            mengView.hidden = false
            mengView.backgroundColor = UIColor(red: 85/255.0, green:  85/255.0, blue:  85/255.0, alpha: 0.2)
            datePicker.frame = CGRectMake(0, ScreenHeight - 216, ScreenWidth, 216)
            datePicker.alpha = 1.0
        }

        UIView.commitAnimations()
    }

    func mengTapGesture(sender: UIPinchGestureRecognizer){
        setControllerShow()
    }
    
    func hiddenView(){
        mengView.hidden = true
    }
    
    
    func filterCellItemClick(item:NSNotification){
        let filterItem = item.object as! ComFqHalcyonEntityPracticeFilterItem
        let section = filterItem.getIndexSection()
        let row = filterItem.getIndexRow()
        let position = filterItem.getPosition()
        let isSelected = filterItem.isSelected()
        let filter = filtersList.getWithInt(Int32(section)) as! ComFqHalcyonEntityPracticeSearchFilter
        let item = filter.getItems().getWithInt(Int32(row * 3 + position)) as! ComFqHalcyonEntityPracticeFilterItem
        item.setSelectedWithBoolean(isSelected)
        
        getSelectedItems()
    }
    
    func getSelectedItems() -> JavaUtilArrayList{
        let listSize = filtersList.size()
        let resultList = JavaUtilArrayList()
        for var i:Int32 = 0 ; i < listSize ; i++ {
            
            let tmpFilter = ComFqHalcyonEntityPracticeSearchFilter()
            let tmpFilterItemList = JavaUtilArrayList()
            let filter = filtersList.getWithInt(i) as! ComFqHalcyonEntityPracticeSearchFilter
            let filterList = filter.getItems()
            let filterSize = filterList.size()
            for var j:Int32 = 0 ; j < filterSize ; j++ {
                let item = filterList.getWithInt(j) as! ComFqHalcyonEntityPracticeFilterItem
                if item.isSelected() {
                    tmpFilterItemList.addWithId(item)
                }
            }
            
            if tmpFilterItemList.size() > 0 {
                tmpFilter.setCategoryWithNSString(filter.getCategory())
                tmpFilter.setItemsWithJavaUtilArrayList(tmpFilterItemList)
                resultList.addWithId(tmpFilter)
            }
        }
        
        return resultList
    }
    
    func resetDatas(){
        let count = filtersList.size()
        for var i:Int32 = 0 ; i < count ; i++ {
            var tmpFilter = ComFqHalcyonEntityPracticeSearchFilter()
            var tmpFilterItemList = JavaUtilArrayList()
            let filter = filtersList.getWithInt(i) as! ComFqHalcyonEntityPracticeSearchFilter
            let filterList = filter.getItems()
            let filterSize = filterList.size()
            
            for var j:Int32 = 0 ; j < filterSize ; j++ {
                let item = filterList.getWithInt(j) as! ComFqHalcyonEntityPracticeFilterItem
                if item.isSelected() {
                    item.setSelectedWithBoolean(false)
                }
            }
        }
        
        tableView.reloadData()
    }
    
    override func onRightBtnOnClick(sender: UIButton) {
        startTimeBtn.setTitle("", forState: UIControlState.Normal)
        endTimeBtN.setTitle("", forState: UIControlState.Normal)
        datePicker.date = NSDate()
        resetDatas()
    }
    
    func setParams(page:Int32,searchFilter:JavaUtilArrayList?,isFilter:Bool){
        params = ComFqHalcyonEntityPracticeSearchParams()
        params.setNeedFiltersWithInt(1)
        params.setResponseTypeWithInt(2)
        params.setPageWithInt(page)
        params.setPageSizeWithInt(20)
        params.setPagintIdWithInt(patientId!)
        if(searchFilter != nil){
            params.setFiltersWithJavaUtilArrayList(searchFilter)
        }
        searchLogic = ComFqHalcyonLogicPracticeSearchLogic(comFqHalcyonLogicPracticeSearchLogic_SearchCallBack: self)
        searchLogic.searchWithComFqHalcyonEntityPracticeSearchParams(params)
        loadingDialog = UIAlertViewTool.getInstance().showLoadingDialog("列表获取中...")
    }
    
    func searchRetrunDataWithJavaUtilArrayList(patients: JavaUtilArrayList!, withJavaUtilArrayList records: JavaUtilArrayList!, withJavaUtilArrayList filters: JavaUtilArrayList!) {
        filtersList = filters
        recordsList = records
        tableView.reloadData()
        loadingDialog?.close()
    }
    
    func searchErrorWithInt(code: Int32, withNSString msg: String!) {
//        self.view.makeToast("列表获取失败")
         FQToast.makeError().show("列表获取失败", superview: Tools.getCurrentViewController().view)
        loadingDialog?.close()
    }
}