//
//  AddAttachmentViewController.swift
//  
//
//  Created by Nan on 15/9/6.
//
//

import UIKit
//**初始化附件监听类**//


class AddAttachmentViewController: BaseViewController,UITableViewDelegate, UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate ,UIActionSheetDelegate,AttachmentItemDeleget,ComFqLibToolsAttachmentManager_AddAttachmentUpLoadingInterface,AttachmentListenerDelegate{

    @IBOutlet var timeView: UIView!
    @IBOutlet weak var label: UILabel!

    @IBOutlet weak var dateLabel: UILabel!
   
    @IBOutlet weak var tableView: UITableView!
    var controller = UIImagePickerController()
    var headActionSheet:UIActionSheet?
    var dateString:String?
    var titleArray:JavaUtilArrayList! = JavaUtilArrayList()
    var itemDic:Dictionary<String,JavaUtilArrayList>?
    var logic:ComFqLibToolsAttachmentManager?
    var recordItem : ComFqHalcyonEntityRecordItem?
    var map:JavaUtilHashMap!
    var photoDic:[UIButton:AttachmentImage] = [UIButton:AttachmentImage]()
    
    var imageIds:JavaUtilArrayList!
    
    var imageList:[AttachmentImage] = [AttachmentImage]()
    override func viewDidLoad() {
        super.viewDidLoad()
        setTittle("附件")
        setRightBtnTittle("添加")
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        dateString = dateFormatter.stringFromDate(NSDate())
        tableView.backgroundColor = UIColor.whiteColor()
        tableView.tableHeaderView?.backgroundColor = UIColor.redColor()
        tableView.registerNib(UINib(nibName: "AddAttachmentTableViewCell", bundle: nil), forCellReuseIdentifier: "AddAttachmentTableViewCell")
        
        
        logic = ComFqLibToolsAttachmentManager.getInstanceWithInt(recordItem!.getRecordItemId())
        logic?.checkupLoadingWithComFqLibToolsAttachmentManager_AddAttachmentLogicInterface(attachmentListener)
        logic?.checkProgressWithComFqLibToolsAttachmentManager_AddAttachmentUpLoadingInterface(self)
        attachmentListener.setDelagete(recordItem!.getRecordItemId(),delegate: self)
        map = recordItem?.getAttachImgIdsMap()
        titleArray = logic?.getDatesWithJavaUtilHashMap(map)
        imageIds = logic?.getAllImageIdsWithJavaUtilHashMap(map, withJavaUtilHashMap: map)
       imageList =  updateLocalDB()
    
    }
    
    override func onLeftBtnOnClick(sender: UIButton) {
        super.onLeftBtnOnClick(sender)
        attachmentListener.clearDelagete(recordItem!.getRecordItemId())
        logic?.clearCheckProgress()
    }

    func removeOne(imageId:Int32){
        let iterator = map.keySet().iterator()
        while(iterator.hasNext()){
            let title = iterator.next() as! String
            for i in 0..<(map.getWithId(title) as! JavaUtilArrayList).size()  {
                let photo = ((map.getWithId(title) as! JavaUtilArrayList).getWithInt(i) as! ComFqHalcyonEntityPhotoRecord)
                if imageId == photo.getImageId() {
                    ((map.getWithId(title) as! JavaUtilArrayList)).removeWithInt(i)
                }
            }
        }
        
    }
    
    
    /**
     同步数据库
     */
    func updateLocalDB() ->[AttachmentImage]{
        let list = AttachmentTools.getAttachmentList(Int(recordItem!.getRecordItemId()))
        if Int32(list.count) < imageIds.size(){
            AttachmentTools.insertAttachmentList(Int(recordItem!.getRecordItemId()), photoList: imageIds)
        }
        return AttachmentTools.getAttachmentList(Int(recordItem!.getRecordItemId()))
    }
    
    override func getXibName() -> String {
        return "AddAttachmentViewController"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AddAttachmentTableViewCell") as! AddAttachmentTableViewCell

        let photo = imageList[indexPath.row]
        var localPath = ""
        if let _ = photo.imageName {
            localPath =  photo.getLocalPath()
        }
        if localPath != ""{
//            print(localPath)
            if let img =  UIImage(contentsOfFile: localPath) {
                 cell.imageView1.image  = img
            }else {
                cell.imageView1.downLoadImageWidthImageId(Int32(photo.imageId), callback: { (view, path) -> Void in
                    let tmpImageView = view as! UIImageView
                    tmpImageView.image = UITools.getImageFromFile(path)
                })
            }
            //加载本地图片
        }else{
            //从网络获取图片
            cell.imageView1.downLoadImageWidthImageId(Int32(photo.imageId), callback: { (view, path) -> Void in
                let tmpImageView = view as! UIImageView
                tmpImageView.image = UITools.getImageFromFile(path)
            })
        }
       
        cell.button.addTarget(self, action: "btnClick:", forControlEvents: UIControlEvents.TouchUpInside)
        cell.button.tag = indexPath.row
        
        //删除事件
        cell.indexPath = indexPath
        cell.deleget = self
        
        photoDic[cell.button] = photo
        return cell
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 138
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.backgroundColor = UIColor.whiteColor()
    }

