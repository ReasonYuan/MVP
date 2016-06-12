//
//  HomeGenderView.swift
//  DoctorPlus_ios
//
//  主页性别图表view，包含图表和按钮
//
//  Created by reason on 15/12/2.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import UIKit

class HomeGenderView: HomeBaseView ,ComFqHalcyonPracticeGetChartLogic_GetSexChartInterface{

    @IBOutlet weak var chartContainer: UIView!
    
    @IBOutlet weak var oGenderBtn: UIButton!
    
    var propors = [CGFloat]() //每一个分类所占的百分比
    
    var titles = JavaUtilArrayList()
    
    var colors = ["df353e","#845bd5","#227fc2","#18c0c3","#5cbd3c","#999999"]
    var logic:ComFqHalcyonPracticeGetChartLogic!
    override init(width: CGFloat, home: ChartHomeViewController) {
        super.init(width: width, home: home)
        logic = ComFqHalcyonPracticeGetChartLogic()
        logic.getSexChartWithJavaUtilArrayList(JavaUtilArrayList(), withBoolean: true, withComFqHalcyonPracticeGetChartLogic_GetSexChartInterface: self)
        
    }
    
    
    override func reloadData(patienIds: JavaUtilArrayList) {
        logic.getSexChartWithJavaUtilArrayList(patienIds, withBoolean: false, withComFqHalcyonPracticeGetChartLogic_GetSexChartInterface: self)
    }
    
    func onGetSexErrorWithInt(code: Int32, withNSString msg: String!) {
        
    }
    
    func onGetSexSuccessWithInt(totalCount: Int32, withJavaUtilArrayList titles: JavaUtilArrayList!, withJavaUtilArrayList values: JavaUtilArrayList!) {
        
        propors.removeAll()
        self.titles = titles
        for var i:Int32 = 0 ; i < values.size() ; i++ {
            let integer = values.getWithInt(i) as! JavaLangInteger
            let count = CGFloat(integer.intValue())
            let propor = CGFloat(count/CGFloat(totalCount))
            propors.append(propor)
        }
        moreInit()
        
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func getXibName() -> String {
        return "HomeGenderView"
    }

    
    override func setFrameByWidth(width: CGFloat) {
        self.frame = CGRectMake(0, 0, frame.width, frame.width-126+29+20+13)
    }
    
    override func moreInit() {
        let genderView: GenderChart = GenderChart(frame: CGRectMake(0,0,chartContainer.frame.width,chartContainer.frame.height))
        genderView.propors = propors
        genderView.colors = colors
        UITools.addChildViewFullInParent(genderView, parent: chartContainer)
        
        initButtons()
    }

    override func getItemCount() -> Int {
        return 3
    }
    
    /**
     初始化可以选择的按钮
     */
    func initButtons() {
        
        //给保留的按钮设置状态
        for(var i = 0; i < propors.count; i++){
            let button: UIButton = viewWithTag(i+20) as! UIButton
            
            if titles.size() != 0 {
                button.setTitle(titles.getWithInt(Int32(i)) as? String, forState: UIControlState.Normal)
            }
            
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
    }
    
    /**
     该类型下数据被点击
     */
    func itemClick(sender:UIButton) {
        sender.selected = !sender.selected
        home.selectData(FilterCategory.Gender, value: (sender.titleLabel?.text)!, isAdd: sender.selected)
    }
}
