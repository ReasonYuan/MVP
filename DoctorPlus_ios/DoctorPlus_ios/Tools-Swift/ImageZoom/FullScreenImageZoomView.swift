//
//  FullScreenImageZoomView.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/8/6.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

protocol FullScreenImageZoomViewDelegate : NSObjectProtocol{
    
    func onPageChanged(position:Int)
}

class FullScreenImageZoomView: UIView,UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var pageImages = [UIImage]()
    var pageViews = [ImageZoomView?]()
    weak var delegate:FullScreenImageZoomViewDelegate?
    var pagePhotoRecords = [ComFqHalcyonEntityPhotoRecord]()
    var selectedPosition = 0
    
    var oldPosition = 0 //用于记录滑动之前的位置
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.hidden = true
        self.alpha = 0.0
        let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("FullScreenImageZoomView", owner: self, options: nil)
        let browView = nibs.lastObject as! UIView
        browView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height)
        self.addSubview(browView)
        
        //手势处理，拦截手势，以免父层接受图片区域的点击事件
        let tapGesture = UITapGestureRecognizer(target: self, action: "handleTapGesture:")
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        self.addGestureRecognizer(tapGesture)
        
        let tapDoubleTapGestrue = UITapGestureRecognizer(target: self, action: "doubleTapGestrue:")
        tapDoubleTapGestrue.numberOfTapsRequired = 2
        tapDoubleTapGestrue.numberOfTouchesRequired = 1
        self.addGestureRecognizer(tapDoubleTapGestrue)
        
        tapGesture.requireGestureRecognizerToFail(tapDoubleTapGestrue)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func doubleTapGestrue(sender: UIPinchGestureRecognizer){
        
    }

    func handleTapGesture(sender: UIPinchGestureRecognizer){
        UIView.animateWithDuration(0.6, animations: { () -> Void in
            self.alpha = 0.0
        }) { (isFinish) -> Void in
            if isFinish {
                self.hidden = true;
            }
        }
        
    }
    
    func showOrHiddenView(isShow:Bool){
        
        if isShow {
            self.hidden = false
            UIView.animateWithDuration(0.6, animations: { () -> Void in
                self.alpha = 1.0
            }) { (isFinish) -> Void in
                    
            }
        }else{
            UIView.animateWithDuration(0.6, animations: { () -> Void in
                self.alpha = 0.0
            }) { (isFinish) -> Void in
                if isFinish {
                    self.hidden = true;
                }
            }
        }
    }
    
    func initData(position:Int){
        
        
        for (index,item) in pagePhotoRecords.enumerate() {
            
            if item.getLocalPath() == nil {
                pageImages.append(UIImage(named: "btn_record_album.png")!)
                ApiSystem.getImageWithComFqHalcyonEntityPhoto(item as ComFqHalcyonEntityPhoto, withComFqLibCallbackICallback: WapperCallback(onCallback: { (localPath) -> Void in
                    let path:NSString? = localPath as? NSString
                    if(path != nil && path != ""){
                        
                        self.pageImages[index] = UIImage(contentsOfFile: item.getLocalPath())!
                        self.firstLoad(self.selectedPosition)
                    }
                }))
            }else{
                if item.getLocalPath() != nil {
                    let image:UIImage? = UIImage(contentsOfFile: item.getLocalPath())
                    if(image != nil){
                        pageImages.append(image!)
                    }else{
                        pageImages.append(UIImage(named: "btn_record_album.png")!)
                    }
                }
                
            }
        }
        
        let pageCount = pageImages.count
        
        for _ in 0..<pageCount{
            pageViews.append(nil)
        }
        
        let pagesScrollViewSize = scrollView.bounds.size
        
        scrollView.contentSize = CGSize(width: ScreenWidth * CGFloat(pageCount),
            height: pagesScrollViewSize.height)
        scrollView.pagingEnabled = true
        firstLoadVisiblePages(position)
        scrollView.delegate = self
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if scrollView.contentSize.height != scrollView.bounds.size.height {
            scrollView.contentSize.height = scrollView.bounds.size.height
        }
    }
    
    //第一次下载之后加载图片
    func firstLoad(page:Int){
        if page < 0 || page >= pageImages.count {
            return
        }
        
        if( pageViews[page] != nil) {
            pageViews[page]!.imageView.image = pageImages[page]
        }
        
    }
    
    func loadPage(page:Int){
        if page < 0 || page >= pageImages.count {
            return
        }
        
        if scrollView.contentSize.height != scrollView.bounds.size.height {
            scrollView.contentSize.height = scrollView.bounds.size.height
        }
        
        if let pageView = pageViews[page] {
            pageViews[page]?.imageView.image = pageImages[page]
        }else {
            let newPageView = ImageZoomView(frame: CGRectMake(ScreenWidth * CGFloat(page), 0, ScreenWidth, ScreenHeight))
            newPageView.imageView.image = pageImages[page]
            scrollView.addSubview(newPageView)
            pageViews[page] = newPageView
        }
        
    }
    
    func purgePage(page: Int) {
        if page < 0 || page >= pageImages.count {
            // 如果超出要显示的范围，什么也不做
            return
        }
        
        // 从scrollView中移除页面并重置pageViews容器数组响应页面
        if let pageView = pageViews[page] {
            pageView.removeFromSuperview()
            pageViews[page] = nil
        }
    }
    
    func firstLoadVisiblePages(position:Int){
        
        let pointX = ScreenWidth * CGFloat(position)
        
        scrollView.setContentOffset(CGPointMake(pointX, scrollView.bounds.origin.y), animated: false)
        
        // 更新pageControl
        selectedPosition = position
        
        // 计算那些页面需要加载
        let firstPage = position - 1
        let lastPage = position + 1
        
        // 清理firstPage之前的所有页面
        for var index = 0; index < firstPage; ++index {
            purgePage(index)
        }
        
        // 加载范围内（firstPage到lastPage之间）的所有页面
        for index in firstPage...lastPage {
            loadPage(index)
        }
        
        // 清理lastPage之后的所有页面
        for var index = lastPage+1; index < pageImages.count; ++index {
            purgePage(index)
        }
    }
    
    func loadVisiblePages() {
        // 首先确定当前可见的页面
        let pageWidth = ScreenWidth
        let page = Int(floor((scrollView.contentOffset.x * 2.0 + pageWidth) / (pageWidth * 2.0)))
        
        // 更新pageControl
        
        selectedPosition = page
        
        
        // 计算那些页面需要加载
        let firstPage = page - 1
        let lastPage = page + 1
        
        // 清理firstPage之前的所有页面
        for var index = 0; index < firstPage; ++index {
            purgePage(index)
        }
        
        // 加载范围内（firstPage到lastPage之间）的所有页面
        for index in firstPage...lastPage {
            loadPage(index)
        }
        
        // 清理lastPage之后的所有页面
        for var index = lastPage+1; index < pageImages.count; ++index {
            purgePage(index)
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        loadVisiblePages()
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        if oldPosition != selectedPosition {
            oldPosition = selectedPosition
            for i in 0..<pageViews.count {
                pageViews[i]?.reSetZoomScale()
            }
        }
        delegate?.onPageChanged(selectedPosition)
    }

    func setDatas(position:Int,pagePhotoRecords:Array<ComFqHalcyonEntityPhotoRecord>){
        self.pagePhotoRecords = pagePhotoRecords
        initData(position)
        self.selectedPosition = position
    }
}
