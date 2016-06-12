//
//  CustomDiagnosisView.swift
//  DoctorPlus_ios
//
//  Created by 王曦 on 15/12/16.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import Foundation
class CustomDiagnosisView:UIView,UITableViewDelegate,UITableViewDataSource,CloseDelegate {
    var tittle:UILabel!
    var tabView:UITableView!
    var tittleWidth:CGFloat = 150
    var tittleHeight:CGFloat = 22
    
    var tmpDistance:CGFloat = 20.0
    var topDistance:CGFloat = 10.0
    
    var cellHeight:Int = 50
    
    var dataList:NSMutableArray = NSMutableArray()
    var tittleStr:String = ""
    
    var cellTittleColor = Tittle_Color.Search
    
    var cellDelegate:tableCellDelegate!
    
    var isSelectAll:Bool = false
    
    var closeDelegate:NextViewCloseDelegate!
    
    var baseList = NSMutableArray()
    
    var nextView:CustomDiagnosisNextView!
    /**
     初始化
     
     - parameter y:        y坐标
     - parameter tittle:   标题
     - parameter list:     数据list
     - parameter delegate: 每个cell的回调
     
     - returns: <#return value description#>
     */
    init(y:CGFloat,tittle:String,list:NSMutableArray,delegate:tableCellDelegate,closeDelegate:NextViewCloseDelegate){
        var height:CGFloat = 0
        self.dataList = list
        self.closeDelegate = closeDelegate
        if dataList.count == 0{
            height = CGFloat(cellHeight) + tmpDistance +  topDistance + tittleHeight
        }else if dataList.count >= 4{
            height = CGFloat(4 * cellHeight) + tmpDistance +  topDistance + tittleHeight
        }else{
            height = CGFloat(dataList.count * cellHeight) + tmpDistance +  topDistance + tittleHeight
        }
       super.init(frame: CGRectMake(0, y, ScreenWidth, height))
       
       self.tittleStr = tittle
       self.cellDelegate = delegate
       initUI()
       self.backgroundColor = UIColor.clearColor()
       addResetNotification()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   private func initUI(){
    tittle = UILabel(frame: CGRectMake((self.frame.width/2 - tittleWidth/2),topDistance,tittleWidth,tittleHeight))
    tittle.text = self.tittleStr 
    tittle.textAlignment = NSTextAlignment.Center
    tittle.backgroundColor = UITools.colorWithHexString("#333333")
    tittle.font = UIFont.systemFontOfSize(15.0)
    tittle.textColor = UIColor.whiteColor()
    UITools.setRoundBounds(tittleHeight/2, view: tittle)
    
    var height = 0
    if dataList.count == 0 {
        height = cellHeight
    }else{
        height = dataList.count * cellHeight
    }

    tabView = UITableView(frame: CGRectMake(0,tittle.frame.origin.y + tittle.frame.height + tmpDistance,self.frame.width,CGFloat(height)))
    tabView.delegate = self
    tabView.dataSource = self
    tabView.backgroundColor = UIColor.clearColor()
    tabView.separatorStyle = UITableViewCellSeparatorStyle.None
    tabView.registerNib(UINib(nibName: "DiagnosisCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "DiagnosisCell")
    
    
    self.addSubview(tittle)
    self.addSubview(tabView)
    nextView = CustomDiagnosisNextView(frame: CGRectMake(0,0,ScreenWidth,ScreenHeight), closeDelegate: self,tittle:tittleStr)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identi = "DiagnosisCell"
        var cell = tabView.dequeueReusableCellWithIdentifier(identi) as? DiagnosisCell
        if cell == nil {
            cell = DiagnosisCell()
        }
        UITools.setBorderWithView(1.0, tmpColor: cellTittleColor, view: cell!.tittle)
        showText(indexPath, cell: cell!)
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(cellHeight)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tabView.deselectRowAtIndexPath(indexPath, animated: false)
        nextView.show(self.baseList)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getNumbersOfSection()
    }
    
    func alertClose(selectAll: Bool, list: NSMutableArray) {
        isSelectAll = selectAll
        resetData(self.frame.origin.y, list: list)
        closeDelegate.AlertClose!()
//        getKeys()
    }
    
    private func showText(indexPath: NSIndexPath,cell:DiagnosisCell){
        var tittle = ""
        if isSelectAll {
            tittle =  "全部"
        }else {
            let row = indexPath.row
            if row == 0 {
                if dataList.count == 0 {
                    tittle =  "空"
                }else{
                    tittle =  dataList[0] as! String
                }
            }else if row == 3 {
                tittle = "..."
            }else{
                tittle = dataList[row] as! String
            }
            
        }
        
        cell.tittle.text = tittle
    }
    
    private func getNumbersOfSection() -> Int{
        if isSelectAll {
            return 1
        }
        
        if dataList.count == 0 {
            return 1
        }
        
        if dataList.count >= 4 {
            return 4
        }else{
            return dataList.count
        }
        
    }
    
    /**
     重置数据
     
     - parameter y:    y位置
     - parameter list: 数据列表
     */
    func resetData(y:CGFloat,list:NSMutableArray){
        self.dataList = list
        var height:CGFloat = 0
        if dataList.count == 0 || isSelectAll {
            height = CGFloat(cellHeight) + tmpDistance +  topDistance + tittleHeight
        }else if dataList.count >= 4{
            height = CGFloat(4 * cellHeight) + tmpDistance +  topDistance + tittleHeight
        }else{
            height = CGFloat(dataList.count * cellHeight) + tmpDistance +  topDistance + tittleHeight
        }
        self.frame = CGRectMake(0, y, ScreenWidth, height)
        print(dataList)
        var tbHeight = 0
        if dataList.count == 0 {
            tbHeight = cellHeight
        }else if dataList.count >= 4{
            tbHeight = (4 * cellHeight)
        }else{
            tbHeight = (dataList.count * cellHeight)
        }
        self.tabView.frame = CGRectMake(0,tittle.frame.origin.y + tittle.frame.height + tmpDistance,self.frame.width,CGFloat(tbHeight))
        tabView.reloadData()
    }
    
    /**
     重置数据
     */
    func reset() {
        self.dataList = self.baseList
        if self.dataList.count != 0 {
            self.isSelectAll = true
        }else{
            self.isSelectAll = false
        }
        
        let height = CGFloat(cellHeight) + tmpDistance +  topDistance + tittleHeight
        self.frame = CGRectMake(0, self.frame.origin.y, ScreenWidth, height)
        let tbHeight = cellHeight
        self.tabView.frame = CGRectMake(0,tittle.frame.origin.y + tittle.frame.height + tmpDistance,self.frame.width,CGFloat(tbHeight))
        tabView.reloadData()
        nextView.isSelectAll = true
    }
    
    /**
     设置tittle的边框颜色
     
     - parameter color: <#color description#>
     */
    func setCellTittleBorderColor(color:CGColorRef){
        cellTittleColor = color
    }
    
    //添加重置选择的通知
    func addResetNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onResetFilterKeys", name: ChoseFilterKeysView.FilterNotificationKey, object: nil)
    }
    
    //重置选择的操作
    func onResetFilterKeys() {
        print("-------------------sex keys reset")
        reset()
    }
    
    //设置筛选的数据
    //keys : ArrayList<ComFqHalcyonEntityPracticeFilterItem>
    func setKeys(keys:JavaUtilArrayList) {
        baseList.removeAllObjects()
        let list = NSMutableArray()
        for i in 0..<keys.size() {
            list.addObject((keys.getWithInt(i) as! ComFqHalcyonEntityPracticeFilterItem).getItemsName())
        }
//        list.addObject("张三")
//        list.addObject("李四")
//        list.addObject("王五")
        baseList = list
        if list.count == 0 {
            isSelectAll = false
        }else{
            isSelectAll = true
        }
        
        resetData(self.frame.origin.y, list: list)
        closeDelegate.AlertClose!()
    }
    
    /**
     获取筛选的结果
     
     - returns: <#return value description#>
     */
    func getKeys() -> Dictionary<String,JavaUtilArrayList>{
        
        var tittle:String = ""
        if self.tittleStr == "病人姓名" {
            tittle  = FilterCategory.Name.rawValue
        }
        
        if self.tittleStr == "籍贯" {
            tittle = FilterCategory.NativePlace.rawValue
        }
        
        if self.tittleStr == "病历诊断" {
            tittle = FilterCategory.Diagnosis.rawValue
        }
        
        let list = JavaUtilArrayList()
        for i in 0..<self.dataList.count {
            list.addWithId(self.dataList[i] as! String)
        }
        
        var dictionary = Dictionary<String,JavaUtilArrayList>()
        dictionary[tittle] = list
        print(dictionary)
        return dictionary
    }
}

enum Tittle_Color{
    static let Search = UITools.colorWithHexString("#c1c1c1").CGColor
    static let ShaiXuan = UIColor.whiteColor().CGColor
}

@objc protocol NextViewCloseDelegate {
    optional func AlertClose()
}

@objc protocol tableCellDelegate {
   optional func cellOnClick(row:Int,diagnosisview:CustomDiagnosisView)
}