//
//  BrowRecordFailImageViewController.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-5-28.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class BrowRecordRecogzingImageViewController: BaseViewController,YRADScrollViewDelegate,YRADScrollViewDataSource,ComFqHalcyonLogicGetImagePathLogic_ImagePathCallBack {
    var scrollView: YRADScrollView!
    var photoList:JavaUtilArrayList?
    var tittleStr:String = ""
    var recordItemId:Int32 = 0
    var getImagePathLogic:ComFqHalcyonLogicGetImagePathLogic?
    var postion:Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
       
        scrollView = YRADScrollView(frame: CGRectMake(0, 70, ScreenWidth, ScreenHeight))
        scrollView.delegate = self
        scrollView.dataSource = self
        scrollView.cycleEnabled = false
        self.view.addSubview(scrollView)
        if photoList == nil {
            if recordItemId != 0 {
                getImagePathLogic = ComFqHalcyonLogicGetImagePathLogic(comFqHalcyonLogicGetImagePathLogic_ImagePathCallBack: self)
                getImagePathLogic?.getImagePathWithInt(recordItemId)
            }
            setTittle(tittleStr)
        }else {
            if photoList?.size() < 1 {
                 setTittle(tittleStr)
            }else {
                tittleStr = "\(tittleStr)（\(postion+1)/\(photoList!.size())）"
                setTittle(tittleStr)
            }
        }
         hiddenRightImage(true)
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
            tittleStr = "\(tittleStr)(\(postion+1)/\(photoList!.size()))"
            setTittle(tittleStr)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func getXibName() -> String {
        return "BrowRecordRecogzingImageViewController"
    }
    
    func viewForYRADScrollView(adScrollView: YRADScrollView!, atPage pageIndex: Int) -> UIView! {
       
        let view = UIView(frame: adScrollView.frame)
        let imageView = UIImageView(frame: CGRectMake(0, 0, ScreenWidth, ScreenHeight - 70))
               if photoList == nil {
           return view
        }else{
            let localPath:String? = (photoList?.getWithInt(Int32(pageIndex)) as! ComFqHalcyonEntityPhotoRecord).getLocalPath()
            if localPath != nil && localPath != ""{
                UITools.getThumbnailImageFromFile(localPath!, width: imageView.frame.size.width, callback: { (image) -> Void in
                    imageView.image = image
                })
            }else {
                imageView.downLoadImageWidthImageId(photoList?.getWithInt(Int32(pageIndex)).getImageId(), callback: { (view, path) -> Void in
                    let tmpView = view as! UIImageView
                    UITools.getThumbnailImageFromFile(path, width: tmpView.frame.size.width, callback: { (image) -> Void in
                        tmpView.image = image
                    })

                })
            }

        }
        view.addSubview(imageView)
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
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
        tittleStr = "浏览识别中病历(\(pageIndex+1)/\(photoList!.size()))"
        setTittle(tittleStr)
    }
}
