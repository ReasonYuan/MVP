//
//  HomeGenderView.swift
//  DoctorPlus_ios
//
//  主页年龄图表view，包含图表和按钮
//
//  Created by reason on 15/12/1.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import UIKit

class HomeAgeView: HomeBaseView ,ComFqHalcyonLogicPracticeHomeAgeLogic_HomeAgeLogicCallBack{

    let colors = ["df353e","#845bd5","#227fc2","#18c0c3","#5cbd3c","#999999"]//每种分类的颜色
    
    @IBOutlet weak var chartContainer: UIView!
    
    @IBOutlet weak var btnAgeFirst: UIButton!
    @IBOutlet weak var btnAgeSecond: UIButton!
    @IBOutlet weak var btnAgeThird: UIButton!
    @IBOutlet weak var btnAgeFourth: UIButton!
    @IBOutlet weak var btnAgeFifth: UIButton!
    @IBOutlet weak var btnAgeSex: UIButton!
    
    var propors = [CGFloat]() //每种分类的比重
    
    var btnArray = [UIButton]()
    
    var homeAgeAllData:ComFqHalcyonEntityPracticeHomeAge? //获取的用户所有的数据
    var isFromFilter = false //是否是从筛选界面过来的
    
    var circleViewsArray = [CircleView]()
    
    override func getXibName() -> String {
        return "HomeAgeView"
    }

    override func setFrameByWidth(width: CGFloat) {
        let containerWidth: CGFloat = width - 126   //容器左右两边各距63
        chartContainer.frame = CGRectMake(63,20,containerWidth,containerWidth)  //容器上下各距离20

        frame = CGRectMake(0, 0, width,  chartContainer.frame.height+40)
    }
    
    override func moreInit() {
        
        btnArray = [btnAgeFirst,btnAgeSecond,btnAgeThird,btnAgeFourth,btnAgeFifth,btnAgeSex]
        getAgeLogic()
    }
        
    override func getItemCount() -> Int {
        return 6
    }
    
    func initChart() {
        var r = (chartContainer.frame.width)/4;   //最里面的小圆半径
        
        //笔粗，由公式:2x*(count-1)+x-0.5x=width而来，默认笔粗和两圆之间的间距一样，-0.5x是因为半径是从笔粗的中间算的
        let patient = r / CGFloat((2.0*CGFloat(6) - 1.5))
        //最外层圈的半径
        r = r + 2*patient*5
        let f = CGRectMake(0,0,chartContainer.frame.width,chartContainer.frame.height)
        for (var i = 0; i < propors.count; i++) {
            //            let circle = CircleView(frame: f)
            //            circle.circleRadius = r
            //            circle.setStoreWidth(5.0)
            //            UITools.addChildViewFullInParent(circle, parent: chartContainer)
            
            let progress = CircleView(frame: f)
            progress.setStoreWidth(patient)
            progress.setStoreColor(UITools.colorWithHexString(colors[i]))
            progress.progress = propors[i]
            progress.circleRadius = r
            UITools.addChildViewFullInParent(progress, parent: chartContainer)
            
            r -= 2*patient //从里面的圆往外面半径递加。其中笔粗为5，间距为5
            circleViewsArray.append(progress)
        }
    }
    
    /**
     初始化可以选择的按钮
     - returns: <#return value description#>
     */
    func initButtons() {
        
        //给保留的按钮设置状态
        for(var i = 0; i < propors.count; i++){
            let button: UIButton = viewWithTag(i+20) as! UIButton
            
            button.backgroundColor = UIColor.clearColor()
            
            if(propors[i] == 0.0){
                button.setBackgroundImage(UITools.imageWithColor(UIColor.clearColor()), forState: UIControlState.Disabled)
                button.enabled = false
                continue
            }
            
            UITools.setRoundBounds(2, view: button)
            let color = UITools.colorWithHexString(colors[i])
            button.setBackgroundImage(UITools.imageWithColor(color), forState: UIControlState.Normal)
            button.setBackgroundImage(UITools.imageWithColor(UIColor.grayColor()), forState: UIControlState.Selected)
            button.addTarget(self, action: "itemClick:", forControlEvents: UIControlEvents.TouchUpInside)
        }
        
        //隐藏掉多余的按钮
        if(propors.count < 6){
            for(var i = propors.count; i < 6; i++){
                viewWithTag(i+20)?.hidden = true
            }
        }
    }
    
    func itemClick(sender:UIButton) {
        sender.selected = !sender.selected
        home.selectData(FilterCategory.Age, value: (sender.titleLabel?.text)!, isAdd: sender.selected)
    }
    
    //主页获取全部数据的logic
    func getAgeLogic() {
        isFromFilter = false
        if homeAgeAllData == nil {
            let logic = ComFqHalcyonLogicPracticeHomeAgeLogic(comFqHalcyonLogicPracticeHomeAgeLogic_HomeAgeLogicCallBack: self)
            logic.getAgeLogic()
        }else{
            setAgeData(homeAgeAllData!)
        }
    }
    
    //通过筛选结果获取数据的logic
    func getAgeWithFilterLogic(patientList:JavaUtilArrayList) {
        isFromFilter = true
        for item in circleViewsArray {
            item.removeFromSuperview()
        }
        circleViewsArray = [CircleView]()
        let logic = ComFqHalcyonLogicPracticeHomeAgeLogic(comFqHalcyonLogicPracticeHomeAgeLogic_HomeAgeLogicCallBack: self)
        logic.getAgeLogicWithJavaUtilArrayList(patientList)
    }
    
    func getHomeAgeErrorWithInt(code: Int32, withNSString e: String!) {
        let logic = ComFqHalcyonLogicPracticeHomeAgeLogic(comFqHalcyonLogicPracticeHomeAgeLogic_HomeAgeLogicCallBack: self)
        logic.getAgeLogic()
    }
    
    func getHomeAgeSuccessWithComFqHalcyonEntityPracticeHomeAge(homeAge: ComFqHalcyonEntityPracticeHomeAge!) {
        
        if !isFromFilter {
            homeAgeAllData = homeAge
        }
        
        setAgeData(homeAge)
    }
    
    func setAgeData(homeAge: ComFqHalcyonEntityPracticeHomeAge) {
        propors.removeAll()
        let ageList = homeAge.getAgeList()
        let ageListCount = ageList.size()
        let totalPatientCount = CGFloat(homeAge.getTotalPatientCount())
        let ageMap = homeAge.getAgeMap()
        
        for i in 0..<Int(ageListCount) {
            let key = ageList.getWithInt(Int32(i)) as! String
            let scope = ageMap.getWithId(key) as! CGFloat
            btnArray[i].hidden = false
            btnArray[i].setTitle(key, forState: UIControlState.Normal)
            propors.append(scope/totalPatientCount)
        }
        
        initButtons()
        initChart()
    }
    
    override func reloadData(patienIds: JavaUtilArrayList) {
        getAgeWithFilterLogic(patienIds)
    }
}
