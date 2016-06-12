//
//  MoreChatViewController.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-7-7.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit
import HitalesSDK
import RealmSwift
var shareGroupId:String = ""
var currentControllerIndex:Int = 0
var shareChatEntityList = JavaUtilArrayList()
var shareIsGroup = false
var isMe = false
class BaseChatViewController: BaseViewController,UITextFieldDelegate,ComFqHalcyonLogicPracticeSendPatientLogic_SendPatientInterface,ComFqHalcyonLogicPracticeSendPatientLogic_SendRecordInterface,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,ComFqHalcyonLogicPracticeUpLoadChatImageManager_UpLoadChatImageManagerCallBack{
    var messageList = JavaUtilArrayList()
    
    var tittleStr:String = ""
    @IBOutlet weak var tabView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet var messageView: UIView!

    var mIDCardmessageList = JavaUtilArrayList()
    var memberList = JavaUtilArrayList()
    
    
    var patientList = JavaUtilArrayList()
    var recordList = JavaUtilArrayList()
    
    var sendPatientLogic = ComFqHalcyonLogicPracticeSendPatientLogic()
    var loadingDialog:CustomIOS7AlertView!
    var position:Int = 0
    var errorSendCount:Int = 0
    var actionSheet:UIActionSheet!
    
    var upLoadImageLogic:ComFqHalcyonLogicPracticeUpLoadChatImageLogic!
    
    var messageImageEntity:ComFqHalcyonEntityChartEntity!
    var imageList = JavaUtilArrayList()
    var imagesView:FullScreenImageZoomView!
    var userImageIdList = Dictionary<Int,Int>()
    
    /// 聊天类型
    var chatType:Int = 0
    
    /// 用于获取最新某人或者某个群的Id
    var customId:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViewDidLoadData()
        initAllTablewNib()
        messageTextField.delegate = self
  
        self.messageView.frame = CGRectMake(0, ScreenHeight - 42, ScreenWidth, 117)
        self.view.addSubview(self.messageView)
        self.tabView.reloadData()
        if (self.tabView.contentSize.height - self.tabView.bounds.size.height) > 0 {
            self.tabView.setContentOffset(CGPointMake(0,self.tabView.contentSize.height - self.tabView.bounds.size.height), animated: true)
        }
        
        tabView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tabViewTap:"))
        
