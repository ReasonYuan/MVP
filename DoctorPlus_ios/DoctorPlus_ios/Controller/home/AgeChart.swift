//
//  GenderChart.swift
//  EChartsDemo
//
//  年龄view的图表部分，专门画主页年龄的view
//
//  Created by reason on 15/11/26.
//  Copyright © 2015年 reason. All rights reserved.
//

import UIKit

class AgeChart: UIView {
    
    var centerX: CGFloat = 0  //图表中心点x坐标
    var centerY: CGFloat = 0  //图表中心的y坐标
    
    var propors: [CGFloat] = [0.0]  //每一个分类所占的百分比
    
    var colors = ["df353e","#845bd5","#227fc2","#18c0c3","#5cbd3c","#999999"]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        propors = [0.7,0.3,0.2,0.05,0.1,0.15]
        backgroundColor = UIColor.clearColor()
        
        
        var r:CGFloat = 16.0
        for (var i = 0; i < propors.count; i++) {
            let circle = CircleView(frame: frame)
            circle.circleRadius = r
            UITools.addChildViewFullInParent(circle, parent: self)
        
            let progress = CircleView(frame: frame)
            progress.setStoreCap(kCALineCapRound)
            progress.setStoreColor(UITools.colorWithHexString(colors[i]))
            progress.progress = propors[i]
            progress.circleRadius = r
            UITools.addChildViewFullInParent(progress, parent: self)
            
            r += 8.0
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     开始画图表
     - parameter rect: some
     */
    override func drawRect(rect: CGRect) {
        
//        centerX = frame.width/2
//        centerY = frame.height/2
//        
//        let context:CGContextRef =  UIGraphicsGetCurrentContext()!;//获取画笔上下文
//        CGContextSetAllowsAntialiasing(context, true) //抗锯齿设置
//        CGContextSetLineWidth(context, 5.0);
//        
//        CGContextSetStrokeColorWithColor(context, UIColor.grayColor().CGColor) //设置画笔颜色
//        
//        let len = min(frame.width, frame.height)
//        var r = len/15
//        
//        for _ in propors{
//            CGContextAddArc(context, centerX, centerY, r+12 , 0, 8, 0) //画弧   //CGFloat(270*M_PI/180)
//            CGContextStrokePath(context)//关闭路径
//            r += 8
//        }
//        
//        CGContextSetLineCap(context,CGLineCap.Round)
//        //        r = len/10
//        var start:CGFloat = 3*3.14159/2
//        for (var i = 0; i < propors.count; i++) {
//            r -= 8
//            CGContextSetStrokeColorWithColor(context, UITools.colorWithHexString(colors[i]).CGColor) //设置画笔颜色
//            CGContextAddArc(context, centerX, centerY, r+12, start, start-2*3.1415*propors[i],1) //画弧   //CGFloat(270*M_PI/180)
//            CGContextStrokePath(context)//关闭路径//3*3.1415/2, 3.1415/2*3-2*3.1415*propors[i]
//            start -= 3.14159/12
//        }
    }
}
