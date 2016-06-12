//
//  RecordTypeLeftMenu.swift
//  TestSwift
//
//  Created by 王曦 on 15/12/8.
//  Copyright © 2015年 王曦. All rights reserved.
//

import Foundation
import UIKit
protocol RecordTypeBtnDelegate {
    func btnOnClick(sender:UIButton)
}

enum MENU_STATE {
    case SHOW
    case CLOSE
    case SHOWING
}

enum SCROLL_STATE {
    case RUNNING
    case STOP
    case START
}
class RecordTypeLeftMenu:UIView {
    var backgroudImageView:UIImageView!
    var btnList:[RecordTypeLeftButton] = [RecordTypeLeftButton]()
    
    /// btn的宽高
    var btnWidth:CGFloat = 40
    
    /// 6个btn上下两端空白距离
    var tmpHeight:CGFloat = 100
    /// 每个btn间的间距
    var tmpDiastance:CGFloat = 10
    
    var showFrame:CGRect = CGRectMake(0, 0, 65, ScreenHeight - 70)
    var closeFrame:CGRect = CGRectMake(-65, 0, 65, ScreenHeight - 70)
    
    /// 6个btn的点击事件回调
    var btnDelagate:RecordTypeBtnDelegate?
    
    /// menu动画的执行状态
    var menuState:MENU_STATE =  .CLOSE
   
    /// 外部控件的滚动状态
    var scrollState:SCROLL_STATE = .STOP
    /// 调用自动关闭menu的次数
    var closeMenuTimes:Int = 0
    /**
     初始化Menu的位置
     
     - parameter frame:       frame
     - parameter btnDelegate: btn的回调
     */
    init(frame: CGRect,btnDelegate:RecordTypeBtnDelegate?) {
        super.init(frame: frame)
        backgroudImageView = UIImageView(frame: CGRectMake(0,0,frame.width,frame.height))
        backgroudImageView.image =  UIImage(imageLiteral: "record_left_menu.png")
        addSubview(backgroudImageView)
        alpha = 0.9
        tmpHeight = (frame.height - 10 * 6 - btnWidth * 6)/2
        self.btnDelagate = btnDelegate
        initRecordTypeBtn()
        initBtnClickListener()
        self.hidden = true
    }
    
    /**
     初始化6个btn
     */
    private func initRecordTypeBtn(){
        let ruyuan = RecordTypeLeftButton(frame: CGRectMake(self.frame.width/2 - btnWidth/2,tmpHeight,btnWidth,btnWidth),tittle: "入院")
        let huayan = RecordTypeLeftButton(frame: CGRectMake(self.frame.width/2 - btnWidth/2,tmpHeight + tmpDiastance + btnWidth,btnWidth,btnWidth),tittle: "化验")
        let jiancha = RecordTypeLeftButton(frame: CGRectMake(self.frame.width/2 - btnWidth/2,tmpHeight + tmpDiastance*2 + btnWidth*2,btnWidth,btnWidth),tittle: "检查")
        let shoushu = RecordTypeLeftButton(frame: CGRectMake(self.frame.width/2 - btnWidth/2,tmpHeight + tmpDiastance*3 + btnWidth*3,btnWidth,btnWidth),tittle: "手术")
        let chuyuan = RecordTypeLeftButton(frame: CGRectMake(self.frame.width/2 - btnWidth/2,tmpHeight + tmpDiastance*4 + btnWidth*4,btnWidth,btnWidth),tittle: "出院")
        let qita = RecordTypeLeftButton(frame: CGRectMake(self.frame.width/2 - btnWidth/2,tmpHeight + tmpDiastance*5 + btnWidth*5,btnWidth,btnWidth),tittle: "其他")
        btnList.append(ruyuan)
        btnList.append(huayan)
        btnList.append(jiancha)
        btnList.append(shoushu)
        btnList.append(chuyuan)
        btnList.append(qita)
        
        self.addSubview(ruyuan)
        self.addSubview(huayan)
        self.addSubview(jiancha)
        self.addSubview(shoushu)
        self.addSubview(chuyuan)
        self.addSubview(qita)

    }

    /**
     showMenu
     
     - parameter complete: 完成的回调
     */
    func show(complete:(ok:Bool)->()){
        self.hidden = false
        if menuState == .SHOWING ||  menuState == .SHOW{
            return
        }
        self.menuState = .SHOWING
        UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.frame = self.showFrame
            }) { (ok) -> Void in
                self.menuState = .SHOW
                complete(ok: ok)
        }
    }
    
    /**
     closeMenu
     
     - parameter complete: 完成的回调
     */
    func close(complete:(ok:Bool)->()){
        if menuState == .SHOWING || menuState == .CLOSE{
            return
        }
        self.menuState = .SHOWING
        UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.frame = self.closeFrame
            }) { (ok) -> Void in
                self.menuState = .CLOSE
                complete(ok: ok)
                self.hidden = true
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   private func initBtnClickListener(){
        for i in 0..<btnList.count {
            btnList[i].tag = i
            btnList[i].addTarget(self, action: "btnOnClick:", forControlEvents: UIControlEvents.TouchUpInside)
        }
    }
    
    internal func btnOnClick(sender:UIButton){
        let tag = sender.tag
        print(tag)
        print("\(sender.titleLabel?.text)")
        print("----------")
        btnDelagate?.btnOnClick(sender)
        switch tag {
        case 0:
            break
        case 1:
            break
        case 2:
            break
        case 3:
            break
        case 4:
            break
        case 5:
            break
        default:
            return
            
        }
    }
    
    /**
     设置Btn不能点击
     
     - parameter index: 0~6 btn的位置
     */
    func setBtnNotEnable(index:Int){
        btnList[index].enabled = false
    }
    
    /**
     设置Btn能点击
     
     - parameter index: 0~6 btn的位置
     */
    func setBtnEnable(index:Int){
        btnList[index].enabled = true
    }
    
    func startTimerCloseMenu(){
        closeMenuTimes++
        Tools.Post({ () -> Void in
            self.closeMenuTimes--
            self.checkExecuteFuction()
            }, delay: 2)
    }
    
    private func checkExecuteFuction(){
        if closeMenuTimes != 0 {
            return
        }else{
            self.closeMenu()
        }
    }
    
    private func closeMenu(){
        if menuState == .SHOWING || menuState == .CLOSE || scrollState == .RUNNING || scrollState == .START {
            return
        }else{
            print("当前状态\(scrollState)")
            close { (ok) -> () in

            }
        }
    }

}