    func btnClick(sender:UIButton){
        if let photo = photoDic[sender] {
            let imagesView = FullScreenImageZoomView(frame: CGRectMake(0, 0, ScreenWidth, ScreenHeight))
            self.view.addSubview(imagesView)
            var pagePhotoRecords = [ComFqHalcyonEntityPhotoRecord]()
            let photoRecord = ComFqHalcyonEntityPhotoRecord()
            photoRecord.setLocalPathWithNSString(photo.imageName)
            print(photo.imageId)
            if photo.imageId != 0 {
                photoRecord.setImageIdWithInt(Int32(photo.imageId))
            }
            
            pagePhotoRecords.append(photoRecord)
            imagesView.setDatas(0, pagePhotoRecords: pagePhotoRecords)
            imagesView.showOrHiddenView(true)
        }
    }
    
    /**
    附件删除事件
    */
    func itemRemove(indexPath: NSIndexPath) {

        let photo = imageList[indexPath.row]
        if (photo.imageId == 0){  //图片只在本地，并没有上传到网络上
            imageList.removeAtIndex(indexPath.row)
            //TODO
            AttachmentTools.deleteAttachment(photo.recordItemId, imageId: photo.imageId, imageName: photo.imageName!)
            tableView.reloadData()
        }else{   //图片已上传到网络上
            let list = JavaUtilArrayList()
            let photoRecord = ComFqHalcyonEntityPhotoRecord()
            photoRecord.setImageIdWithInt(Int32(photo.imageId))
            list.addWithId(photoRecord)
            logic?.removeAttachmentWithInt(Int32(photo.recordItemId), withJavaUtilArrayList: list)
        }
    }
    
   //调用系统相机
    override func onRightBtnOnClick(sender:UIButton){
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
        let obj = ComFqHalcyonEntityPracticeUpLoadObject(int: recordItem!.getRecordItemId(), withNSString: path)
        AttachmentTools.insertAttachment(Int(recordItem!.getRecordItemId()), imageId: 0, imageName: photo.imageName!, status: AttachmentImageStatus.Uploading)
        logic?.upLoadingWithComFqHalcyonEntityPhotoRecord(photoRecord, withInt: recordItem!.getRecordItemId(), withId: obj)
        imageList.append(photo)
        tableView.reloadData()
    }
    
    /**
    上传图片失败的回调
    
    - parameter recordItemId: <#recordItemId description#>
    - parameter imageName:    <#imageName description#>
    */
    func onUpLoadingErrorWithInt(recordItemId: Int32, withNSString imageName: String!) {
        //TODO 修改数据库状态 更新UI
        FQToast.makeError().show("上传失败", superview: self.view)
    }
    
    /**
     上传图片成功的回调
     
     - parameter recordItemId: <#recordItemId description#>
     - parameter imageId:      <#imageId description#>
     */
    func onUpLoadingSuccessWithInt(recordItemId: Int32, withInt imageId: Int32,withNSString imageName:String!) {
        //TODO 修改数据库状态 更新UI
    }
    
    /**
     修改附件失败的回调
     
     - parameter recordItemId: <#recordItemId description#>
     - parameter imageId:      <#imageId description#>
     */
    func onModifyErrorWithInt(recordItemId: Int32, withInt imageId: Int32) {
        //TODO 修改数据库状态 更新UI
        FQToast.makeError().show("修改附件失败", superview: self.view)
    }
    
    /**
     修改附件成功的回调
     
     - parameter recordItemId: <#recordItemId description#>
     - parameter imageId:      <#imageId description#>
     */
    func onModifySuccessWithInt(recordItemId: Int32, withInt imageId: Int32) {
        //TODO 修改数据库状态 更新UI
    }
    
    /**
     删除附件失败的回调
     
     - parameter code: <#code description#>
     - parameter msg:  <#msg description#>
     */
    func onRemoveErrorWithInt(code: Int32, withNSString msg: String!, withInt recordItemId: Int32,withInt imageId:Int32) {
        FQToast.makeError().show("删除附件失败", superview: self.view)
    }
    
    /**
     删除附件成功的回调
     
     - parameter photos: <#photos description#>
     */
    
    func onRemoveSuccessWithJavaUtilArrayList(photos: JavaUtilArrayList!, withInt reocordItemId: Int32,withInt imageId: Int32) {
        updateUI(reocordItemId)
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
            if (photo.imageName != "") {
                if photo.imageName == imageName {
                    if let _ = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: Int(i), inSection: 0)) {
                        (tableView.cellForRowAtIndexPath(NSIndexPath(forRow: Int(i), inSection: 0)) as! AddAttachmentTableViewCell).progressLabel.text = "\(Int(progress*100))%"
                    }
                    
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
     取消上传图片的方法 参数是imageName图片的名字
     
     - parameter sender: <#sender description#>
     */
    @IBAction func cancle(sender: AnyObject) {
        let photo = imageList[1]
        ComFqLibHttpHelper.cancleWithNSString(photo.imageName)
    }
    
    func updateUI(recordItemId: Int32){
        imageList = AttachmentTools.getAttachmentList(Int(recordItemId))
        tableView.reloadData()
    }
}
