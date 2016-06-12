//
//  BrowRecordViewController.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-5-19.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class BrowRecordViewController: BaseViewController,TopViewCurrentIndexCallBack,BottomViewCurrentIndexCallBack,ComFqHalcyonLogic2GetRecordTypeListLogic_LoadRecordTypesCallBack,ComFqHalcyonLogic2RemoveRecordItemLogic_RemoveItemCallBack{

    @IBOutlet weak var takePhotoBtn: UIButton!
    @IBOutlet weak var topCasouleView: UIView!
    @IBOutlet weak var bottomBrowRecordView: UIView!
    var items: [Int] = []
    var topView:BrowRecordTopView?
    var bottomView:BrowRecordBottomView?
    var currentIndex:Int = 0
    var patient:ComFqHalcyonEntityPatient?
    var isShareModel:Bool = false
    var recordItemId:Int32 = 0
    var itemList = JavaUtilArrayList()
    
    var mRecord:ComFqHalcyonEntityRecord?
    /**获取到的病历下病历记录的列表*/
    var mRecordTypes = JavaUtilArrayList()
    var deleteDialog:CustomIOS7AlertView?
    
    var removeLogic:ComFqHalcyonLogic2RemoveRecordItemLogic?
    var upLoadLogic:ComFqHalcyonLogic2UploadRecordLogic?
    var dialog:CustomIOS7AlertView?
    override func viewDidLoad() {
        super.viewDidLoad()
        setTittle(mRecord!.getFolderName())
        hiddenRightImage(true)
        let height = ScreenHeight - 80 - 137 - 70
        topView = BrowRecordTopView(frame:CGRectMake(0, 0, ScreenWidth, topCasouleView.frame.size.height))
        topView!.topViewIndexCallBack = self
        bottomView = BrowRecordBottomView(frame:CGRectMake(0, 0, ScreenWidth, height))
        bottomView!.bottomViewIndexCallBack = self
        topCasouleView.addSubview(topView!)
        bottomBrowRecordView.addSubview(bottomView!)
        print("\(height)")
        
        if mRecord!.getFolderId() != 0 {
            getRecordTypeList()
        }
        
        ComFqLibRecordRecordCache.initCacheWithInt(mRecord!.getFolderId(), withInt: mRecord!.getFolderType())
        
         ComFqLibRecordRecordUploadNotify.inistance()
    }

    func getRecordTypeList(){
        dialog = UIAlertViewTool.getInstance().showLoadingDialog("正在加载数据...")
        let recordTypeListLogic = ComFqHalcyonLogic2GetRecordTypeListLogic(comFqHalcyonLogic2GetRecordTypeListLogic_LoadRecordTypesCallBack: self)
        recordTypeListLogic.loadRecordTypesWithInt(Int32(mRecord!.getFolderId()), withBoolean: isShareModel)
    }
    
    /**
    * 获得病历下记录数据失败后回调
    */
    func loadRecordTypesErrorWithInt(code: Int32, withNSString msg: String!) {
        dialog?.close()
        UIAlertViewTool.getInstance().showAutoDismisDialog("加载数据失败", width: 210, height: 120)
    }
    
    /**
    * 获得病历下记录数据成功后回调
    */
    func loadRecordTypesResultWithInt(code: Int32, withJavaUtilArrayList mResultList: JavaUtilArrayList!) {
        dialog?.close()
        mRecordTypes = mResultList
        showAnimate()
        // 补充并格式化数据,主要是排序和添加没有的病历类型（入院、出院、检查等）
        ComFqLibRecordRecordTool.addAndFormatTypesWithInt(mRecord!.getFolderType(), withJavaUtilArrayList: mRecordTypes)
        // 把正在上传的也加入进来，并放到每份的最前面
        ComFqLibRecordRecordTool.addUploadReocrdWithInt(Int32(mRecord!.getFolderId()), withJavaUtilArrayList: mRecordTypes)
        //如果有的类型的病历里面没有记录，则构造一个假的记录用于UI显示
        let size = mRecordTypes.size()
        for i in 0..<size {
            ComFqLibRecordRecordTool.checkNewTypesWithComFqHalcyonEntityRecordType(mRecordTypes.getWithInt(Int32(i)) as! ComFqHalcyonEntityRecordType)
        }
        
        topView?.initData(mRecordTypes)
        bottomView?.initData(mRecordTypes,mNavigationController: self.navigationController!)
//        bottomView?.recordId = Int(mRecord!.getFolderId())
        bottomView?.mIsShareModel = isShareModel
        for i in 0..<size
        {
            itemList.addAllWithJavaUtilCollection((mRecordTypes.getWithInt(Int32(i)) as! ComFqHalcyonEntityRecordType).getItemList())
        }
    }
    
    func showAnimate(){
        self.takePhotoBtn.transform = CGAffineTransformMakeScale(0.01, 0.01)
        self.takePhotoBtn.hidden = false
        UIView.setAnimationCurve(UIViewAnimationCurve.EaseIn)
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.takePhotoBtn.transform = CGAffineTransformMakeScale(1.0, 1.0)
        }) { (isOk) -> Void in
            
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let snap = ComFqLibRecordSnapPhotoManager.getInstance()
        if snap == nil {
            return
        }else {
            let tps = snap.getRealyTypes()
            if tps.size() > 0 {
                let size = mRecordTypes.size()
                for i in 0..<size
                {
                    itemList.addAllWithJavaUtilCollection((mRecordTypes.getWithInt(Int32(i)) as! ComFqHalcyonEntityRecordType).getItemList())
                }
                ComFqLibRecordRecordTool.updateDataFromSnapWithJavaUtilArrayList(mRecordTypes, withJavaUtilArrayList: tps)
                topView?.refreshData(mRecordTypes)
                bottomView?.refreshData(mRecordTypes)
                upLoadRecord(tps)
                ComFqLibRecordRecordCache.getInstance().setUnUploadTypesWithJavaUtilArrayList(nil)
                snap.clear()
            }
        }
    }
    
    func upLoadRecord(types:JavaUtilArrayList){
        upLoadLogic = ComFqHalcyonLogic2UploadRecordLogic()
        upLoadLogic?.upLoadWithNSString("", withInt: mRecord!.getFolderId(), withJavaUtilArrayList: types)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func getXibName() -> String {
        return "BrowRecordViewController"
    }
    
    func onBottomViewCurrentIndexCallBack(index: Int,mCurrentId:Int32) {
        let recordItemSamp = itemList.getWithInt(Int32(index)) as! ComFqHalcyonEntityRecordItemSamp
        let type = recordItemSamp.getRecordType()
        if type != mRecordTypes.getWithInt(Int32(topView!.getCurrentIndex())).getRecordType() {
            topView?.scrollToIndex(index)
        }
        
        currentIndex = index
        recordItemId = mCurrentId
    }
   
    func onTopViewCurrentIndexCallBack(index: Int) {
        let recordItemSamp = itemList.getWithInt(Int32(bottomView!.carousel.currentItemIndex)) as! ComFqHalcyonEntityRecordItemSamp
        let type = recordItemSamp.getRecordType()
        if type != mRecordTypes.getWithInt(Int32(index)).getRecordType() {
            bottomView?.scrollToIndex(index)
        }
        
        
    }
    
    
    @IBAction func deleteClick(sender: AnyObject) {
         print("删除按钮点击----\(recordItemId)")
        let recordItemSamp = itemList.getWithInt(Int32(currentIndex)) as! ComFqHalcyonEntityRecordItemSamp
        if recordItemSamp.getRecStatus() == ComFqHalcyonEntityRecordItemSamp_REC_NONE_DATA {
            return
        }
        deleteDialog = UIAlertViewTool.getInstance().showNewDelDialog("确认删除？", target: self, actionOk: "deleteSure", actionCancle: "deleteCancle")
//        deleteDialog?.show()

    }
    
    @IBAction func shareClick(sender: AnyObject) {
         print("分享按钮点击----\(recordItemId)")
        let recordItemSamp = itemList.getWithInt(Int32(currentIndex)) as! ComFqHalcyonEntityRecordItemSamp
        if recordItemSamp.getRecStatus() != ComFqHalcyonEntityRecordItemSamp_REC_SUCC {
            return
        }
        let controller = ChoseSharePeopleViewController()
        controller.mShareType = Int(ComFqLibRecordRecordConstants_SHARE_RECORD_ITEM)
        controller.mShareItem = recordItemSamp
        controller.mRecordId = mRecord?.getFolderId()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    /**确定删除**/
    func deleteSure(){
        let recordItemSamp = itemList.getWithInt(Int32(currentIndex)) as! ComFqHalcyonEntityRecordItemSamp
        deleteDialog?.close()
        if recordItemSamp.getRecStatus() == ComFqHalcyonEntityRecordItemSamp_REC_UPLOAD {
             onDeleteItem(recordItemSamp,isSuccess: true)
        }else {
            removeLogic = ComFqHalcyonLogic2RemoveRecordItemLogic(comFqHalcyonLogic2RemoveRecordItemLogic_RemoveItemCallBack: self)
            removeLogic?.removeRecordItemWithInt(recordItemSamp.getRecordItemId())
        }
        
    }
    
    /**取消删除**/
    func deleteCancle(){
         deleteDialog?.close()
    }
    
    func doRemovebackWithInt(recordItemId: Int32, withBoolean isSuccess: Bool) {
        if isSuccess {
            let recordItemSamp = itemList.getWithInt(Int32(currentIndex)) as! ComFqHalcyonEntityRecordItemSamp
            onDeleteItem(recordItemSamp,isSuccess: true)
        }
    }
    
    func onErrorWithInt(code: Int32, withJavaLangThrowable error: JavaLangThrowable!) {
        UIAlertViewTool.getInstance().showAutoDismisDialog("操作失败！", width: 210, height: 120)
    }
    
    func onDeleteItem(recordItemSamp:ComFqHalcyonEntityRecordItemSamp,isSuccess:Bool){
        let type = recordItemSamp.getRecordType()
        for i in 0..<mRecordTypes.size() {
            let rt = mRecordTypes.getWithInt(i) as! ComFqHalcyonEntityRecordType
            if rt.getRecordType() == type {
                if recordItemSamp.getUuid() != nil{
                    if !recordItemSamp.getUuid().isEmpty {
                       ComFqHalcyonHalcyonUploadLooper.getInstance().cancelUploadCellWithInt(mRecord!.getFolderId(), withNSString: recordItemSamp.getUuid())
                    }
                }
               
                rt.getItemList().removeWithId(recordItemSamp)
                ComFqLibRecordRecordTool.checkNewTypesWithComFqHalcyonEntityRecordType(rt)
                topView?.refreshData(mRecordTypes)
                bottomView?.refreshData(mRecordTypes)
                bottomView?.scrollToIndex(currentIndex)
               
                break
            }
        }
    }
    
    override func onLeftBtnOnClick(sender: UIButton) {
        super.onLeftBtnOnClick(sender)
        topView?.removeFromSuperview()
        bottomView?.removeFromSuperview()
        //退出这个病历浏览界面时，BrowRecordItemActivity里面缓存的这个病历下的所有记录数据
        ComFqLibRecordRecordCache.clearCache();
        
        //退出这个病历浏览界面时，取消监听这个病历下记录正在上传的图片上传完成后的事件
        ComFqLibRecordRecordUploadNotify.getInstance().clear();
    }
    
    @IBAction func takePhoto(sender: AnyObject) {
       
        let recordItemSamp = itemList.getWithInt(Int32(currentIndex)) as! ComFqHalcyonEntityRecordItemSamp
        if recordItemSamp.getRecStatus() != ComFqHalcyonEntityRecordItemSamp_REC_NONE_DATA  && !isTypeCatch(recordItemSamp){
            var msg:String = ""
            if recordItemSamp.getRecordType() == ComFqLibRecordRecordConstants_TYPE_ADMISSION {
                msg = "一份病历只能拍摄一份入院记录"
            }else if recordItemSamp.getRecordType() == ComFqLibRecordRecordConstants_TYPE_DISCHARGE {
                msg = "一份病历只能拍摄一份出院记录"
            }
            UIAlertViewTool.getInstance().showAutoDismisDialog(msg, width: 210, height: 120)
        }else {
             print("拍照")
            
            /**以下参数需要传到拍照界面**/
            let itemType = recordItemSamp.getRecordType()
            /**需要传递的参数**/
            let isAdmissinEnough = false
            /**需要传递的参数**/
            let isDischargeEnough = false
            
            for i in 0..<mRecordTypes.size() {
                let rtp = mRecordTypes.getWithInt(i) as! ComFqHalcyonEntityRecordType
                if rtp.getRecordType() == ComFqLibRecordRecordConstants_TYPE_ADMISSION && rtp.getItemWithInt(0).getRecordType() != ComFqHalcyonEntityRecordItemSamp_REC_NONE_DATA {
                    
    
                }else if rtp.getRecordType() == ComFqLibRecordRecordConstants_TYPE_DISCHARGE && rtp.getItemWithInt(0).getRecordType() != ComFqHalcyonEntityRecordItemSamp_REC_NONE_DATA{
                    
                }
            }
            
            let takePhotoController = TakePhotoViewController()
            takePhotoController.isAdmissinEnough = isAdmissinEnough
            takePhotoController.isDischargeEnough = isDischargeEnough
            takePhotoController.currentType = itemType
            /**跳转到拍照界面**/
            self.navigationController?.pushViewController(takePhotoController, animated: false)
        }
        
    }
    
    func isTypeCatch(recordItemSamp:ComFqHalcyonEntityRecordItemSamp) -> Bool{
        if recordItemSamp.getRecordType() == ComFqLibRecordRecordConstants_TYPE_ADMISSION || recordItemSamp.getRecordType() == ComFqLibRecordRecordConstants_TYPE_DISCHARGE {
            return false
        }else {
            return true
        }
    }
}
