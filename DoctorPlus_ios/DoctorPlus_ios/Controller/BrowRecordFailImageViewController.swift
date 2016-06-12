//
//  BrowRecordFailImageViewController.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-5-28.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class BrowRecordFailImageViewController: BaseViewController,YRADScrollViewDelegate,YRADScrollViewDataSource,ComFqHalcyonLogicGetImagePathLogic_ImagePathCallBack,ComFqHalcyonLogic2RemoveRecordItemLogic_RemoveItemCallBack{
    var scrollView: YRADScrollView!
    var tittleStr:String = "无法识别"
    var recordItemId:Int32 = 0
    var photoList:JavaUtilArrayList?
    var getImagePathLogic:ComFqHalcyonLogicGetImagePathLogic?
    var postion:Int = 0
    @IBOutlet weak var reTakePhoto: UIButton!
    @IBOutlet weak var deletePhoto: UIButton!
    var removeLogic:ComFqHalcyonLogic2RemoveRecordItemLogic?
    var itemSamp:ComFqHalcyonEntityRecordItemSamp?
    override func viewDidLoad() {
        super.viewDidLoad()
        hiddenRightImage(true)
        UITools.setButtonStyle(reTakePhoto, buttonColor: Color.color_emerald, textSize: 19.0, textColor: UIColor.whiteColor(), isOpposite: false, radius: 5.0)
        UITools.setButtonStyle(deletePhoto, buttonColor: Color.color_emerald, textSize: 19.0, textColor: UIColor.whiteColor(), isOpposite: false, radius: 5.0)
        deletePhoto.addTarget(self, action: "deletePohto:", forControlEvents: UIControlEvents.TouchUpInside)
        reTakePhoto.addTarget(self, action: "reTakePhoto:", forControlEvents: UIControlEvents.TouchUpInside)
        
        scrollView = YRADScrollView(frame: CGRectMake(0, 70, ScreenWidth, ScreenHeight - 107))
        scrollView.delegate = self
        scrollView.dataSource = self
        scrollView.cycleEnabled = false
        self.view.addSubview(scrollView)
        if photoList == nil || photoList?.size() == 0{
            recordItemId = itemSamp!.getRecordItemId()
            getImagePathLogic = ComFqHalcyonLogicGetImagePathLogic(comFqHalcyonLogicGetImagePathLogic_ImagePathCallBack: self)
            getImagePathLogic?.getImagePathWithInt(recordItemId)
        }else {
            if photoList?.size() < 1 {
                setTittle(tittleStr)
            }else {
                tittleStr = "无法识别(\(postion+1)/\(photoList?.size()))"
                setTittle(tittleStr)
            }
             scrollView.reloadData()
        }

    }

    
    
    func dobackWithJavaUtilArrayList(photos: JavaUtilArrayList!) {
        if photos == nil {
            UIAlertViewTool.getInstance().showAutoDismisDialog("没有可供浏览的图片", width: 210, height: 120)
            return
        }
        photoList = photos
        scrollView.reloadData()
        if photoList?.size() < 1 {
            setTittle(tittleStr)
        }else {
            tittleStr = "无法识别(\(postion+1)/\(photoList!.size()))"
            setTittle(tittleStr)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

    
    override func getXibName() -> String {
        return "BrowRecordFailImageViewController"
    }
    
    func viewForYRADScrollView(adScrollView: YRADScrollView!, atPage pageIndex: Int) -> UIView! {
        let view = BrowRecordImageFailVIew(frame: adScrollView.frame)
        if photoList == nil {
            return view
        }else{
            let localPath:String? = (photoList?.getWithInt(Int32(pageIndex)) as! ComFqHalcyonEntityPhotoRecord).getLocalPath()
            if localPath != nil && localPath != ""{
//                view.imageView.image =  UIImage.createThumbnailImageFromFile(localPath, maxWidth: view.imageView.frame.size.width)
                UITools.getThumbnailImageFromFile(localPath!, width: view.imageView.frame.size.width, callback: { (image) -> Void in
                   view.imageView.image = image
                })
            }else {
                view.imageView.downLoadImageWidthImageId(photoList?.getWithInt(Int32(pageIndex)).getImageId(), callback: { (view, path) -> Void in
                    let tmpView = view as! UIImageView
                    UITools.getThumbnailImageFromFile(path, width: tmpView.frame.size.width, callback: { (image) -> Void in
                        tmpView.image = image
                    })
                })
            }
        }
        return view
    }
    
    func numberOfViewsForYRADScrollView(adScrollView: YRADScrollView!) -> UInt {
        if photoList == nil {
            return 0
        }else {
            return UInt(photoList!.size())
        }
        
    }
    
    func adScrollView(adScrollView: YRADScrollView!, didScrollToPage pageIndex: Int) {
        print("\(pageIndex)")
        postion = pageIndex
        tittleStr = "无法识别(\(pageIndex+1)/\(photoList?.size()))"
        setTittle(tittleStr)
    }
    
    func deletePohto(sender:UIButton){
       let tag = sender.tag
        photoList?.removeWithInt(Int32(tag))
        scrollView.reloadData()
        if photoList?.size() <= 0 {
            deletePhoto.hidden = true
            tittleStr = "无法识别"
            setTittle(tittleStr)
        }else{
            tittleStr = "无法识别(\(postion+1)/\(photoList?.size()))"
            setTittle(tittleStr)
        }
        
    }
    
    func reTakePhoto(sender:UIButton){
        removeLogic = ComFqHalcyonLogic2RemoveRecordItemLogic(comFqHalcyonLogic2RemoveRecordItemLogic_RemoveItemCallBack: self)
        removeLogic?.removeRecordItemWithInt(itemSamp!.getRecordItemId())
        /**将recordType传到拍照界面**/
        let recordType = itemSamp?.getRecordType()
        let controller = TakePhotoViewController()
        controller.currentType = recordType!
        /**跳转到拍照界面**/
        self.navigationController?.pushViewController(controller, animated: true)
        
        let count  = self.navigationController?.viewControllers.count
         self.navigationController?.viewControllers.removeRange(Range(start:count! - 2, end: count! - 1))
        
    }
    
    func doRemovebackWithInt(recordItemId: Int32, withBoolean isSuccess: Bool) {
        
    }
}
