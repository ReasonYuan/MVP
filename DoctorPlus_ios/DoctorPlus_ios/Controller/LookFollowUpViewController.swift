//
//  LookFollowUpViewController.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-5-14.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class LookFollowUpViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource,ComFqHalcyonLogic2SendFollowUpLeaveMessageLogic_SendFollowUpLeaveMessageLogicInterface,ComFqHalcyonLogic2SearchFollowUpDetailLogic_SearchFollowUpDetailLogicInterface,UpdateCallBack {

    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var tabView: UITableView!
    @IBOutlet weak var mTittle: UIButton!
    var list:NSMutableArray = NSMutableArray()
    @IBOutlet weak var scrollView: UIScrollView!
    var mTimerId:Int32 = 0
    var messageList = JavaUtilArrayList()
    var mCurrentFollowUp:ComFqHalcyonEntityFollowUp?
    override func viewDidLoad() {
        super.viewDidLoad()
        setTittle("查看随访")
        hiddenRightImage(true)
        UITools.setRoundBounds(10.0, view: messageTextField)
        tabView.registerNib(UINib(nibName: "LookFollowUpCell", bundle:nil), forCellReuseIdentifier: "LookFollowUpCell")

        getDetail()

       
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        var tmpHeight:CGFloat = scrollView.frame.size.height
//        var lookFollowUpView = LookFollowUpView(frame: CGRectMake(0, 0, ScreenWidth, tmpHeight))
//        
//        scrollView.addSubview(lookFollowUpView)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func getXibName() -> String {
        return "LookFollowUpViewController"
    }
    
    /**回复留言**/
    @IBAction func submitMessageClick(sender: AnyObject) {
        var textString = messageTextField.text
        if !textString!.isEmpty {
            submitMessage(textString!,timerId:mTimerId)
        }
    }
    
    /**提交留言logic**/
    func submitMessage(msg:String,timerId:Int32){
        let sendMesageLogic  = ComFqHalcyonLogic2SendFollowUpLeaveMessageLogic(comFqHalcyonLogic2SendFollowUpLeaveMessageLogic_SendFollowUpLeaveMessageLogicInterface: self)
        sendMesageLogic.submitMessageWithNSString(msg, withInt: timerId)
    }
    
    func onSubmitMessageSuccess() {
        let leaveMessage = ComFqHalcyonEntityLeaveMessage()
        var time = Int64(NSDate().timeIntervalSince1970 * 1000)
        
        /**格式化当前时间**/
        let format =  NSDateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss a"
        let timestr = format.stringFromDate(NSDate())
        
        leaveMessage.setmDateWithNSString(timestr)
        leaveMessage.setmMessageWithNSString(messageTextField.text)
        leaveMessage.setmNameWithNSString(ComFqLibToolsConstants.getUser().getUsername())
        leaveMessage.setRoleTypeWithInt(Int32(1))
        messageList.addWithId(leaveMessage)
        tabView.reloadData()
        messageTextField.text = ""
        messageTextField.resignFirstResponder()
    }
    
    func onSubmitMessageErrorWithInt(code: Int32, withNSString msg: String!) {
        UIAlertViewTool.getInstance().showAutoDismisDialog("回复留言失败！", width: 210, height: 120)
    }

    func onErrorWithInt(code: Int32, withJavaLangThrowable error: JavaLangThrowable!) {
        UIAlertViewTool.getInstance().showAutoDismisDialog("操作失败！", width: 210, height: 120)
    }
    
    /**获取随访的详细内容**/
    func getDetail(){
        let detailLogic = ComFqHalcyonLogic2SearchFollowUpDetailLogic(comFqHalcyonLogic2SearchFollowUpDetailLogic_SearchFollowUpDetailLogicInterface: self)
      detailLogic.searchFollowUpDetailWithInt(mTimerId)
    }
    
    func onSearchErrorWithInt(code: Int32, withNSString msg: String!) {
        UIAlertViewTool.getInstance().showAutoDismisDialog("获取数据失败！", width: 210, height: 120)
    }
    
    func onSearchSuccessWithComFqHalcyonEntityFollowUp(mFollowUp: ComFqHalcyonEntityFollowUp!) {
        mCurrentFollowUp = mFollowUp
        mTittle.setTitle(mFollowUp.getmFolloUpTempleName(), forState: UIControlState.Normal)
        messageList = mFollowUp.getmMessageList()
        tabView.reloadData()
        initFollowUpViewDataAndView(mFollowUp)
      
    }
    
    /**初始化FolloUpView**/
    func initFollowUpViewDataAndView(mFollowUp:ComFqHalcyonEntityFollowUp){
        removeALlViewFromScrollView()
        let mOnceFollowUpCycleList = mFollowUp.getmFollowUpItemsList()
		let mItemsId = JavaUtilArrayList()
		let size = mOnceFollowUpCycleList.size()
		let mFriendList = mFollowUp.getmFriendsList();
		if (size == 0) {
            self.navigationController?.popViewControllerAnimated(true)
            return
		}
        if size > 0 {
            scrollView.contentSize = CGSizeMake(ScreenWidth*CGFloat(size), scrollView.frame.size.height)
        }
        
        let patient = mFriendList.getWithInt(0) as! ComFqHalcyonEntityContacts
        scrollView.delegate = self
        for var i = 0; i < Int(size); i++ {
            let mCycle = mOnceFollowUpCycleList.getWithInt(Int32(i)) as! ComFqHalcyonEntityOnceFollowUpCycle
            mItemsId.addWithId(JavaLangInteger.valueOfWithInt(mCycle.getmItemtId()))
            let lookFollowUpView = LookFollowUpView(frame: CGRectMake(ScreenWidth*CGFloat(i), 0, ScreenWidth,  scrollView.frame.size.height))
            lookFollowUpView.setData(mItemsId!, data: mCycle.getmTimerDate()!, patient: patient , mCycle: mCycle , timerId: Int(mTimerId), mCallBack: self,navigation:self.navigationController!)
            scrollView.addSubview(lookFollowUpView)
        }
    }
    
    /**移除scrollView中所有的子View**/
    func removeALlViewFromScrollView(){
        var countSize = scrollView.subviews.count
        for view in scrollView.subviews {
            view.removeFromSuperview()
        }
    }
    
    /**取消随访的回调**/
    func onCallBack(type: Int) {
        if  type == 1 {
            getDetail()
        } else if type == 2 {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if Int(messageList.size()) > 0 {
             return (40.0 + calculateHeightForCell(indexPath))
        }else{
            return 40.0
        }
       
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return Int(messageList.size())
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier: String = "LookFollowUpCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? LookFollowUpCell
        if cell == nil{
            cell = LookFollowUpCell()
        }
        let row =  indexPath.row
       
        let leaveMessage:ComFqHalcyonEntityLeaveMessage = messageList.getWithInt(Int32(row)) as! ComFqHalcyonEntityLeaveMessage
        
        if leaveMessage.getRoleType() == 1 {
             cell?.icon.image = UIImage(named: "doctor_icon.png")
        } else if leaveMessage.getRoleType() == 3 {
             cell?.icon.image = UIImage(named: "patient_icon.png")
        }
        
        let date = ComFqLibToolsTimeFormatUtils.getTimeByFormatWithLong(ComFqLibToolsTimeFormatUtils.getTimeMillisByDateWithSecondsWithNSString(leaveMessage.getmDate()))
        cell?.time.text = date
        cell?.name.lineBreakMode = NSLineBreakMode.ByTruncatingMiddle
        cell?.name.text = "\(leaveMessage.getmName()):"
        cell?.contentLabel.numberOfLines = 0
        cell?.contentLabel.text = leaveMessage.getmMessage()
        cell?.contentLabel.sizeToFit()
        cell?.contentLabel.frame.size.height = calculateHeightForCell(indexPath)
        
        
        return cell!
    }
    
    func calculateHeightForCell(indexPath:NSIndexPath) -> CGFloat{
        let row =  indexPath.row
        let contentLabel = UILabel(frame: CGRectMake(49, 38, self.tabView.frame.size.width - 49 - 36, 17))
        contentLabel.font = UIFont.systemFontOfSize(15.0)
        contentLabel.numberOfLines = 0
        
         let leaveMessage:ComFqHalcyonEntityLeaveMessage = messageList.getWithInt(Int32(row)) as! ComFqHalcyonEntityLeaveMessage
        contentLabel.text = leaveMessage.getmMessage()
        contentLabel.sizeToFit()
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.ByCharWrapping
        let attrbutes = [NSFontAttributeName:contentLabel.font,NSParagraphStyleAttributeName:paragraphStyle.copy()]
        
        let width = contentLabel.frame.size.width
        let contentString:NSString = contentLabel.text!
        let contentLableSize = (contentString.boundingRectWithSize(CGSizeMake(width, CGFloat(MAXFLOAT)), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: attrbutes, context: nil)).size
        let contentHeight = contentLableSize.height
        return contentHeight
    }
}
