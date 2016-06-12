//
//  SnapItemPhotoReviewViewController.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-6-2.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class SnapItemPhotoReviewViewController: BaseViewController,YRADScrollViewDelegate,YRADScrollViewDataSource {

    
    var typeTitle:String = ""
    var scrollView:YRADScrollView?
    var photoList = JavaUtilArrayList()
    var currentPage = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView = YRADScrollView(frame: CGRectMake(0, 70, ScreenWidth, ScreenHeight))
        scrollView!.delegate = self
        scrollView!.dataSource = self
        scrollView!.cycleEnabled = false
        self.view.addSubview(scrollView!)
        if photoList.size() > 0 {
            setTittle("\(typeTitle)(\(1)/\(photoList.size()))")
        }else{
            setTittle("\(typeTitle)(0/0)")
        }
        hiddenRightImage(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func getXibName() -> String {
        return "SnapItemPhotoReviewViewController"
    }
    
    func viewForYRADScrollView(adScrollView: YRADScrollView!, atPage pageIndex: Int) -> UIView! {
        let view = UIView(frame: adScrollView.frame)
        let imageView = UIImageView(frame: CGRectMake(0, 0, ScreenWidth, ScreenHeight - 70))
        
        let photoPath = photoList.getWithInt(Int32(pageIndex)).getLocalPath()
//        imageView.image =  UIImage.createThumbnailImageFromFile(photoPath, maxWidth: imageView.frame.size.width)
        UITools.getThumbnailImageFromFile(photoPath, width: imageView.frame.size.width, cache: true) { (image) -> Void in
            imageView.image = image
        }
        view.addSubview(imageView)
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        return view
    }
    
    func numberOfViewsForYRADScrollView(adScrollView: YRADScrollView!) -> UInt {
        
        if photoList == nil {
            return 0
        }
        
        return UInt(photoList.size())
    }
    
    func adScrollView(adScrollView: YRADScrollView!, didScrollToPage pageIndex: Int) {
        print("\(pageIndex)")
        currentPage = pageIndex
        let tittleStr = "\(typeTitle)(\(pageIndex+1)/\(photoList.size()))"
        setTittle(tittleStr)
    }

}
