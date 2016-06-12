//
//  SettinhFollowUpViewController.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/5/14.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit
var settingFollowUpViewController_followUpTemple:ComFqHalcyonEntityFollowUpTemple!

class SettingFollowUpViewController: BaseViewController,ComFqHalcyonLogic2SearchFollowUpTempleDetailLogic_SearchFollowUpTempleDetailLogicInterface,ComFqHalcyonLogic2AddOneFollowUpLogic_AddOneFollowUpLogicInterface,UITextViewDelegate,ComFqHalcyonLogic2SearchFollowUpDetailLogic_SearchFollowUpDetailLogicInterface,NAPickerViewDelegate {

    @IBOutlet weak var followUpModifyName: UILabel!
    @IBOutlet weak var messageKuang: UIImageView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var timeBtn: UIButton!
    @IBOutlet weak var headKuang: UIImageView!
    @IBOutlet weak var headImage: UIImageView!
    @IBOutlet weak var patientname: UILabel!
    @IBOutlet weak var fabuBtn: UIButton!
    
    @IBOutlet var choseDateView: UIView!
    var choseTimeAlertView:CustomIOS7AlertView?
    var yearPickerView:NAPickerView?
    var mounthPickerView:NAPickerView?
    var dayPickerView:NAPickerView?
    var yearList = [String]()
    var mounthList = [String]()
    var dayList = [String]()
    var yearTemp = [String]()
    var mounthTemp = [String]()
    var dayTemp = [String]()
    var year = 0
    var mounth = 0
    var day = 0
    
    var dialog:CustomIOS7AlertView!
    
    var followUpTemple:ComFqHalcyonEntityFollowUpTemple!
    var mPatient:ComFqHalcyonEntityContacts!
    var mCycles:JavaUtilArrayList! = JavaUtilArrayList()
    var mFollowUp:ComFqHalcyonEntityFollowUp! = ComFqHalcyonEntityFollowUp()
    var mPatientList = JavaUtilArrayList()
    var mTimerHashMap:JavaUtilHashMap!
    var mCurrentFollowUp:ComFqHalcyonEntityFollowUp!
    var mAlarmClock:ComFqHalcyonEntityAlarmClock!
    var mTimerId:Int32!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTittle("")
        hiddenRightImage(true)
        getData()
        messageTextView.layer.borderWidth = 1.0
        messageTextView.layer.borderColor = UIColor(red: 98/255, green: 192/255, blue: 180/255, alpha: 1.0).CGColor
        
        UITools.setBorderWithHeadKuang(headKuang)
        
        let rect:CGRect? = headImage.bounds
        UITools.setRoundBounds(CGRectGetHeight(rect!)/2, view: headImage)
        
        UITools.setButtonWithColor(ColorType.EMERALD, btn: fabuBtn, isOpposite: false)
        
        mPatientList.addWithId(mPatient)
        mFollowUp.setmFriendsListWithJavaUtilArrayList(mPatientList)
        followUpModifyName.text = followUpTemple.getTempleName()
        patientname.text = mPatient.getName()
        
        let date:NSDate = NSDate()
        let formatter:NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.stringFromDate(date)
        timeBtn.setTitle(dateString, forState: UIControlState.Normal)
        
        
        
