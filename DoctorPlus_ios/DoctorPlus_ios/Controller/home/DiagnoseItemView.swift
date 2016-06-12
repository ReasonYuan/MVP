//
//  DiagnoseItemView.swift
//  DoctorPlus_ios
//
//  Created by reason on 15/12/3.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import UIKit

class DiagnoseItemView: UIView {
    
    @IBOutlet weak var progressLabel: UILabel!   //百分比标签
//    @IBOutlet weak var diagnoseLabel: UILabel!   //诊断标签
    @IBOutlet weak var chartContainer: UIView!   //图表容器
    @IBOutlet weak var btnLabel: UIButton!
    
    
    var progressView: CircleView!   //圆环
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("DiagnoseItemView", owner: self, options: nil)
        let view = nibs.lastObject as! UIView

        UITools.addChildViewFullInParent(view, parent: self)
        
        let r = frame.width/2-1.5
        
        progressView = CircleView(frame: CGRectMake(0,0,2*r,2*r))
        
        progressView.circleRadius = r
        progressView.setStoreWidth(3.0)
        
        UITools.addChildViewFullInParent(progressView, parent: chartContainer)
        UITools.setRoundBounds(2.0, view: btnLabel)
        print(btnLabel)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //设置百分比
    func setProgress(progress: CGFloat){
        progressView.progress = progress
        progressLabel.text = "\(progress*100)%"
    }
    
    //
    func setStoreColor(color: UIColor){
        progressView.setStoreColor(color)
        progressLabel.textColor = color
    }
    
    func setTittle(str:String){
        btnLabel.setTitle(str, forState: UIControlState.Normal)
    }
   
}
