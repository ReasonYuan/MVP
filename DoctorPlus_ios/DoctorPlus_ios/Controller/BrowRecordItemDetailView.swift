//
//  BrowRecordItemDetailView.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-5-21.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class BrowRecordItemDetailView: UIView,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,ComFqHalcyonLogic2GetRecordItemLogic_RecordItemCallBack,ImageCallBack,NormalRecordItemViewDelegate,ComFqHalcyonLogic2GetRecordItemLogic_ModifyItemCallBack{
    
    @IBOutlet weak var line: UILabel!
    @IBOutlet weak var leftBtn: UIButton!
    @IBOutlet weak var rightBtn: UIButton!
    @IBOutlet weak var infoText: UITextView!
    @IBOutlet weak var tittle: UILabel!
    @IBOutlet weak var centerView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var detailText: UILabel!
    @IBOutlet weak var detailIcon: UIImageView!
    @IBOutlet var InfoView: UIView!
    var mIsSharedImage:Bool = false
    var imageList = JavaUtilArrayList()
    var isShowInfo = false
    var mRecordItem:ComFqHalcyonEntityRecordItem?
    var isShareModel:Bool = false
    var getdataLogic:ComFqHalcyonLogic2GetRecordItemLogic?
    var navigation:UINavigationController?
    var tmpRecordType:Int32 = 0
    var isModify = false
    typealias RecordItemCallBack  = (ComFqHalcyonEntityRecordItem?) -> ()
    var mRecordItemCallBack:RecordItemCallBack?
    var recordType = Int32(0)
    var itemList = JavaUtilArrayList()
    var alertView:CustomIOS7AlertView?
    weak var tmpScrollView: YRADScrollView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        let view = NSBundle.mainBundle().loadNibNamed("BrowRecordItemDetailView", owner: self, options: nil)[0] as! UIView
        view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height)
        self.addSubview(view)
        collectionView.registerNib(UINib(nibName: "BrowRecordItemDetailCollectionViewCell", bundle:nil), forCellWithReuseIdentifier: "BrowRecordItemDetailCollectionViewCell")
        UITools.setBorderWithView(1.0, tmpColor: Color.color_emerald.CGColor, view: detailText)
        UITools.setBorderWithView(2.0, tmpColor: Color.color_emerald.CGColor, view: InfoView)
        InfoView.layer.backgroundColor = UIColor.whiteColor().CGColor
        detailText.backgroundColor = UIColor.clearColor()
        leftBtn.addTarget(self, action: "back:", forControlEvents: UIControlEvents.TouchUpInside)
        rightBtn.hidden = true
    }
    
    
    func back(sender:UIButton){
        if isModify {
            if alertView == nil {
                alertView = UIAlertViewTool.getInstance().showZbarDialog("是否保存正在编辑的病例？", target: self, actionOk: "sureSaveBtnClick", actionCancle: "cancelSaveBtnClick", actionOkStr: "保存", actionCancelStr: "取消")
            }
            alertView?.show()
        }else{
            navigation?.popViewControllerAnimated(true)
        }
        
    }
    
    /**确认保存*/
    func sureSaveBtnClick(){
        alertView?.close()
        rightBtn.hidden = true
        isModify = false
        saveEditInfo()
        NSNotificationCenter.defaultCenter().postNotificationName(EDIT_MODEL_KEY, object: isModify)
    }
    
    /**取消保存*/
    func cancelSaveBtnClick(){
        alertView?.close()
        rightBtn.hidden = true
        isModify = false
        if centerView.subviews.count > 0 {
            if recordType != ComFqLibRecordRecordConstants_TYPE_EXAMINATION && recordType != ComFqLibRecordRecordConstants_TYPE_MEDICAL_IMAGING {
                let view = centerView.subviews[0] as! NormalRecordItemView
                view.isModify = false
                view.tmpContents = view.contents
                view.tableView.reloadData()
            }
        }
        NSNotificationCenter.defaultCenter().postNotificationName(EDIT_MODEL_KEY, object: isModify)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("BrowRecordItemDetailCollectionViewCell", forIndexPath: indexPath) as! BrowRecordItemDetailCollectionViewCell
        let row = indexPath.row
        if mIsSharedImage || imageList.getWithInt(Int32(row)).isShared(){
            cell.imageView.image = UIImage(named: "btn_record_album.png")
        }else {
            
            cell.imageView.downLoadImageWidthImageId(imageList.getWithInt(Int32(row)).getImageId(), callback: { (view, path) -> Void in
                let tmpImageView = view as! UIImageView
                UITools.getThumbnailImageFromFile(path, width: tmpImageView.frame.size.width,cache:false, callback: { (image) -> Void in
                    tmpImageView.image = image
                })
//                tmpImageView.image = UIImage.createThumbnailImageFromFile(path, maxWidth: tmpImageView.frame.size.width)
            })
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("\(indexPath.row)")
        let controller = BrowRecordImageViewController()
        let recordInfoId = mRecordItem!.getRecordInfoId()
        controller.recordInfoId = recordInfoId
        let imageId = imageList.getWithInt(Int32(indexPath.row)).getImageId()
        controller.imageId = imageId
        let photoList = JavaUtilArrayList()
        let size = itemList.size()
        for i in 0..<size {
            photoList.addAllWithJavaUtilCollection(itemList.getWithInt(i).getPhotos())
        }
        
        var position:Int32 = 0
        if photoList != nil {
            for  i in 0..<photoList.size() {
                let photo = photoList.getWithInt(i) as! ComFqHalcyonEntityPhotoRecord
                if photo.isShared() {
                    if recordInfoId == photo.getRecordInfoId() {
                        position = i
                        break
                    }
                }else if imageId == photo.getImageId() {
                    position = i
                    break
                }
            }
            
        }
        
        controller.initData(photoList, mPosition: Int(position))
        controller.currentPage =  Int(position)
        controller.imageCallBacK = self
        self.navigation?.pushViewController(controller, animated: true)
    }
    
    func clearImage(){
        imageList.clear()
        collectionView.reloadData()
    }
    
    func onImageControllerCallBack(currentIndex: Int) {
        print("------------------------\(currentIndex)")
        let size  = itemList.size()
        var count:Int32 = 0
        for i in 0..<size {
            let recordItemSamp = itemList.getWithInt(i) as! ComFqHalcyonEntityRecordItemSamp
            count += recordItemSamp.getPhotos().size()
            if count >= Int32(currentIndex) {
                tmpScrollView.scrollViewToIndex(i)
                break
            }
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if mIsSharedImage{
            return 1
        }else {
            return Int(imageList.size())
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func setRefreshData(mImageList:JavaUtilArrayList,isShared:Bool = false){
        if isShared {
           mIsSharedImage = isShared
        }
        imageList = mImageList
        collectionView.reloadData()
    }
    
    @IBAction func showDetail(sender: AnyObject) {
        if isShowInfo {
            closeInfo()
        }else {
            showInfo()
        }
    }
    
    /**展示基本信息列表**/
    func showInfo(){
        detailIcon.image = UIImage(named: "btn_close_info.png")
        isShowInfo = true
        self.InfoView.frame = CGRectMake(20, self.line.frame.origin.y, self.line.frame.width - 40, 300)
        self.addSubview(InfoView)
    }
   
    /**关闭基本信息列表**/
    func closeInfo(){
        detailIcon.image = UIImage(named: "btn_open_info.png")
        isShowInfo = false
        InfoView.removeFromSuperview()
    }
    
    func initData(mRecordSamp:ComFqHalcyonEntityRecordItemSamp,callBack:RecordItemCallBack){
        tmpRecordType = mRecordSamp.getRecordType()
        mRecordItemCallBack = callBack
        recordType = 0//ComFqLibRecordRecordConstants.getBigTypeWithComFqHalcyonEntityRecordItemSamp(mRecordSamp)
        tittle.text = ComFqLibRecordRecordConstants.getTypeNameByRecordTypeWithInt(recordType)
        mRecordItem = ComFqLibRecordRecordCache.getInstance().getCacheWithInt(mRecordSamp.getRecordInfoId())
        
        if mRecordItem != nil {
            var mIsShareModel:Bool = mRecordItem!.isShareModel()
            if !isShareModel {
                ComFqLibRecordRecordCache.getInstance().addCacheWithComFqHalcyonEntityRecordItem(mRecordItem)
                mRecordItem = nil
            }
            
        }
        
        if mRecordItem != nil {
            iniAllInfo()
            mRecordItemCallBack!(mRecordItem)
        }else {
            if getdataLogic == nil {
                getdataLogic = ComFqHalcyonLogic2GetRecordItemLogic(comFqHalcyonLogic2GetRecordItemLogic_RecordItemCallBack: self)
                getdataLogic?.loadRecordItemWithInt(mRecordSamp.getRecordInfoId(), withBoolean: isShareModel)
            }else{
                getdataLogic?.loadRecordItemWithInt(mRecordSamp.getRecordInfoId(), withBoolean: isShareModel)
            }
            
        }
       
    }
    
    func doRecordItemBackWithComFqHalcyonEntityRecordItem(recordItem: ComFqHalcyonEntityRecordItem!) {
        if recordItem == nil {
            
        }else {
            mRecordItem = recordItem
            if mRecordItem?.getPhotos().size() == 0 {
                mRecordItem?.setPhotosWithJavaUtilArrayList(recordItem.getPhotos())
            }
            if mRecordItem?.getRecordType() != 0 {
                ComFqLibRecordRecordCache.getInstance().addCacheWithComFqHalcyonEntityRecordItem(mRecordItem!)
            }
            iniAllInfo()
        }
        if recordItem != nil{
            

        }
        mRecordItemCallBack!(recordItem)
    }
    
    func iniAllInfo(){
        imageList = mRecordItem?.getPhotos()
        let isShare:Bool =  mRecordItem!.isShared()
        if isShareModel || isShare {
            setRefreshData(imageList, isShared: true)
        }else {
            setRefreshData(imageList, isShared: false)
        }
        
        setInfoData(mRecordItem!.getBaseInfo())
        if mRecordItem?.getRecordType() == ComFqLibRecordRecordConstants_TYPE_MEDICAL_IMAGING {
             detailText.text = "报告内容"
        }
    }

    func setInfoData(jsonInfo:FQJSONArray){
        infoText.layer.backgroundColor = UIColor.whiteColor().CGColor
        infoText.backgroundColor = UIColor.whiteColor()
        var allString:String = ""
        let size = jsonInfo.length()
        for i in 0..<size {
            var tmpstr:String = ""
            let json = jsonInfo.getJSONObjectWithInt(i)
           let keys = json.keys() as JavaUtilIterator
            while(keys.hasNext()){
                let key = keys.next() as! String
                if key == "index" {
                    continue
                }
                var value = json.getStringWithNSString(key) as NSString
                if !value.isEmpty() {
                    value = value.replace(":", withSequence: "")
                }
                tmpstr = "\(key):\(value)\n"
                allString = "\(allString)\(tmpstr)"
            }
        }
        
        infoText.text = allString
    }
    
    /**右上角确认保存按钮点击事件*/
    @IBAction func onTopRightBtnClick() {
        alertView?.close()
        rightBtn.hidden = true
        isModify = false
        saveEditInfo()
        NSNotificationCenter.defaultCenter().postNotificationName(EDIT_MODEL_KEY, object: isModify)
    }
    
    func getModiftyStatus(isModify: Bool) {
        if rightBtn.hidden {
            rightBtn.hidden = false
        }
        self.isModify = isModify
    }
    
    func saveEditInfo(){
        if centerView.subviews.count > 0 {
            if recordType != ComFqLibRecordRecordConstants_TYPE_EXAMINATION && recordType != ComFqLibRecordRecordConstants_TYPE_MEDICAL_IMAGING {
                let view = centerView.subviews[0] as! NormalRecordItemView
                let keys = view.titles
                var contents = view.tmpContents
                let mJsonInfo = mRecordItem!.getNoteInfo() as FQJSONArray
                for (index,item) in keys.enumerate(){
                    let json = mJsonInfo.optJSONObjectWithInt(Int32(index))
                    json.putOptWithNSString(item, withId: contents[index])
                }
                mRecordItem?.setNoteInfoWithFQJSONArray(mJsonInfo)
                var logic = ComFqHalcyonLogic2GetRecordItemLogic()
//                logic.modifyRecordItemWithInt(mRecordItem!.getRecordInfoId(), withInt: 2, withId: mRecordItem?.getNoteInfo().toStringWithInt(Int32(0)), withComFqHalcyonLogic2GetRecordItemLogic_ModifyItemCallBack:self)
                view.isModify = false
                view.tableView.reloadData()
            }
            
        }
    }
    
    func doBackWithBoolean(isb: Bool) {
        
    }
}
