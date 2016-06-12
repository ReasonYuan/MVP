//
//  NormalRecordNewViewController.swift
//  
//
//  Created by Nan on 15/8/14.
//
//

import UIKit

class NormalRecordNewViewController: BaseViewController,  ComFqHalcyonUilogicRecordDTLogic_RecordDTCallBack, NewNormalRecordViewDelegate, ComFqHalcyonLogicPracticeShareLogic_ShareSaveRecordCallBack {

    var imagesView:FullScreenImageZoomView?
    var uilogic :ComFqHalcyonUilogicRecordDTNormalLogic!
    var recordAbstract: ComFqHalcyonEntityPracticeRecordAbstract!
    var newNormalRecordView: NewNormalRecordView!
    var isShared:Bool =  false
    var loadingDialog:CustomIOS7AlertView?
    var shareMessageId:Int32!
    var saveloadingDialog:CustomIOS7AlertView?
    override func viewDidLoad() {
        super.viewDidLoad()
        newNormalRecordView = NewNormalRecordView(frame: CGRectMake(0 , 70, ScreenWidth,ScreenHeight - 70))
        self.view.addSubview(newNormalRecordView!)
        newNormalRecordView.delegate = self
        // Do any additional setup after loading the view.
        //newNormalRecordView.mainTableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tabViewTap:"))
        hiddenRightImage(true)
        uilogic = ComFqHalcyonUilogicRecordDTNormalLogic(comFqHalcyonUilogicRecordDTLogic_RecordDTCallBack:self)
        uilogic.resquestRecordDetailDataWithInt(recordAbstract.getRecordInfoId())
        
        if isShared {
            
            if isMe{
                isFromSearch = true
                bigRightBtn.hidden = true
                
            }else{
                newNormalRecordView.backToPatientBtn.hidden = true
                bigRightBtn.hidden = false
                bigRightBtn.setTitle("保存", forState : UIControlState.Normal)
                
            }
            
        }else {
            
            bigRightBtn.hidden = true
            
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
    //MARK:------------the call back methods of recordDTLogic
    func loadDataErrorWithNSString(msg: String){
        
//        self.view.makeToast(msg)
        FQToast.makeError().show(msg, superview: Tools.getCurrentViewController().view)
        
    }
    
    override func getXibName() -> String {
        return "NormalRecordNewViewController"
    }
    
    func loadDataSuccess(){
        
        var time = uilogic.getTemplementsCount()
        if(time > 0){
            newNormalRecordView.uilogic = uilogic
            newNormalRecordView.recordAbstract = recordAbstract
            //newNormalRecordView.mainTableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tabViewTap"))
            newNormalRecordView.updateTopLabel()
            newNormalRecordView.mainTableView.reloadData()
            
        }
    }
    
    func modifyStatusWithBoolean(isSuccess:Bool){
        if isSuccess{
            FQToast.makeSystem().show("保存成功", superview: Tools.getCurrentViewController().view)
//            self.view.makeToast("保存成功")
            //(UIAlertViewTool.getInstance() as UIAlertViewTool).showAutoDismisDialog("保存成功", width: 210, height: 120)
            
        }else{
             FQToast.makeError().show("保存失败", superview: Tools.getCurrentViewController().view)
//            self.view.makeToast("保存失败")
            //(UIAlertViewTool.getInstance() as UIAlertViewTool).showAutoDismisDialog("保存失败", width: 210, height: 120)
            
        }
        
        
    }
    //MARK:------------the patient button method
    func backToPatientBtnClicked(){
        if isFromSearch!{
            var control = ExplorationRecordListViewController()
            control.patientItem = uilogic?.getPatientAbstract()
            self.navigationController?.pushViewController(control, animated: true)
            
        }else{
            
            self.navigationController?.popViewControllerAnimated(true)
        }
        
        
    }
    //MARK:------------the image button method
    func imageBtnClicked(){
        
        typealias RecordItemCallBack  = (ComFqHalcyonEntityRecordItem?) -> ()
        showImage()
        if imagesView != nil {
            if imagesView!.hidden {
                imagesView!.hidden = false
            }
        }
        
    }
    func showImage(){
        
        var imgList = uilogic.getImgIds()
        if imgList == nil || imgList!.size() == 0 {
//            self.view.makeToast("没有原图")
            FQToast.makeError().show("没有原图", superview: Tools.getCurrentViewController().view)
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
                var photoRecord = ComFqHalcyonEntityPhotoRecord()
                var imageId = imgList!.getWithInt(i) as! NSNumber
                photoRecord.setImageIdWithInt(imageId.intValue)
                photoRecord.setStateWithInt(ComFqHalcyonEntityPhotoRecord_REC_STATE_SUCC)
                pagePhotoRecords.append(photoRecord)
            }
        }
        if pagePhotoRecords.count > 0 {
            imagesView!.setDatas(0, pagePhotoRecords: pagePhotoRecords)
        }
        
        
        
    }
    override func onLeftBtnOnClick(sender: UIButton)  {
        if imagesView != nil && !imagesView!.hidden {
            imagesView!.hidden = true
        }else{
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    //MARK:------------the top right button method
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
    
    override func onRightBtnOnClick(sender:UIButton){
        if isShared {
            saveloadingDialog = UIAlertViewTool.getInstance().showLoadingDialog("保存中，请耐心等待...")
            var saveShare = ComFqHalcyonLogicPracticeShareLogic(comFqHalcyonLogicPracticeShareLogic_ShareSaveRecordCallBack: self)
            //TODO==YY==暂时写个0，到时要改到对应的recordInfoId
            //println("////////////////////\(shareMessageId)")
            saveShare.saveSharedRecordWithInt(shareMessageId, withInt:recordAbstract.getRecordItemId())
            //saveShare.saveSharedRecordWithInt(0, withInt:recordAbstract.getRecordItemId())
            
        }
    }
}
