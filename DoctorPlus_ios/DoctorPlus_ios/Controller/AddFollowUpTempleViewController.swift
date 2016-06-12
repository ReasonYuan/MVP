//
//  AddFollowUpTempleViewController.swift
//  DoctorPlus_ios
//
//  Created by monkey on 15-5-14.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class AddFollowUpTempleViewController: BaseViewController ,NAPickerViewDelegate,UITextViewDelegate,ComFqHalcyonLogic2OperateFollowUpTempleLogic_OperateFollowUpTempleLogicInterface,ComFqHalcyonLogic2SearchFollowUpTempleDetailLogic_SearchFollowUpTempleDetailLogicInterface {
    
    @IBOutlet weak var edtTempleName: UITextField!
    @IBOutlet weak var edtTempleContent: UITextView!
    @IBOutlet weak var saveTempleBtn: UIButton!
    @IBOutlet weak var delTempleBtn: UIButton!
    @IBOutlet weak var lastTimeView: UIView!
    @IBOutlet weak var nextTimeView: UIView!
    @IBOutlet weak var templeTimeLabel: UILabel!
    @IBOutlet weak var templeFirstTimeLable: UILabel!
    @IBOutlet var choseTimeAlert: UIView!
    @IBOutlet weak var timeBottomLine: UILabel!
    @IBOutlet weak var timeBtn: UIButton!
    
    
    var currentIndex:Int = 1
    var delAlertView:CustomIOS7AlertView?
    var choseTimeAlertView:CustomIOS7AlertView?
    var templeList = [ComFqHalcyonEntityOnceFollowUpCycle]()
    var numberPickView:NAPickerView?
    var datePickView:NAPickerView?
    var numberList = [String]()
    var dateList = [String]()
    var currentOnceFollowUpCycle:ComFqHalcyonEntityOnceFollowUpCycle?
    var followUpTemple:ComFqHalcyonEntityFollowUpTemple!
    var mCurrentId:Int32!
    var isFirstTimeShow = false
    //    var mCurrentTemp:ComFqHalcyonEntityFollowUpTemple!
    
    
    var templeStyle:Int?
    let ADD_TEMPLE:Int = 1
    let FROM_SEND:Int = 2
    let FROM_EDIT:Int = 3
    var isGetdata = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
