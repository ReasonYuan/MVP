//
//  ExamItemViewController.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/7/27.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit
var isFromSearch :Bool? = false

class ExamItemViewController: BaseViewController ,ComFqHalcyonUilogicRecordDTLogic_RecordDTCallBack,UITextFieldDelegate,ComFqHalcyonLogicPracticeShareLogic_ShareSaveRecordCallBack,NormalExamItemViewDelegate,UnnormalExamUIViewDelegate,ComFqLibToolsAttachmentManager_AddAttachmentUpLoadingInterface,AttachmentListenerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate ,UIActionSheetDelegate ,UnitViewDelegate{
    var dialog:CustomIOS7AlertView!
    var textView:UITextField!
    var textView1:UITextField!
    var textView2:UITextField!
    var headActionSheet:UIActionSheet?
    var recordAbstract:ComFqHalcyonEntityPracticeRecordAbstract!
    var recordDTExamLogic:ComFqHalcyonUilogicRecordDTExamLogic?
    var isNormal:Bool = false
    var isShared:Bool = false
    var isEdit:Bool = true
    var normalExamItemView:NormalExamItemView!
    var logic:ComFqLibToolsAttachmentManager?
    var shareMessageId:Int32!
    var saveloadingDialog:CustomIOS7AlertView?
    var map:JavaUtilHashMap!
    var unnormalExamItemView:UnnormalExamUIView?
    var imagesView:FullScreenImageZoomView!
    var imgList:JavaUtilArrayList?
    var isFromChart :Bool? = false
    var unitView:UnitView?
    var photoDic:[UIButton:AttachmentImage] = [UIButton:AttachmentImage]()
    var isUpdate = false
    var imageIds:JavaUtilArrayList!
    
    var imageList:[AttachmentImage] = [AttachmentImage]()
    override func viewDidLoad() {
        super.viewDidLoad()
        if isShared {
            if isMe {
                setRightBtnTittle("")
            }else{
                setRightBtnTittle("保存")
            }
        }else {
            setRightBtnTittle("")
            setRightBtnClickable(false)
        }
        
        unitView = UnitView(frame: CGRectMake(0, ScreenHeight - 66, self.view.frame.size.width, 66))
        unitView?.backgroundColor = UIColor.blackColor()
        unitView?.delegate = self
        unitView?.hidden = true
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onExamItemChanged:", name: "OnExamItemChanged", object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        recordDTExamLogic = ComFqHalcyonUilogicRecordDTExamLogic(comFqHalcyonUilogicRecordDTLogic_RecordDTCallBack: self)
        
        let recordInfoId = recordAbstract.getRecordInfoId()
        let recordId = recordAbstract.getRecordItemId()
        
        if OfflineManager.instance.isExists(CacheType.Records, id: Int64(recordId)) {
            let str = OfflineManager.instance.getRecordInfo(Int64(recordId), recordInfoid: Int64(recordInfoId))
            if let result = str {
                recordDTExamLogic?.offlineHandleWithNSString(result)
            }
            
        }else{
            recordDTExamLogic?.resquestRecordDetailDataWithInt(recordInfoId)
        }
    }
    
