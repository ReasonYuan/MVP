//
//  NewNormalRecordViewController.swift
//  DoctorPlus_ios
//
//  Created by liaomin on 15-7-20.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class NewNormalRecordViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, ComFqHalcyonLogicPracticeShareLogic_ShareSaveRecordCallBack, UITextViewDelegate, ComFqHalcyonUilogicRecordDTLogic_RecordDTCallBack{
    
    @IBOutlet weak var backgroundView: UIView!
    
    //是否可以编辑
    var isEditable = true
    
    //获取数据条数
    var number = -1
    
    //UITextViewDelegate,comFqHalcyonLogic2GetRecordItemLogic_RecordItemCallBack,
    
    //是否是首次加载数据
    var firstTime = true
    
    //var mRecordItem:ComFqHalcyonEntityRecordItem?
    
    //标记处于编辑状态的textView
    var isEditingNum = -1
    
    var loadingDialog:CustomIOS7AlertView?
    
    //时间标签
    @IBOutlet weak var timeLabel: UILabel!
    
    //提示标签
    @IBOutlet weak var remindLabel: UILabel!
    
    @IBOutlet weak var addAttachmentBtn2: UIButton!
    @IBOutlet weak var addAttachmentBtn: UIButton!
    @IBOutlet weak var backToPatientBtn: UIButton!
    var editingIndex = -1
    //编辑状态，初始为非编辑状态
    var isModify = false
    
    //滑动列表显示与否
    var isSlideViewShow = false
    
    //滑动列表内容数组
    var slideTitles = [String]()
    
    
    //病历内容数组--标题
    var tableViewTitle = [String]()
    
    //病历内容数组--内容
    var tableViewContent = [String]()
    
    //获取病历详情逻辑
    //    var logic :ComFqHalcyonLogic2GetRecordItemLogic!
    
    var uilogic :ComFqHalcyonUilogicRecordDTNormalLogic!
    
    //var isOwned = false
    var isEditingText: String!
    
    //是否是分享的记录
    var isShared:Bool = false
    
    //病历记录的数据id（区别于recordItemId）
    //    var recordInfoId:Int32! = 0
    
    //保存分享记录的时调用接口需要使用
    var shareMessageId:Int32!
    
    //病历显示tableView
    @IBOutlet weak var mainTableView: UITableView!
    
    //滑动tableView
    @IBOutlet weak var slideTableView: UITableView!
    
    //提示标签下方整个视图的view
    @IBOutlet weak var secondView: UIView!
    
    var imagesView:FullScreenImageZoomView?
    
    var recordAbstract: ComFqHalcyonEntityPracticeRecordAbstract!
    
    var isBigImageShow = false
    
    ////    var record:ComFqHalcyonEntityPracticeRecordAbstract?
    
    var saveloadingDialog:CustomIOS7AlertView?
    
    var isFromSearch = false
    
    //MARK: ------------加载Xib
    override func getXibName() -> String {
        return "NewNormalRecordViewController"
        
        
    }
    
    
    
    //MARK: ------------视图初始化
    override func viewDidLoad() {
        
        super.viewDidLoad()
        addAttachmentBtn2.hidden = true
        timeLabel.hidden = true
        backgroundView.backgroundColor = UIColor(red: 85/255.0, green:  85/255.0, blue:  85/255.0, alpha: 0)
        slideTableView.hidden = true
        backgroundView.hidden = true
        
        
        uilogic = ComFqHalcyonUilogicRecordDTNormalLogic(comFqHalcyonUilogicRecordDTLogic_RecordDTCallBack:self)
        
        let recordInfoId = recordAbstract.getRecordInfoId()
        let recordId = recordAbstract.getRecordItemId()
        
        if OfflineManager.instance.isExists(CacheType.Records, id: Int64(recordId)) {
            let str = OfflineManager.instance.getRecordInfo(Int64(recordId), recordInfoid: Int64(recordInfoId))
            if let result = str {
                uilogic.offlineHandleWithNSString(result)
            }
        }else{
            uilogic.resquestRecordDetailDataWithInt(recordInfoId)
        }
        
        
        //隐藏导航栏右边的小按钮
        hiddenRightImage(true)/////
        
        //设置导航栏右按钮可见
        
        if isShared {
            
            if isMe{
                isFromSearch = true
                bigRightBtn.hidden = true
                
            }else{
                backToPatientBtn.hidden = true
                addAttachmentBtn.hidden = true
                addAttachmentBtn2.hidden = false
                bigRightBtn.hidden = false
                bigRightBtn.setTitle("保存", forState : UIControlState.Normal)
                
            }
        }else {
            //bigRightBtn.setTitle("编辑", forState : UIControlState.Normal)
            bigRightBtn.hidden = true
            
        }
        
        mainTableView.registerNib(UINib(nibName: "NewRecordCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "NewRecordCell")
        
        slideTableView.registerNib(UINib(nibName: "SlideTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "SlideTableViewCell")
        
        //添加点击事件方法，点击病案内容mainTableView，执行tableviewTab方法
        mainTableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tabViewTap:"))
        
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "slideViewTap"))
        
        //注册通知,监听键盘弹出事件
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name:UIKeyboardWillShowNotification, object: nil)
        //注册通知,监听键盘消失事件
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidHidden", name: UIKeyboardWillHideNotification, object: nil)
        
        //        showImages()
        
    }
    
    
    func loadDataErrorWithNSString(msg: String){
        
//        self.view.makeToast(msg)
        FQToast.makeError().show(msg, superview: self.view)
        
    }
    
    
    func modifyStatusWithBoolean(isSuccess:Bool){
        if isSuccess{
             FQToast.makeSystem().show("保存成功", superview: self.view)
//            self.view.makeToast("保存成功")
            //(UIAlertViewTool.getInstance() as UIAlertViewTool).showAutoDismisDialog("保存成功", width: 210, height: 120)
            
        }else{
             FQToast.makeError().show("保存失败", superview: self.view)
//            self.view.makeToast("保存失败")
            //(UIAlertViewTool.getInstance() as UIAlertViewTool).showAutoDismisDialog("保存失败", width: 210, height: 120)
            
        }
    }
    
    
    func loadDataSuccess(){
        
        
        
        timeLabel.text = uilogic.getRecTime()
        remindLabel.text = uilogic.getNoticeMessage()
        //remindLabel.text = "999999999999999"
        
        let number = uilogic.getTemplementsCount()
        
        
        var i :Int32
        if(firstTime){
            
            for ( i = 0; i < number; i++){
                
                
                
                
                slideTitles.append(uilogic.getInfoTitleByIndexWithInt(i))
                tableViewTitle.append(uilogic.getInfoTitleByIndexWithInt(i))
                tableViewContent.append(uilogic.getInfoContentByIndexWithInt(i))
                
            }
            
        }
        let time = uilogic.getTemplementsCount()
        if(time > 0){
            firstTime = false
            
        }
        updateTopLabel()
        mainTableView.reloadData()
        slideTableView.reloadData()
    }
    
    
    
    
    
    //MARK:------------test
    
    /**键盘出现后view上移*/
    func keyboardDidShow(notification:NSNotification){
        let d:NSDictionary! = notification.userInfo
        let kbSize:CGSize! = d.objectForKey(UIKeyboardFrameEndUserInfoKey)?.CGRectValue.size
        let frame = secondView.frame
        secondView.frame = CGRectMake(frame.origin.x, -kbSize.height+120, frame.size.width, frame.size.height)
    }
    
    /**键盘消失后view下移*/
    func keyboardDidHidden(){
        
        let frame = secondView.frame
        secondView.frame = CGRectMake(0, 0 , frame.size.width, frame.size.height)
        
    }
    
    
    //点击mainTableView之后执行此方法： 如果没有处于编辑状态 就弹出右侧菜单
    func tabViewTap(gestrue:UITapGestureRecognizer){
        
        
        if !isModify {
            setControllerShow()
        }
    }
    
    func slideViewTap(){
        
        setControllerShow()
        
    }
    
    //显示滑出的tableView
    func setControllerShow(){
        
        
        if isSlideViewShow {
            
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(0.4)
            UIView.setAnimationDelegate(self)
            UIView.setAnimationCurve(UIViewAnimationCurve.EaseInOut)
            UIView.setAnimationDidStopSelector(Selector("hiddenView"))
            isSlideViewShow = false
            slideTableView.frame = CGRectMake(ScreenWidth , 0, ScreenWidth*(2/3), ScreenHeight - 60)
            
            backgroundView.backgroundColor = UIColor(red: 85/255.0, green:  85/255.0, blue:  85/255.0, alpha: 0)
            UIView.commitAnimations()
        }else{
            backgroundView.hidden = false
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(0.4)
            UIView.setAnimationDelegate(self)
            UIView.setAnimationCurve(UIViewAnimationCurve.EaseInOut)
            isSlideViewShow = true
            slideTableView.hidden = false
            slideTableView.frame = CGRectMake(ScreenWidth * (1/3), 0, ScreenWidth*(2/3), ScreenHeight - 60)
            backgroundView.backgroundColor = UIColor(red: 85/255.0, green:  85/255.0, blue:  85/255.0, alpha: 0.85)
            UIView.commitAnimations()
            
        }
        
    }
    
    func hiddenView(){
        backgroundView.hidden = true;
    }
    
    
    //设置按钮点击后执行
    override func onRightBtnOnClick(sender:UIButton){
        if isShared {
            saveloadingDialog = UIAlertViewTool.getInstance().showLoadingDialog("保存中，请耐心等待...")
            let saveShare = ComFqHalcyonLogicPracticeShareLogic(comFqHalcyonLogicPracticeShareLogic_ShareSaveRecordCallBack: self)
            //TODO==YY==暂时写个0，到时要改到对应的recordInfoId
            //println("////////////////////\(shareMessageId)")
            saveShare.saveSharedRecordWithInt(shareMessageId, withInt:recordAbstract.getRecordItemId())
            //saveShare.saveSharedRecordWithInt(0, withInt:recordAbstract.getRecordItemId())
            
        }else {
            if(isModify){
                
                //转变到不编辑状态
                bigRightBtn.setTitle("编辑", forState : UIControlState.Normal)
                isModify = false
                
                let index = Int32(isEditingNum)
                uilogic.editContentWithInt(index, withNSString: isEditingText)
                uilogic.saveEditInfo()
                mainTableView.reloadData()
                updateTopLabel()
                
            }else{
                //转变到编辑中状态
                
                bigRightBtn.setTitle("完成", forState : UIControlState.Normal)
                isModify = true
                mainTableView.reloadData()
                updateTopLabel()
                
            }
            
        }
    }
    
    
    var dialog:CustomIOS7AlertView?
    /**保存失败回调*/
    func shareErrorWithInt(code: Int32, withNSString msg: String!) {
        saveloadingDialog?.close()
        dialog = UIAlertViewTool.getInstance().showZbarDialogWith1Btn("保存失败", target: self, actionOk: "cancel")
    }
    /**保存成功回调*/
    func shareSaveRecordSuccessWithInt(newRecordId: Int32) {
        saveloadingDialog?.close()
        dialog = UIAlertViewTool.getInstance().showZbarDialogWith1Btn("保存成功", target: self, actionOk: "sure")
        
    }
    
    func sure(){
        dialog?.close()
        self.navigationController?.popViewControllerAnimated(true)
    }
    func cancel(){
        dialog?.close()
        
    }
    
    //顶部标签更新（隐藏或显示）
    func updateTopLabel(){
        
        
        if (isModify || remindLabel.text == nil || remindLabel.text == ""){//转变到编辑中状态
            remindLabel.hidden = true
            let height = secondView.bounds.size.height + 30
            secondView.frame = CGRectMake(0,0,secondView.bounds.size.width,height)
            
            
        }else{
            // let height = ScreenHeight - 30
            //secondView.frame = CGRectMake(0,30,secondView.bounds.size.width,height)
            
            let frame = secondView.frame
            secondView.frame = CGRectMake(frame.origin.x,frame.origin.y + 30,frame.size.width,frame.size.height - 30)
            
            let str = remindLabel.text!
            let length = str.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
            
            if ( length > 80){
                labelTextAnimationStart()
            }
        }
        
        
        
    }
    
    
    
    // MARK:  ---------tableView数据源方法
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == mainTableView {
            
            
            
            let cell = tableView.dequeueReusableCellWithIdentifier("NewRecordCell") as? NewRecordCell
            
            
            let index = Int32(indexPath.row)
            cell?.label.text = uilogic.getInfoTitleByIndexWithInt(index)
            
            cell?.contentField.text = tableViewContent[indexPath.row]
            cell?.contentField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "textViewTap:"))
            
            cell?.contentField.delegate = self
            
            
            cell?.selected = false
            //
            //
            //            slideTitles.append(uilogic.getInfoTitleByIndexWithInt(i))
            //            tableViewTitle.append(uilogic.getInfoTitleByIndexWithInt(i))
            //            tableViewContent.append(uilogic.getInfoContentByIndexWithInt(i))
            
            if isModify {
                cell?.contentField.editable = true
                
            }else{
                
                cell?.contentField.editable = false
                
            }
            
            
            
            return cell!
            
            
            
        }else if tableView == slideTableView {
            
            let cell =  tableView.dequeueReusableCellWithIdentifier("SlideTableViewCell") as? SlideTableViewCell
            
            // cell!.titleLabel.text = tableViewTitle[indexPath.row]
            let index = Int32(indexPath.row)
            
            cell?.titleLabel.text = uilogic.getInfoTitleByIndexWithInt(index)
            
            _ = calculateWidthForCell(indexPath)
            
            
            //            if length > 102 {
            //                let frame = cell?.titleLabel.frame
            //                cell?.titleLabel.frame = CGRectMake(10,11, length , frame!.size.height)
            //                cell?.titleLabel.textAlignment =  NSTextAlignment.Center
            //
            //                UIView.beginAnimations(nil, context: nil)
            //                UIView.setAnimationDuration(5.0)
            //                UIView.setAnimationCurve(UIViewAnimationCurve.Linear)
            //                UIView.setAnimationDelegate(self)
            //                UIView.setAnimationRepeatCount(100)
            //                UIView.setAnimationRepeatAutoreverses(true)
            //                cell?.titleLabel.frame = CGRectMake(-(length - 100), 11, length, frame!.size.height )
            //                UIView.commitAnimations()
            //
            //}else{
            // slideTableView.setEditing(true)
            _ = cell?.titleLabel.frame
            //cell?.titleLabel.frame = CGRectMake(ScreenWidth*(2/3) - length, frame!.origin.y, length, frame!.size.height)
            //cell?.titleLabel.textAlignment =  NSTextAlignment.Right
            
            
            // }
            
            return cell!
        }
        
        return UITableViewCell()
        
        
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == mainTableView {
            return tableViewContent.count
            //            return Int(uilogic.getTemplementsCount())
        }else if tableView == slideTableView{
            return tableViewContent.count
            //            return Int(uilogic.getTemplementsCount()) + 1
        }
        return 0
    }
    
    func textViewTap(gestrue:UITapGestureRecognizer){
        let g = gestrue as UITapGestureRecognizer
        _ = g.view as! UITextView!
        
        if !isModify {
            
            setControllerShow()
        }
        
    }
    
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if tableView == mainTableView {
            
            if let cell = tableView.dequeueReusableCellWithIdentifier("NewRecordCell") as? NewRecordCell {
                cell.contentField.text = tableViewContent[indexPath.row]
                _ = Int32(indexPath.row)
                
                
                let textViewHeight  = cell.contentField.sizeThatFits(CGSizeMake(tableView.frame.size.width - 50, CGFloat(FLT_MAX))).height
                
                return (textViewHeight == 0 ? 10 : textViewHeight + 50)
            }
            return 44
            
            
        }else if tableView == slideTableView{
            
            return 44
            
        }
        
        
        
        
        
        return 44
        
        
        
    }
    // MARK:  ---------textView代理方法
    
    
    
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool{
        
        textView.layer.borderColor=UIColor.grayColor().CGColor
        textView.layer.borderWidth = 1.0
        
        
        for var i = 0 ; i < tableViewContent.count ; i++ {
            let text = tableViewContent[i]
            
            
            if ( textView.text == text){
                isEditingNum = i
                
                
            }
        }
        isEditingText = textView.text
        return true
        
        
    }
    
    func textViewShouldEndEditing(textView: UITextView) -> Bool{
        
        textView.layer.borderColor=UIColor.clearColor().CGColor
        textView.resignFirstResponder()
        return true
    }
    
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        return true
        
    }
    
    func textViewDidChange(textView: UITextView) {
        
        
        tableViewContent[isEditingNum] = textView.text
        
        isEditingText = textView.text
        
        // let frame = textView.frame
        
        mainTableView.beginUpdates()
        mainTableView.endUpdates()
    }
    
    func textViewDidEndEditing(textView: UITextView){
        
        let str: String = textView.text
        let index = Int32(isEditingNum)
        
        uilogic.editContentWithInt(index, withNSString: str)
        
    }
    
    
    // MARK:  ---------tableView代理方法
    
    
    
    //锚点设置
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if tableView == slideTableView {
            
            cellScrollTo(tableViewTitle[indexPath.row])
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            
        }
    }
    func cellScrollTo(title:String){
        var position = -1
        for (index,item) in tableViewTitle.enumerate(){
            if item == title{
                position = index
                break
            }
        }
        if position != -1 {
            let scrollIndexPath = NSIndexPath(forRow: position, inSection: 0)
            mainTableView.scrollToRowAtIndexPath(scrollIndexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //label text animation
    func labelTextAnimationStart(){
        
        
        remindLabel.frame = CGRectMake(0, 0, remindLabel.frame.size.width + ScreenWidth/8, remindLabel.frame.height)
        remindLabel.textAlignment =  NSTextAlignment.Center
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(5.0)
        UIView.setAnimationCurve(UIViewAnimationCurve.Linear)
        UIView.setAnimationDelegate(self)
        UIView.setAnimationRepeatCount(100)
        UIView.setAnimationRepeatAutoreverses(true)
        remindLabel.frame = CGRectMake(-(ScreenWidth/10) , 0, remindLabel.frame.size.width, remindLabel.frame.size.height)
        UIView.commitAnimations()
        
        
    }
    
    //MARK: ------------------显示图片
    //点击图片按钮后执行的方法
    @IBAction func detailButtonClicked(sender: UIButton) {
        
        //var mRecordItem:ComFqHalcyonEntityRecordItem?
        typealias RecordItemCallBack  = (ComFqHalcyonEntityRecordItem?) -> ()
        showImages()
        
        
    }
    
    @IBAction func addAttachment(sender: AnyObject) {
        if uilogic?.getRecordItem() != nil{
            let control = AddAttachmentViewController()
            control.recordItem = uilogic?.getRecordItem()
            control.recordItem?.setAttachImgIdsMapWithJavaUtilHashMap(recordAbstract.getAttachImgIdsMap())
            self.navigationController?.pushViewController(control, animated: true)
        }
    }
    
    
    
    @IBAction func patientButtonClicked(sender: UIButton) {
        
        if  isFromSearch {
            let controller = ExplorationRecordListViewController()
            controller.patientItem = uilogic.getPatientAbstract()
            print(controller.patientItem)
            controller.isShared = !isMe
            self.navigationController?.pushViewController(controller, animated:true)
            return
        }
        self.navigationController?.popViewControllerAnimated(true)
        
        
    }
    
    
    
    func showImages(){
        let imgList = uilogic.getImgIds()
        if imgList == nil || imgList!.size() == 0 {
//            self.view.makeToast("没有原图")
            FQToast.makeError().show("没有原图", superview: self.view)
            return
            
        }
        if imagesView != nil {
            imagesView!.removeFromSuperview();
            imagesView = nil
        }
        imagesView = FullScreenImageZoomView(frame: CGRectMake(0, 0, ScreenWidth, ScreenHeight))
        self.view.addSubview(imagesView!)
        
        
        var pagePhotoRecords = [ComFqHalcyonEntityPhotoRecord]()
        
        if imgList != nil {
            for var i:Int32 = 0 ; i < imgList!.size() ; i++ {
                let photoRecord = ComFqHalcyonEntityPhotoRecord()
                let imageId = imgList!.getWithInt(i) as! NSNumber
                photoRecord.setImageIdWithInt(imageId.intValue)
                photoRecord.setStateWithInt(ComFqHalcyonEntityPhotoRecord_REC_STATE_SUCC)
                pagePhotoRecords.append(photoRecord)
            }
        }
        if pagePhotoRecords.count > 0 {
            imagesView!.setDatas(0, pagePhotoRecords: pagePhotoRecords)
            imagesView?.showOrHiddenView(true)
        }
        
    }
    
    override func onLeftBtnOnClick(sender: UIButton)  {
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    //MARK: ------------------计算cell中label的长度
    func calculateWidthForCell(indexPath:NSIndexPath) -> CGFloat{
        
        _ =  indexPath.row
        
        let contentLabel = UILabel(frame: CGRectMake(0, 0, ScreenWidth - 112 - 10, 21.0))
        
        contentLabel.font = UIFont.systemFontOfSize(17.0)
        
        contentLabel.numberOfLines = 0
        
        
        let index = Int32(indexPath.row)
        
        contentLabel.text = uilogic.getInfoTitleByIndexWithInt(index)
        
        contentLabel.sizeToFit()
        
        
        
        let paragraphStyle = NSMutableParagraphStyle()
        
        paragraphStyle.lineBreakMode = NSLineBreakMode.ByCharWrapping
        
        let attrbutes = [NSFontAttributeName:contentLabel.font,NSParagraphStyleAttributeName:paragraphStyle.copy()]
        
        
        
        let height = contentLabel.frame.size.height
        
        let contentString:NSString = contentLabel.text!
        
        let contentLableSize = (contentString.boundingRectWithSize(CGSizeMake(CGFloat(MAXFLOAT),height), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: attrbutes, context: nil)).size
        
        let contentWidth = contentLableSize.width
        
        
        
        return contentWidth
        
    }
    
}
