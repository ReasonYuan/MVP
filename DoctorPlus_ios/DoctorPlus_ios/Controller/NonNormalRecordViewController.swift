//
//  NonNormalRecordViewController.swift
//  DoctorPlus_ios
//
//  Created by chenjie on 15/12/10.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import UIKit

class NonNormalRecordViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, ComFqHalcyonLogicPracticeShareLogic_ShareSaveRecordCallBack, UITextViewDelegate, ComFqHalcyonUilogicRecordDTLogic_RecordDTCallBack,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UnitViewDelegate,AttachmentListenerDelegate,ComFqLibToolsAttachmentManager_AddAttachmentUpLoadingInterface {
    
    
    
    //是否可以编辑
    var isEditable = true
    
    //获取数据条数
    var number = -1
    
    //是否是首次加载数据
    var firstTime = true
    
    //标记处于编辑状态的textView
    var isEditingNum = -1
    
    var loadingDialog:CustomIOS7AlertView?
    
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
    
    var uilogic :ComFqHalcyonUilogicRecordDTNormalLogic!
    
    var isEditingText: String!
    
    //是否是分享的记录
    var isShared:Bool = false
    
    //病历记录的数据id（区别于recordItemId）
    //    var recordInfoId:Int32! = 0
    
    //保存分享记录的时调用接口需要使用
    var shareMessageId:Int32!
    
    //显示大图
    var imagesView:FullScreenImageZoomView?
    
    var recordAbstract: ComFqHalcyonEntityPracticeRecordAbstract!
    
    var isBigImageShow = false
    
    var saveloadingDialog:CustomIOS7AlertView?
    
    var isFromSearch = false
    
    //病历显示tableView
    @IBOutlet weak var mainTableView: UITableView!
    
    //滑动tableView
    @IBOutlet weak var slideTableView: UITableView!
    
    //时间标签
    @IBOutlet weak var timeLabel: UILabel!
    
    //化验单名字标签
    @IBOutlet weak var recordNameLabel: UILabel!
    
    @IBOutlet weak var addAttachmentBtn: UIButton!
    @IBOutlet weak var backToPatientBtn: UIButton!
    @IBOutlet weak var showImageBtn:UIButton!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    
    /// 服务器获取的原图
    var imgList:JavaUtilArrayList?
    
    var unitView:UnitView?
    
    var headActionSheet:UIActionSheet?
    
    /// 数据库获取的附件图
    var imageList:[AttachmentImage] = [AttachmentImage]()
    

    /// 管理附件的logic
    var logic:ComFqLibToolsAttachmentManager?
    
    /// 图片map
    var map:JavaUtilHashMap!
    
    /// 服务器获取的附件图
    var imageIds:JavaUtilArrayList!
    
