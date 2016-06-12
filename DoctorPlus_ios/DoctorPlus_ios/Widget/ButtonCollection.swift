//
//  ButtonCollection.swift
//  TestSwift
//
//  Created by 王曦 on 15/11/25.
//  Copyright © 2015年 王曦. All rights reserved.
//

import Foundation
import UIKit

@objc protocol ButtonCollectionDelegate {
    optional func LeftOnClick(sender:UIButton)
    optional func UpOnClick(sender:UIButton)
    optional func RightOnClick(sender:UIButton)
    optional func DownOnClick(sender:UIButton)
}

enum CerterBtnState{
    case SHOW
    case CLOSE
}

enum Direction {
    case UP
    case LEFT
    case RIGHT
    case DOWN
}

class ButtonCollection:UIView {
    /// 展开button的个数,目前设计只考虑了2个和3个
    var btnCount:Int = 0
    /// button图片的集合
    var btnImageList:[String] = [String]()
    
    /// button禁止点击图片的集合
//    var btnNotEnableImageList:[String] = [String]()
    
    /// 居中的默认Button
    var centerBtn:UIButton!
    /// centerBtn周围btn的集合
    var btnList:[UIButton] = [UIButton]()
    
    /// centerBtn周围btn的固定宽高
    let  GROUPBTNWIDTH:CGFloat = 50.0
    let GROUPBTNHEIGHT:CGFloat = 50.0
    let BTNDISTANCE:CGFloat = 20
    
    /// centerBtn的状态，展开或是关闭
    var centerBtnState:CerterBtnState = .CLOSE
    
    /// centerBtn两种状态下的image
    var centerBtnImageList:[String] = [String]()
    
    var superView:UIView!
    
    var moveDistance:CGFloat = 0
    
    var durationTime = 0.3
    
    var damping:CGFloat = 0.5
    
    var velocity:CGFloat = 0.5
    
    var btnClickDelegate:ButtonCollectionDelegate!

