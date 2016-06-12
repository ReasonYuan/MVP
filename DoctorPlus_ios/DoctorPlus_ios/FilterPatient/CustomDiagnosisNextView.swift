//
//  CustomDiagnosisNextView.swift
//  DoctorPlus_ios
//
//  Created by 王曦 on 15/12/16.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import Foundation
enum CellStatus {
    case Selected
    case UnSelected
}

protocol CloseDelegate {
    func alertClose(selectAll:Bool,list:NSMutableArray)
}

class CustomDiagnosisNextView:UIView{
    
    var dataList:NSMutableArray!
    
    @IBOutlet weak var tittle: UILabel!
    var topDistance:CGFloat = 110
    var tittleHeight:CGFloat = 25
    @IBOutlet weak var selectAllImage: UIImageView!
    @IBOutlet weak var selectAlllabel: UILabel!
    @IBOutlet weak var clearAllImage: UIImageView!
    @IBOutlet weak var tabView: UITableView!
    var superView:UIView!
    var cellHeight:Int = 50
    var containerView:UIView!
    var cellTittleColor = Tittle_Color.ShaiXuan
    var selectedMap:Dictionary<Int,CellStatus> =  Dictionary<Int,CellStatus>()
    var isSelectAll:Bool = true
    
    var myCloseDelegate:CloseDelegate!
    init(frame: CGRect,closeDelegate:CloseDelegate,tittle:String) {
        super.init(frame: frame)
        self.myCloseDelegate = closeDelegate
        let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("CustomDiagnosisNextView", owner: self, options: nil)
        containerView = nibs.lastObject as! UIView
        containerView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height)
        self.addSubview(containerView)
        self.superView = Tools.getCurrentViewController().view
        self.tittle.text = tittle
        tabView.registerNib(UINib(nibName: "DiagnosisNextViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "DiagnosisNextViewCell")
        if isSelectAll {
           initSelectAllBtn()
        }else{
           initSelectNotAllBtn()
        }
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    @IBAction func selectAllClick(sender: AnyObject) {
        for i in 0..<dataList.count {
            selectedMap[i] = CellStatus.Selected
        }
        initSelectAllBtn()
        tabView.reloadData()
    }
    
    @IBAction func clearAllClick(sender: AnyObject) {
        for i in 0..<dataList.count {
            selectedMap[i] = CellStatus.UnSelected
        }
        initSelectNotAllBtn()
        tabView.reloadData()
    }
    
    @IBAction func sureBtnClick(sender: AnyObject) {
        
        let list = getSelectTittles()
        if list.count == dataList.count{
            if list.count != 0 {
                isSelectAll = true
            }else{
                isSelectAll = false
            }
        }else{
            isSelectAll = false
        }
        myCloseDelegate.alertClose(isSelectAll, list: list)
        close()
    }
    
    func getIsSelectAll() ->Bool {
        let list = getSelectTittles()
        if list.count == dataList.count{
            if list.count != 0 {
                isSelectAll = true
            }else{
                isSelectAll = false
            }
        }else{
            isSelectAll = false
        }
        return isSelectAll
    }
    
    func initSelectAllBtn() {
        selectAllImage.image = UIImage(imageLiteral: "select_all_selected.png")
        selectAlllabel.textColor = UIColor(red: 13/255.0, green: 107/255.0, blue: 180/255.0, alpha: 1.0)
    }
    
    
    func initSelectNotAllBtn() {
        selectAllImage.image = UIImage(imageLiteral: "select_all_normal.png")
        selectAlllabel.textColor = UITools.colorWithHexString("#55555f")
    }
    
    func initStatusMap(list:NSMutableArray){
        if isSelectAll {
            for i in 0..<list.count {
                selectedMap[i] = CellStatus.Selected
            }
        }
    }
    
    /**
     显示view
     
     - parameter list: <#list description#>
     */
    func show(list:NSMutableArray){
        self.dataList = list
        initStatusMap(list)
        self.superView.addSubview(self)
        self.tabView.reloadData()
        self.containerView.transform = CGAffineTransformScale(self.transform, CGFloat(0.1), CGFloat(0.1))
        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
            self.containerView.transform = CGAffineTransformScale(self.transform, CGFloat(1), CGFloat(1))
            }) { (finish) -> Void in

        }
    }
    
    /**
     关闭view
     
     - returns: <#return value description#>
     */
    func close(){
        self.containerView.transform = CGAffineTransformScale(self.transform, CGFloat(1), CGFloat(1))
        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
            self.containerView.transform = CGAffineTransformScale(self.transform, CGFloat(0.1), CGFloat(0.1))
            }) { (finish) -> Void in
//               self.containerView.transform = CGAffineTransformScale(self.transform, CGFloat(1), CGFloat(1))
               self.removeFromSuperview()
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identi = "DiagnosisNextViewCell"
        var cell = tabView.dequeueReusableCellWithIdentifier(identi) as? DiagnosisNextViewCell
        if cell == nil {
            cell = DiagnosisNextViewCell()
        }
        let row = indexPath.row
        UITools.setBorderWithView(0.5, tmpColor: cellTittleColor, view: cell!.tittle)
        cell!.tittle.text = dataList[row] as? String
        if (selectedMap[row] == CellStatus.Selected) {
            cell!.tittle.textColor = UIColor(red: 13/255.0, green: 107/255.0, blue: 180/255.0, alpha: 1.0)
        }else{
            cell!.tittle.textColor = UITools.colorWithHexString("#55555f")
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(cellHeight)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tabView.deselectRowAtIndexPath(indexPath, animated: false)
        let select = selectedMap[indexPath.row]
        if select ==  CellStatus.Selected {
            selectedMap[indexPath.row] = CellStatus.UnSelected
            (tabView.cellForRowAtIndexPath(indexPath) as! DiagnosisNextViewCell).tittle.textColor = UITools.colorWithHexString("#c1c1c1")
        }else{
             selectedMap[indexPath.row] = CellStatus.Selected
            (tabView.cellForRowAtIndexPath(indexPath) as! DiagnosisNextViewCell).tittle.textColor = UIColor(red: 13/255.0, green: 107/255.0, blue: 180/255.0, alpha: 1.0)
        }
        
        if getIsSelectAll() {
            initSelectAllBtn()
        }else {
            initSelectNotAllBtn()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    /**
     设置tittle的边框颜色
     
     - parameter color: <#color description#>
     */
    func setCellTittleBorderColor(color:CGColorRef){
        cellTittleColor = color
    }
    
    /**
     获取选择的筛选项
     */
    func getSelectTittles() ->NSMutableArray{
        let list = NSMutableArray()
        for i in 0..<selectedMap.count {
            if selectedMap[i]! == CellStatus.Selected {
               list.addObject(dataList[i])
                print(dataList[i])
            }
        }
        
        return list
    }
   
}