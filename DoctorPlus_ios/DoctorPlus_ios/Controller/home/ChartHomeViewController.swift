//
//  ChartHomeViewController.swift
//  DoctorPlus_ios
//
//  1.8.0版本的主页（ViewController），用TableView包含一个按钮和四个图表
//
//  Created by reason on 15/11/30.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import UIKit

class ChartHomeViewController: UIViewController, UITableViewDelegate ,UITableViewDataSource{

    let titles:[String] = ["","年龄","性别","诊断","地域"]
    
    let cellIdentifier = "chartHomeViewCell"   //缓存的cell名字
    
    @IBOutlet weak var selectView: UIView!       //所选择字段结果展示的面板
    
    @IBOutlet weak var siftButton: UIButton!     //筛选按钮
    
    @IBOutlet weak var counterButton: UIButton!  //选择的计数按钮
    
    @IBOutlet weak var clearButton: UIButton!    //清除所有选择项按钮
    
    @IBOutlet weak var tableView: UITableView!   //展示cell的列表
    
    var charts: [HomeBaseView]!   //存放cell内子view的数组
    
    var selectCount: Int = 0       //所选择数据的总数
    
    //存放cell所选择数据的字典，根据cell种类，数据key分为:age、gender、diagnose、area
    var selectedDicr: Dictionary<FilterCategory,[String]> = Dictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView!.registerNib(UINib(nibName: "ChartHomeViewCell", bundle:nil), forCellReuseIdentifier: cellIdentifier)
        
        selectView.hidden = true
        
        
        let width:CGFloat = UIScreen.mainScreen().bounds.width-54.0-16 // cell两边各距27px,cell四周各-8
        let record = HomeRecordView(width:width,home:self)
        let age = HomeAgeView(width:width,home:self)
        let gender = HomeGenderView(width:width,home:self)
        let diagnose = HomeDiagnoseView(width:width,home:self)
//        let map = HomeMapView(width:width,home:self)
        
        charts = [record, age,gender,diagnose]
    }
    
    func reloadFilterData(patienIds:JavaUtilArrayList){
        for chartView in charts{
            chartView.reloadData(patienIds)
        }
    }
    
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return charts.count
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return charts[indexPath.row].getHeight()+44.0 //下面控件加上分隔线和title的高度
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let index = indexPath.row
        
        let cell : ChartHomeViewCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ChartHomeViewCell
        
        cell.clearAllSubView()
        cell.addView(charts[index])
        
        if(index == 0){
            cell.hiddenDivider(true)
        }else{
            cell.hiddenDivider(false)
            cell.titleLabel.text = "\(titles[index])分布可视化图表"
        }
        
        return cell
    }
    
    /**
     搜索按钮被点击
     */
    @IBAction func onSearchClick(sender: AnyObject) {
//        showSelectedView()
        let controller = FilterSearchViewController()
        controller.isFromHome = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    /**
     筛选按钮被点击
     */
    @IBAction func onSiftClick(sender: AnyObject) {
        let controller = SearchPatientController()
        let params = ComFqHalcyonEntityPracticeSearchParams()
        
        params.setResponseTypeWithInt(2)
        params.setKeyWithNSString("")
        params.setPageWithInt(1)
        params.setPageSizeWithInt(10)
        params.setNeedFiltersWithBoolean(true)
        params.setFiltersWithJavaUtilArrayList(getSearchFilter(selectedDicr))
        controller.isFromChart = false
        controller.setParams(params, isFromFilter: true)
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    
    func getSearchFilter(map:Dictionary<FilterCategory,[String]>) -> JavaUtilArrayList {
        
        let list = JavaUtilArrayList()
        for (key,value) in selectedDicr {
            let searchFilter = ComFqHalcyonEntityPracticeSearchFilter()
            let filters = JavaUtilArrayList()
            let array = value
            searchFilter.setCategoryWithNSString(key.rawValue)
            for var i:Int = 0 ; i < array.count ; i++ {
                let name = array[i]
                let filter = ComFqHalcyonEntityPracticeFilterItem()
                filter.setItemsNameWithNSString(name)
                filters.addWithId(filter)
            }
            searchFilter.setItemsWithJavaUtilArrayList(filters)
            list.addWithId(searchFilter)
        }
        return list
    }
    
    /**
     清除按钮被点击
     */
    @IBAction func onClearClick(sender: AnyObject) {
        selectCount = 0
        setSelectedView()
        
        for(var i = 1; i < charts.count; i++){
            charts[i].clearSelected()
        }
        selectedDicr.removeAll()
    }
    
    /**
     显示选择结果的view
     */
    func showSelectedView() {
        if(selectView.hidden){
            selectView.hidden = false
        }else{
            selectView.hidden = true
        }
    }
    
    /**
     各类型数据选择子项
     - parameter isAdd: true表示选择该项，false表示取消选择该项
     */
    func selectData(key:FilterCategory, value:String, isAdd: Bool) {
        
        if(isAdd){
            if var _:[String] = selectedDicr[key] {
                selectedDicr[key]!.append(value)
            }else {
                var ary = [String]()
                ary.append(value)
                selectedDicr[key] = ary
                
            }
            
            selectCount++
        }else{
            if var ary:[String] = selectedDicr[key] {
                for(var i = 0; i < ary.count; i++){
                    if(ary[i] == value){
                        selectedDicr[key]!.removeAtIndex(i)
                        break
                    }
                }
            }
            
            selectCount--
        }
        
        setSelectedView()
        print("------\(selectedDicr[key])")
    }
    
    /**
     设置所选择的结果面板的UI:改变选择数、显示、隐藏等等
     */
    func setSelectedView() {
        if(selectCount == 0){
            showSelectedView()
        }else {
            counterButton.setTitle("\(selectCount)", forState: UIControlState.Disabled)
            if(selectCount == 1 && selectView.hidden){
                showSelectedView()
            }
        }
    }
}
