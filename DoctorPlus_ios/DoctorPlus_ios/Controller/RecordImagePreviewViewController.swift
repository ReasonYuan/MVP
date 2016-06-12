//
//  RecordImagePreviewViewController.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/5/19.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class RecordImagePreviewViewController: BaseViewController, XLCycleScrollViewDatasource ,XLCycleScrollViewDelegate{

    @IBOutlet weak var uploadBtn: UIButton!
    @IBOutlet weak var delBtn: UIButton!
    var imgId :Int!
    var recordInfoId: Int!
    var iv : UIImageView!
    var markNum = 1
    let ScreenHeight = UIScreen.mainScreen().bounds.size.height
    let ScreenWidth = UIScreen.mainScreen().bounds.size.width
    var pageControl = UIPageControl()
    var mSnapManager:ComFqLibRecordSnapPhotoManager!
    var photos = JavaUtilArrayList()
    var csView:XLCycleScrollView!
    var dialog:CustomIOS7AlertView?
    var uploadButtonClicked = false
    var mTiShiDialog:CustomIOS7AlertView?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setRightImage(isHiddenBtn: false, image: UIImage(named: "btn_menu.png")!)
        UITools.setRoundBounds(5, view: uploadBtn)
        UITools.setRoundBounds(5, view: delBtn)
        UITools.setButtonWithColor(ColorType.EMERALD, btn: uploadBtn, isOpposite: false)
        UITools.setButtonWithColor(ColorType.EMERALD, btn: delBtn, isOpposite: false)
        self.view.backgroundColor = UIColor.whiteColor()
        
        csView = XLCycleScrollView(frame: CGRectMake(20, 80, (ScreenWidth-40), ScreenHeight - 260))
        csView.delegate = self
        csView.datasource = self
        self.view.addSubview(csView)
        csView.backgroundColor = UIColor.clearColor()
    }
    override func getXibName() -> String {
        return "RecordImagePreviewViewController"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        photos.clear()
        photos = mSnapManager.getAllPhotos()
       
        if photos.size() == 0 {
            csView.removeFromSuperview()
            setTittle("")
        }else {
             csView.reloadData()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func numberOfPages() -> Int {
        return Int(photos.size())
    }

    func pageAtIndex(index: Int) -> UIView! {
        var title:String?
        if(index == 1)
        {
            title = "1/\(Int(photos.size()))"
        }else if(index == 0){
            title = "\(Int(photos.size()))/\(Int(photos.size()))"
        }else{
            title = "\(index)/\(Int(photos.size()))"
        }
        setTittle(title!)
        let container = UIView(frame: CGRectMake(0, 0, (ScreenWidth-40), ScreenHeight - 260))
        container.backgroundColor = UIColor.clearColor()
        
        let iv = UIImageView(frame: CGRectMake(0, 25, (ScreenWidth-40), ScreenHeight - 260))
        let photo:ComFqHalcyonEntityPhotoRecord = photos.getWithInt(Int32(index)) as! ComFqHalcyonEntityPhotoRecord
        iv.image = UITools.getImageFromFile(photo.getLocalPath())
        iv.contentMode = UIViewContentMode.ScaleAspectFit
        
        let uv = UIView(frame: CGRectMake(0, 0, (ScreenWidth-40), 20))
        uv.backgroundColor = UIColor(red: 98/255, green: 192/255, blue: 180/255, alpha: 1.0)
        uv.layer.masksToBounds = true
        uv.layer.cornerRadius = 3.0
        uv.layer.borderWidth = 0.0
        container.addSubview(uv)
        
        let label = UILabel(frame: CGRectMake(10, 2, 150, 16))
        label.backgroundColor = UIColor.clearColor()
        label.text = ComFqLibRecordRecordConstants.getTypeNameByRecordTypeWithInt(mSnapManager.getLastType().getType())
        label.textColor = UIColor.whiteColor()
        label.font = UIFont.boldSystemFontOfSize(12.0)
        uv.addSubview(label)
        
        container.addSubview(iv)
        
        return container
    }
    
    @IBAction func upLoading(sender: AnyObject) {
        print("上传")
        if ComFqLibToolsConstants.getUser().isOnlyWifi() && !isNetWorkOK() {
            mTiShiDialog = UIAlertViewTool.getInstance().showZbarDialogWith1Btn("请连接wifi或者关闭设置中“仅wifi状态下上传病历”", target: self, actionOk: "dialogOK:")
        }else{
            if photos.size() > 0 {
                uploadButtonClicked = true
                if(mSnapManager.getRecordId() == 0){
                    dialog =  UIAlertViewTool.getInstance().showNewDelDialog("上传病历出现失败！", target: self, actionOk: "deleteOk:", actionCancle: "deleteCancle:")
                    return
                }
                self.navigationController?.popToViewController((self.navigationController!.viewControllers as NSArray).objectAtIndex(self.navigationController!.viewControllers.count - 3) as! UIViewController, animated: true)
            }else{
                return
            }
        }
       
       
    }

    
    @IBAction func deleteClicked(sender: AnyObject) {
        print("删除")
        if photos.size() > 0 {
            uploadButtonClicked = false
            dialog =  UIAlertViewTool.getInstance().showNewDelDialog("是否删除这张照片？", target: self, actionOk: "deleteOk:", actionCancle: "deleteCancle:")
        }else{
            return
        }
       
    }
    
    func deleteOk(sender:UIButton){
        if(!uploadButtonClicked){
            let index =  csView.currentPage
            let photo:ComFqHalcyonEntityPhotoRecord = photos.getWithInt(Int32(index)) as! ComFqHalcyonEntityPhotoRecord
            photos.removeWithId(photo)
            mSnapManager.removeWithComFqHalcyonEntityPhotoRecord(photo)
            if(Int(photos.size()) == 0){
                csView.removeFromSuperview()
                self.setTittle("'")
            }else{
                csView.reloadData()
            }
        }
        dialog?.close()
    }
    
    func deleteCancle(sender:UIButton){
        dialog?.close()
    }
    
    override func onRightBtnOnClick(sender: UIButton) {
        if ComFqLibToolsConstants.getUser().isOnlyWifi() && !isNetWorkOK() {
            mTiShiDialog = UIAlertViewTool.getInstance().showZbarDialogWith1Btn("请连接wifi或者关闭设置中“仅wifi状态下上传病历”", target: self, actionOk: "dialogOK:")
        }else{
            self.navigationController?.pushViewController(AllRecordPhotoViewController(), animated: true)
        }
 
    }
    
    func dialogOK(sender:UIButton){
        mTiShiDialog?.close()
    }

    
    /*!
    * 判断是否有网络连接
    */
    func isNetWorkOK()->Bool{
//        var remoteHostStatus:NetworkStatus = Tools.getNetWorkState()
//        if remoteHostStatus == NetworkStatus.NotReachable {
//            return false
//        }else if remoteHostStatus == NetworkStatus.ReachableViaWWAN {
//            return false
//        }
        return Tools.isWifiConnect()
    }
}
