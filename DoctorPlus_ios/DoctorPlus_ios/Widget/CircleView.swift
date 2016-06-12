//
//  CircleView.swift
//  DoctorPlus_ios
//
//  圆环控件，由于需要路径动画，所以用CALayer实现
//
//  Created by reason on 15/12/3.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import UIKit

class CircleView: UIView {


    let circlePathLayer = CAShapeLayer()  //路径画布
    var circleRadius: CGFloat = 8.0       //圆的半径

    var progress: CGFloat = 1.0           //圆弧占圆的百分比
    
    var isShowWholeCircle = true          //是否需要画外层的整圆
    
    //圆环路径长度，1为整圆环，0时则什么都没有
    var progressLine: CGFloat {
        get {
            return circlePathLayer.strokeEnd
        }
        set {
            if (newValue > progress) {
                circlePathLayer.strokeEnd = progress
            } else if (newValue < 0) {
                circlePathLayer.strokeEnd = 0
            } else {
                circlePathLayer.strokeEnd = newValue
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.clearColor()
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willMoveToWindow(newWindow: UIWindow?) {
        super.willMoveToWindow(newWindow)
        
        if(newWindow != nil){
            progressLine = 0.0
            drawPathStart()
        }
    }
    
    //配置画笔参数
    func configure() {
        progressLine = 0.0
        circlePathLayer.frame = bounds
        circlePathLayer.lineWidth = 5.0
        circlePathLayer.fillColor = UIColor.clearColor().CGColor
        circlePathLayer.strokeColor = UIColor.grayColor().CGColor
        circlePathLayer.lineCap = kCALineCapRound
        
        layer.addSublayer(circlePathLayer)
    }
    
    //赋值一个path给circlelayer
    func circleFrame() -> CGRect {
        var circleFrame = CGRect(x: 0, y: 0, width: 2*circleRadius, height: 2*circleRadius)
        circleFrame.origin.x = CGRectGetMidX(circlePathLayer.bounds) - CGRectGetMidX(circleFrame)
        circleFrame.origin.y = CGRectGetMidY(circlePathLayer.bounds) - CGRectGetMidY(circleFrame)
        return circleFrame
    }
    
    //创建路径
    func circlePath() -> UIBezierPath {
        return UIBezierPath(ovalInRect: circleFrame())
    }
    
    //由于layers没有autoresizingMask这个属性，所以需要在layoutSubviews方法更新circlePathLayer的frame来恰当地响应view的size变化。
    override func layoutSubviews() {
        super.layoutSubviews()
            circlePathLayer.frame = bounds
            circlePathLayer.path = circlePath().CGPath
    }
    
    //开始画路径
    func drawPathStart(){
        let timer = NSTimer.scheduledTimerWithTimeInterval(0.02, target: self, selector: "storeLine:", userInfo: nil, repeats:true);
        timer.fire()
    }
    
    //画路径的计算器
    func storeLine(timer: NSTimer) {
        progressLine += 0.02
        if(progressLine >= progress){
            timer.invalidate()
        }
    }
    
    //设置圆环的颜色
    func setStoreColor(color:UIColor){
        circlePathLayer.strokeColor = color.CGColor
    }
    
    func setStoreCap(lineCap:String){
        circlePathLayer.lineCap = lineCap
    }
    
    func setStoreWidth(width: CGFloat){
        circlePathLayer.lineWidth = width
    }
    
    
    /**
     画一个整圆，根据参数isShowWholeCircle判断是否需要画
     - parameter rect: some
     */
    override func drawRect(rect: CGRect) {
        
        if(!isShowWholeCircle){
            return
        }
        
        let centerX = frame.width/2
        let centerY = frame.height/2
        
        let context:CGContextRef =  UIGraphicsGetCurrentContext()!;//获取画笔上下文
        CGContextSetAllowsAntialiasing(context, true) //抗锯齿设置
        
        CGContextSetLineWidth(context, circlePathLayer.lineWidth);
        CGContextSetStrokeColorWithColor(context, UITools.colorWithHexString("363848").CGColor) //设置画笔颜色
        
        //画圆
        CGContextAddArc(context, centerX, centerY, circleRadius, 0, 8, 0) //画弧   //CGFloat(270*M_PI/180)
        CGContextStrokePath(context)
    }
}
