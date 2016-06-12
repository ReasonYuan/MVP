//
//  BrowsePicturesViewController.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/5/18.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class BrowsePicturesViewController: BaseViewController ,UIScrollViewDelegate{

    var lastScaleFactor : CGFloat! = 1  //放大、缩小
    var mTitle = ""
    var iv : UIImageView!
    var markNum = 1
    let ScreenHeight = UIScreen.mainScreen().bounds.size.height
    let ScreenWidth = UIScreen.mainScreen().bounds.size.width
    var pageControl = UIPageControl()
    var imagesArr = ["app_icon.png","app_icon.png","app_icon.png","app_icon.png","app_icon.png"]
    @IBOutlet var sv: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setTittle("\(mTitle)(\(markNum)/\(imagesArr.count))")
        hiddenRightImage(true)
        self.view.backgroundColor = UIColor.whiteColor()
        self.sv.delegate = self
        for(var i = 0 ; i < imagesArr.count ; i++){
            self.iv = UIImageView(frame: CGRectMake(CGFloat(i) * ScreenWidth, 0, ScreenWidth, ScreenHeight-70))
            self.iv.image = UIImage(named: imagesArr[i])
            iv.contentMode = UIViewContentMode.ScaleAspectFit
            self.sv.addSubview(iv!)
        }
        self.sv.showsHorizontalScrollIndicator = false
        
        self.sv.pagingEnabled = true
        self.pageControl.bounds = CGRectMake(0, 0, 150, 50)
        self.pageControl.center = CGPointMake(ScreenWidth * 0.5+75, ScreenHeight - 45)
        
        self.pageControl.currentPageIndicatorTintColor = UIColor.redColor()
        self.pageControl.pageIndicatorTintColor = UIColor.grayColor()
        self.pageControl.currentPage = 1
        
        self.view.addSubview(self.pageControl)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: "handlePinchGesture:")
        self.iv.addGestureRecognizer(pinchGesture)
        
        let doubleTapRecgnizer = UITapGestureRecognizer(target: self, action: "scrollViewDoubleTapped:")
        doubleTapRecgnizer.numberOfTapsRequired = 2
        doubleTapRecgnizer.numberOfTouchesRequired = 1
        self.iv.addGestureRecognizer(doubleTapRecgnizer)
        
        let twoFingerTapRecognizer = UITapGestureRecognizer(target: self, action: "scrollViewTwoFingerTapped:")
        twoFingerTapRecognizer.numberOfTapsRequired = 1
        twoFingerTapRecognizer.numberOfTouchesRequired = 2
        self.iv.addGestureRecognizer(twoFingerTapRecognizer)
    }

    override func viewWillAppear(animated: Bool) {
        let scrollViewFrame = self.sv.frame
        let scaleWidth = scrollViewFrame.size.width / self.sv.contentSize.width
        let scaleHeight = scrollViewFrame.size.height / self.sv.contentSize.height
        let minScale = min(scaleWidth,scaleHeight)
        self.sv.minimumZoomScale = minScale
        self.sv.maximumZoomScale = 1.0
        self.sv.zoomScale = minScale
    }
    
    override func viewDidLayoutSubviews() {
        self.sv.contentSize = CGSizeMake(CGFloat(self.imagesArr.count) * ScreenWidth, 0)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let pageWidth = self.sv.frame.width
        let currentPage = Int(floor((self.sv.contentOffset.x - pageWidth/2) / pageWidth)) + 1
        if(currentPage == 0)
        {
            markNum = 1
        }else if(currentPage == (imagesArr.count + 1)) {
            markNum = imagesArr.count
        }else{
            markNum = currentPage + 1
        }
        setTittle("\(mTitle)(\(markNum)/\(imagesArr.count))")
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let offSetX = self.sv.contentOffset.x
        let index = offSetX/self.view.frame.size.width
        self.pageControl.currentPage = Int (index)
    }
    
    override func getXibName() -> String {
        return "BrowsePicturesViewController"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func centerScrollViewContents(){
        let boundsSize = self.sv.bounds.size
        var contentsFrame = self.iv.frame
        
        if(contentsFrame.size.width < boundsSize.width){
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width)/2.0
        }else{
            contentsFrame.origin.x = 0.0
        }
        
        if(contentsFrame.size.height < boundsSize.height){
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height)/2.0
        }else{
            contentsFrame.origin.y = 0.0
        }
        
        self.iv.frame = contentsFrame
    }
    
    func handlePinchGesture(sender:UIPinchGestureRecognizer){
        let factor = sender.scale
        if factor > 1{
            //图片放大
            self.iv.transform = CGAffineTransformMakeScale(lastScaleFactor + factor-1, lastScaleFactor+factor - 1)
        }else{
            //缩小
            self.iv.transform = CGAffineTransformMakeScale(lastScaleFactor * factor, lastScaleFactor * factor)
        }
        //状态是否结束，如果结束保存数据
        if sender.state == UIGestureRecognizerState.Ended{
            if factor > 1{
                lastScaleFactor = lastScaleFactor + factor - 1
            }else{
                lastScaleFactor = lastScaleFactor * factor
            }
        }
    }
    
    func scrollviewDoubleTapped(recognizer: UITapGestureRecognizer){
        let pointInView = recognizer.locationInView(self.iv)
        var newZoomScale = self.sv.zoomScale * 1.5
        newZoomScale = min(newZoomScale ,self.sv.maximumZoomScale)
        let scrollViewsSize = self.sv.bounds.size
        let w = scrollViewsSize.width / newZoomScale
        let h = scrollViewsSize.height / newZoomScale
        let x = pointInView.x - (w / 2.0)
        let y = pointInView.y - (h / 2.0)
        let rectToZoomTo = CGRectMake(x, y, w, h)
        self.sv.zoomToRect(rectToZoomTo, animated: true)
        print("doubleClicked")
    }
    
    func scrollViewTwoFingerTapped(recognizer:UITapGestureRecognizer){
        var newZoomScale = self.sv.zoomScale / 1.5
        newZoomScale = max(newZoomScale,self.sv.minimumZoomScale)
        self.sv.setZoomScale(newZoomScale, animated: true)
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.iv
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        self.centerScrollViewContents()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch:UITouch = touches.first!
        if(touch.tapCount == 2){
            var zs = self.sv.zoomScale
            zs = ( zs == 1.0 ) ? 2.0 : 1.0
            
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(0.3)
            self.sv.zoomScale = zs
            UIView.commitAnimations()
        }

    }
    
//    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
//        var touch:UITouch = touches.anyObject() as! UITouch
//        if(touch.tapCount == 2){
//            var zs = self.sv.zoomScale
//            zs = ( zs == 1.0 ) ? 2.0 : 1.0
//            
//            UIView.beginAnimations(nil, context: nil)
//            UIView.setAnimationDuration(0.3)
//            self.sv.zoomScale = zs
//            UIView.commitAnimations()
//        }
//    }
    
}
