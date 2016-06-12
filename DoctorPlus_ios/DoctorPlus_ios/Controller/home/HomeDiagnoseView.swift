//
//  HomeDiagnoseView.swift
//  DoctorPlus_ios
//
//  主页诊断图表view，包含图表和按钮
//
//  Created by reason on 15/12/2.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import UIKit

class HomeDiagnoseView: HomeBaseView,ComFqHalcyonLogicPracticeGetPatientDiagnoseLogic_GetPatientDiagnoseInterface{
    
    var colors = ["df353e","#845bd5","#227fc2","#18c0c3","#5cbd3c","#999999"]//每种分类的颜色
    
//    var propors: [CGFloat] = [0.7,0.3,0.2] //每种分类的比重(暂时的，到时应该有个类，包含诊断名和百分比)
    var propors:Propors = Propors(propors: [], titls: [])
    
    let divider: CGFloat = 25.0     //各图表之间的水平间隔
    
    let DIVIDERTB: CGFloat = 40.0    //两排图表上下间距
    
    let MARGINTB: CGFloat = 20.0     //view距离cell上下两部的间距
    
    var itemWidth: CGFloat = 10.0     //图表小圆的半径
    
    var logic:ComFqHalcyonLogicPracticeGetPatientDiagnoseLogic!
    
    var width:CGFloat = 0
    
    override func getXibName() -> String {
        return "HomeDiagnoseView"
    }
    
    override func initContentView(width: CGFloat) {
        self.width = width
    }
    
    override func setFrameByWidth(width: CGFloat) {
        self.width = width
    }
    
    override func moreInit() {
        logic = ComFqHalcyonLogicPracticeGetPatientDiagnoseLogic(comFqHalcyonLogicPracticeGetPatientDiagnoseLogic_GetPatientDiagnoseInterface: self)
        logic.getDianoseWithJavaUtilArrayList(JavaUtilArrayList(), withBoolean: true)
        
    }
    
    func initUIView(){
        
        itemWidth = (width - 2*divider)/3  //减去横排三个圆中两个各为20的间隔以及6个各位1.5的边
        let height:CGFloat = propors.count/4 == 0 ? itemWidth+40.0 : 2*(itemWidth+40.0)+DIVIDERTB  //23:20的字高和20的间距
        
        contentView = UIView(frame: CGRectMake(0,MARGINTB,width,height)) //距离cell上下各为20
        addSubview(contentView)
        
        frame = CGRectMake(0,0,width,contentView.frame.height+2*MARGINTB) //view距离cell上下各距20
        
        for(var i = 0; i < propors.count; i++){
            let x = CGFloat(i%3)*(itemWidth+divider)
            let y = i < 3 ? 0 : itemWidth+20+20+DIVIDERTB  //2r为直径，20位诊断title的高度
            
            let diagnoseItem = DiagnoseItemView(frame: CGRectMake(x,y,itemWidth,itemWidth+40.0))
            diagnoseItem.setProgress(propors.propors[i])
            diagnoseItem.setStoreColor(UITools.colorWithHexString(colors[i]))
            diagnoseItem.setTittle(propors.tittles[i])
            diagnoseItem.btnLabel.tag = i + 20
            diagnoseItem.btnLabel.addTarget(self, action: "click:", forControlEvents: UIControlEvents.TouchUpInside)
            diagnoseItem.btnLabel.setBackgroundImage(UITools.imageWithColor(UITools.colorWithHexString(colors[i])), forState: UIControlState.Normal)
            diagnoseItem.btnLabel.setBackgroundImage(UITools.imageWithColor(UIColor.grayColor()), forState: UIControlState.Selected)
            contentView.addSubview(diagnoseItem)
        }
 
    }
    
    func OnGetFailedWithInt(code: Int32, withNSString msg: String!) {
        FQToast.makeError().show("网络不给力！", superview: Tools.getCurrentViewController().view)
    }
    
    func OnGetSuccessWithInt(responseCode: Int32, withInt totalCount: Int32, withJavaUtilArrayList tittles: JavaUtilArrayList!, withJavaUtilArrayList values: JavaUtilArrayList!) {
        var propors:[CGFloat] = [CGFloat]()
        var titls:[String] = [String]()
        
        for i in 0..<tittles.size() {
            titls.append(tittles.getWithInt(i) as! String)
            let value = NSString(format: "%.4f", ((values.getWithInt(i) as! NSString).floatValue)/100).doubleValue
            print(CGFloat(value))
            propors.append(CGFloat(value))
        }
        let propo = Propors(propors: propors, titls: titls)
        self.propors = propo
        initUIView()
    }
    
    override func getItemCount() -> Int {
        return self.propors.count
    }

    func click(sender:UIButton){
        sender.selected = !sender.selected
        home.selectData(FilterCategory.Diagnosis, value: (sender.titleLabel?.text)!, isAdd: sender.selected)
    }
    
    override func reloadData(patienIds: JavaUtilArrayList) {
        contentView.removeFromSuperview()
        logic.getDianoseWithJavaUtilArrayList(patienIds, withBoolean: false)
    }
}
