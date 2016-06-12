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

class GenderChart: UIView {
    
    var centerX: CGFloat = 0  //图表中心点x坐标
    var centerY: CGFloat = 0  //图表中心的y坐标
    
    var propors: [CGFloat] = [0.4,0.45,0.15]  //每一个分类所占的百分比
    
    var colors = ["df353e","#845bd5","#227fc2"]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.clearColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func willMoveToWindow(newWindow: UIWindow?) {
        super.willMoveToWindow(newWindow)
//        if(newWindow != nil){
//            
//        }
    }
    
    
    /**
     开始画图表
     - parameter rect: some
     */
    override func drawRect(rect: CGRect) {
        
        centerX = frame.width/2
        centerY = frame.height/2
        
        let context:CGContextRef =  UIGraphicsGetCurrentContext()!;//获取画笔上下文
        CGContextSetAllowsAntialiasing(context, true) //抗锯齿设置
        
        CGContextSetLineWidth(context, 2.0);
        CGContextSetStrokeColorWithColor(context, UITools.colorWithHexString("40414b").CGColor) //设置画笔颜色
        
        let r = min(frame.width, frame.height)/2-2  //最外层圆环的半径
        
        //画最里面和最外面的圆环
        CGContextAddArc(context, centerX, centerY, r-46, 0, 8, 0) //画弧   //CGFloat(270*M_PI/180)
        CGContextStrokePath(context)
        CGContextAddArc(context, centerX, centerY, r , 0, 8, 0) //画弧   //CGFloat(270*M_PI/180)
        CGContextStrokePath(context)//关闭路径

        CGContextSetLineWidth(context, 25);

        //从-90度开始，顺时针画性别比
        var end:CGFloat = -CGFloat(M_PI_2)
        for (var i = 0; i < propors.count; i++) {
            let start:CGFloat = end
            end = start+2*CGFloat(M_PI)*propors[i]
            CGContextSetStrokeColorWithColor(context, UITools.colorWithHexString(colors[i]).CGColor) //设置画笔颜色
            CGContextAddArc(context, centerX, centerY, r-23, start, end,0) //画弧   //CGFloat(270*M_PI/180)
            CGContextStrokePath(context)//关闭路径//3*3.1415/2, 3.1415/2*3-2*3.1415*propors[i]
        }
    }
}
