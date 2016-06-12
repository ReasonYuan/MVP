//
//  BrowseImageZoomView.swift
//  DoctorPlus_ios
//
//  Created by monkey on 15-7-16.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

protocol BrowseImageZoomViewDelegate : NSObjectProtocol{
    
    func onPageChanged(position:Int)
}

class BrowseImageZoomView: UIView ,UIScrollViewDelegate{

    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageLabel: UILabel!
    
    var pageImages = [UIImage]()
    var pageViews = [ImageZoomView?]()
    
    weak var delegate:BrowseImageZoomViewDelegate?
    
    var pagePhotoRecords = [ComFqHalcyonEntityPhotoRecord]()
    var selectedPosition = 0
    
    var pageWidth:CGFloat!
    
    override init(frame:CGRect){
        super.init(frame: frame)
        
        let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("BrowseImageZoomView", owner: self, options: nil)
        let browView = nibs.lastObject as! UIView
        browView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height)
        self.addSubview(browView)
        
        pageWidth = frame.size.width
        
        scrollView.frame = CGRect(origin: scrollView.frame.origin, size: CGSize(width: frame.width, height: frame.size.height))
        initData(0)
        
        //手势处理，拦截手势，以免父层接受图片区域的点击事件
        let tapGesture = UITapGestureRecognizer(target: self, action: "handleTapGesture:")
        scrollView.addGestureRecognizer(tapGesture)
    }
    
    
    func handleTapGesture(sender: UIPinchGestureRecognizer){
//        self.hidden = true;
    }

    
    func initData(position:Int){

        
        for (index,item) in pagePhotoRecords.enumerate() {
            
            if item.getLocalPath() == nil {
                pageImages.append(UIImage(named: "btn_record_album.png")!)
                ApiSystem.getImageWithComFqHalcyonEntityPhoto(item as ComFqHalcyonEntityPhoto, withComFqLibCallbackICallback: WapperCallback(onCallback: { (localPath) -> Void in
                    let path:NSString? = localPath as? NSString
                    if(path != nil && path != ""){
                        print("browseImageZoomView------------------------\(item.getLocalPath())")
                        self.pageImages[index] = UIImage(contentsOfFile: item.getLocalPath())!
                        self.firstLoad(self.selectedPosition)
                    }
                }))
            }else{
                pageImages.append(UIImage(contentsOfFile: item.getLocalPath())!)
            }
        }
        
        let pageCount = pageImages.count
        
        pageLabel.text = "1/\(pageCount)"
        
        for _ in 0..<pageCount{
            pageViews.append(nil)
        }
        
        let pagesScrollViewSize = scrollView.bounds.size
        
        scrollView.contentSize = CGSize(width: pageWidth * CGFloat(pageCount),
            height: pagesScrollViewSize.height)
        scrollView.pagingEnabled = true
        firstLoadVisiblePages(position)
        scrollView.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        
        if let _ = pageViews[page] {
            pageViews[page]?.imageView.image = pageImages[page]
        }else {
            let newPageView = ImageZoomView(frame: CGRectMake(pageWidth * CGFloat(page), 0, pageWidth, scrollView.bounds.size.height))
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
        
        let pointX = pageWidth * CGFloat(position)
        
        scrollView.setContentOffset(CGPointMake(pointX, scrollView.bounds.origin.y), animated: false)
        
        // 更新pageControl
        pageLabel.text = "\(position + 1)/\(pageViews.count)"
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
        let page = Int(floor((scrollView.contentOffset.x * 2.0 + pageWidth) / (pageWidth * 2.0)))
        
        // 更新pageControl
        pageLabel.text = "\(page + 1)/\(pageViews.count)"
        
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
    
    /**
     滑动至某一页
     
     - parameter page: 页
     */
    func scrollToPage(page:Int) {
        selectedPosition = page
        
        scrollView.scrollRectToVisible(CGRectMake(CGFloat(selectedPosition) * pageWidth, 0, pageWidth, scrollView.bounds.size.height), animated: true)
        
        for i in 0..<pageViews.count {
            pageViews[i]?.reSetZoomScale()
        }
        delegate?.onPageChanged(selectedPosition)
        
    }

    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        loadVisiblePages()
    }
    
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        for i in 0..<pageViews.count {
            pageViews[i]?.reSetZoomScale()
        }
        delegate?.onPageChanged(selectedPosition)
    }

}