        let photo:ComFqHalcyonEntityPhoto! = ComFqHalcyonEntityPhoto()
        photo.setImageIdWithInt(mPatient.getImageId())
        ApiSystem.getHeadImageWithComFqHalcyonEntityPhoto(photo, withComFqLibCallbackICallback: WapperCallback(onCallback: { (data) -> Void in
            let path:NSString? = data as? NSString
            if(path != nil){
                self.headImage.image = UITools.getImageFromFile(path!)
            }
        }), withBoolean: false, withInt: Int32(2))
//        Tools.runOnOtherThread({ () -> AnyObject! in
//            self.setChoseTimeViewData()
//            return nil
//        }, callback: { (tt) -> Void in
//            
//        })
        setChoseTimeViewData()
    }
    
    func textViewDidChange(textView: UITextView) {
        if textView.text != ""{
            mFollowUp.setmTipsWithNSString(textView.text)
        }
        
    }
    
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        //限制输入表情后九宫格不能使用
//        if (ContainsEmoji.isContainsEmoji(text)) {
//            return false
//        }
        return true
    }
    
    /**获取模板详细内容*/
    func getData(){
        let mDetailLogic:ComFqHalcyonLogic2SearchFollowUpTempleDetailLogic = ComFqHalcyonLogic2SearchFollowUpTempleDetailLogic(comFqHalcyonLogic2SearchFollowUpTempleDetailLogic_SearchFollowUpTempleDetailLogicInterface: self, withInt: followUpTemple.getmTempleId())
        mDetailLogic.getTempleDetail()
    }
    
    func onErrorWithInt(code: Int32, withJavaLangThrowable error: JavaLangThrowable!) {
        dialog.close()
        UIAlertViewTool.getInstance().showAutoDismisDialog("获取数据或者设置随访失败！", width: 210, height: 120)
    }
    
    func onSearchErrorWithInt(errCode: Int32, withNSString msg: String!) {
        UIAlertViewTool.getInstance().showAutoDismisDialog("获取数据失败！", width: 210, height: 120)
    }
    
    func onSearchSuccessWithComFqHalcyonEntityFollowUpTemple(mFollowUpTemple: ComFqHalcyonEntityFollowUpTemple!) {
        followUpTemple = mFollowUpTemple
        mCycles = followUpTemple.getmArrayList()
        let date:NSDate = NSDate()
        let formatter:NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.stringFromDate(date)
        mCycles.getWithInt(Int32(0)).setmTimerDateWithNSString(dateString)
        mFollowUp.setmFolloUpTempleNameWithNSString(followUpTemple.getTempleName())
        mFollowUp.setmDoctorIdWithInt(ComFqLibToolsConstants.getUser().getUserId())
    }
    /**发布随访*/
    func addFollowUp(){
        mCycles = followUpTemple.getmArrayList()
        dialog = UIAlertViewTool.getInstance().showLoadingDialog("")
        let mTmpCycle = ComFqLibToolsSettingFollowUpManager.calculationAllTimeWithJavaUtilArrayList(mCycles, withNSString: timeBtn.titleLabel?.text)
        mFollowUp.setmFollowUpItemsListWithJavaUtilArrayList(mTmpCycle)
        let mAddOneFollowUpLogic = ComFqHalcyonLogic2AddOneFollowUpLogic(comFqHalcyonLogic2AddOneFollowUpLogic_AddOneFollowUpLogicInterface: self, withComFqHalcyonEntityFollowUp: mFollowUp)
        mAddOneFollowUpLogic.addFollowUp()
    }
    
    func onAddErrorWithInt(code: Int32, withNSString msg: String!) {
        dialog.close()
        UIAlertViewTool.getInstance().showAutoDismisDialog("设置随访失败", width: 210, height: 120)
    }
    func onAddSuccessWithInt(timerId: Int32) {
        dialog.close()
//        calculationAlarmLongTime(mCycles, timerId: timerId)
        UIAlertViewTool.getInstance().showAutoDismisDialog("设置随访成功", width: 210, height: 120)
        self.navigationController?.pushViewController(HomeViewController(), animated: true)
        
    }
    
    /**
    * 计算闹钟提醒列表
    *
    * @param mCycles
    * @return
    */
    func calculationAlarmLongTime(mCycles:JavaUtilArrayList,
        timerId:Int32) {
    mTimerId = timerId
    getDetail(mCycles, mTimerId: timerId)
    }
    
    func getDetail(mCycles:JavaUtilArrayList,
        mTimerId:Int32){
            mTimerHashMap = JavaUtilHashMap()
            let mDetailLogic:ComFqHalcyonLogic2SearchFollowUpDetailLogic! = ComFqHalcyonLogic2SearchFollowUpDetailLogic(comFqHalcyonLogic2SearchFollowUpDetailLogic_SearchFollowUpDetailLogicInterface: self)
            mDetailLogic.searchFollowUpDetailWithInt(mTimerId)
    }
   
    /**将时间信息保存进闹钟*/
    func onSearchSuccessWithComFqHalcyonEntityFollowUp(mFollowUp: ComFqHalcyonEntityFollowUp!) {
        mCurrentFollowUp = mFollowUp
        let mTmpCycles = mCurrentFollowUp.getmFollowUpItemsList()
        let mTimerList:JavaUtilArrayList! = JavaUtilArrayList()
        for var i:Int32 = 0 ;i < mCycles.size(); i++ {
            let mCycle:ComFqHalcyonEntityOnceFollowUpCycle! = mCycles.getWithInt(i) as! ComFqHalcyonEntityOnceFollowUpCycle
            let mItemId = mTmpCycles.getWithInt(i).getmItemtId()
            let time = ComFqLibToolsTimeFormatUtils.getTimeMillisByDateWithNSString(mCycle.getmTimerDate())
            let alarmTime = ComFqLibToolsSettingFollowUpManager.calculationOnceAlarmLongTimeWithLong(time)
            mTimerList.addWithId(Int(alarmTime))
            mTimerHashMap.putWithId(Int(mItemId), withId: Int(alarmTime))
        }
        
        mAlarmClock = ComFqHalcyonEntityAlarmClock()
        mAlarmClock.setTimerListWithJavaUtilArrayList(mTimerList)
        mAlarmClock.setUserIdWithInt(mPatient.getUserId())
        mAlarmClock.setTimerIdWithInt(mTimerId)
        mAlarmClock.setmTimeHashMapWithJavaUtilHashMap(mTimerHashMap)
        sendMessage()
        
    }
    
    
     /**
       通知病人客户端设置随访的闹钟
      */
    func sendMessage() {
//    JSONObject mJsonObject = new JSONObject();
//    Iterator mIterator = mTimerHashMap.keySet().iterator();
//    while (mIterator.hasNext()) {
//    int itemId = (Integer) mIterator.next();
//    try {
//				mJsonObject.put(String.valueOf(itemId),
//    mTimerHashMap.get(itemId) / 1000);
//    } catch (JSONException e) {
//				e.printStackTrace();
//    }
//    }
//    HalcyonApplication.getInstance().sendMessage(
//				MessageStruct.MESSAGE_TYPE_NEW_FOLLOW_UP, "新的随访",
//				mPatient.getUserId(), mJsonObject);
    }
    
    
    override func viewWillAppear(animated: Bool) {
        //注册通知,监听键盘弹出事件
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name:UIKeyboardWillShowNotification, object: nil)
        //注册通知,监听键盘消失事件
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidHidden", name: UIKeyboardWillHideNotification, object: nil)
    }
    /**键盘出现后view上移*/
    func keyboardDidShow(notification:NSNotification){
        var d:NSDictionary! = notification.userInfo
        var kbSize:CGSize! = d.objectForKey(UIKeyboardFrameEndUserInfoKey)?.CGRectValue.size
        self.view.frame = CGRectMake(0, -kbSize.height+90, ScreenWidth, ScreenHeight)
    }
    
    /**键盘消失后view下移*/
    func keyboardDidHidden(){
         self.view.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight)
    }

    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func getXibName() -> String {
        return "SettingFollowUpViewController"
    }

    
    /**随访标题点击*/
    @IBAction func followUpModify(sender: AnyObject) {
        let controller:AddFollowUpTempleViewController! = AddFollowUpTempleViewController()
        controller.templeStyle = controller.FROM_SEND
        controller.mCurrentId = followUpTemple.getmTempleId()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    /**发布点击*/
    @IBAction func fabu(sender: AnyObject) {
        addFollowUp()
    }
    /**首访时间点击*/
    @IBAction func firstTime(sender: AnyObject) {
        showDateAlert()
    }
    
    /**头像点击*/
    @IBAction func headClick(sender: AnyObject) {
        let controller:PatientDetailViewController! = PatientDetailViewController()
        controller.mPatientFriendId = mPatient.getUserId()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    /**
    确认选择时间的点击事件
    */
    @IBAction func onChoseTimeClick() {
        choseTimeAlertView?.close()
        let yearPosition = yearPickerView?.getCurrentIndex().row
        let mounthPosition = mounthPickerView?.getCurrentIndex().row
        let dayPosition = dayPickerView?.getCurrentIndex().row
        let yearTmp = yearList[yearPosition!]
        let mounthTmp = mounthList[mounthPosition!]
        let dayTmp = dayList[dayPosition!]
        timeBtn.setTitle("\(yearTmp)-\(mounthTmp)-\(dayTmp)", forState: UIControlState.Normal)
//        Tools.runOnOtherThread({ () -> AnyObject! in
//             self.resetPickerView()
//            return nil
//            }, callback: { (tt) -> Void in
//                
//        })
       resetPickerView()
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
        let date = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy"
        year = Int(formatter.stringFromDate(date))!
        formatter.dateFormat = "MM"
        mounth = Int(formatter.stringFromDate(date))!
        formatter.dateFormat = "dd"
        day = Int(formatter.stringFromDate(date))!
        for i in 1...31 {
            if i < 10 {
                dayTemp.append("0\(i)")
            }else{
                dayTemp.append("\(i)")
            }
        }
        for i in 1...12{
            if i < 10 {
                mounthTemp.append("0\(i)")
            }else{
                mounthTemp.append("\(i)")
            }
            
        }
        for i in 1974...Int(year){
            yearTemp.append("\(i)")
        }
        for i in 0..<100 {
            
            yearList += yearTemp
            mounthList += mounthTemp
            dayList += dayTemp
        }
        yearPickerView = setPickerViewStyle(CGRectMake(0, 50, 120, 150), items: yearList, index: 100/2*yearTemp.count-2)
        mounthPickerView = setPickerViewStyle(CGRectMake(120, 50, 80, 150), items: mounthList, index: 100/2*mounthTemp.count + mounth - 2)
        dayPickerView = setPickerViewStyle(CGRectMake(200, 50, 80, 150), items: dayList, index: 100/2*dayTemp.count + day - 2)
    }

    /**
    显示选择时间的Dialog
    */
    func showDateAlert(){
        choseTimeAlertView = CustomIOS7AlertView()
        choseTimeAlertView?.setCancelonTouch(true)
        choseDateView.addSubview(dayPickerView!)
        choseDateView.addSubview(mounthPickerView!)
        choseDateView.addSubview(yearPickerView!)
        UITools.setRoundBounds(7, view: choseDateView)
        choseTimeAlertView!.containerView = choseDateView
        choseTimeAlertView!.show()
    }
    
    func resetPickerView(){
    
        dayPickerView?.removeFromSuperview()
        mounthPickerView?.removeFromSuperview()
        yearPickerView?.removeFromSuperview()
        yearPickerView = setPickerViewStyle(CGRectMake(0, 50, 120, 150), items: yearList, index: 100/2*yearTemp.count-2)
        mounthPickerView = setPickerViewStyle(CGRectMake(120, 50, 80, 150), items: mounthList, index: 100/2*mounthTemp.count + mounth - 2)
        dayPickerView = setPickerViewStyle(CGRectMake(200, 50, 80, 150), items: dayList, index: 100/2*dayTemp.count + day - 2)
    }
    
    func didSelectedAtIndexDel(index: Int) {
        
    }
}
