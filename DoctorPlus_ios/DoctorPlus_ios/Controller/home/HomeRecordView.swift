//
//  HomeRecordView.swift
//  DoctorPlus_ios
//
//  主页第一个cell内的view，点击进入行医生涯的按钮
//
//  Created by reason on 15/12/1.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import UIKit

class HomeRecordView: HomeBaseView {

    
//    let MARGIN_LR = 50.0  //按钮距离两边的间隔
    

    override func initContentView(width: CGFloat) {
        let btnHeight = width - 100  //按钮两边各距50
        contentView = UIView(frame: CGRectMake(0,0,width,btnHeight+50))//按钮上距30，下距20
        UITools.addChildViewFullInParent(contentView, parent: self)
        
        
        let btn: UIButton = UIButton(frame: CGRectMake(50,30,btnHeight,btnHeight))
        btn.setBackgroundImage(UIImage(named: "xysy.png"), forState: UIControlState.Normal)
        btn.addTarget(self, action: "onRecordClick:", forControlEvents: UIControlEvents.TouchUpInside)
        contentView.addSubview(btn)
    }
    
    override func setFrameByWidth(width: CGFloat) {
        self.frame = CGRectMake(0, 0, width,  contentView.frame.size.height)
    }
    
    /**
     行医生涯按钮被点击，跳转到行医生涯页面
     */
    func onRecordClick(sender: AnyObject) {
        let controller = PatientViewController()
        Tools.getCurrentViewController().navigationController?.pushViewController(controller, animated: true)
    }
}
