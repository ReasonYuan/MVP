//
//  ImageZoomView.swift
//  DoctorPlus_ios
//
//  Created by monkey on 15-7-14.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class ImageZoomView: UIView , UIScrollViewDelegate{

    var scrollView:UIScrollView!
    var imageView:UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let subFrame = CGRectMake(0, 0, frame.size.width, frame.size.height)
        scrollView = UIScrollView(frame: subFrame)
        let image = UIImage(named: "analysis_exam.jpg")
        imageView = UIImageView(image:image)
        imageView.frame = subFrame
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        scrollView.addSubview(imageView)
        
        scrollView.contentSize = image!.size
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "scrollViewDoubleTapped:")
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(doubleTapRecognizer)
        
        let scrollViewFrame = scrollView.frame
        let scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width
        let scaleHeight = scrollViewFrame.size.height / scrollView.contentSize.height
        let minScale = min(scaleWidth, scaleHeight)
        scrollView.minimumZoomScale = 1.0
        
        scrollView.maximumZoomScale = 2.0
        scrollView.zoomScale = minScale
        
        centerScrollViewContents()
        
        addSubview(scrollView)
        scrollView.delegate = self
    }

    func setImage(name:String){
        imageView = UIImageView(image: UIImage(contentsOfFile:name))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        centerScrollViewContents()
    }
    
    func centerScrollViewContents() {
        let boundsSize = scrollView.bounds.size
        var contentsFrame = imageView.frame
        
        if contentsFrame.size.width < boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
        } else {
            contentsFrame.origin.x = 0.0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
        } else {
            contentsFrame.origin.y = 0.0
        }
        
        imageView.frame = contentsFrame
    }
    
    func scrollViewDoubleTapped(recognizer: UITapGestureRecognizer) {

        let pointInView = recognizer.locationInView(imageView)

        if(scrollView.zoomScale < scrollView.maximumZoomScale){
            var newZoomScale = scrollView.zoomScale * 2.0
            newZoomScale = min(newZoomScale, scrollView.maximumZoomScale)
            
            let scrollViewSize = scrollView.bounds.size
            let w = scrollViewSize.width / newZoomScale
            let h = scrollViewSize.height / newZoomScale
            let x = pointInView.x - (w / 2.0)
            let y = pointInView.y - (h / 2.0)
            
            let rectToZoomTo = CGRectMake(x, y, w, h);
            
            scrollView.zoomToRect(rectToZoomTo, animated: true)
        }else{
            
            let newZoomScale = CGFloat(1)
            
            let scrollViewSize = scrollView.bounds.size
            let w = scrollViewSize.width / newZoomScale
            let h = scrollViewSize.height / newZoomScale
            let x = pointInView.x - (w / 2.0)
            let y = pointInView.y - (h / 2.0)
            
            let rectToZoomTo = CGRectMake(x, y, w, h);
            
            scrollView.zoomToRect(rectToZoomTo, animated: true)
        }
        
    }

    func reSetZoomScale(){
        scrollView.zoomScale = 1
    }
}