    func loadDataSuccess() {
        if((recordDTExamLogic?.isOtherExam()) != nil && (recordDTExamLogic?.isOtherExam()) == true){
            unnormalExamItemView = UnnormalExamUIView(frame: CGRectMake(0, 70, ScreenWidth, ScreenHeight))
            if isShared {
                if isMe {
                    isFromSearch = true
                    unnormalExamItemView!.backToPatientBtn.hidden = false
                    unnormalExamItemView!.backToPatientBtn.setImage(UIImage(named: "btn_back_patient.png"), forState: UIControlState.Normal)
                    unnormalExamItemView!.backToPatientBtn.setImage(UIImage(named: "btn_back_patient.png"), forState: UIControlState.Highlighted)
                }else{
                    //通过判断返回病案按钮是否显示来确定附件按钮的位置
                    unnormalExamItemView!.backToPatientBtn.hidden = false
                    unnormalExamItemView!.backToPatientBtn.setImage(UIImage(named: "btn_back_patient.png"), forState: UIControlState.Normal)
                    unnormalExamItemView!.backToPatientBtn.setImage(UIImage(named: "btn_back_patient.png"), forState: UIControlState.Highlighted)
                    unnormalExamItemView!.backToAttachmentBtn.hidden = true
                }
            }
            imgList = recordDTExamLogic?.getImgIds()
            unnormalExamItemView?.delegate = self
            unnormalExamItemView!.recordDTExamLogic = recordDTExamLogic
            unnormalExamItemView!.recordAbstract = self.recordAbstract
            unnormalExamItemView!.setDatas(recordDTExamLogic)
            setRightBtnTittle("")//先不要编辑按钮
            setRightBtnClickable(false)
            self.view.addSubview(unnormalExamItemView!)
            
            self.view.addSubview(unitView!)
            logic = ComFqLibToolsAttachmentManager.getInstanceWithInt((recordDTExamLogic?.getRecordItem().getRecordItemId())!)
            logic?.checkupLoadingWithComFqLibToolsAttachmentManager_AddAttachmentLogicInterface(attachmentListener)
            logic?.checkProgressWithComFqLibToolsAttachmentManager_AddAttachmentUpLoadingInterface(self)
            attachmentListener.setDelagete((recordDTExamLogic?.getRecordItem().getRecordItemId())!,delegate: self)
            map = unnormalExamItemView!.recordAbstract?.getAttachImgIdsMap()
            imageIds = logic?.getAllImageIdsWithJavaUtilHashMap(map, withJavaUtilHashMap: map)
            imageList =  updateLocalDB()
            refreshUI()
        }else{
            normalExamItemView = NormalExamItemView(frame: CGRectMake(0, 70, ScreenWidth, ScreenHeight - 70))
            if isShared {
                if isMe {
                    isFromSearch = true
                    normalExamItemView.backToPatientBtn.hidden = false
                    normalExamItemView.backToPatientBtn.setImage(UIImage(named: "btn_back_patient.png"), forState: UIControlState.Normal)
                    normalExamItemView.backToPatientBtn.setImage(UIImage(named: "btn_back_patient.png"), forState: UIControlState.Highlighted)
                }else{
                    //通过判断返回病案按钮是否显示来确定附件按钮的位置
                    normalExamItemView.backToPatientBtn.hidden = false
                    normalExamItemView.backToPatientBtn.setImage(UIImage(named: "icon_attachment.png"), forState: UIControlState.Normal)
                    normalExamItemView.backToPatientBtn.setImage(UIImage(named: "icon_attachment_highlight.png"), forState: UIControlState.Highlighted)
                    normalExamItemView.backToAttachmentBtn.hidden = true
                }
            }
            normalExamItemView!.recordDTExamLogic = recordDTExamLogic
            normalExamItemView!.recordAbstract = self.recordAbstract
            imgList = recordDTExamLogic?.getImgIds()
            normalExamItemView.delegate = self
            normalExamItemView!.startGetPatientItemExamLogic(1)
            self.view.addSubview(normalExamItemView!)
            self.view.addSubview(unitView!)
            logic = ComFqLibToolsAttachmentManager.getInstanceWithInt((recordDTExamLogic?.getRecordItem().getRecordItemId())!)
            logic?.checkupLoadingWithComFqLibToolsAttachmentManager_AddAttachmentLogicInterface(attachmentListener)
            logic?.checkProgressWithComFqLibToolsAttachmentManager_AddAttachmentUpLoadingInterface(self)
            attachmentListener.setDelagete((recordDTExamLogic?.getRecordItem().getRecordItemId())!,delegate: self)
            map = normalExamItemView.recordAbstract?.getAttachImgIdsMap()
            imageIds = logic?.getAllImageIdsWithJavaUtilHashMap(map, withJavaUtilHashMap: map)
            imageList =  updateLocalDB()
            refreshUI()
        }
    }
    
    func loadDataErrorWithNSString(msg: String!) {
        
    }
    