    var isUpdate = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hiddenRightImage(true)
        initBtn()
        initLogic()
        initView()
    }
    
    
    /**
     查看原图点击
     
     - parameter sender: btn
     */
    @IBAction func detailButtonClicked(sender: UIButton) {
        typealias RecordItemCallBack  = (ComFqHalcyonEntityRecordItem?) -> ()
        showImages()
        
        
    }
    /**
     添加附件
     
     - parameter sender: btn
     */
    @IBAction func addAttachment(sender: AnyObject) {
//        if uilogic?.getRecordItem() != nil{
//            let control = AddAttachmentViewController()
//            control.recordItem = uilogic?.getRecordItem()
//            control.recordItem?.setAttachImgIdsMapWithJavaUtilHashMap(recordAbstract.getAttachImgIdsMap())
//            self.navigationController?.pushViewController(control, animated: true)
//        }
                headActionSheet = UIActionSheet()
                headActionSheet?.addButtonWithTitle("拍摄")
                headActionSheet?.addButtonWithTitle("从相册选择")
                headActionSheet?.addButtonWithTitle("取消")
                headActionSheet?.cancelButtonIndex = 2
                headActionSheet?.delegate = self
                headActionSheet?.showInView(self.view)
    }
    
    func actionSheet(actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int){
        switch buttonIndex {
        case 0:
            let sourcetype = UIImagePickerControllerSourceType.Camera
            let controller = UIImagePickerController()
            controller.delegate = self
            controller.allowsEditing = false;//设置不可编辑
            controller.sourceType = sourcetype
            self.presentViewController(controller, animated: true, completion: nil)//进入照相
        case 1:
            let pickImageController = UIImagePickerController()
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
                pickImageController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                pickImageController.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(pickImageController.sourceType)!
            }
            pickImageController.delegate = self
            pickImageController.allowsEditing = true
            pickImageController.allowsEditing = false;//设置不可编辑
            self.presentViewController(pickImageController, animated: true, completion: nil)//进入相册页面
        default:
            print("")
        }
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
  
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        var path:String!
        let photos = info[UIImagePickerControllerOriginalImage] as? UIImage
        path = Tools.saveImage(photos)
        
        //添加数据及UI
        let photo = AttachmentImage()
        let photoRecord = ComFqHalcyonEntityPhotoRecord()
        photoRecord.setLocalPathWithNSString(path)
        photo.imageName = path
        let obj = ComFqHalcyonEntityPracticeUpLoadObject(int:recordAbstract.getRecordItemId(), withNSString: path)
        print("-----------\(path)")
        AttachmentTools.insertAttachment(Int(recordAbstract.getRecordItemId()), imageId: 0, imageName: photo.imageName!, status: AttachmentImageStatus.Uploading)
        logic?.upLoadingWithComFqHalcyonEntityPhotoRecord(photoRecord, withInt: recordAbstract.getRecordItemId(), withId: obj)
        imageList.append(photo)
        showBottomView()
        //        tableView.reloadData()
        //刷新ui
        unitView?.addNewUnit(photo.imageName, withName: "")
        
        isUpdate = true
        refreshUI()
    }
    
    
    
    
    /**
     返回点击
     
     - parameter sender: btn
     */
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
    
    
    /**
     显示原图
     */
    func showImages(){
        if uilogic.getImgIds() == nil{
            return
        }
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
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == mainTableView {
            let cell = tableView.dequeueReusableCellWithIdentifier("NewRecordCell") as? NewRecordCell
            let index = Int32(indexPath.row)
            cell?.label.text = uilogic.getInfoTitleByIndexWithInt(index)+":"
            cell?.contentField.text = tableViewContent[indexPath.row]
            cell?.contentField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "textViewTap:"))
            cell?.contentField.delegate = self
            cell?.selected = false
            if isModify {
                cell?.contentField.editable = true
            }else{
                cell?.contentField.editable = false
            }
            return cell!
        }else if tableView == slideTableView {
            let cell =  tableView.dequeueReusableCellWithIdentifier("SlideTableViewCell") as? SlideTableViewCell
            let index = Int32(indexPath.row)
            cell?.titleLabel.text = uilogic.getInfoTitleByIndexWithInt(index)
            return cell!
        }
        return UITableViewCell()
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if tableView == mainTableView {
            
            if let cell = tableView.dequeueReusableCellWithIdentifier("NewRecordCell") as? NewRecordCell {
                cell.contentField.text = tableViewContent[indexPath.row]
                let textViewHeight  = cell.contentField.sizeThatFits(CGSizeMake(tableView.frame.size.width - 30, CGFloat(FLT_MAX))).height
                return textViewHeight + 27
            }
            
            return 50
            
        }else if tableView == slideTableView{
            
            return 30
        }
        
        return 44
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == mainTableView {
            return tableViewContent.count
        }else if tableView == slideTableView{
            return tableViewContent.count
        }
        return 0
    }
    
    /**
     锚点点击
     */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if tableView == slideTableView {
            
            cellScrollTo(tableViewTitle[indexPath.row])
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            
        }
    }
    
    /**
     跳转至锚地
     
     - parameter title: 锚点
     */
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
    
    /**
     点击mainTableView之后执行此方法： 如果没有处于编辑状态 就弹出右侧菜单
     
     - parameter gestrue: 手势
     */
    func tabViewTap(gestrue:UITapGestureRecognizer){
        
        
        if !isModify {
            setSlideViewShow()
        }
    }
    
    func slideViewTap(){
        
        setSlideViewShow()
        
    }
    
    
    /**
     显示锚点tableview
     */
    func setSlideViewShow(){
        
        
        if isSlideViewShow {
            
            
            backgroundView.hidden = true
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(0.4)
            UIView.setAnimationDelegate(self)
            UIView.setAnimationCurve(UIViewAnimationCurve.EaseInOut)
            UIView.setAnimationDidStopSelector(Selector("hiddenView"))
            isSlideViewShow = false
            slideTableView.frame = CGRectMake(ScreenWidth , 0, 257, ScreenHeight - 60)
            UIView.commitAnimations()
        }else{
            
            
            
            backgroundView.hidden = false
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(0.4)
            UIView.setAnimationDelegate(self)
            UIView.setAnimationCurve(UIViewAnimationCurve.EaseInOut)
            isSlideViewShow = true
            slideTableView.frame = CGRectMake(ScreenWidth - 257, 0, 257, ScreenHeight - 60)
            UIView.commitAnimations()
            
        }
        
    }
    
    
    /**
     编辑按钮监听
     
     - parameter sender: 编辑按钮
     */
    override func onRightBtnOnClick(sender:UIButton){
        if isShared {
            saveloadingDialog = UIAlertViewTool.getInstance().showLoadingDialog("保存中，请耐心等待...")
            let saveShare = ComFqHalcyonLogicPracticeShareLogic(comFqHalcyonLogicPracticeShareLogic_ShareSaveRecordCallBack: self)
            saveShare.saveSharedRecordWithInt(shareMessageId, withInt:recordAbstract.getRecordItemId())
            
        }else {
            if(isModify){
                
                //转变到不编辑状态
                bigRightBtn.setTitle("编辑", forState : UIControlState.Normal)
                isModify = false
                
                let index = Int32(isEditingNum)
                uilogic.editContentWithInt(index, withNSString: isEditingText)
                uilogic.saveEditInfo()
                mainTableView.reloadData()
                
            }else{
                //转变到编辑中状态
                
                bigRightBtn.setTitle("完成", forState : UIControlState.Normal)
                isModify = true
                mainTableView.reloadData()
                
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
    
    func textViewTap(gestrue:UITapGestureRecognizer){
        let g = gestrue as UITapGestureRecognizer
        _ = g.view as! UITextView!
        
        if !isModify {
            
            setSlideViewShow()
        }
        
    }
    
    
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
        
        mainTableView.beginUpdates()
        mainTableView.endUpdates()
    }
    
    func textViewDidEndEditing(textView: UITextView){
        
        let str: String = textView.text
        let index = Int32(isEditingNum)
        
        uilogic.editContentWithInt(index, withNSString: str)
        
    }
    
    
    
    
    /**
     加载数据成功回调
     */
    func loadDataSuccess() {
        timeLabel.text = uilogic.getRecTime()
        recordNameLabel.text = uilogic.getRecordName()
        
        /// 有多少项,并给各项数据赋值
        let number = uilogic.getTemplementsCount()
        if(firstTime){
            for var  i:Int32 = 0; i < number; i++ {
                slideTitles.append(uilogic.getInfoTitleByIndexWithInt(i))
                tableViewTitle.append(uilogic.getInfoTitleByIndexWithInt(i))
                tableViewContent.append(uilogic.getInfoContentByIndexWithInt(i))
            }
        }
        
        let time = uilogic.getTemplementsCount()
        if(time > 0){
            firstTime = false
        }
        mainTableView.reloadData()
        slideTableView.reloadData()
        
        
        logic = ComFqLibToolsAttachmentManager.getInstanceWithInt((uilogic.getRecordItem().getRecordItemId()))
        logic?.checkupLoadingWithComFqLibToolsAttachmentManager_AddAttachmentLogicInterface(attachmentListener)
        logic?.checkProgressWithComFqLibToolsAttachmentManager_AddAttachmentUpLoadingInterface(self)
        attachmentListener.setDelagete((uilogic.getRecordItem().getRecordItemId()),delegate: self)
        map = recordAbstract?.getAttachImgIdsMap()
        imageIds = logic?.getAllImageIdsWithJavaUtilHashMap(map, withJavaUtilHashMap: map)
        imageList =  updateLocalDB()
        
        showBottomView()
        
        refreshUI()
    }
    
    /**
     加载数据出错
     
     - parameter msg: 错误信息
     */
    func loadDataErrorWithNSString(msg: String!) {
//        self.view.makeToast(msg)
        FQToast.makeError().show(msg, superview: self.view)
    }
    
    
    /**
     修改是否成功回调
     
     - parameter isb:true修改成功 false 修改失败
     */
    func modifyStatusWithBoolean(isb: Bool) {
        if isb{
//            self.view.makeToast("保存成功")
            FQToast.makeSystem().show("保存成功", superview: self.view)
            
        }else{
            FQToast.makeError().show("保存失败", superview: self.view)
//            self.view.makeToast("保存失败")
            
        }
    }
    /**
     设置btn的背景图片
     */
    func initBtn(){
        let backNomalImage = UIImage(named: "icon_back_patient.png")
        let backHighlightImage = UITools.imageByApplyingAlpha(0.7, image: backNomalImage!)
        backToPatientBtn.setBackgroundImage(backNomalImage, forState: UIControlState.Normal)
        backToPatientBtn.setBackgroundImage(backHighlightImage, forState: UIControlState.Highlighted)
        
        let showNomalImage = UIImage(named: "icon_show_recordimg.png")
        let showHighlightImage = UITools.imageByApplyingAlpha(0.7, image: showNomalImage!)
        showImageBtn.setBackgroundImage(showNomalImage, forState: UIControlState.Normal)
        showImageBtn.setBackgroundImage(showHighlightImage, forState: UIControlState.Highlighted)
        
        let addNomalImage = UIImage(named: "icon_record_attachment.png")
        let addHighlightImage = UITools.imageByApplyingAlpha(0.7, image: addNomalImage!)
        addAttachmentBtn.setBackgroundImage(addNomalImage, forState: UIControlState.Normal)
        addAttachmentBtn.setBackgroundImage(addHighlightImage, forState: UIControlState.Highlighted)
    }
    
    
    
    
    /**
     初始化logic
     */
    func initLogic(){
        
        
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
    }
    

    
    /**
     显示底部附件View
     */
    func showBottomView(){
        if imageList.count != 0 {
            bottomViewHeight.constant = 80
            
        }else{
            bottomViewHeight.constant = 0
        }
    }
    
    /**
     初始化视图
     */
    func initView(){
        
        unitView = UnitView(frame: CGRectMake(0,0,ScreenWidth,66))
        unitView?.backgroundColor = UITools.colorWithHexString("#1e1e28")
        unitView?.delegate = self
        bottomView.addSubview(unitView!)
        
        
        backgroundView.frame = CGRectMake(0,0,ScreenWidth,ScreenHeight - 70)
        
        if isShared {
            
            if isMe{
                isFromSearch = true
                bigRightBtn.hidden = true
                bigRightBtn.setTitle("编辑", forState : UIControlState.Normal)
                
            }else{
                backToPatientBtn.hidden = true
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
        //这个版本不需要编辑
        //        //注册通知,监听键盘弹出事件
        //        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name:UIKeyboardWillShowNotification, object: nil)
        //        //注册通知,监听键盘消失事件
        //        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidHidden", name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    
    
    //暂时不用
    /**
    键盘出现后的监听
    
    - parameter notification: notification
    */
    func keyboardDidShow(notification:NSNotification){
        let d:NSDictionary! = notification.userInfo
        let kbSize:CGSize! = d.objectForKey(UIKeyboardFrameEndUserInfoKey)?.CGRectValue.size
        //        let frame = secondView.frame
        //        secondView.frame = CGRectMake(frame.origin.x, -kbSize.height+120, frame.size.width, frame.size.height)
    }
    
    /**
     键盘消失后的监听
     */
    func keyboardDidHidden(){
        
        //        let frame = secondView.frame
        //        secondView.frame = CGRectMake(0, 0 , frame.size.width, frame.size.height)
        
    }
    
    
    
    func itemClicked(unitCell: UnitCell!) {
        let i = unitView?.unitList.indexOfObject(unitCell)
        if unitCell.getVisible() {
            //查看大图
            showImage(i!)
        }else{
            unitCell.setVisible(false)
            //重新上传或重新修改
            if unitCell.status == 1{
                //重新上传
                let photo =  imageList[i!]
                let photoRecord = ComFqHalcyonEntityPhotoRecord()
                photoRecord.setLocalPathWithNSString(photo.imageName)
                let obj = ComFqHalcyonEntityPracticeUpLoadObject(int:recordAbstract.getRecordItemId(), withNSString: photo.imageName)
                print("-----------\(photo.imageName)")
                logic?.upLoadingWithComFqHalcyonEntityPhotoRecord(photoRecord, withInt: recordAbstract.getRecordItemId(), withId: obj)
                AttachmentTools.updateAttachment(Int(recordAbstract.getRecordItemId()), imageId: 0, imageName: photo.imageName!, status: AttachmentImageStatus.Uploading)
            }else if unitCell.status == 3{
                //重新修改
                let photo =  imageList[i!]
                let photoRecord = ComFqHalcyonEntityPhotoRecord()
                photoRecord.setImageIdWithInt(Int32(photo.imageId))
                logic?.uploadAttachWithComFqHalcyonEntityPhotoRecord(photoRecord, withInt: recordAbstract.getRecordItemId())
                unitCell.status = 5
            }
        }
    }
    
    func removeOne(imageId:Int32){
        let iterator = map.keySet().iterator()
        while(iterator.hasNext()){
            let title = iterator.next() as! String
            for i in 0..<(map.getWithId(title) as! JavaUtilArrayList).size()  {
                let photo = ((map.getWithId(title) as! JavaUtilArrayList).getWithInt(i) as! ComFqHalcyonEntityPhotoRecord)
                if imageId == photo.getImageId() {
                    ((map.getWithId(title) as! JavaUtilArrayList)).removeWithInt(i)
                    return
                }
            }
        }
        
    }
    
    func itemDelete(unitCell: UnitCell!) {
        //        print("_________________________")
        let i = unitView?.unitList.indexOfObject(unitCell)
        print("---数组i----\(i)")
        let photo = AttachmentTools.getAttachmentList(Int(recordAbstract.getRecordItemId()))[i!]
        
        if photo.status == AttachmentImageStatus.ChangeSUCCESS {
            //图片已上传到网络上
            let list = JavaUtilArrayList()
            let photoRecord = ComFqHalcyonEntityPhotoRecord()
            photoRecord.setImageIdWithInt(Int32(photo.imageId))
            list.addWithId(photoRecord)
            logic?.removeAttachmentWithInt(Int32(photo.recordItemId), withJavaUtilArrayList: list)
            
        }else{
            if (photo.imageId == 0 || photo.imageName != ""){  //图片只在本地，并没有上传到网络上
                imageList.removeAtIndex(i!)
                //TODO
                AttachmentTools.deleteAttachment(photo.recordItemId, imageId: photo.imageId, imageName: photo.imageName!)
                //                if photo.status == AttachmentImageStatus.Uploading {
                ComFqLibHttpHelper.cancleWithNSString(photo.imageName)
                //                }
            }
        }
        
    }

    
    
    func showImage(index:Int){
        if imageList.count == 0 {
            self.view.makeToast("没有附件")
            return
        }
        imagesView = FullScreenImageZoomView(frame: CGRectMake(0, 0, ScreenWidth, ScreenHeight))
        self.view.addSubview(imagesView!)
        
        var pagePhotoRecords = [ComFqHalcyonEntityPhotoRecord]()
        if imageList.count != 0 {
            for var i:Int32 = 0 ; i < Int32(imageList.count) ; i++ {
                let photoRecord = ComFqHalcyonEntityPhotoRecord()
                let attachImage = (imageList[Int(i)] as AttachmentImage)
                photoRecord.setImageIdWithInt(Int32(attachImage.imageId))
                photoRecord.setLocalPathWithNSString(attachImage.imageName)
                pagePhotoRecords.append(photoRecord)
            }
        }
        
        if pagePhotoRecords.count > 0 {
            imagesView!.setDatas(index, pagePhotoRecords: pagePhotoRecords)
            imagesView!.showOrHiddenView(true)
        }
        
    }

    
    func refreshUI(){
        print("---------\(imageList.count)")
        if imageList.count > 0 {
            unitView?.hidden = false
            for i in 0..<self.imageList.count {
                if !isUpdate {
                    self.unitView!.addNewUnit("", withName: "")
                }
                if i == self.imageList.count - 1 {
                    self.unitView!.addNewUnit("", withName: "")
                }
                let photo = imageList[i]
                let cell = unitView?.unitList[i] as! UnitCell
                let status:Int
                if photo.status != nil {
                    status = photo.status.rawValue
                    cell.status = status
                    if (status == 1 || status == 3){
                        cell.setVisible(true)
                    }else{
                        cell.setVisible(false)
                    }
                }
                
                print(unitView?.unitList.count)
                var localPath = ""
                if let _ = photo.imageName {
                    localPath =  photo.getLocalPath()
                }
                if localPath != ""{
                    if let img =  UIImage(contentsOfFile: localPath) {
                        cell.setBackgroundImage(img, forState: UIControlState.Normal)
                    }else {
                        cell.downLoadImageWidthImageId(Int32(photo.imageId), callback: { (view, path) -> Void in
                            cell.setBackgroundImage(UITools.getImageFromFile(path), forState: UIControlState.Normal)
                        })
                    }
                    //加载本地图片
                }else{
                    //从网络获取图片
                    cell.downLoadImageWidthImageId(Int32(photo.imageId), callback: { (view, path) -> Void in
                        cell.setBackgroundImage(UITools.getImageFromFile(path), forState: UIControlState.Normal)
                    })
                }
                
            }
        }else{
            unitView?.hidden = true
        }
    }

    /**
     同步数据库
     */
    func updateLocalDB() ->[AttachmentImage]{
        let list = AttachmentTools.getAttachmentList(Int((uilogic?.getRecordItem().getRecordItemId())!))
        if Int32(list.count) < imageIds.size(){
            AttachmentTools.insertAttachmentList(Int((uilogic?.getRecordItem().getRecordItemId())!), photoList: imageIds)
        }
        print("------服务器附件数\(imageIds.size())----------本地数据库附件数\(list.count)")
        return AttachmentTools.getAttachmentList(Int((uilogic?.getRecordItem().getRecordItemId())!))
    }
    
    func updateUI(recordItemId: Int32){
        imageList = AttachmentTools.getAttachmentList(Int(recordItemId))
        showBottomView()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func getXibName() -> String {
        return "NonNormalRecordViewController"
    }
    
    /**
     上传图片进度
     
     - parameter progress:  进度
     - parameter imageName: 图片名字
     - parameter obj:       特殊用途
     */
    func upLoadProgressWithFloat(progress: Float, withNSString imageName: String!, withId obj: AnyObject!) {
        print("------\(progress)-------\(imageName)")
        for i in 0..<self.imageList.count {
            let photo = imageList[i]
            (unitView?.unitList[i] as! UnitCell).status = 0
            if (photo.imageName != "") {
                if photo.imageName == imageName {
                    let s = "\(Int(progress*100))%"
                    (unitView?.unitList[i] as! UnitCell).setProgress(s)
                }
            }
        }

    }
    
    /**
     上传图片失败的回调
     
     - parameter recordItemId: <#recordItemId description#>
     - parameter imageName:    <#imageName description#>
     */
    func onUpLoadingErrorWithInt(recordItemId: Int32, withNSString imageName: String!) {
        //TODO 修改数据库状态 更新UI
        for i in 0..<self.imageList.count {
            let photo = imageList[i]
            print(photo.imageName)
            print(imageName)
            if (photo.imageName != "") {
                if photo.imageName == imageName {
                    (unitView?.unitList[i] as! UnitCell).status = 1
                    (unitView?.unitList[i] as! UnitCell).setProgress("100%")
                    (unitView?.unitList[i] as! UnitCell).setVisible(true)
                }
            }
        }
        FQToast.makeError().show("上传失败", superview: self.view)
    }
    
    /**
     上传图片成功的回调
     
     - parameter recordItemId: <#recordItemId description#>
     - parameter imageId:      <#imageId description#>
     */
    func onUpLoadingSuccessWithInt(recordItemId: Int32, withInt imageId: Int32,withNSString imageName:String!) {
        //TODO 修改数据库状态 更新UI
        for i in 0..<self.imageList.count {
            let photo = imageList[i]
            print(photo.imageId)
            if (photo.imageId != 0) {
                if photo.imageId == Int(imageId) {
                    (unitView?.unitList[i] as! UnitCell).status = 2
                    (unitView?.unitList[i] as! UnitCell).setVisible(false)
                }
            }
        }
    }
    
    /**
     修改附件失败的回调
     
     - parameter recordItemId: <#recordItemId description#>
     - parameter imageId:      <#imageId description#>
     */
    func onModifyErrorWithInt(recordItemId: Int32, withInt imageId: Int32) {
        //TODO 修改数据库状态 更新UI
        for i in 0..<self.imageList.count {
            let photo = imageList[i]
            print(photo.imageId)
            if (photo.imageId != 0) {
                if photo.imageId == Int(imageId) {
                    (unitView?.unitList[i] as! UnitCell).status = 3
                    (unitView?.unitList[i] as! UnitCell).setVisible(false)
                }
            }
        }
        FQToast.makeError().show("修改附件失败", superview: self.view)
    }
    
    /**
     修改附件成功的回调
     
     - parameter recordItemId: <#recordItemId description#>
     - parameter imageId:      <#imageId description#>
     */
    func onModifySuccessWithInt(recordItemId: Int32, withInt imageId: Int32) {
        //TODO 修改数据库状态 更新UI
        for i in 0..<self.imageList.count {
            let photo = imageList[i]
            print(photo.imageId)
            if (photo.imageId != 0) {
                if photo.imageId == Int(imageId) {
                    (unitView?.unitList[i] as! UnitCell).status = 4
                    (unitView?.unitList[i] as! UnitCell).setVisible(true)
                }
            }
        }
        updateUI(recordItemId)
    }
    
    /**
     删除附件失败的回调
     
     - parameter code: <#code description#>
     - parameter msg:  <#msg description#>
     */
    func onRemoveErrorWithInt(code: Int32, withNSString msg: String!, withInt recordItemId: Int32,withInt imageId:Int32) {
        updateUI(recordItemId)
        FQToast.makeError().show(msg, superview: self.view)
    }
    
    /**
     删除附件成功的回调
     
     - parameter photos: <#photos description#>
     */
    
    func onRemoveSuccessWithJavaUtilArrayList(photos: JavaUtilArrayList!, withInt reocordItemId: Int32,withInt imageId: Int32) {
        removeOne(imageId)
        updateUI(reocordItemId)
        
        imageList = updateLocalDB()
        showBottomView()
    }
    
    /**
     取消上传的回调
     
     - parameter recordItemId: <#recordItemId description#>
     - parameter imageName:    <#imageName description#>
     */
    func onCancleUpLoadingWithInt(recordItemId: Int32, withNSString imageName: String!) {
        //TODO删除本地数据
        updateUI(recordItemId)
    }
    
    /**
     取消添加附件imageid的回调
     
     - parameter recordItemId: <#recordItemId description#>
     - parameter imageId:      <#imageId description#>
     */
    func onCancleModifyingWithInt(recordItemId: Int32, withInt imageId: Int32) {
        //TODO删除本地数据
        updateUI(recordItemId)
    }
    

}
