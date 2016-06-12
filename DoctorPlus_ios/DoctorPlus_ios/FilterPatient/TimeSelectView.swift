//
//  TimeSelectView.swift
//  DoctorPlus_ios
//
//  Created by sunning on 15/12/17.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import UIKit

class TimeSelectView: UIView {

    var baseList = NSMutableArray()
    @IBOutlet var datePicker: UIDatePicker!
    var isMenuShow = false
    var filterStartTime = ""
    var filterEndTime = ""
    var isStartDate = true
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var startTimeButton: UIButton!
    @IBOutlet weak var endTimeButton: UIButton!
    init(frame: CGRect,startTime: String,endTime: String) {
        super.init(frame: frame)
        let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("TimeSelectView", owner: self, options: nil)
        let view = nibs.firstObject as! UIView
        view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height)
        self.addSubview(view)
        UITools.setRoundBounds(11, view: titleLabel)
        startTimeButton.layer.borderColor = UITools.colorWithHexString("#c1c1c1").CGColor
        startTimeButton.layer.borderWidth = 1
        startTimeButton.layer.cornerRadius = 3
        endTimeButton.layer.borderColor = UITools.colorWithHexString("#c1c1c1").CGColor
        endTimeButton.layer.borderWidth = 1
        endTimeButton.layer.cornerRadius = 3
        startTimeButton.setTitleColor(UITools.colorWithHexString("#55555F"), forState: UIControlState.Normal)
        endTimeButton.setTitleColor(UITools.colorWithHexString("#55555F"), forState: UIControlState.Normal)
        //字体大小自适应，解决iphone5上日期显示不完而出现省略号的问题
        startTimeButton.titleLabel?.adjustsFontSizeToFitWidth = true
        endTimeButton.titleLabel?.adjustsFontSizeToFitWidth = true
        datePicker.frame = CGRectMake(0, ScreenHeight, ScreenWidth, 216)
        datePicker.backgroundColor = UIColor.whiteColor()
        addResetNotification()
        let controller = Tools.getCurrentViewController()
        controller.view.addSubview(datePicker)
        if startTime != "" {
            startTimeButton.setTitle(startTime, forState: UIControlState.Normal)
        }
        if endTime != "" {
            endTimeButton.setTitle(endTime, forState: UIControlState.Normal)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
    @IBAction func dateChange(sender: UIDatePicker) {
        let control = sender
        let date = control.date
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.stringFromDate(date)
        
                //字体大小自适应，解决iphone5上日期显示不完而出现省略号的问题
                startTimeButton.titleLabel?.adjustsFontSizeToFitWidth = true
                endTimeButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
                if(isStartDate){
                    startTimeButton.setTitle(dateString, forState: UIControlState.Normal)
                }else{
                    endTimeButton.setTitle(dateString, forState: UIControlState.Normal)
                }
    }
    
    //开始时间按钮点击
    @IBAction func startTimeClicked(sender: AnyObject) {
        print("开始时间点击")
        isStartDate = true
        
        if endTimeButton.titleLabel?.text != nil && endTimeButton.titleLabel?.text != "结束时间" {
            if startTimeButton.titleLabel?.text != nil && startTimeButton.titleLabel?.text != "开始时间" {
                if startTimeButton.titleLabel?.text != "开始时间" && startTimeButton.titleLabel?.text != "结束时间" {
                    let dateFormater = NSDateFormatter()
                    let startTime:String! = ((startTimeButton.titleLabel?.text)! as NSString).substringToIndex(4) as String + "年" + ((startTimeButton.titleLabel?.text)! as NSString).substringWithRange(NSMakeRange(5, 2)) + "月" + ((startTimeButton.titleLabel?.text)! as NSString).substringWithRange(NSMakeRange(8, 2))
                    dateFormater.dateFormat = "yyyy年MM月dd"
                    let date = dateFormater.dateFromString(startTime)
                    datePicker.date = date!
                }else{
                    datePicker.date = NSDate()
                }
            }
            let dateFormater = NSDateFormatter()
            let time:String! = ((endTimeButton.titleLabel?.text)! as NSString).substringToIndex(4) as String + "年" + ((endTimeButton.titleLabel?.text)! as NSString).substringWithRange(NSMakeRange(5, 2)) + "月" + ((endTimeButton.titleLabel?.text)! as NSString).substringWithRange(NSMakeRange(8, 2))
            dateFormater.dateFormat = "yyyy年MM月dd"
            let date = dateFormater.dateFromString(time)
            datePicker.maximumDate = date!
            datePicker.minimumDate = nil
        }
        
        setControllerShow()
    }
    
    //结束时间按钮点击
    @IBAction func endTimeClicked(sender: AnyObject) {
        print("结束时间点击")
        isStartDate = false
        if startTimeButton.titleLabel?.text != "开始时间"  {
            if endTimeButton.titleLabel?.text != nil && endTimeButton.titleLabel?.text != "结束时间"{
                if endTimeButton.titleLabel?.text != nil && endTimeButton.titleLabel?.text != "结束时间" {
                    let dateFormater = NSDateFormatter()
                    let endTime:String! = ((endTimeButton.titleLabel?.text)! as NSString).substringToIndex(4) as String + "年" + ((endTimeButton.titleLabel?.text)! as NSString).substringWithRange(NSMakeRange(5, 2)) + "月" + ((endTimeButton.titleLabel?.text)! as NSString).substringWithRange(NSMakeRange(8, 2))
                    dateFormater.dateFormat = "yyyy年MM月dd"
                    let date = dateFormater.dateFromString(endTime)
                    datePicker.date = date!
                }else{
                    datePicker.date = NSDate()
                }
            }
            let dateFormater = NSDateFormatter()
            let time:String! = ((startTimeButton.titleLabel?.text)! as NSString).substringToIndex(4) as String + "年" + ((startTimeButton.titleLabel?.text)! as NSString).substringWithRange(NSMakeRange(5, 2)) + "月" + ((startTimeButton.titleLabel?.text)! as NSString).substringWithRange(NSMakeRange(8, 2))
            dateFormater.dateFormat = "yyyy年MM月dd"
            let date = dateFormater.dateFromString(time)
            datePicker.minimumDate = date!
            datePicker.maximumDate = nil
        }
        setControllerShow()
    }
    
    func closeController(){
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.5)
        UIView.setAnimationDelegate(self)
        UIView.setAnimationCurve(UIViewAnimationCurve.EaseInOut)
        
        isMenuShow = false
        datePicker.frame.origin.y = ScreenHeight
        datePicker.alpha = 0.0
        UIView.setAnimationDidStopSelector(Selector("hiddenView"))
        
        UIView.commitAnimations()
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
            UIView.setAnimationDidStopSelector(Selector("hiddenView"))
        }else{
            isMenuShow = true
            datePicker.frame = CGRectMake(0, ScreenHeight - 216, ScreenWidth, 216)
            datePicker.alpha = 1.0
        }
        
