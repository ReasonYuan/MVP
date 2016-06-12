//
//  HomeBaseView.swift
//  DoctorPlus_ios
//
//  主页cell内view的基类。其他cell的view均继承至它
//
//  Created by reason on 15/12/1.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import UIKit

class HomeBaseView: UIView {
    

    var contentView: UIView!
    
    var home: ChartHomeViewController!
    
    init(width:CGFloat, home:ChartHomeViewController){
        super.init(frame:CGRectMake(0, 0, width, 0))
        
        self.home = home
        
        initContentView(width)
        setFrameByWidth(width)
        moreInit()
    }
    
//    init(width:CGFloat, home:ChartHomeViewController,propors:Propors){
//        super.init(frame:CGRectMake(0, 0, width, 0))
//        
//        self.home = home
//        
//        initData(propors)
//        initContentView(width)
//        setFrameByWidth(width)
//        moreInit()
//    }
    
//    func initData(propors:Propors){
//        self.propors = propors
//    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     初始化(填充)内部的view
     - parameter width: 控件宽度
     */
    func initContentView(width: CGFloat){
        let nibs:NSArray = NSBundle.mainBundle().loadNibNamed(getXibName(), owner: self, options: nil)
        contentView = nibs.lastObject as! UIView
        contentView.frame = CGRectMake(0, 0, width, contentView.frame.size.height)
        UITools.addChildViewFullInParent(contentView, parent: self)
    }
    
    /**
     更多其他的初始化，一般为对view添加具体的图表
     */
    func moreInit() {
        
    }
    
    /**
     由得到的宽度算出高度，从而重新设置控件的frame
     */
    func setFrameByWidth(width: CGFloat){
        frame = CGRectMake(0, 0, width,  contentView.frame.size.height)
    }
    
    /**
     得到主页item对应的xib的名字
     - returns: xib的名字
     */
    func getXibName() -> String {
        return "HomeRecordView"
    }
    
    
    /**
     得到控件高度
     - returns: 控件高度
     */
    func getHeight() -> CGFloat {
        return frame.height
    }
    
    /**
     清除该类型下所有已选择的数据
     */
    func clearSelected() {
        let lastTag = 20+getItemCount()
        
        for(var i = 20; i < lastTag; i++){
            let btn = viewWithTag(i) as! UIButton
            btn.selected = false
        }
    }
    
    /**
     该类型下所含有的分类数
     */
    func getItemCount() -> Int {
        return 0
    }
    
    /**
     重新刷新数据
     */
    func reloadData(patienIds:JavaUtilArrayList){
        
    }
}
