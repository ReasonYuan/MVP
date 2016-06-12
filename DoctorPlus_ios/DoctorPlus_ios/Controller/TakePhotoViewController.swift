//
//  TakePhotoViewController.swift
//  DoctorPlus_ios
//
//  Created by 廖敏 on 15/5/11.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

var NoRecordId = false;

class TakePhotoViewController: BaseViewController,QBImagePickerControllerDelegate{
    
    @IBOutlet weak var mCameraView: CameraView!
    
    @IBOutlet var slideUpView: TGCameraSlideUpView!
    
    @IBOutlet var slideDownView: TGCameraSlideDownView!
    
    @IBOutlet weak var thumbnailBtn: UIButton!
    
    @IBOutlet weak var takePhotoNUm: UILabel!
    
    @IBOutlet weak var takePhotoBtn: UIButton!
    
    @IBOutlet weak var lastButton: UIButton!
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var centerText: UILabel!
    
    var cameraImage:UIImage?
    
    var isEnterByParcticeRecord = false
    
    //入院是否足够
    var isAdmissinEnough = false

    //出院是否足够
    var isDischargeEnough = false
    
    //初始化的类型
    var currentType:Int32 = 0
    
    var mRecordId:Int32 = 0

    var mSnapManager:ComFqLibRecordSnapPhotoManager!
    
    var imagePickerController:QBImagePickerController!
    
    @IBOutlet weak var previewPicView: UIView!
    
    private var isFirst = true
    
    override func getXibName() -> String {
        NoRecordId = false;
        if(ComFqLibRecordRecordCache.getInstance() == nil){ //直接点击的拍照
            NoRecordId = true;
        }
        return "TakePhotoViewController"
    }
    
