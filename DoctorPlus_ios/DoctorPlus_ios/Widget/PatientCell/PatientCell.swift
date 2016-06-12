//
//  PatientCell.swift
//  DoctorPlus_ios
//
//  Created by reason on 15/10/22.
//  Copyright (c) 2015年 YiYiHealth. All rights reserved.
//

import UIKit

class PatientCell : UITableViewCell,PatientCellProtocol{

    internal var conentContainer: UIView?
    
    internal var swipe: MGSwipeTableCell?  //侧滑控件
    
    internal var indexPath: NSIndexPath?   //cell的序号

    internal var iEvent: PatientCellEventProtocol?  //cell（所有需要用到）的点击事件
    
    var isClickEnable: Bool!
    
    /**
    初始化方法,对外的
    
    - parameter data:    cell所要展示的数据
    - parameter dexPath: cell的序号
    - parmeter event:  cell（所有需要用到）的点击事件
    */
    func initData(data:ComFqHalcyonEntityPracticeRecordData,dexPath:NSIndexPath,event:PatientCellEventProtocol?){
        indexPath = dexPath
        iEvent = event
        
        conentContainer = self.viewWithTag(77)
        
        initData(data)
    }
    
    /**
    初始化方法，需要子类去实现
    - parameter data: cell所要展示的数据
    */
    func initData(data:ComFqHalcyonEntityPracticeRecordData){}
    
    /**
    - 设置是否可以滑动
    */
    func setCanSliding(isCanSliding: Bool) {
        swipe?.setEditing(isCanSliding, animated: false)
    }
    
    /**
    得到缓存的swipecell的识别名字，需要子类重写
    - returns: swipecell的名字
    */
    func getSwipeCellName() -> String{
        return "SwiftCellName"
    }
    
    /**
    得到侧滑菜单按钮的颜色
    - returns: UIColor 按钮的颜色
    */
    func getMenuButtonColor() -> UIColor{
        return UIColor(red: 29/255.0, green: 31/255.0, blue: 102/255.0, alpha: 1)
    }
    
    /**
    返回左滑时菜单按钮，需要子类重写
    - returns: 按钮就的集合
    */
    func createRightButtons() -> NSArray? {
        return nil
    }
    func createRightButtons(icons:[String],actions:[String]) -> NSArray? {
        let array = NSMutableArray()
        let color = getMenuButtonColor()
        
        for i in 0..<icons.count{
            var button:MGSwipeButton?
            button = MGSwipeButton(title: nil, icon: UIImage(named: icons[i]), backgroundColor: color)
            button?.addTarget(self, action: Selector(actions[i]), forControlEvents: UIControlEvents.TouchUpInside)
            array.addObject(button!)
        }
        
        return array
    }
    
    /**
    填充数据
    - parameter view: 包含有各种需要填充数据的控件的View
    */
    func fillData(view:UIView){}
    
    /**
    Item 是否可以点击
    - parameter isEnable: true表示可以点击，反正则不能点击
    */
    func setClickEnable(isEnable: Bool) {
        isClickEnable = isEnable
    }
    
    /**
    通过xib名字得到布局的View
    - parameter xibName: xib布局文件的名字
    - parameter index:   文件中布局view的序号
    - returns: view
    */
    func loadXibByName(xibName:String!,index:Int) -> UIView {
        return NSBundle.mainBundle().loadNibNamed(xibName, owner: self, options: nil)[index] as! UIView
    }
    
    /**
    控件自适应父控件填满布局
    - parameter chile:  需要自适应的子控件
    - parameter parent: 子控件的父控件
    */
    func viewFullInParent(child:UIView!,parent:UIView!){
        BaseViewController.addChildViewFullInParent(child, parent: parent)
    }
    
    /**
    初始化侧滑控件
    */
    func initSwipe(){
        let cellIdentifier: String = getSwipeCellName()
        swipe = MGSwipeTableCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: cellIdentifier)
        swipe?.backgroundColor = UIColor(red: 29/255.0, green: 31/255.0, blue: 102/255.0, alpha: 1)
        
        BaseViewController.addChildViewFullInParent(swipe, parent: conentContainer)
        
        swipe?.rightSwipeSettings.transition = MGSwipeTransitionStatic
        swipe?.rightExpansion.buttonIndex = -1
        swipe?.rightExpansion.fillOnTrigger = true
        
        //先把滑动出右边按钮功能关掉
        let btns = createRightButtons() as? [AnyObject]
        if(btns != nil){
            swipe?.rightButtons = btns
        }
        
        setClickListener()
    }
    
    func setClickListener(){
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("onItemClicked"))
        swipe?.addGestureRecognizer(tapGesture)
    }
    
    /**
    下载图片并在view中显示
    - parameter imageView: 显示图片的控件
    - parameter imageId:   要下载图片的id
    */
    func loadImage(view:UIView!,imageId:Int32!){
        if imageId != 0 {
            view.downLoadImageWidthImageId(Int32(imageId), callback: { (view, path) -> Void in
                let tmpImageView = view as! UIButton
                tmpImageView.setBackgroundImage(UITools.getImageFromFile(path), forState: UIControlState.Normal)
            })
        }
    }
    
    /**
    给按钮设置点击的方法
    - parameter btn:    需要设置点击事件的方法
    - parameter action: 方法的名字
    */
    func btnAddTarget(btn:UIButton!,action:String!){
        btn.addTarget(self, action: Selector(action), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    /**
    整个Cell被点击
    */
    func onItemClicked(){
        
    }
    
}