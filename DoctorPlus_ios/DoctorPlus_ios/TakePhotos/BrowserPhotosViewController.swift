//
//  BrowserPhotosViewController.swift
//  DoctorPlus_ios
//
//  Created by chenjie on 15/12/25.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import UIKit

class BrowserPhotosViewController: BaseViewController,ButtonCollectionDelegate,BrowserImageViewDelegate {
    
    /// 识别时间
    @IBOutlet weak var discriminateTime: UILabel!
    /// 识别状态
    @IBOutlet weak var discriminateStatus: UILabel!
    /// 识别正确率
    @IBOutlet weak var discriminateAccuracy: UILabel!
    /// 归档按钮
    @IBOutlet weak var fileBtn: UIButton!
    /// 图片区域
    @IBOutlet weak var photosContent: UIView!
    /// 底部菜单按钮
    var buttonCollection:ButtonCollection!
    
    var browserView:BrowserImageView!
    
    //    var photoManager:ComFqHalcyonPracticePhotosManager!
    var photoList:NSMutableArray!
    
    /// 是否是单页模式
    var isSinglePages = false
    
    var dialog:CustomIOS7AlertView!
    
    var fileView:FileView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //初始化TopBar
        setLeftTextString("放弃")
        setLeftImage(isHiddenBtn: false, image: UIImage())
        hiddenRightImage(true)
        //        setRightBtnTittle("暂存")
        
        //        photoManager = ComFqHalcyonPracticePhotosManager.getInstance()
        
        //        let all = Tools.toNSarray(photoManager.getAllPhotos()) as! [ComFqHalcyonEntityPhotoRecord]
        
        TakePhotoTools.insertPhotoList(photoList, status: RecordPhotoStatus.Uploading)
        var all:[ComFqHalcyonEntityPhotoRecord] = [ComFqHalcyonEntityPhotoRecord]()
        for var i = 0 ; i < photoList.count ; i++ {
            let photo:ComFqHalcyonEntityPhotoRecord = photoList.objectAtIndex(i) as! ComFqHalcyonEntityPhotoRecord
            all.append(photo)
        }
        
        
        //初始化归档按钮
        let nomalImage = UIImage(named: "guidang.png")
        let highlightImage = UITools.imageByApplyingAlpha(0.7, image: nomalImage!)
        fileBtn.setBackgroundImage(nomalImage, forState: UIControlState.Normal)
        fileBtn.setBackgroundImage(highlightImage, forState: UIControlState.Highlighted)
        
        buttonCollection = ButtonCollection(frame: CGRect(x: ScreenWidth/2 - 30, y: ScreenHeight - 80, width: 60, height: 60), btnCount: 3, centerBtnImageList: ["show_menu.png","close_menu.png"], btnNormalList: ["re_take_photo.png","look_content_normal.png","re_cut.png"], superView: self.view, delegate: self )
        
        browserView = BrowserImageView(frame:CGRectMake(0, 0, ScreenWidth - 24, ScreenHeight - 110),delegate:self)
        
        browserView.setDatas(0, pagePhotoRecords: all)
        if !isSinglePages {
            setTittle("\(all.count)/\(1)")
        }else{
            setTittle("")
        }
        
        photosContent.addSubview(browserView)
        
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
        print("第\(position)页")
        if !isSinglePages {
            setTittle("\(browserView.pagePhotoRecords.count)/\(position+1)")
        }else{
            setTittle("")
        }
    }
    
    
    /**
     当前位置是否识别
     
     - parameter yes: 是否
     */
    func onOcrStateComplete(yes: Bool) {
        if yes {
            buttonCollection.setBtnEnable(Direction.RIGHT)
        }else{
            buttonCollection.setBtnNotEnable(Direction.RIGHT, imageName: "look_content_not_enable.png")
        }
    }
    
    /**
     当前位置是否显示图片
     
     - parameter yes: 是否
     */
    func onImageIsShow(yes: Bool) {
        if yes {
            buttonCollection.setBtnNormalImage(Direction.RIGHT, imageName: "look_content_normal.png")
        }else{
            buttonCollection.setBtnNormalImage(Direction.RIGHT, imageName: "look_old_image.png")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func getXibName() -> String {
        return "BrowserPhotosViewController"
    }
    
    /**
     重拍
     
     - parameter sender: <#sender description#>
     */
    func LeftOnClick(sender: UIButton) {
        print("重拍")
    }
    
    /**
     重新裁剪
     
     - parameter sender: <#sender description#>
     */
    func UpOnClick(sender: UIButton) {
        print("剪切")
    }
    
    /**
     查看内容或者查看图片
     
     - parameter sender: <#sender description#>
     */
    func RightOnClick(sender: UIButton) {
        print("查看")
        browserView.showImageOrText()
    }
    
    //    override func onRightBtnOnClick(sender: UIButton) {
    //        print("暂存")
    //    }
    
    /**
    放弃按钮点击
    
    - parameter sender: <#sender description#>
    */
    override func onLeftBtnOnClick(sender: UIButton) {
        dialog = UIAlertViewTool.getInstance().showNewDelDialog("是否放弃当前图片", target: self, actionOk: "giveUp", actionCancle: "cancel")
    }
    
    /**
     放弃
     */
    func giveUp(){
        
        //TOOD
        //        photoManager.removeAll()
        dialog.cancel()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    /**
     取消
     */
    func cancel(){
        dialog.cancel()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    
}