    /**
     初始化控件
     
     - parameter frame:                 控件的frame
     - parameter count:                 周围btn数量，目前只支持2个或者3个的样式
     - parameter centerBtnImageList:    中心按钮的图片列表，分别为普通状态和按下状态
     - parameter btnImageList:          周围btn普通状态的图片列表，分别为left，right，up，down
     - parameter btnNotEnableImageList: 周围btn不能点击状态的图片列表，分别为left，right，up，down
     - parameter superView:             需要将该控件加入的父类view
     - parameter delegate:              周围btn的点击时间回调
     
     - returns: <#return value description#>
     */
    init(frame:CGRect,btnCount count:Int,centerBtnImageList:[String],btnNormalList btnImageList:[String],superView:UIView,delegate:ButtonCollectionDelegate){
        super.init(frame: frame)
        print("初始化ButtonCollection")
        self.superView = superView
        centerBtn = UIButton(frame: frame)
        centerBtnState = .CLOSE
        centerBtn.addTarget(self, action: Selector("centerBtnClick:"), forControlEvents: UIControlEvents.TouchUpInside)
        self.btnCount = count
        self.btnImageList = btnImageList
        self.centerBtnImageList = centerBtnImageList
//        self.btnNotEnableImageList = btnNotEnableImageList
        self.btnClickDelegate = delegate
        createGroupBtn(btnCount, centerBtn: centerBtn)
        self.userInteractionEnabled = false
    }
  
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     创建centerBtn周围的btn
     */
    func createGroupBtn(btnCount:Int,centerBtn:UIButton){
        
        let centerX = centerBtn.center.x - GROUPBTNWIDTH/2
        let centerY = centerBtn.center.y - GROUPBTNHEIGHT/2
        
        switch btnCount {
        case 1:
            break
        case 2:
            let leftBtn = UIButton(frame: CGRectMake(centerX,centerY,GROUPBTNWIDTH,GROUPBTNHEIGHT))
            let rightBtn = UIButton(frame: CGRectMake(centerX,centerY,GROUPBTNWIDTH,GROUPBTNHEIGHT))
            
            leftBtn.setBackgroundImage(UIImage(imageLiteral: btnImageList[0]), forState: UIControlState.Normal)
            rightBtn.setBackgroundImage(UIImage(imageLiteral: btnImageList[1]), forState: UIControlState.Normal)
            
            btnList.append(leftBtn)
            btnList.append(rightBtn)
            self.superView.addSubview(leftBtn)
            self.superView.addSubview(rightBtn)
            break
        case 3:
            let leftBtn = UIButton(frame: CGRectMake(centerX,centerY,GROUPBTNWIDTH,GROUPBTNHEIGHT))
            let rightBtn = UIButton(frame: CGRectMake(centerX,centerY,GROUPBTNWIDTH,GROUPBTNHEIGHT))
            let upBtn = UIButton(frame: CGRectMake(centerX,centerY,GROUPBTNWIDTH,GROUPBTNHEIGHT))
            
            leftBtn.setBackgroundImage(UIImage(imageLiteral: btnImageList[0]), forState: UIControlState.Normal)
            rightBtn.setBackgroundImage(UIImage(imageLiteral: btnImageList[1]), forState: UIControlState.Normal)
            upBtn.setBackgroundImage(UIImage(imageLiteral: btnImageList[2]), forState: UIControlState.Normal)
            
            btnList.append(leftBtn)
            btnList.append(rightBtn)
            btnList.append(upBtn)
            
            self.superView.addSubview(leftBtn)
            self.superView.addSubview(rightBtn)
            self.superView.addSubview(upBtn)
            break
        default:
            return
        }
        
        for i in 0..<self.btnList.count {
            btnList[i].tag = i
            UITools.setRoundBounds(GROUPBTNWIDTH/2, view: btnList[i])
            btnList[i].addTarget(self, action: Selector("groupBtnClick:"), forControlEvents: UIControlEvents.TouchUpInside)
        }
        
        UITools.setRoundBounds(centerBtn.frame.size.width/2, view: centerBtn)
        moveDistance = (BTNDISTANCE + self.centerBtn.frame.size.width/2 + self.btnList[0].frame.size.width/2)
        centerBtn.setBackgroundImage(UIImage(imageLiteral: centerBtnImageList[0]), forState: UIControlState.Normal)
        self.superView.addSubview(centerBtn)
    }
    
    /**
     centerBtn点击事件
     */
    func centerBtnClick(btn:UIButton){
        update()
    }
    
    func update() {
        self.centerBtn.enabled = false
        if centerBtnState == .CLOSE {
            showGroupBtn()
        }
        if centerBtnState == .SHOW{
            closeGroupBtn()
        }
        
    }
    
    /**
     展开btn动画
     */
    func showGroupBtn(){
        centerBtn.setBackgroundImage(UIImage(imageLiteral: centerBtnImageList[1]), forState: UIControlState.Normal)
            if btnCount == 2 {
                UIView.animateWithDuration(durationTime, delay: 0, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                    self.btnList[0].center.x -= self.moveDistance
                    self.btnList[1].center.x += self.moveDistance
                    }, completion: { (ok) -> Void in
                        self.centerBtnState = .SHOW
                        self.centerBtn.enabled = true
                })
            }
            
