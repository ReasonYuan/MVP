//
//  NotFiledView.swift
//  DoctorPlus_ios
//
//  Created by Monkey on 15/12/23.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import UIKit

class NotFiledView: UIView ,UITableViewDataSource,UITableViewDelegate{
    
    var isClose = true
    @IBOutlet weak var picTableView: UITableView!
    var picArray = [ComFqHalcyonEntityPhotoRecord]()
    var backAlertView:CustomIOS7AlertView?
    var photoManager:ComFqHalcyonPracticePhotosManager!
    override init(frame: CGRect) {
        super.init(frame: frame)
        addXib()
        initWidgets()
        self.hidden = true
        photoManager = ComFqHalcyonPracticePhotosManager.getInstance()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //绑定Xib
    func addXib() {
        let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("NotFiledView", owner: self, options: nil)
        let view = nibs.lastObject as! UIView
        view.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight)
        self.addSubview(view)
    }
    
    func initWidgets() {
        picTableView.registerNib(UINib(nibName: "NotFiledPicTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "NotFiledPicTableViewCell")
    }
    
    //关闭view
    func closeView() {
        UIView.animateWithDuration(1.2, animations: { () -> Void in
                self.transform = CGAffineTransformMakeTranslation(0, ScreenHeight)
            }) { (isFinish) -> Void in
                self.isClose = true
                self.hidden = true
        }
    }
    
    //显示view
    func openView() {
        self.hidden = false
        picArray = getPhotosArray()
        picTableView.reloadData()
        UIView.animateWithDuration(1.2, animations: { () -> Void in
            self.transform = CGAffineTransformMakeTranslation(0, -ScreenHeight)
            }) { (isFinish) -> Void in
                self.isClose = false
        }
    }
    
    //退出按钮点击事件
    @IBAction func onBackClickListener(sender: AnyObject) {
        backAlertView = UIAlertViewTool.getInstance().showNewDelDialog("是否放弃当前已拍摄图片？", target: self, actionOk: "onBackSureClick", actionCancle: "onBackCancelClick")
    }
    
    func onBackSureClick() {
        Tools.getCurrentViewController().navigationController?.popViewControllerAnimated(true)
    }
    
    func onBackCancelClick() {
        backAlertView?.close()
    }
    
    //返回拍照界面的按钮点击事件
    @IBAction func onStayInCameraClickListener(sender: AnyObject) {
        closeView()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NotFiledPicTableViewCell") as! NotFiledPicTableViewCell
        cell.setData(picArray[indexPath.row])
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return picArray.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        picArray.removeAtIndex(indexPath.row)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Top)
    }
    
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        return "删除"
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        Tools.getCurrentViewController().navigationController?.pushViewController(BrowserImagesViewController(), animated: true)
    }
    
    func getPhotosArray() -> Array<ComFqHalcyonEntityPhotoRecord> {
        var photos = [ComFqHalcyonEntityPhotoRecord]()
        let photosJavaList = photoManager.getAllPhotos()
        let size = photoManager.getAllPhotos().size()
        for i in 0..<size {
            photos.append(photosJavaList.getWithInt(i) as! ComFqHalcyonEntityPhotoRecord)
        }
        return photos
    }
}