        UIView.commitAnimations()
    }
    
    //添加重置选择的通知
    func addResetNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onResetFilterKeys", name: ChoseFilterKeysView.FilterNotificationKey, object: nil)
    }
    
    //重置选择的操作
    func onResetFilterKeys() {
        print("-------------------time  clear")
        filterStartTime = ""
        filterEndTime = ""
        startTimeButton.setTitle("开始时间", forState: UIControlState.Normal)
        endTimeButton.setTitle("结束时间", forState: UIControlState.Normal)
    }

    //设置筛选的数据
    //keys : ArrayList<ComFqHalcyonEntityPracticeFilterItem>
    func setKeys(keys:JavaUtilArrayList) {
        let list = NSMutableArray()
        for i in 0..<keys.size() {
            list.addObject((keys.getWithInt(i) as! ComFqHalcyonEntityPracticeFilterItem).getItemsName())
        }
        if list.count >= 2 {
            startTimeButton.setTitle(list[0] as? String, forState: UIControlState.Normal)
            endTimeButton.setTitle(list[1] as? String, forState: UIControlState.Normal)
        }else if list.count == 1 {
            startTimeButton.setTitle(list[0] as? String, forState: UIControlState.Normal)
            endTimeButton.setTitle(list[0] as? String, forState: UIControlState.Normal)
        }else if list.count == 0{
            startTimeButton.setTitle("开始时间", forState: UIControlState.Normal)
            endTimeButton.setTitle("结束时间", forState: UIControlState.Normal)
        }
        
    }
    
    /**
     获取筛选的结果
     
     - returns: <#return value description#>
     */

    
    func getStartTime() -> String{
        if startTimeButton.titleLabel?.text == "开始时间"{
            return ""
        }
        return (startTimeButton.titleLabel?.text)!
    }
    
    func getEndTime() -> String{
        if endTimeButton.titleLabel?.text == "结束时间"{
            return ""
        }
        return (endTimeButton.titleLabel?.text)!
    }
}