            if btnCount == 3 {
                UIView.animateWithDuration(durationTime, delay: 0, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                    self.btnList[0].center.x -= self.moveDistance
                    self.btnList[1].center.x += self.moveDistance
                    self.btnList[2].center.y -= self.moveDistance
                    }, completion: { (ok) -> Void in
                        self.centerBtnState = .SHOW
                        self.centerBtn.enabled = true
                })
            }
       
    }
    
    /**
     收回btn动画
     */
    func closeGroupBtn(){
        centerBtn.setBackgroundImage(UIImage(imageLiteral: centerBtnImageList[0]), forState: UIControlState.Normal)
            if btnCount == 2 {
                UIView.animateWithDuration(durationTime, delay: 0, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                    self.btnList[0].center.x += self.moveDistance
                    self.btnList[1].center.x -= self.moveDistance
                    }, completion: { (ok) -> Void in
                        self.centerBtnState = .CLOSE
                        self.centerBtn.enabled = true
                })
            }
            
            if btnCount == 3 {
                UIView.animateWithDuration(durationTime, delay: 0, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                    self.btnList[0].center.x += self.moveDistance
                    self.btnList[1].center.x -= self.moveDistance
                    self.btnList[2].center.y += self.moveDistance
                    }, completion: { (ok) -> Void in
                        self.centerBtnState = .CLOSE
                        self.centerBtn.enabled = true
                })
            }
        
    }
    
    /**
     设置某个方向的btn不能点击
     
     - parameter direction: <#direction description#>
     */
    func setBtnNotEnable(direction:Direction,imageName:String){
        switch direction {
        case .LEFT:
            btnList[0].setBackgroundImage(UIImage(imageLiteral: imageName), forState: UIControlState.Disabled)
            btnList[0].enabled = false
            break
        case .RIGHT:
            btnList[1].setBackgroundImage(UIImage(imageLiteral: imageName), forState: UIControlState.Disabled)
            btnList[1].enabled = false
            break
        case .UP:
            btnList[2].setBackgroundImage(UIImage(imageLiteral: imageName), forState: UIControlState.Disabled)
            btnList[2].enabled = false
            break
        case .DOWN:
            break
       
        }
    }
    
    /**
     设置某个方向的btn能点击
     
     - parameter direction: <#direction description#>
     */
    func setBtnEnable(direction:Direction){
        switch direction {
        case .LEFT:
            btnList[0].setBackgroundImage(UIImage(imageLiteral: btnImageList[0]), forState: UIControlState.Normal)
            btnList[0].enabled = true
            break
        case .RIGHT:
            btnList[1].setBackgroundImage(UIImage(imageLiteral: btnImageList[1]), forState: UIControlState.Normal)
            btnList[1].enabled = true
            break
        case .UP:
            btnList[2].setBackgroundImage(UIImage(imageLiteral: btnImageList[2]), forState: UIControlState.Normal)
            btnList[2].enabled = true
            break
        case .DOWN:
            break
            
        }
    }
    
    /**
     更换某个方向Btn的图片
     
     - parameter direction: 方向
     - parameter imageName: 名字
     */
    func setBtnNormalImage(direction:Direction,imageName:String){
        switch direction {
        case .LEFT:
            btnList[0].setBackgroundImage(UIImage(imageLiteral: imageName), forState: UIControlState.Normal)
            break
        case .RIGHT:
            btnList[1].setBackgroundImage(UIImage(imageLiteral: imageName), forState: UIControlState.Normal)
            break
        case .UP:
            btnList[2].setBackgroundImage(UIImage(imageLiteral: imageName), forState: UIControlState.Normal)
            break
        case .DOWN:
            break
            
        }

    }
    
    /**
     外部btn的点击事件
     
     - parameter sender: <#sender description#>
     */
    func groupBtnClick(sender:UIButton){
        let tag = sender.tag
        switch tag {
        case 0:
            btnClickDelegate.LeftOnClick!(sender)
            print("左边按钮被点击")
            break
        case 1:
            btnClickDelegate.RightOnClick!(sender)
            print("右边边按钮被点击")
            break
        case 2:
            btnClickDelegate.UpOnClick!(sender)
            print("上边按钮被点击")
            break
        case 3:
            btnClickDelegate.DownOnClick!(sender)
            print("下边按钮被点击")
            break
        default:
            return
        }
    }
    
    /**
     隐藏view
     */
    func hidden(){
        for i in 0..<self.btnList.count  {
            (self.btnList[i] as UIView).hidden = true
        }
        centerBtn.hidden = true
        self.hidden = true
    }
    
    /**
     显示view
     */
    func show(){
        for i in 0..<self.btnList.count  {
            (self.btnList[i] as UIView).hidden = false
        }
        centerBtn.hidden = false
        self.hidden = false
    }
    
}