//
//  BrowRecordImageViewController.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-5-26.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class BrowRecordImageViewController: BaseViewController,YRADScrollViewDelegate,YRADScrollViewDataSource {
     var scrollView: YRADScrollView!
    var mImageList = JavaUtilArrayList()
    var position:Int = 0
    var recordInfoId:Int32 = 0
    var imageId:Int32 = 0
    var tittleStr:String = ""
    var imageCallBacK:ImageCallBack?
    var currentPage:Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        hiddenRightImage(true)
        scrollView = YRADScrollView(frame: CGRectMake(0, 70, ScreenWidth, ScreenHeight))
        scrollView.delegate = self
        scrollView.dataSource = self
        scrollView.cycleEnabled = false
        self.view.addSubview(scrollView)
        scrollView.scrollViewToIndex(Int32(position))
        tittleStr = "查看原图（\(position+1)/\(mImageList.size())）"
        setTittle(tittleStr)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
    
    override func getXibName() -> String {
        return "BrowRecordImageViewController"
    }

    func viewForYRADScrollView(adScrollView: YRADScrollView!, atPage pageIndex: Int) -> UIView! {
        let view = UIView(frame: adScrollView.frame)
        var imageView:UIImageView?
       
        if mImageList.getWithInt(Int32(pageIndex)).isShared() {
            imageView = UIImageView(frame: CGRectMake(ScreenWidth/2 - 50 ,ScreenHeight/2 - 100, 100, 100))
            let label =  UILabel(frame: CGRectMake(ScreenWidth/2 - 100 ,imageView!.frame.origin.y + 100, 200, 20))
            label.text = "分享图片,无法查看"
            label.font = UIFont.systemFontOfSize(13.0)
            label.textAlignment = NSTextAlignment.Center
            label.textColor = UIColor.lightGrayColor()
            imageView!.image = UIImage(named: "btn_record_album.png")
            view.addSubview(label)
        }else {
            imageView = UIImageView(frame: CGRectMake(0, 0, ScreenWidth, ScreenHeight - 70))
            imageView!.downLoadImageWidthImageId(mImageList.getWithInt(Int32(pageIndex)).getImageId(), callback: { (view, path) -> Void in
                let tmpView = view as! UIImageView
                UITools.getThumbnailImageFromFile(path, width: tmpView.frame.size.width, callback: { (image) -> Void in
                     tmpView.image = image
                })
            })
        }
        view.addSubview(imageView!)
        imageView!.contentMode = UIViewContentMode.ScaleAspectFit
        return view
    }
    
    func numberOfViewsForYRADScrollView(adScrollView: YRADScrollView!) -> UInt {
        return UInt(mImageList.size())
    }
    
    func adScrollView(adScrollView: YRADScrollView!, didScrollToPage pageIndex: Int) {
        print("\(pageIndex)")
        currentPage = pageIndex
        tittleStr = "查看原图（\(pageIndex+1)/\(mImageList.size())）"
        setTittle(tittleStr)
    }
    
    func initData(imageList:JavaUtilArrayList,mPosition:Int){
        mImageList = imageList
        position = mPosition
    }
    
    override func onLeftBtnOnClick(sender: UIButton) {
        super.onLeftBtnOnClick(sender)
        imageCallBacK?.onImageControllerCallBack(currentPage + 1)
    }
}

protocol ImageCallBack {
    func onImageControllerCallBack(currentIndex:Int)
}