        //标记当前界面位置、加好友使用
        nextPosition = self.navigationController?.viewControllers.count

    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
    func initAllTablewNib(){
        tabView.registerNib(UINib(nibName: "SimpleChatViewCellTableViewCell", bundle:nil), forCellReuseIdentifier: "SimpleChatViewCellTableViewCell")
        tabView.registerNib(UINib(nibName: "SimpleChatRightCell", bundle:nil), forCellReuseIdentifier: "SimpleChatRightCell")
        tabView.registerNib(UINib(nibName: "ChatAddTableViewCell", bundle:nil), forCellReuseIdentifier: "ChatAddTableViewCell")
        tabView.registerNib(UINib(nibName: "ChatAnalysisRightTableViewCell", bundle:nil), forCellReuseIdentifier: "ChatAnalysisRightTableViewCell")
        tabView.registerNib(UINib(nibName: "ChatRecordRightTableViewCell", bundle:nil), forCellReuseIdentifier: "ChatRecordRightTableViewCell")
        tabView.registerNib(UINib(nibName: "ChatAnalysisTableViewCell", bundle:nil), forCellReuseIdentifier: "ChatAnalysisTableViewCell")
        tabView.registerNib(UINib(nibName: "ChatRecordTableViewCell", bundle:nil), forCellReuseIdentifier: "ChatRecordTableViewCell")
        
        
        //注册通知,监听键盘弹出事件
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name:UIKeyboardWillShowNotification, object: nil)
        //注册通知,监听键盘消失事件
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    /**键盘出现后view上移*/
    func keyboardDidShow(notification:NSNotification){
        var d:NSDictionary! = notification.userInfo
        var kbSize:CGSize! = d.objectForKey(UIKeyboardFrameEndUserInfoKey)?.CGRectValue.size
        var height = ScreenHeight - 42
        messageView.frame = CGRectMake(0,height - kbSize.height, ScreenWidth, 117)
        tabView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight - 43 - 70 - kbSize.height)
        if (tabView.contentSize.height - tabView.bounds.size.height) > 0 {
            tabView.setContentOffset(CGPointMake(0,tabView.contentSize.height - tabView.bounds.size.height), animated: true)
        }
        
    }
    
    func keyboardDidHidden(notification:NSNotification){
        messageView.frame = CGRectMake(0, ScreenHeight - 42, ScreenWidth, 117)
        tabView.frame = CGRectMake(0,0, ScreenWidth, ScreenHeight - 43 - 70)
        if (tabView.contentSize.height - tabView.bounds.size.height) > 0 {
            tabView.setContentOffset(CGPointMake(0,tabView.contentSize.height - tabView.bounds.size.height), animated: true)
        }
    }
    
    override func onLeftBtnOnClick(sender: UIButton) {
        super.onLeftBtnOnClick(sender)
        leftBtnOnClick()
    }
    
    func tabViewTap(tapGesture:UITapGestureRecognizer){
        showOrHidenView(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        var text = textField.text
        if !text!.isEmpty {
            submitText()
        }
        textField.becomeFirstResponder()
        return false
    }
    
    override func onRightBtnOnClick(sender: UIButton) {
        rightBtnOnClick()
    }
   
    @IBAction func sendOtherOnClick(sender: AnyObject) {
        showOrHidenView(false)
    }
    
    func showOrHidenView(yes:Bool){
        self.view.endEditing(true)
        if yes {
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.messageView.frame = CGRectMake(0, ScreenHeight - 42, ScreenWidth, 117)
                self.tabView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight  - 70 - 43)
                if (self.tabView.contentSize.height - self.tabView.bounds.size.height) > 0 {
                    self.tabView.setContentOffset(CGPointMake(0,self.tabView.contentSize.height - self.tabView.bounds.size.height), animated: true)
                }
            })
            
        }else{
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.messageView.frame = CGRectMake(0, ScreenHeight - 116, ScreenWidth, 117)
                self.tabView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight -  70 - 116)
                if (self.tabView.contentSize.height - self.tabView.bounds.size.height) > 0 {
                    self.tabView.setContentOffset(CGPointMake(0,self.tabView.contentSize.height - self.tabView.bounds.size.height), animated: true)
                }
            })
        }
        
        
    }
    
    /*发送群文本消息*/
    func submitText(){
        var str =  messageTextField.text
        if str!.characters.count > 0 {
            var messageEntity = ComFqHalcyonEntityChartEntity()
            messageEntity.setMessageTypeWithInt(1)
            messageEntity.setUserNameWithNSString(ComFqLibToolsConstants.getUser().getName())
            messageEntity.setMessageWithNSString(str)
            messageEntity.setUserIdWithInt(ComFqLibToolsConstants.getUser().getUserId())
            messageEntity.setUserImageIdWithInt(ComFqLibToolsConstants.getUser().getImageId())
            messageEntity.setMessageIndexWithInt(messageList.size())
            
            var date = NSDate().timeIntervalSince1970
            messageEntity.setmSendTimeWithDouble(date)
            messageList.addWithId(messageEntity)
            sendMessage(messageEntity.description(), success: true, payLoad: "", callBackTag: "")
        }
        
        messageTextField.text = ""
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    override func getXibName() -> String {
        return "BaseChatViewController"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        initViewWillAppearLoadData()
        if mIDCardmessageList.size() != 0 {
            sendIDCard(mIDCardmessageList)
        }
        
        if shareChatEntityList.size() != 0 {
            for i in 0..<shareChatEntityList.size() {
                let shareChatEntity:ComFqHalcyonEntityChartEntity! = shareChatEntityList.getWithInt(Int32(i)) as! ComFqHalcyonEntityChartEntity
                let date = NSDate().timeIntervalSince1970
                shareChatEntity.setmSendTimeWithDouble(date)
                shareChatEntity!.setMessageIndexWithInt(messageList.size())
                sendMessage(shareChatEntity!.description(), success: true, payLoad: "", callBackTag: "")
            }
            shareChatEntityList.clear()
        }
        
        if patientList.size() != 0 {
            sendPatientList()
        }
        
        if recordList.size() != 0 {
            sendReocordList()
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let row = indexPath.row
        let entity = (messageList.getWithInt(Int32(row))  as? ComFqHalcyonEntityChartEntity)
        let userId = entity?.getUserId()
        var messageType = entity?.getMessageType()
        var imageId:Int32 = 0
       
        var cell:ChatBaseCell?
        if userId != ComFqLibToolsConstants.getUser().getUserId() {
            cell =  ChatCellFactory.getInstance().createCell(DIRECTION.LEFT, entity: entity!, tableView: tableView,chatType: getChatType(),customId:getCustomId(),toUser:getToUser())
        }else{
            cell =  ChatCellFactory.getInstance().createCell(DIRECTION.RIGHT, entity: entity!, tableView: tableView,chatType: getChatType(),customId:getCustomId(),toUser:getToUser())
        }
        
        cell!.initData(entity!)
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        showOrHidenView(true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let row =  indexPath.row
        let entity = (messageList.getWithInt(Int32(row))  as? ComFqHalcyonEntityChartEntity)
        var userId = entity?.getUserId()
        let messageType = entity?.getMessageType()
        
        if messageType == 2 || messageType == 3 {
            return 130
        }else if messageType == 6 {
            return 136
        }else if messageType == 4 {
            return CGFloat(entity!.getImageHeight() + 38 + 10)
        }else{
            if MessageTools.calculateHeightForCell(entity!) <= 18 {
//                return (70 + 10)
                return 70
            }else{
//                return (MessageTools.calculateHeightForCell(entity!) + 38 + 26)
                return (MessageTools.calculateHeightForCell(entity!) + 38 + 10)
            }
        }
        
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(messageList.size())
    }
    

    /**选择病案**/
    @IBAction func patientOnclick(sender: AnyObject) {
       
    }
    
    var IdcardCount = 0
    /**发送名片**/
    func sendIDCard(cardList:JavaUtilArrayList){
        let countSize = cardList.size()
        for i in 0..<countSize {
            let messageEntity = cardList.getWithInt(i) as! ComFqHalcyonEntityChartEntity
            let date = NSDate().timeIntervalSince1970
            messageEntity.setmSendTimeWithDouble(date)
            messageEntity.setMessageIndexWithInt(messageList.size())
            sendMessage(messageEntity.description(), success: true, payLoad: "", callBackTag: "")
        }
        mIDCardmessageList.clear()
    }
    
    /**发送病案列表**/
    func sendPatientList(){
        loadingDialog = UIAlertViewTool.getInstance().showLoadingDialog("病案发送中...")
        var isSend:Int32 = 0
        if allDidSendInfo {
            isSend = 0
        }else{
            isSend = 1
        }
        for i in 0..<patientList.size() {
            let patientabstract =  patientList.getWithInt(i) as! ComFqHalcyonEntityPracticePatientAbstract
            sendChatPatientLogic(patientabstract.getPatientId(), obj: patientabstract, shareType: isSend)
            
        }
        patientList.clear()
    }
    
    /**发送记录列表**/
    func sendReocordList(){
        loadingDialog = UIAlertViewTool.getInstance().showLoadingDialog("记录发送中...")
        var isSend:Int32 = 0
        if allDidSendInfo {
            isSend = 0
        }else{
            isSend = 1
        }
        for i in 0..<recordList.size() {
            let recordabstract =  recordList.getWithInt(i) as! ComFqHalcyonEntityPracticeRecordAbstract
            sendChatRecordLogic(recordabstract.getRecordItemId(), obj: recordabstract, shareType: isSend)
        }
        recordList.clear()
    }
    
    func onSendPatientErrorWithInt(errorCode: Int32, withNSString msg: String!) {
        if position == Int(patientList.size()){
            position = 0
            loadingDialog.close()
            if errorSendCount != 0 {
                FQToast.makeError().show("您有\(errorSendCount)份病案分享失败！", superview: self.view)
            }
        }else{
            position++
            errorSendCount++
        }
        
        
    }
    
    
    func onSendPatientSuccessWithInt(shareMessageId: Int32, withInt sharePatientId: Int32,withComFqHalcyonEntityPracticePatientAbstract obj: ComFqHalcyonEntityPracticePatientAbstract!) {
        let date = NSDate().timeIntervalSince1970
        let chatEntity = ComFqHalcyonEntityChartEntity()
        chatEntity.setmSendTimeWithDouble(date)
        chatEntity.setSharePatientEntityWithComFqHalcyonEntityPracticePatientAbstract(obj, withInt: sharePatientId, withInt: shareMessageId)
        chatEntity.setMessageIndexWithInt(messageList.size())

        sendMessage(chatEntity.description(), success: true, payLoad: "", callBackTag: "")
        if position == Int(patientList.size()){
            position = 0
            loadingDialog.close()
            if errorSendCount != 0 {
                FQToast.makeError().show("您有\(errorSendCount)份病案分享失败！", superview: self.view)
            }
        }else{
            position++
        }
        
        
    }
    
    func onSendRecordErrorWithInt(errorCode: Int32, withNSString msg: String!) {
        if position == Int(recordList.size()){
            position = 0
            loadingDialog.close()
            if errorSendCount != 0 {
                FQToast.makeError().show("您有\(errorSendCount)份记录分享失败！", superview: self.view)
            }
        }else{
            position++
            errorSendCount++
        }
        
    }
  
    func onSendRecordSuccessWithInt(shareMessageId: Int32, withInt shareRecordItemId: Int32, withFQJSONArray shareRecordInfIds: FQJSONArray!, withComFqHalcyonEntityPracticeRecordAbstract obj: ComFqHalcyonEntityPracticeRecordAbstract!) {
        obj.setIsShowIdentityWithBoolean(allDidSendInfo)
        for m in 0..<shareRecordInfIds.length() {
            let date = NSDate().timeIntervalSince1970
            let chatEntity = ComFqHalcyonEntityChartEntity()
            chatEntity.setmSendTimeWithDouble(date)
            chatEntity.setRecordInfoIdWithInt(shareRecordInfIds.optIntWithInt(m))
            chatEntity.setMessageIndexWithInt(messageList.size())
            chatEntity.setShareRecordEntityWithComFqHalcyonEntityPracticeRecordAbstract(obj, withInt: shareRecordItemId, withInt: shareMessageId)

            sendMessage(chatEntity.description(), success: true, payLoad: "", callBackTag: "")
        }
        if position == Int(recordList.size()){
            position = 0
            loadingDialog.close()
            if errorSendCount != 0 {
                FQToast.makeError().show("您有\(errorSendCount)份记录分享失败！", superview: self.view)
            }
        }else{
            position++
        }
    }
    
    /**选择照片**/
    @IBAction func sendPicture(sender: AnyObject) {
        actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitles: "拍摄", "从本地相册选择")
        actionSheet.showInView(self.view)
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            print("点击拍照")
            Tools.Post({ () -> Void in
                self.cameraClick()
                }, delay: 0.5)
            
        }
        if buttonIndex == 2 {
            print("点击从相册选择")
            Tools.Post({ () -> Void in
                self.photoClick()
                }, delay: 0.5)
            
        }
        actionSheet.dismissWithClickedButtonIndex(buttonIndex, animated: true)
    }
    
    /**进入系统拍照界面**/
    func cameraClick() {
        let sourcetype = UIImagePickerControllerSourceType.Camera
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.allowsEditing = false//设置可编辑
        controller.sourceType = sourcetype
        self.presentViewController(controller, animated: true, completion: nil)//进入照相界面
    }
    
    /**进入系统选择照片界面**/
    func photoClick() {
        let pickImageController = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            pickImageController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            pickImageController.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(pickImageController.sourceType)!
        }
        pickImageController.delegate = self
        pickImageController.allowsEditing = false
        self.presentViewController(pickImageController, animated: true, completion: nil)//进入相册界面
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image =  info[UIImagePickerControllerOriginalImage] as! UIImage
        var data = UIImageJPEGRepresentation(image, 0.5)
        var height:CGFloat = 0
        var width:CGFloat = 0
        if (image.size.width/image.size.height) > (ScreenWidth/ScreenHeight) {
            width = ScreenWidth / 4
            height = width * image.size.height / image.size.width
        }else{
            height = ScreenHeight / 4
            width = height * image.size.width / image.size.height
        }
        
        print("hhhhhhhhhhhhhhhhhhhh---\(height)---wwwwwwwwwww---\(width)")
        let path = ComFqHalcyonExtendFilesystemFileSystem.getInstance().getImgTempPath()
        let date = NSDate().timeIntervalSince1970
        let name = "\(date)"
        var success =  UIImageManager.saveImageToLocal(image, path:path, imageName: name)
        
        messageImageEntity = ComFqHalcyonEntityChartEntity()
        messageImageEntity.setMessageTypeWithInt(4)
        messageImageEntity.setUserNameWithNSString(ComFqLibToolsConstants.getUser().getName())
        messageImageEntity.setUserIdWithInt(ComFqLibToolsConstants.getUser().getUserId())
        messageImageEntity.setUserImageIdWithInt(ComFqLibToolsConstants.getUser().getImageId())
        messageImageEntity.setMessageIndexWithInt(messageList.size())
        messageImageEntity.setImagePathWithNSString(name)
        messageImageEntity.setImageWidthWithFloat(Float(width))
        messageImageEntity.setImageHeightWithFloat(Float(height))
        messageImageEntity.setSendImageTypeWithInt(1)
        messageImageEntity.setmSendTimeWithDouble(date)
        
        messageList.addWithId(messageImageEntity)
        sendImageMessage(messageImageEntity.description(), success: true, path: path + name, messageImageEntity: messageImageEntity)
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func onUpLoadChatImageSuccessWithInt(imageId: Int32, withInt messageIndex: Int32) {
        
    }
    
    func onProcessWithFloat(process: Float, withInt messageIndex: Int32) {
        let row = messageIndex
        if  tabView.cellForRowAtIndexPath(NSIndexPath(forRow: Int(row), inSection: 0)) != nil {
            print(row)
            let cell =  tabView.cellForRowAtIndexPath(NSIndexPath(forRow: Int(row), inSection: 0)) as! SimpleChatRightCell
            (cell.subviews.last as! ChatProgressView).progressLabel.text = "\(Int(process*100))%"
           var count =  cell.subviews.count
            print(cell.subviews)
            print(process)
            if process == 1.0 {
//                (cell.subviews.last as! ChatProgressView).subviews.last!.removeFromSuperview()
                (cell.subviews.last as! ChatProgressView).removeFromSuperview()
            }
            
        }
    }
    
    func onUpLoadChatImageFailedWithInt(errorCode: Int32, withNSString msg: String!, withInt messageIndex: Int32) {
        
    }
    
    /**
    初始化单聊和群里viewdidload需要的参数
    */
    func initViewDidLoadData(){
        
    }
    
    /**
    初始化单聊和群里viewwillappear需要的参数
    */
    func initViewWillAppearLoadData(){
        
    }
    
    /**
    初始化单聊和群里左侧点击事件
    */
    func leftBtnOnClick(){
        
    }
    
    /**
    初始化单聊和群里右侧点击事件
    */
    func rightBtnOnClick(){
        
    }
    
    /**
    单聊、群聊公用一个发送接口，各自继承实现(发送图片稍有不同，使用另外一个接口)
    */
    func sendMessage(message:String,success:Bool,payLoad:String,callBackTag:String){
       
    }
    
    /**
    单聊、群聊公用发送图片接口
    */
    func sendImageMessage(message:String,success:Bool,path:String,messageImageEntity:ComFqHalcyonEntityChartEntity){
       
    }
    
    /**
    单聊、群聊公用病案logic公共接口
    */
    func sendChatPatientLogic(patientId:Int32,obj:ComFqHalcyonEntityPracticePatientAbstract,shareType:Int32){
  
    }
    
    /**
    单聊、群聊公用病例logic公共接口
    */
    func sendChatRecordLogic(recordItemId:Int32,obj:ComFqHalcyonEntityPracticeRecordAbstract,shareType:Int32){
      
    }
    
    /**
    返回聊天的类型
    
    - returns: <#return value description#>
    */
    func getChatType() ->Int {
        return chatType
    }
   
    /**
    返回对方的Id或者群Id
    
    - returns: <#return value description#>
    */
    func getCustomId() ->String {
        return customId
    }
    
    /**
     获取发送对方的对象，群返回nil
     
     - returns: <#return value description#>
     */
    func getToUser() -> ComFqHalcyonEntityPerson?{
        return nil
    }
    
}