//        Tools.runOnOtherThread({ () -> AnyObject! in
//            self.setChoseTimeViewData()
//            return nil
//        }, callback: { (tt) -> Void in
//            
//        })
        setChoseTimeViewData()
    }
    
    func initView(){
        if templeStyle == ADD_TEMPLE {
            setTittle("新增模板")
        }else{
            setTittle("编辑随访")
            getDate()
        }
        
        hiddenRightImage(true)
        UITools.setViewBorder(1, borderColor: Color.color_grey, backgroundColor: UIColor.whiteColor(),view: edtTempleName)
        UITools.setViewBorder(1, borderColor: Color.color_emerald, backgroundColor: UIColor.whiteColor(),view: edtTempleContent)
        UITools.setButtonStyle(delTempleBtn, buttonColor: Color.color_grey, textSize: 16, textColor: UIColor.blackColor(), isOpposite: true)
        UITools.setButtonStyle(saveTempleBtn, buttonColor: Color.color_emerald, textSize: 24, textColor: Color.color_emerald,radius:5)
        isFirstTime(true)
        if templeStyle == ADD_TEMPLE {
            initFollowUp()
            currentOnceFollowUpCycle = templeList[currentIndex - 1]
        }
        
        
    }
    
    func  getDate(){
        isGetdata = true
        let mDetailLogic:ComFqHalcyonLogic2SearchFollowUpTempleDetailLogic! = ComFqHalcyonLogic2SearchFollowUpTempleDetailLogic(comFqHalcyonLogic2SearchFollowUpTempleDetailLogic_SearchFollowUpTempleDetailLogicInterface: self, withInt: mCurrentId)
        mDetailLogic.getTempleDetail()
    }
    func onSearchErrorWithInt(errCode: Int32, withNSString msg: String!) {
        isGetdata = false
        UIAlertViewTool.getInstance().showAutoDismisDialog("获取模板详细信息失败！", width: 210, height: 120)
    }
    
    func onSearchSuccessWithComFqHalcyonEntityFollowUpTemple(mFollowUpTemple: ComFqHalcyonEntityFollowUpTemple!) {
        isGetdata = false
        followUpTemple = mFollowUpTemple
        followUpTemple.setmTempleIdWithInt(mCurrentId)
        edtTempleName.text = followUpTemple.getTempleName()
        for var i:Int32 = 0; i < followUpTemple.getmArrayList().size(); i++ {
            templeList.append(followUpTemple.getmArrayList().getWithInt(i) as! ComFqHalcyonEntityOnceFollowUpCycle)
        }
        edtTempleName.enabled = false
        currentOnceFollowUpCycle = templeList[currentIndex - 1]
        updateUI()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func getXibName() -> String {
        return "AddFollowUpTempleViewController"
    }
    
    /**
    选择距离上次多长时间的点击事件
    */
    @IBAction func onChoseTimeClick() {
        showDateAlert()
    }
    
    /**
    上一次按钮点击事件
    */
    @IBAction func onLastTimeBtnClick() {
        currentIndex--
        if currentIndex == 1 {
            isFirstTime(true)
        }
        updateUI()
    }
    
    /**
    下一次按钮点击事件
    */
    @IBAction func onNextTimeBtnClick() {
        currentIndex++
        
        if currentIndex > 1 {
            isFirstTime(false)
        }
        
        if currentIndex == templeList.count + 1 {
            initFollowUp()
        }
        updateUI()
        
    }
    
    /**
    删除随访的点击事件
    */
    @IBAction func onDelTempleBtnClick() {
        if currentIndex == 1 {
            UIAlertViewTool.getInstance().showAutoDismisDialog("首次随访不能删除", width: 210, height: 120)
            return
        }else{
            delAlertView = UIAlertViewTool.getInstance().showNewDelDialog("确认删除？", target: self, actionOk: "onDelSureClick", actionCancle: "onDelCancelClick")
        }
    }
    
    /**
    确认删除模板的点击事件
    */
    func onDelSureClick(){
        templeList.removeAtIndex(currentIndex - 1)
        if currentIndex >= templeList.count + 1 {
            currentIndex--
            if currentIndex == 1 {
                isFirstTime(true)
            }
        }
        updateUI()
        delAlertView?.close()
    }
    
    /**
    取消删除模板的点击事件
    */
    func onDelCancelClick(){
        delAlertView?.close()
    }
    
    /**
    保存随访的点击事件
    */
    //升级到xcode 6.4后这方法要报错···
    @IBAction func onSaveTempleBtnClick() {
        //新建模板
//        if templeStyle == ADD_TEMPLE{
//            var str:String = edtTempleName.text
//            if str == "" {
//                UIAlertViewTool.getInstance().showAutoDismisDialog("请先填写模板名称", width: 210, height: 120)
//            }else{
//                saveTempleBtn.enabled = false
//                followUpTemple = ComFqHalcyonEntityFollowUpTemple()
//                followUpTemple.setTempleNameWithNSString(str)
//                var tmlist:JavaUtilArrayList = JavaUtilArrayList()
//                for temp:ComFqHalcyonEntityOnceFollowUpCycle! in templeList{
//                    tmlist.addWithId(temp)
//                }
//                followUpTemple.setmArrayListWithJavaUtilArrayList(tmlist)
//                var logic:ComFqHalcyonLogic2OperateFollowUpTempleLogic! = ComFqHalcyonLogic2OperateFollowUpTempleLogic(comFqHalcyonLogic2OperateFollowUpTempleLogic_OperateFollowUpTempleLogicInterface: self, withComFqHalcyonEntityFollowUpTemple: followUpTemple)
//                logic.CreateFollowUPTemple()
//            }
//            
//        }
//        //修改原有模板
//        if templeStyle == FROM_EDIT{
//            saveTempleBtn.enabled = false
//            var tmlist:JavaUtilArrayList = JavaUtilArrayList()
//            for temp:ComFqHalcyonEntityOnceFollowUpCycle! in templeList{
//                tmlist.addWithId(temp)
//            }
//            
//            followUpTemple.setmArrayListWithJavaUtilArrayList(tmlist)
//            var logic:ComFqHalcyonLogic2OperateFollowUpTempleLogic! = ComFqHalcyonLogic2OperateFollowUpTempleLogic(comFqHalcyonLogic2OperateFollowUpTempleLogic_OperateFollowUpTempleLogicInterface: self, withComFqHalcyonEntityFollowUpTemple: followUpTemple)
//            logic.ModifyFollowUpTemple()
//            
//        }
//        //从发布模板进入
//        if templeStyle == FROM_SEND {
//            saveTempleBtn.enabled = false
//            var tmlist:JavaUtilArrayList = JavaUtilArrayList()
//            for temp:ComFqHalcyonEntityOnceFollowUpCycle! in templeList{
//                tmlist.addWithId(temp)
//            }
//            
//            followUpTemple.setmArrayListWithJavaUtilArrayList(tmlist)
//            var c:Int! = self.navigationController?.viewControllers.count
//            var controller:SettingFollowUpViewController! = self.navigationController?.viewControllers[c-2] as! SettingFollowUpViewController
//            controller.followUpTemple = followUpTemple
//            self.navigationController?.popViewControllerAnimated(true)
//        }
    }
    func onErrorWithInt(code: Int32, withJavaLangThrowable error: JavaLangThrowable!) {
        saveTempleBtn.enabled = true
        if isGetdata {
            UIAlertViewTool.getInstance().showAutoDismisDialog("获取模板详细信息失败！", width: 210, height: 120)
        }else{
            if templeStyle == ADD_TEMPLE {
                UIAlertViewTool.getInstance().showAutoDismisDialog("新增模板失败", width: 210, height: 120)
            }else{
                UIAlertViewTool.getInstance().showAutoDismisDialog("保存失败", width: 210, height: 120)
            }
        }
        isGetdata = false
    }
    
    func onDataErrorWithInt(code: Int32, withNSString msg: String!) {
        saveTempleBtn.enabled = true
        if templeStyle == ADD_TEMPLE {
            UIAlertViewTool.getInstance().showAutoDismisDialog("新增模板失败", width: 210, height: 120)
        }else{
            UIAlertViewTool.getInstance().showAutoDismisDialog("保存失败", width: 210, height: 120)
        }
    }
    
    func onDataReturn() {
        saveTempleBtn.enabled = true
        if templeStyle == ADD_TEMPLE {
            UIAlertViewTool.getInstance().showAutoDismisDialog("新增模板成功", width: 210, height: 120)
        }else{
            UIAlertViewTool.getInstance().showAutoDismisDialog("保存成功", width: 210, height: 120)
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func isFirstTime(isFirst:Bool){
        if isFirst {
            templeFirstTimeLable.text = "首次访问时间"
            templeFirstTimeLable.textColor = Color.color_grey
            lastTimeView.hidden = true
            timeBtn.hidden = true
        }else{
            templeFirstTimeLable.text = "距上次"
            templeFirstTimeLable.textColor = Color.color_emerald
            templeFirstTimeLable.hidden = false
            lastTimeView.hidden = false
            timeBtn.hidden = false
        }
    }
    
    /**
    确认选择时间的按钮点击事件
    */
    @IBAction func onChoseTimeSureClick(sender: AnyObject) {
        let numPosition = numberPickView?.getCurrentIndex().row
        let datePosition = datePickView?.getCurrentIndex().row
        let numTemp = numberList[numPosition!]
        let dateTemp = dateList[datePosition!]
        templeFirstTimeLable.text = "距上次\(numTemp)\(dateTemp)"
        currentOnceFollowUpCycle?.setmItentValueWithNSString(numTemp)
        currentOnceFollowUpCycle?.setmItemUnitWithNSString(dateTemp)
        choseTimeAlertView?.close()
        choseTimeAlertView = nil
//        Tools.runOnOtherThread({ () -> AnyObject! in
//            self.resetPickerView()
//            return nil
//        }, callback: { (tt) -> Void in
//            
//        })
        resetPickerView()
    }
    
    
    func initFollowUp(){
        let cycle = ComFqHalcyonEntityOnceFollowUpCycle()
        cycle.setmItemNameWithNSString("")
        templeList.append(cycle)
        
        if currentIndex > 1 {
            showDateAlert()
        }
        
    }
    
    func updateUI(){
        edtTempleContent.text = ""
        currentOnceFollowUpCycle = templeList[currentIndex - 1]
        let itemValue:String? = currentOnceFollowUpCycle?.getmItentValue()
        let itemUnit = parseStrDate(currentOnceFollowUpCycle?.getmItemUnit())
        if currentIndex == 1{
            templeTimeLabel.text = "首次随访时间"
            timeBottomLine.hidden = true
        }else{
            timeBottomLine.hidden = false
            if itemValue == nil || itemUnit == nil {
                templeFirstTimeLable.text = "距上次"
            } else {
                templeFirstTimeLable.text = "距上次\(itemValue!)\(itemUnit!)"
            }
        }
        templeTimeLabel.text = "\(currentIndex)/\(templeList.count)"
        edtTempleContent.text = currentOnceFollowUpCycle?.getmItemName() ?? ""
    }
    
    /**
    设置选择时间的View的现实样子
    */
    func setPickerViewStyle(frame:CGRect,items:Array<String>,index:Int) -> (NAPickerView){
        
        let pickerView = NAPickerView(frame:frame,andItems:items,andDelegate:self)
        pickerView.backgroundColor = UIColor.clearColor()
        pickerView?.configureBlock = { cell,item in
            let templeCell:NALabelCell = cell as! NALabelCell
            let tempItem:String = item as! String
            templeCell.textView.textAlignment = NSTextAlignment.Center
            templeCell.textView.font = UIFont.systemFontOfSize(CGFloat(30))
            templeCell.textView.textColor = UIColor.grayColor()
            templeCell.textView.text = tempItem
        }
        pickerView?.highlightBlock = {cell in
            let templeCell:NALabelCell = cell as! NALabelCell
            templeCell.textView.textColor = Color.color_emerald
        }
        pickerView?.unhighlightBlock = {cell in
            let templeCell:NALabelCell = cell as! NALabelCell
            templeCell.textView.textColor = UIColor.grayColor()
        }
        
        pickerView?.setIndex(index)
        return pickerView
    }
    
    /**
    初始化选择时间的数据
    */
    func setChoseTimeViewData(){
        var numberTemp = [String]()
        let dateTemp = ["天","周","月","年"]
        for i in 1...10 {
            numberTemp.append("\(i)")
        }
        
        for i in 0..<100 {
            
            numberList += numberTemp
            dateList += dateTemp
        }
        numberPickView = setPickerViewStyle(CGRectMake(0, 50, 120, 150), items: numberList, index: 100/2*10-1)
        datePickView = setPickerViewStyle(CGRectMake(120, 50, 120, 150), items: dateList, index: 100/2*4-1)
    }
    
    func resetPickerView(){
        numberPickView?.removeFromSuperview()
        datePickView?.removeFromSuperview()
        numberPickView = setPickerViewStyle(CGRectMake(0, 50, 120, 150), items: numberList, index: 100/2*10-1)
        datePickView = setPickerViewStyle(CGRectMake(120, 50, 120, 150), items: dateList, index: 100/2*4-1)
    }
    
    /**
    显示选择时间的Dialog
    */
    func showDateAlert(){
        choseTimeAlertView = CustomIOS7AlertView()
//        choseTimeAlertView?.setCancelonTouch(true)
        choseTimeAlert.addSubview(numberPickView!)
        choseTimeAlert.addSubview(datePickView!)
        UITools.setRoundBounds(7, view: choseTimeAlert)
        choseTimeAlertView!.containerView = choseTimeAlert
        choseTimeAlertView!.show()
    }
    
    func didSelectedAtIndexDel(index: Int) {
        
    }
    
    func parseStrDate(str:String?) -> String?{
        var tmp:String?
        switch str ?? ""{
        case "day":
            tmp = "天"
        case "week":
            tmp = "周"
        case "month":
            tmp = "月"
        case "year":
            tmp = "年"
        default:
            tmp = nil
        }
        return tmp
    }
    
    func textViewDidChange(textView: UITextView) {
        currentOnceFollowUpCycle?.setmItemNameWithNSString(textView.text)
    }
}
