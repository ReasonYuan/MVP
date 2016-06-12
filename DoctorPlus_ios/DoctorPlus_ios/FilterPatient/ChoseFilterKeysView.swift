//
//  ChoseFilterKeysView.swift
//  DoctorPlus_ios
//
//  Created by Monkey on 15/12/16.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import UIKit

enum FilterCategory : String{
    case RecordTime = "记录时间"
    case Name = "姓名"
    case Gender = "性别"
    case Age = "年龄"
    case NativePlace = "籍贯"
    case RecordType = "记录类型"
    case Diagnosis = "诊断"
}

class ChoseFilterKeysView: UIView,tableCellDelegate,NextViewCloseDelegate {
    
    var sexView:PatientSexView!
    var recordTypeView:RecordTypeView!
    var ageView:AgeView!
    @IBOutlet weak var keysScroll: UIScrollView!
    static let FilterNotificationKey = "FilterKeysReset"
    var viewFrame:CGRect!
    var isFromChart = false
    var timeSelectView:TimeSelectView!
    var patientNameDiagnosisView:CustomDiagnosisView!
    var patientFromDiagnosisView:CustomDiagnosisView!
    var patientDiagnosisView:CustomDiagnosisView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        viewFrame = frame
        initXib()
        addDiagnosisView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //初始化要显示的xib
    func initXib() {
        let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("ChoseFilterKeysView", owner: self, options: nil)
        let view = nibs.lastObject as! UIView
        view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height)
        let line = DashedLineView(frame: CGRect(x: 16, y: 48, width: ScreenWidth - 32, height: 1))
        view.addSubview(line)
        self.addSubview(view)
        keysScroll.contentSize = CGSize(width: viewFrame.size.width, height: viewFrame.size.height - 44)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        timeSelectView.closeController()
    }
    
    //添加病历诊断的view
    func addDiagnosisView() {
        timeSelectView = TimeSelectView(frame: CGRectMake(0,0,ScreenWidth,150), startTime: "", endTime: "")
        patientNameDiagnosisView = CustomDiagnosisView(y: timeSelectView.frame.origin.y + timeSelectView.frame.height, tittle: "病人姓名", list: NSMutableArray(), delegate: self,closeDelegate: self)
        sexView = PatientSexView(frame: CGRectMake(0, patientNameDiagnosisView.frame.origin.y + patientNameDiagnosisView.frame.height, ScreenWidth, 140))
        patientFromDiagnosisView = CustomDiagnosisView(y: sexView.frame.origin.y + sexView.frame.height, tittle: "籍贯", list: NSMutableArray(), delegate: self,closeDelegate: self)
        ageView = AgeView(frame: CGRectMake(0, patientFromDiagnosisView.frame.origin.y + patientFromDiagnosisView.frame.height, ScreenWidth, 200))
        
        patientDiagnosisView = CustomDiagnosisView(y: ageView.frame.origin.y + ageView.frame.height, tittle: "病历诊断", list: NSMutableArray(), delegate: self,closeDelegate: self)
        
        recordTypeView = RecordTypeView(frame: CGRectMake(0, patientDiagnosisView.frame.origin.y + patientDiagnosisView.frame.height, ScreenWidth, 200))
        
        addScrollSubView()
        
    }
    func AlertClose() {
        reDisPlayView()
    }
    func getScrollContentSize() -> CGSize{
        let height = patientNameDiagnosisView.frame.height + sexView.frame.height  + patientFromDiagnosisView.frame.height + ageView.frame.height + patientDiagnosisView.frame.height + recordTypeView.frame.height + timeSelectView.frame.height
        let size = CGSize(width: viewFrame.size.width, height: height)
        return size
    }
  
    @IBAction func onResetClickListener(sender: UIButton) {
        NSNotificationCenter.defaultCenter().postNotificationName(ChoseFilterKeysView.FilterNotificationKey, object: nil)
        reDisPlayView()
    }
    
    /**
     重新刷新view
     */
    func reDisPlayView() {
        let chilrenviews = keysScroll.subviews
        for chilren in chilrenviews {
            chilren.removeFromSuperview()
        }
        addScrollSubView()
    }
    
    func addScrollSubView(){
        timeSelectView.frame = CGRectMake(0,0,ScreenWidth,150)
       patientNameDiagnosisView.frame.origin.y = timeSelectView.frame.origin.y + timeSelectView.frame.height
       sexView.frame  =   CGRectMake(0, patientNameDiagnosisView.frame.origin.y + patientNameDiagnosisView.frame.height, ScreenWidth, 140)
        patientFromDiagnosisView.frame.origin.y = sexView.frame.origin.y + sexView.frame.height
        ageView.frame = CGRectMake(0, patientFromDiagnosisView.frame.origin.y + patientFromDiagnosisView.frame.height, ScreenWidth, 200)
        patientDiagnosisView.frame.origin.y = ageView.frame.origin.y + ageView.frame.height
        recordTypeView.frame = CGRectMake(0, patientDiagnosisView.frame.origin.y + patientDiagnosisView.frame.height, ScreenWidth, 200)
        
        keysScroll.addSubview(patientDiagnosisView)
        keysScroll.addSubview(patientFromDiagnosisView)
        keysScroll.addSubview(patientNameDiagnosisView)
        keysScroll.addSubview(sexView)
        keysScroll.addSubview(recordTypeView)
        keysScroll.addSubview(ageView)
        keysScroll.addSubview(timeSelectView)
        keysScroll.contentSize = getScrollContentSize()
    }
    
    //查看点击事件
    @IBAction func onSearchClickListener(sender: UIButton) {
        let controller = SearchPatientController()
        controller.isFromChart = self.isFromChart
        controller.setParams(getUserChoseFilters(), isFromFilter: true)
        controller.keys = (Tools.getCurrentViewController() as! FilterSearchViewController).searchKey
        Tools.getCurrentViewController().navigationController?.pushViewController(controller, animated: true)
    }
    
    //设置过滤的数据
    func setFilterKeys(filters:JavaUtilArrayList) {
        
        sexView.setKeys(getFiltersWithString(filters, key: FilterCategory.Gender))
        recordTypeView.setKeys(getFiltersWithString(filters, key: FilterCategory.RecordType))
        ageView.setKeys(getFiltersWithString(filters, key: FilterCategory.Age))
        timeSelectView.setKeys(getFiltersWithString(filters, key: FilterCategory.RecordTime))
        patientNameDiagnosisView.setKeys(getFiltersWithString(filters, key: FilterCategory.Name))
        patientFromDiagnosisView.setKeys(getFiltersWithString(filters, key: FilterCategory.NativePlace))
        patientDiagnosisView.setKeys(getFiltersWithString(filters, key: FilterCategory.Diagnosis))
        
    }
    
    //通过类型获取筛选数据的列表
    func getFiltersWithString(filters:JavaUtilArrayList,key:FilterCategory) -> JavaUtilArrayList {
        var result:JavaUtilArrayList!
        
        for var i:Int32 = 0 ; i < filters.size() ; i++ {
            
            let searchFilter = filters.getWithInt(i) as! ComFqHalcyonEntityPracticeSearchFilter
            let category = searchFilter.getCategory()
            if category == key.rawValue {
                result = searchFilter.getItems()
                break
            }
        }
        if result == nil {
            result = JavaUtilArrayList()
        }
        
        return result
    }
    
    //用户选择的条件
    func getUserChoseFilters() -> ComFqHalcyonEntityPracticeSearchParams{
        let searchParams = ComFqHalcyonEntityPracticeSearchParams()
        let list = JavaUtilArrayList()
        list.addWithId(getSearchFilter(patientNameDiagnosisView.getKeys(), category: FilterCategory.Name))
        list.addWithId(getSearchFilter(patientFromDiagnosisView.getKeys(), category: FilterCategory.NativePlace))
        list.addWithId(getSearchFilter(patientDiagnosisView.getKeys(), category: FilterCategory.Diagnosis))
        list.addWithId(getSearchFilter(sexView.getResult(), category: FilterCategory.Gender))
        list.addWithId(getSearchFilter(ageView.getResult(), category: FilterCategory.Age))
        list.addWithId(getRecordTypeSearchFilter(recordTypeView.getResult()))
        searchParams.setFiltersWithJavaUtilArrayList(list)
        searchParams.setToDataWithNSString(timeSelectView.getEndTime())
        searchParams.setFromDataWithNSString(timeSelectView.getStartTime())
        return searchParams
    }
    
    func getSearchFilter(map:Dictionary<String,JavaUtilArrayList>,category:FilterCategory) -> ComFqHalcyonEntityPracticeSearchFilter {
        let searchFilter = ComFqHalcyonEntityPracticeSearchFilter()
        let filters = JavaUtilArrayList()
        let array = map[category.rawValue] ?? JavaUtilArrayList()
        searchFilter.setCategoryWithNSString(category.rawValue)
        for var i:Int32 = 0 ; i < array!.size() ; i++ {
            let name = array!.getWithInt(i) as! String
            let filter = ComFqHalcyonEntityPracticeFilterItem()
            filter.setItemsNameWithNSString(name)
            filters.addWithId(filter)
        }
        searchFilter.setItemsWithJavaUtilArrayList(filters)
        return searchFilter
    }
    
    func getRecordTypeSearchFilter(map:[String:[String:[String]]]) -> ComFqHalcyonEntityPracticeSearchFilter  {
        let searchFilter = ComFqHalcyonEntityPracticeSearchFilter()
        let dic = map[FilterCategory.RecordType.rawValue]
        let filter = ComFqHalcyonEntityPracticeFilterItem()
        let javaMap = JavaUtilHashMap()
        let array = JavaUtilArrayList()
        searchFilter.setCategoryWithNSString(FilterCategory.RecordType.rawValue)
        for (key,values) in dic! {
            let tmpArray = JavaUtilArrayList()
            for value in values {
                tmpArray.addWithId(value)
            }
            javaMap.putWithId(key, withId: tmpArray)
        }
        filter.setItemsMapWithJavaUtilMap(javaMap)
        array.addWithId(filter)
        searchFilter.setItemsWithJavaUtilArrayList(array)
        return searchFilter
    }
}
