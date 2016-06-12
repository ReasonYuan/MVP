//
//  LookFollowUpView.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-5-15.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class LookFollowUpView: UIView,ComFqHalcyonLogic2CancleFollowUpLogic_CancleFollowUpLogicInterface{
    
    let width:CGFloat = UIScreen.mainScreen().bounds.size.width
    let height:CGFloat = UIScreen.mainScreen().bounds.size.height
    var mView:UIView?
    @IBOutlet weak var doctorHead: UIButton!
    @IBOutlet weak var patientHead: UIButton!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var doctorName: UILabel!
    @IBOutlet weak var patientName: UILabel!
    @IBOutlet weak var cancleFollowUpBtn: UIButton!
    @IBOutlet weak var textVIew: UITextView!
    @IBOutlet weak var backGroundBtn: UIButton!
    var mPatient:ComFqHalcyonEntityContacts?
    var callBack:UpdateCallBack?
    var mCurrentCycle:ComFqHalcyonEntityOnceFollowUpCycle?
    var mTimerId:Int = 0
    var mItemsId:JavaUtilArrayList?
    var navigationController:UINavigationController?
    var mCustomDialog:CustomIOS7AlertView?
    var cancleFollowUpLogic:ComFqHalcyonLogic2CancleFollowUpLogic?
    override init(frame: CGRect) {
        super.init(frame: frame)
        mView = NSBundle.mainBundle().loadNibNamed("LookFollowUpView", owner: self, options: nil)[0] as? UIView
        mView?.frame = CGRectMake(20, 0, frame.size.width - 40, frame.size.height)
        self.addSubview(mView!)
        UITools.setBorderWithHeadKuang(doctorHead)
        UITools.setBorderWithHeadKuang(patientHead)
        cancleFollowUpBtn.setBackgroundImage(UITools.imageWithColor(UIColor.whiteColor()), forState: UIControlState.Normal)
        cancleFollowUpBtn.setBackgroundImage(UITools.imageWithColor(UIColor(red: 234/255, green: 236/255, blue: 235/255, alpha: 1.0)), forState: UIControlState.Highlighted)
        cancleFollowUpBtn.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        cancleFollowUpBtn.setTitleColor(UIColor(red: 98/255, green: 192/255, blue: 180/255, alpha: 1.0), forState: UIControlState.Highlighted)
        UITools.setBorderWithView(1, tmpColor: UIColor(red: 98/255, green: 192/255, blue: 180/255, alpha: 1.0).CGColor, view: cancleFollowUpBtn)
        cancleFollowUpBtn.titleLabel?.font = UIFont.systemFontOfSize(16)
        backGroundBtn.contentMode = UIViewContentMode.ScaleAspectFit
        backGroundBtn.setBackgroundImage(Tools.createNinePathImageForImage(UIImage(named: "followup_kuang.png"), leftMargin: 30.0, rightMargin: 35.0, topMargin: 30.0, bottomMargin: 35.0), forState: UIControlState.Normal)
    }
   

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setData(itemsId:JavaUtilArrayList,data:String,patient:ComFqHalcyonEntityContacts,mCycle:ComFqHalcyonEntityOnceFollowUpCycle,timerId:Int,mCallBack:UpdateCallBack,navigation:UINavigationController){
        callBack = mCallBack
        mPatient = patient
        mTimerId = timerId
        mCurrentCycle = mCycle
        mItemsId = itemsId
        doctorName.text = ComFqLibToolsConstants.getUser().getName()
        patientName.text = mPatient?.getName()
        time.text = "随访时间： \(data)"
        doctorHead.downLoadImageWidthImageId(ComFqLibToolsConstants.getUser().getImageId(), callback: { (view, path) -> Void in
            let tmpBtn:UIButton = view as! UIButton
            tmpBtn.setBackgroundImage(UITools.getImageFromFile(path), forState: UIControlState.Normal)
        })
        patientHead.downLoadImageWidthImageId(mPatient?.getImageId(), callback: { (view, path) -> Void in
            let tmpBtn:UIButton = view as! UIButton
            tmpBtn.setBackgroundImage(UITools.getImageFromFile(path), forState: UIControlState.Normal)
        })
        
        textVIew.text = mCurrentCycle?.getmItemName()
        navigationController = navigation
    }
    
    /**病人头像点击**/
    @IBAction func patientHeadClick(sender: AnyObject) {
        let controller =  PatientDetailViewController()
        controller.mPatientFriendId = mPatient?.getUserId()
        navigationController?.pushViewController(controller, animated: true)
    }
    
   
    func onCancleBtnClick(){
        if mCustomDialog == nil {
            mCustomDialog = CustomIOS7AlertView()
            setDialogStyle(sureDelBtn,cancelBtn: cancelDelBtn)
            mCustomDialog?.containerView = delFollowUp
            mCustomDialog?.show()
        }else {
            mCustomDialog?.show()
        }
    }
    
    /**取消随访Dialog的确定按钮**/
    func onSureBtnClick(){
        cancleFollowUpLogic = ComFqHalcyonLogic2CancleFollowUpLogic(comFqHalcyonLogic2CancleFollowUpLogic_CancleFollowUpLogicInterface: self)
        if thisTimeBtn.selected {
            cancleFollowUpLogic?.cancleOneFollowUpWithInt((mCurrentCycle?.getmItemtId())!)
        }else if allBtn.selected {
            cancleFollowUpLogic?.cancleAllFollowUpWithInt(Int32(mTimerId))
        }
    }
    
     /**取消随访Dialog的取消按钮**/
    @IBAction func cancleClick(sender: AnyObject) {
        onCancleBtnClick()
    }
    
    func onCancleErrorWithInt(code: Int32, withNSString msg: String!) {
         mCustomDialog?.close()
    }
    
    
    func onCancleSuccess() {
        /**此处没有设置取消闹钟**/
        if thisTimeBtn.selected {
            callBack?.onCallBack(1)
        }else if allBtn.selected{
            callBack?.onCallBack(2)
        }
         mCustomDialog?.close()
    }
    
    func onErrorWithInt(code: Int32, withJavaLangThrowable error: JavaLangThrowable!) {
        UIAlertViewTool.getInstance().showAutoDismisDialog("取消随访失败！", width: 210, height: 120)
    }
    
    @IBOutlet var delFollowUp: UIView!
    @IBOutlet weak var thisTimeBtn: UIButton!
    @IBOutlet weak var allBtn: UIButton!
    @IBOutlet weak var sureDelBtn: UIButton!
    @IBOutlet weak var cancelDelBtn: UIButton!
    
    func setDialogStyle(sureBtn:UIButton, cancelBtn:UIButton){
        UITools.setButtonStyle(sureBtn, buttonColor: Color.color_emerald, textSize: 24, textColor: Color.color_emerald)
        UITools.setButtonStyle(cancelBtn, buttonColor: Color.color_grey, textSize: 24, textColor: Color.color_grey,isOpposite:true)
        UITools.setBtnWithOneRound(sureBtn, corners: UIRectCorner.BottomLeft)
        UITools.setBtnWithOneRound(cancelBtn, corners: UIRectCorner.BottomRight)
        UITools.setRoundBounds(9,view: delFollowUp)
        UITools.setBorderWithView(1, tmpColor: Color.color_emerald.CGColor, view: cancelBtn)
        UITools.setSelectBtnStyle(thisTimeBtn, selectedColor: Color.color_emerald, unSelectedColor: Color.color_grey)
        UITools.setSelectBtnStyle(allBtn, selectedColor: Color.color_emerald, unSelectedColor: Color.color_grey)
        thisTimeBtn.selected = true
        allBtn.selected = false
    }
    
    @IBAction func onThisTimeClick() {
        thisTimeBtn.selected = true
        allBtn.selected = false
    }
    
    @IBAction func onAllTimeClick() {
        thisTimeBtn.selected = false
        allBtn.selected = true
    }

    /**dialog确定取消按钮**/
    @IBAction func cancleFollowupClick(sender: AnyObject) {
        onSureBtnClick()
    }
    
    /**dialog取消按钮**/
    @IBAction func dismissCancle(sender: AnyObject) {
        mCustomDialog?.close()
    }
}

protocol UpdateCallBack {
    func onCallBack(type:Int)
}