    override func setTittle(str: String) {
        super.setTittle(str)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ComFqLibRecordRecordCache.initCacheWithInt(0, withInt: 0)
        ComFqLibRecordRecordUploadNotify.inistance()
        
        previewPicView.hidden = true
        mRecordId = ComFqLibRecordRecordCache.getInstance().getRecordId()
        mSnapManager = ComFqLibRecordSnapPhotoManager.instanceWithInt(mRecordId, withInt: ComFqLibRecordRecordCache.getInstance().getDocType(), withInt: currentType, withBoolean: isAdmissinEnough, withBoolean: isDischargeEnough)
        
        imagePickerController = QBImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsMultipleSelection = !mSnapManager.isSignlePhotoWithInt(currentType)

        imagePickerController.filterType = QBImagePickerControllerFilterType.Photos
//        imagePickerController.clearsSelectionOnViewWillAppear = true
        UITools.setRoundBounds(takePhotoNUm.frame.size.width/2, view: takePhotoNUm)
        takePhotoNUm.hidden = true
        setTittle(ComFqLibRecordRecordConstants.getTypeNameByRecordTypeWithInt(currentType))
        lastButton.hidden = true
        setRightImage(isHiddenBtn: false, image: UIImage(named:"snapphoto_camera_ok.png")!)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.mCameraView.startPreview()
        if(isFirst){
            TGCameraSlideView.hideSlideUpView(slideUpView, slideDownView: slideDownView, atView: self.view) { () -> Void in
                
            }
            isFirst = false
        }
        let count = Int(mSnapManager.getPhotoCount());
        if( count > 0){
            thumbnailBtn.hidden = false
            takePhotoNUm.hidden = false
            takePhotoNUm.text = String(count)
            thumbnailBtn.setBackgroundImage(UIImage.createThumbnailImageFromFile(mSnapManager.getLastPhotoPath(), maxWidth: thumbnailBtn.frame.size.width), forState: UIControlState.Normal)
        }else{
            takePhotoNUm.hidden = true
            thumbnailBtn.hidden = true
        }
        self.setCenterText()
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.mCameraView.stop()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func takePhoto(sender: AnyObject) {
        

    }
    

    @IBAction func selectPhotos(sender: AnyObject) {
        self.navigationController?.pushViewController(imagePickerController, animated: true)
        self.navigationController?.navigationBarHidden = false
    }
    
    @IBAction func onThumbnailBtnClick(sender: AnyObject) {
        if(mSnapManager.getPhotoCount() > 0){
            let previewControll = RecordImagePreviewViewController()
            previewControll.mSnapManager = self.mSnapManager
            self.navigationController?.pushViewController(previewControll, animated: true)
        }
    }
    
    func dismissImagePickerController(){
        self.navigationController?.navigationBarHidden = true
        if (self.presentedViewController != nil) {
            self.dismissViewControllerAnimated(true, completion:nil)
        }else{
            self.navigationController?.popToViewController(self, animated: true)
        }
    }
    
    func imagePickerController(imagePickerController: QBImagePickerController!, didSelectAsset asset: ALAsset!) {
        var cGImage : CGImage! = asset.defaultRepresentation().fullResolutionImage().takeUnretainedValue()
//        var ori : UIImageOrientation = imagePickerController.toUIImageOrientation(asset.defaultRepresentation().orientation())
//        var image = UIImage(CGImage: cGImage,scale: UIScreen.mainScreen().scale, orientation: ori )
//        var filePath = self.saveImage(image)
//        self.currentCopyAddPhoto(filePath)
//        self.setThumbnailImage(UIImage(CGImage:asset.thumbnail().takeUnretainedValue()))
//        self.dismissImagePickerController()
    }
    
    func imagePickerController(imagePickerController: QBImagePickerController!, didSelectAssets assets: [AnyObject]!) {
        let selectedAssets:NSArray = assets
        if(selectedAssets.count > 0){
//            for asset in selectedAssets {
//                var cGImage : CGImage! = asset.defaultRepresentation().fullResolutionImage().takeUnretainedValue()
//                var ori : UIImageOrientation = imagePickerController.toUIImageOrientation(asset.defaultRepresentation().orientation())
//                var image = UIImage(CGImage: cGImage,scale: UIScreen.mainScreen().scale, orientation: ori )
//                var filePath = self.saveImage(image)
//                self.currentCopyAddPhoto(filePath)
//            }
//        
//            self.setThumbnailImage(UIImage(CGImage: (selectedAssets.lastObject as ALAsset).thumbnail().takeUnretainedValue()))
        }
        
        self.dismissImagePickerController()
    }
    
    func setThumbnailImage(image:UIImage!){
        thumbnailBtn.hidden = false
        thumbnailBtn.setBackgroundImage(image, forState: UIControlState.Normal)
        let count = Int(mSnapManager.getPhotoCount());
        if( count > 0){
            takePhotoNUm.hidden = false
            takePhotoNUm.text = String(count)
        }else{
            takePhotoNUm.hidden = true
        }
        if(mSnapManager.isSignlePhoto()){
            self.onNextButtonClick(self.nextButton)
        }
        self.setCenterText()
    }
    
    func currentCopyAddPhoto(path:NSString){
        mSnapManager.initCurrentType()
        mSnapManager.currentCopyAddPhotoWithNSString(path as String)
    }
    
    
    func saveImage(image:UIImage!) -> String {
        var time = Int64(NSDate().timeIntervalSince1970 * 1000)
        var filePath = FileSystem.getRecordCachePath() + time.description  + ".jpg"
        UIImageJPEGRepresentation(image, 1)!.writeToFile(filePath, atomically: true)
        return filePath
    }
    
    func imagePickerControllerDidCancel(imagePickerController: QBImagePickerController!) {
        self.dismissImagePickerController()
    }

    
    @IBAction func reTakePhoto(sender: AnyObject) {
        self.previewPicView.hidden = true
        self.takePhotoBtn.hidden = false
        cameraImage = nil
        self.mCameraView.startPreview()

    }
    
    @IBAction func usePhoto(sender: AnyObject) {
        if(cameraImage != nil){
            let filePath = self.saveImage(cameraImage)
            self.currentCopyAddPhoto(filePath)
            self.setThumbnailImage(UIImage.createThumbnailImageFromFile(filePath, maxWidth: self.thumbnailBtn.frame.size.width))
        }
        self.previewPicView.hidden = true
        self.takePhotoBtn.hidden = false
        self.mCameraView.startPreview()
    }
    
    override func onRightBtnOnClick(sender: UIButton) {
        if mSnapManager.getTypes().size() > 0 {
            ComFqLibRecordRecordCache.getInstance().setUnUploadTypesWithJavaUtilArrayList(mSnapManager.getTypes())
        }
        if( isEnterByParcticeRecord ){//跳转到选病例的界面
            self.navigationController?.popViewControllerAnimated(true)
            ComFqLibRecordRecordCache.clearCache()
        }else if(NoRecordId){
           self.navigationController?.pushViewController(SelectPatientListViewController(), animated: true)
        }else{
            self.navigationController?.popViewControllerAnimated(true)
        }
       
    }
    
    
    override func onLeftBtnOnClick(sender: UIButton) {
        super.onLeftBtnOnClick(sender)
        mSnapManager.clear()
    }
    
    func setCenterText(){
        let count = Int(mSnapManager.getCurrentTypePhotoCount())
        let index = mSnapManager.getCurrentIndex()
        if(mSnapManager.isSignlePhoto()){
            nextButton.hidden = true
            lastButton.hidden = true
        }else{
            if(mSnapManager.isSignelCopy()){
                nextButton.hidden = true
                lastButton.hidden = true
            }else{
                if(index == 0){
                    lastButton.hidden = true
                }else{
                    lastButton.hidden = false
                }
                if(count == 0){
                    nextButton.hidden = true
                }else{
                    nextButton.hidden = false
                }
            }
        }
        centerText.text = "第\(index + 1)份(\(count))"
    }
    
    @IBAction func onLastButtonClick(sender: AnyObject) {
        mSnapManager.lastRecordItem()
        self.setCenterText()
    }
    
    @IBAction func onNextButtonClick(sender: AnyObject) {
        mSnapManager.nextRecordItem()
        self.setCenterText()
    }
}
