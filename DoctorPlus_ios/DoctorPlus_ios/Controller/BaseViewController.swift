//
//  BaseViewController.swift
//  DocPlus_ios
//
//  Created by XiWang on 15-4-24.
//  Copyright (c) 2015年 FQ. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    let grayColor:UIColor = UIColor(red: CGFloat(241.0/255.0), green: CGFloat(241.0/255.0), blue: CGFloat(241.0/255.0), alpha: CGFloat(1))
    @IBOutlet weak var leftText: UILabel!
    @IBOutlet weak var bigRightBtn: UIButton!
    @IBOutlet weak var bigLeftBtn: UIButton!
    @IBOutlet weak var leftImage: UIImageView!
    @IBOutlet weak var topTittle: UILabel!
    @IBOutlet weak var rightImage: UIImageView!
    @IBOutlet weak var leftBtn: UIButton!
    @IBOutlet weak var rightBtn: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var TopBar: UIView!
    @IBOutlet weak var rightLabel: UILabel!
    let mWidth = UIScreen.mainScreen().applicationFrame.size.width
    let mHeight = UIScreen.mainScreen().applicationFrame.size.height
    let width:CGFloat = UIScreen.mainScreen().bounds.size.width
    let height:CGFloat = UIScreen.mainScreen().bounds.size.height
    var mTrash:ComFqHalcyonPracticeTrash!;
    override func viewDidLoad() {
        mTrash = ComFqHalcyonPracticeTrash.getInstance()
        super.viewDidLoad()
        let xibName = getXibName()
        if "" != xibName {
            let mView:UIView? = NSBundle.mainBundle().loadNibNamed(getXibName(), owner: self, options: nil)[0] as? UIView
            mView?.backgroundColor = grayColor
            BaseViewController.addChildViewFullInParent(mView, parent: containerView)
        }
        initTopBtn()

    }
    
    class func addChildViewFullInParent(child:UIView!,parent:UIView!){
        child.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(child)
        parent.addConstraint(NSLayoutConstraint(item: child, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: parent, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        parent.addConstraint(NSLayoutConstraint(item: child, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: parent, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
        parent.addConstraint(NSLayoutConstraint(item: child, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: parent, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0))
        parent.addConstraint(NSLayoutConstraint(item: child, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: parent, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0))
    }

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        TalkingData.trackPageBegin(self.getXibName())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    init() {
        super.init(nibName: "BaseViewController", bundle:nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getXibName() -> String{
        return ""
    }
    
    /**设置Tittle内容**/
    func setTittle(str:String){
        topTittle.hidden = false
        topTittle.text = str
    }
    
    /**设置Tittle是否隐藏**/
    func hiddenTittle(yes:Bool){
        topTittle.hidden = true
    }
    
    func setRightBtnTittle(str:String){
        rightBtn.hidden = true
        bigRightBtn.hidden = false
        rightLabel.text = str
        rightLabel.hidden = false
//        bigRightBtn.setTitleColor(Colo, forState: UIControlState.Normal)
    }
    
    /**
    设置右边按钮是否可点击
    **/
    func setRightBtnClickable(isClick:Bool){
        bigRightBtn.userInteractionEnabled = isClick
    }
    
    /**
    设置右边按钮title颜色
    **/
    func setRightBtnTitleColor(color:UIColor){
        rightLabel.textColor = color
    }
    
    /**
    设置左边按钮text
    **/
    func setLeftTextString(str:String){
        leftText.text = str
    }
    
    /**
    设置LeftTopBar图片 使用默认的back功能 可以不用调用此函数
    **/
    func setLeftImage(isHiddenBtn yes:Bool = true,image:UIImage = UIImage(named:"icon_topleft.png")!){
        if yes {
            leftBtn.hidden = yes
            bigLeftBtn.hidden = yes
            leftText.hidden = yes
        }else {
             leftBtn.setBackgroundImage(image, forState: UIControlState.Normal)
             leftText.hidden = yes
        }
    }
    
    /**
    设置RightTopBar图片 使用默认的功能 可以不用调用此函数
    **/
    func setRightImage(isHiddenBtn yes:Bool = true,image:UIImage = UIImage(named:"icon_topright_add.png")!){
        if yes {
            rightBtn.hidden = yes
            bigRightBtn.hidden = yes
            rightLabel.hidden = true
        }else {
            rightBtn.setBackgroundImage(image, forState: UIControlState.Normal)
            rightLabel.hidden = true
            rightBtn.hidden = false
        }
    }
    
    /**
    隐藏LeftTopBar
    **/
    func hiddenLeftImage(yes:Bool){
        leftBtn.hidden = yes
        bigLeftBtn.hidden = yes
        leftText.hidden = yes
    }
    
    /**
    隐藏RightTopBar
    **/
    func hiddenRightImage(yes:Bool){
        rightBtn.hidden = yes
        bigRightBtn.hidden = yes
        rightLabel.hidden = yes
    }
    
    /**LeftTopBar点击事件，子Controller可以选择重写自己的处理方法**/
    func onLeftBtnOnClick(sender:UIButton){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
     /**RightTopBar点击事件，子Controller可以选择重写自己的处理方法**/
    func onRightBtnOnClick(sender:UIButton){
        
    }

    /**
    初始化Topbar
    **/
    func initTopBtn(){
        let leftDefaultImage = UIImage(named:"icon_topleft.png")!
        leftBtn.setBackgroundImage(leftDefaultImage, forState: UIControlState.Normal)
        bigLeftBtn.addTarget(self, action: "onLeftBtnOnClick:", forControlEvents: UIControlEvents.TouchUpInside)
        let rightDefaultImage = UIImage(named:"icon_topright_add.png")!
        rightBtn.setBackgroundImage(rightDefaultImage, forState: UIControlState.Normal)
        bigRightBtn.addTarget(self, action: "onRightBtnOnClick:", forControlEvents: UIControlEvents.TouchUpInside)

    }
    
    /**
    隐藏键盘
    **/
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
        TalkingData.trackPageEnd(self.getXibName())
    }
    
    deinit{
        print("---------------->  \(NSStringFromClass(self.classForCoder)) delloc! ");
    }
    
    func getTrashList(type:String!) -> [Int32]{
        var list = [Int32]()
        let javaArray = mTrash.getTrashWithNSString(type)
        for var i:Int32 = 0 ; i < javaArray.size() ; i++ {
            let intenger:JavaLangInteger = javaArray.getWithInt(i) as! JavaLangInteger
            list.append(intenger.intValue())
        }
        return list
    }
   
}
