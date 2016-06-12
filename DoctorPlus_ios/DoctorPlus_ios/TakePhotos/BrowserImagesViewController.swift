//
//  BrowserImagesViewController.swift
//  DoctorPlus_ios
//
//  Created by chenjie on 15/12/28.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import UIKit

class BrowserImagesViewController: BaseViewController,ButtonCollectionDelegate,BrowseImageZoomViewDelegate {
    
    /// 图片区域
    @IBOutlet weak var photosContent: UIView!
    /// 底部菜单按钮
    var buttonCollection:ButtonCollection!
    
    var picScroll:BrowseImageZoomView!
    
    var photoManager:ComFqHalcyonPracticePhotosManager!
    
    var photoList:NSMutableArray!
    
    var fileView:FileView!
    
    /// 当前位置
    var position:Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //初始化TopBar
        setLeftTextString("添加")
        setLeftImage(isHiddenBtn: false, image: UIImage())
        hiddenRightImage(true)
        setRightBtnTittle("暂存")
        
        photoManager = ComFqHalcyonPracticePhotosManager.getInstance()
        
//        photoList = Tools.toNSarray(photoManager.getAllPhotos()) as! [ComFqHalcyonEntityPhotoRecord]
        
        setTittle("\(photoList.count)/\(1)")
        
        buttonCollection = ButtonCollection(frame: CGRect(x: ScreenWidth/2 - 30, y: ScreenHeight - 80, width: 60, height: 60), btnCount: 2, centerBtnImageList: ["show_menu.png","close_menu.png"], btnNormalList: ["delete.png","add_to.png"], superView: self.view, delegate: self )
        
        var all:[ComFqHalcyonEntityPhotoRecord] = [ComFqHalcyonEntityPhotoRecord]()
        for var i = 0 ; i < photoList.count ; i++ {
            let photo:ComFqHalcyonEntityPhotoRecord = photoList.objectAtIndex(i) as! ComFqHalcyonEntityPhotoRecord
            all.append(photo)
        }

        
        picScroll = BrowseImageZoomView(frame: CGRectMake(0, 0, ScreenWidth - 24, ScreenHeight - 110))
        picScroll.delegate = self
        picScroll.pagePhotoRecords = all
        picScroll.initData(0)
        
        photosContent.addSubview(picScroll)
        
        fileView = FileView(frame: CGRect(x: 0, y: ScreenHeight, width: ScreenWidth, height: ScreenHeight))
        self.view.addSubview(fileView)
        
    }
    
    /**
     归档按钮点击
     
     - parameter sender: 归档btn
     */
    @IBAction func fileBtnClick(sender: AnyObject) {
        fileView.openView()
    }
    
    /**
     图片页面改变监听
     
     - parameter position: 当前位置
     */
    func onPageChanged(position: Int) {
        self.position = position
        print("第\(position)页")
        setTittle("\(Tools.toNSarray(photoManager.getAllPhotos()).count)/\(position+1)")
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func getXibName() -> String {
        return "BrowserImagesViewController"
    }
    

    
    override func onRightBtnOnClick(sender: UIButton) {
        print("暂存")
    }
    
    /**
     删除图片
     
     - parameter sender:
     */
    func LeftOnClick(sender: UIButton) {
        
    }
    
    /**
     合并
     
     - parameter sender:
     */
    func RightOnClick(sender: UIButton) {
        fileView.openView()
    }
    
    
}