    func modifyStatusWithBoolean(isb: Bool) {
        if isb {
            
        }else{
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func getXibName() -> String {
        return "ExamItemViewController"
    }
    
    override func onLeftBtnOnClick(sender: UIButton) {
        
        if normalExamItemView != nil {
            if imagesView != nil && !(imagesView.hidden) {
                imagesView.showOrHiddenView(false)
                imagesView.removeFromSuperview()
                imagesView = nil
            }else{
                self.navigationController?.popViewControllerAnimated(true)
            }
        }else{
            unnormalExamItemView?.editTableView.hidden = true
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func okClick(){
        normalExamItemView.xmName = textView.text!
        normalExamItemView.value = textView1.text!
        normalExamItemView.unit = textView2.text!
        normalExamItemView.editConfirm()
        setRightBtnTittle("编辑")
        isEdit = true
        normalExamItemView.unit = ""
        normalExamItemView.value = ""
        normalExamItemView.xmName = ""
        dialog.close()
    }
    
    func cancelClick(){
        setRightBtnTittle("编辑")
        isEdit = !isEdit
        dialog.close()
    }
    
    override func onRightBtnOnClick(sender: UIButton) {
        if isShared {
            if isMe {
                
            }else{
                saveloadingDialog = UIAlertViewTool.getInstance().showLoadingDialog("保存中，请耐心等待...")
                let saveShare = ComFqHalcyonLogicPracticeShareLogic(comFqHalcyonLogicPracticeShareLogic_ShareSaveRecordCallBack: self)
                saveShare.saveSharedRecordWithInt(shareMessageId, withInt:recordAbstract.getRecordItemId())
            }
        }
    }
    
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
    
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField == textView {
            normalExamItemView.xmName = textView.text!
        }else if textField == textView1 {
            normalExamItemView.value = textView1.text!
        }else {
            normalExamItemView.unit = textView2.text!
        }
    }
    
    func onImgClick() {
        showAllImages()
    }
    
    func onBackClick() {
        if isShared == true && isMe == false {
            if recordDTExamLogic?.getRecordItem() != nil{
                let control = AddAttachmentViewController()
                control.recordItem = recordDTExamLogic?.getRecordItem()
                control.recordItem?.setAttachImgIdsMapWithJavaUtilHashMap(recordAbstract.getAttachImgIdsMap())
                self.navigationController?.pushViewController(control, animated: true)
            }
        }else{
            if isFromSearch! {
                let control = ExplorationRecordListViewController()
                control.patientItem = recordDTExamLogic?.getPatientAbstract()
                control.isShared = !isMe
                self.navigationController?.pushViewController(control, animated: true)
            }else{
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
    }
    
    func onLookImgClick() {
        showAllImages()
    }
    
    //附件点击
    func onBackToAttachmentClick() {
        if recordDTExamLogic?.getRecordItem() != nil{
            takePhotos()
        }
    }
    
    
    func onToPatientClick() {
        if isShared == true && isMe == false {
            if recordDTExamLogic?.getRecordItem() != nil{
                let control = AddAttachmentViewController()
                control.recordItem = recordDTExamLogic?.getRecordItem()
                control.recordItem?.setAttachImgIdsMapWithJavaUtilHashMap(recordAbstract.getAttachImgIdsMap())
                self.navigationController?.pushViewController(control, animated: true)
            }
        }else{
            if isFromSearch! {
                let control = ExplorationRecordListViewController()
                control.patientItem = recordDTExamLogic?.getPatientAbstract()
                self.navigationController?.pushViewController(control, animated: true)
            }else{
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
    }
    
    
    func showImages(index:Int){
        if imageList.count == 0 {
//            self.view.makeToast("没有附件")
             FQToast.makeError().show("没有附件", superview: self.view)
            return
        }
        imagesView = FullScreenImageZoomView(frame: CGRectMake(0, 0, ScreenWidth, ScreenHeight))
        self.view.addSubview(imagesView)
        
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
            imagesView.setDatas(index, pagePhotoRecords: pagePhotoRecords)
            imagesView.showOrHiddenView(true)
        }
        
    }
    
    func showAllImages(){
        if imgList?.size() == 0 {
//            self.view.makeToast("没有原图")
            FQToast.makeError().show("没有原图", superview: self.view)
            return
        }
        imagesView = FullScreenImageZoomView(frame: CGRectMake(0, 0, ScreenWidth, ScreenHeight))
        self.view.addSubview(imagesView)
        
        var pagePhotoRecords = [ComFqHalcyonEntityPhotoRecord]()
        if imgList != nil {
            for var i:Int32 = 0 ; i < imgList!.size() ; i++ {
                let photoRecord = ComFqHalcyonEntityPhotoRecord()
                let imageId = imgList!.getWithInt(i) as! NSNumber
                photoRecord.setImageIdWithInt(imageId.intValue)
                pagePhotoRecords.append(photoRecord)
            }
        }
        
        if pagePhotoRecords.count > 0 {
            imagesView.setDatas(0, pagePhotoRecords: pagePhotoRecords)
            imagesView.showOrHiddenView(true)
        }

    }
    
    func onExamItemChanged(notification:NSNotification){
        imgList = notification.object as? JavaUtilArrayList
    }
    
    func itemClicked(unitCell: UnitCell!) {
        let i = unitView?.unitList.indexOfObject(unitCell)
        if unitCell.getVisible() {
            //查看大图
            showImages(i!)
        }else{
            unitCell.setVisible(false)
            //重新上传或重新修改
            if unitCell.status == 1{
                //重新上传
                let photo =  imageList[i!]
                let photoRecord = ComFqHalcyonEntityPhotoRecord()
                photoRecord.setLocalPathWithNSString(photo.imageName)
                let obj = ComFqHalcyonEntityPracticeUpLoadObject(int:normalExamItemView.recordAbstract.getRecordItemId(), withNSString: photo.imageName)
                logic?.upLoadingWithComFqHalcyonEntityPhotoRecord(photoRecord, withInt: normalExamItemView.recordAbstract.getRecordItemId(), withId: obj)
                AttachmentTools.updateAttachment(Int(normalExamItemView.recordAbstract.getRecordItemId()), imageId: 0, imageName: photo.imageName!, status: AttachmentImageStatus.Uploading)
            }else if unitCell.status == 3{
                //重新修改
                let photo =  imageList[i!]
                let photoRecord = ComFqHalcyonEntityPhotoRecord()
                photoRecord.setImageIdWithInt(Int32(photo.imageId))
                logic?.uploadAttachWithComFqHalcyonEntityPhotoRecord(photoRecord, withInt: normalExamItemView.recordAbstract.getRecordItemId())
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
        let i = unitView?.unitList.indexOfObject(unitCell)
        let photo = AttachmentTools.getAttachmentList(Int(normalExamItemView.recordAbstract.getRecordItemId()))[i!]
        
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
                ComFqLibHttpHelper.cancleWithNSString(photo.imageName)
            }
        }
    }

    
    //调用系统相机
    func takePhotos(){
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
        let obj = ComFqHalcyonEntityPracticeUpLoadObject(int:normalExamItemView.recordAbstract.getRecordItemId(), withNSString: path)
        AttachmentTools.insertAttachment(Int(normalExamItemView.recordAbstract.getRecordItemId()), imageId: 0, imageName: photo.imageName!, status: AttachmentImageStatus.Uploading)
        logic?.upLoadingWithComFqHalcyonEntityPhotoRecord(photoRecord, withInt: normalExamItemView.recordAbstract.getRecordItemId(), withId: obj)
        imageList.append(photo)
        //刷新ui
        unitView?.addNewUnit(photo.imageName, withName: "")
        isUpdate = true
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
    }
    
    
    /**
     上传图片进度
     
     - parameter progress:  进度
     - parameter imageName: 图片名字
     - parameter obj:       特殊用途
     */
    func upLoadProgressWithFloat(progress: Float, withNSString imageName: String!, withId obj: AnyObject!) {
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
    
    /**
     同步数据库
     */
    func updateLocalDB() ->[AttachmentImage]{
        let list = AttachmentTools.getAttachmentList(Int((recordDTExamLogic?.getRecordItem().getRecordItemId())!))
        if Int32(list.count) < imageIds.size(){
            AttachmentTools.insertAttachmentList(Int((recordDTExamLogic?.getRecordItem().getRecordItemId())!), photoList: imageIds)
        }
        return AttachmentTools.getAttachmentList(Int((recordDTExamLogic?.getRecordItem().getRecordItemId())!))
    }
    
    func updateUI(recordItemId: Int32){
        imageList = AttachmentTools.getAttachmentList(Int(recordItemId))
        hiddenAttachment()
    }
    
    func refreshUI(){
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
    
    func hiddenAttachment(){
        if imageList.count == 0 {
            unitView?.hidden = true
        }
    }
}
