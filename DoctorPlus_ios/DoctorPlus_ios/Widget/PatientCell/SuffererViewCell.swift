//
//  SuffererViewCell.swift
//  DoctorPlus_ios
//
//  Created by reason on 15/8/27.
//  Copyright (c) 2015年 YiYiHealth. All rights reserved.
//

import Foundation


class SuffererViewCell : PatientCell{
    
    
//    @IBOutlet weak var contentContainer: UIView!
    
    var labelName:UILabel?
    var labelGender:UILabel?
    var labelNumber:UILabel?
    var btnHeadImg:UIButton!
    
    var suffererEntity:ComFqHalcyonEntityPracticeSuffererAbstract?
    
//    var isClicked:Bool = true
//    var isRecly:Bool = false
    
    var didSendInfo:Bool = false
    

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    /**通过数据，初始化UI*/
    override func initData(data:ComFqHalcyonEntityPracticeRecordData){
//        iConentContainer = contentContainer
        suffererEntity = data as? ComFqHalcyonEntityPracticeSuffererAbstract
        
        if swipe != nil{
            swipe?.removeFromSuperview()
            swipe = nil
        }
        
        initSwipe()
        let view = loadXibByName("SuffererViewCellAlpha", index: 0)
        viewFullInParent(view, parent: swipe?.contentView)
//        var view = NSBundle.mainBundle().loadNibNamed("SuffererViewCellAlpha", owner: self, options: nil)[0] as! UIView
//        BaseViewController.addChildViewFullInParent(view, parent: swipe?.contentView)
        
        btnHeadImg = view.viewWithTag(91) as! UIButton
        labelName = view.viewWithTag(92) as? UILabel
        labelGender = view.viewWithTag(93) as? UILabel
        labelNumber = view.viewWithTag(94) as? UILabel
        
        
        UITools.setRoundBounds(btnHeadImg.frame.size.width/2, view: btnHeadImg)//btnHeadImg.frame.size.width/2
        
        if suffererEntity != nil {
            labelName?.text = suffererEntity!.getSuffererName()
            labelGender?.text = suffererEntity!.getGender()
            labelNumber?.text = "\(suffererEntity!.getMemberNumber())"
        }
        
        //下载用户头像
        loadImage(btnHeadImg, imageId: suffererEntity!.getHeadImgId())
//        var imageId:Int32 = suffererEntity!.getHeadImgId()
//        if imageId != 0 {
//            btnHeadImg!.downLoadImageWidthImageId(Int32(imageId), callback: { (view, path) -> Void in
//                self.btnHeadImg!.setBackgroundImage(UITools.getImageFromFile(path), forState: UIControlState.Normal)
//            })
//        }
        
        btnAddTarget(btnHeadImg, action:"suffererInfo")
//        btnHeadImg.addTarget(self, action: Selector("suffererInfo"), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    override func getSwipeCellName() -> String {
        return "SuffererSwipeCell"
    }
    
//    /**初始化侧滑控件*/
//    func initSwipe(){
//        let cellIdentifier: String = "SuffererSwipeCell"
//        swipe = MGSwipeTableCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: cellIdentifier)
//        swipe?.backgroundColor = UIColor(red: 29/255.0, green: 31/255.0, blue: 102/255.0, alpha: 1)
//        
//        BaseViewController.addChildViewFullInParent(swipe, parent: self.contentContainer)
//        
//        swipe?.rightSwipeSettings.transition = MGSwipeTransitionStatic
//        swipe?.rightExpansion.buttonIndex = -1
//        swipe?.rightExpansion.fillOnTrigger = true
//        
//        //先把滑动出右边按钮功能关掉
////        swipe?.rightButtons = createRightButtons() as [AnyObject]
//        var tapGesture = UITapGestureRecognizer(target: self, action: Selector("onItemClicked"))
//        swipe?.addGestureRecognizer(tapGesture)
//    }
    
    /**创建右滑后打开的菜单按钮*/
   override func createRightButtons() -> NSArray? {
        var btns = NSMutableArray()
        var title = ["保存"]
        
        let color = getMenuButtonColor()
        
        for i in 0..<title.count{
            var button:MGSwipeButton?
            button = MGSwipeButton(title: title[i], icon: nil, backgroundColor: color)
            
            btnAddTarget(button, action: "onSaveClicked")
        }
//        return btns
        return nil //先禁止侧滑功能
    }
    
    /**查看患者资料*/
    func suffererInfo(){
        let controller = UserInfoViewController()
        controller.scanUrl = "\(ComFqLibToolsUriConstants.getUserURL())?user_id=\(suffererEntity!.getSuffererId())"
        Tools.getCurrentViewController(self).navigationController?.pushViewController(controller, animated: true)
    }
    
    /**整个view被点击*/
    override func onItemClicked(){
        let controller = ChooseMemberViewController()
        controller.suffererEntity = suffererEntity
        
        Tools.getCurrentViewController(self).navigationController?.pushViewController(controller, animated: true)
    }
    
    /**保存按钮被点击*/
    func onSaveClicked(){
        
    }
    
}