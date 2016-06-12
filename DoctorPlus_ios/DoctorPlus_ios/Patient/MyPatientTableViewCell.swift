//
//  MyPatientTableViewCell.swift
//  DoctorPlus_ios
//
//  Created by Monkey on 15/11/30.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import UIKit

class MyPatientTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var headImg: UIButton!
    @IBOutlet weak var hasDown: UIImageView!
    @IBOutlet weak var patientName: UILabel!
    @IBOutlet weak var selectedBtn: UIButton!
    @IBOutlet weak var structuredBtn: UIButton!
    @IBOutlet weak var hasNewLabel: UILabel!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var cutlineLabel: UILabel!
    @IBOutlet weak var contextLabel: UILabel!
    
    var indexPath: NSIndexPath?
    var patient:ComFqHalcyonEntityPracticePatientAbstract?
    var isEdit = false
    var hasNew = false
    var recycle = false
    var dialog2:IndetifyDialog!
    //去身份化
    var didSendInfo:Bool = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //结构化点击事件
    @IBAction func onStructuredClickListener(sender: UIButton) {
        
        let controller = StructuredViewController()
        controller.patientId = Int(patient!.getPatientId())
        Tools.getCurrentViewController().navigationController?.pushViewController(controller, animated: true)
    }

    @IBAction func onSelectedClickListener(sender: UIButton) {
        if sender.selected {
            selectedBtn.selected = false
        }else{
            selectedBtn.selected = true
        }
        patient?.setSelectedWithBoolean(selectedBtn.selected)
    }
    
    /**
     分享按钮的点击事件
     
     - parameter sender:
     */
    @IBAction func onShareClickListener(sender: UIButton) {
        
        dialog2 = UIAlertViewTool.getInstance().showRemoveIndetifyDialog(didSendInfo, target: self, actionOk: "sendClick:", actionCancle: "cancel:", actionRemoveIndentify: "secretProtocolClick:", selecBtn: "withInfoBtnClick:")
    }
    
    //供选择的btn点击事件
    func withInfoBtnClick(sender:AnyObject?){
        if didSendInfo{
            didSendInfo = false
            dialog2.selectBtn!.setBackgroundImage(UIImage(named: "icon_circle_no.png"), forState: UIControlState.Normal)
            print("去身份化")
        }else{
            didSendInfo = true
            dialog2.selectBtn!.setBackgroundImage(UIImage(named: "icon_circle_yes.png"), forState: UIControlState.Normal)
            print("不去身份化")
        }
    }
    
    //隐私协议
    func secretProtocolClick(sender:AnyObject?){
        dialog2.alertView!.close()
        Tools.getCurrentViewController().navigationController?.pushViewController(ProtocolViewController(),animated:true)
    }
    
    //取消发送
    func cancel(sender:AnyObject?){
        dialog2.alertView!.close()
    }
    
    //点击发送
    func sendClick(sender:AnyObject?){
        dialog2.alertView!.close()
        
        let controller = MoreChatListViewController()
        controller.type = 2;
        let patientList = JavaUtilArrayList()
        patientList.addWithId(patient)
        controller.patientList = patientList
        controller.didSendInfo = didSendInfo;
        Tools.getCurrentViewController(self).navigationController?.pushViewController(controller, animated: true)
       
        didSendInfo = true
        
        
    }
    
    
    func setItemSelected(isSelected:Bool) {
        selectedBtn.selected = isSelected
        patient?.setSelectedWithBoolean(selectedBtn.selected)
    }
    
    func setCellContent(indexPath: NSIndexPath,patient:ComFqHalcyonEntityPracticePatientAbstract) {
        self.indexPath = indexPath
        self.patient = patient
        
        patientName.text = patient.getShowName()
        contextLabel.text = patient.getDiagnose()
        loadImage(headImg, imageId: patient.getUserImageId())
        
        if isEdit && patient.isSelected() {
            selectedBtn.selected = true
        }else{
            selectedBtn.selected = false
        }
    }
    
    /**
     下载图片并在view中显示
     - parameter imageView: 显示图片的控件
     - parameter imageId:   要下载图片的id
     */
    func loadImage(view:UIView!,imageId:Int32!){
        if imageId != 0 {
            view.downLoadImageWidthImageId(Int32(imageId), callback: { (view, path) -> Void in
                let tmpImageView = view as! UIButton
                tmpImageView.setBackgroundImage(UITools.getImageFromFile(path), forState: UIControlState.Normal)
            })
        }
    }
    
    func setCellStatus(isEdit:Bool) {
        self.isEdit = isEdit
        
        if recycle {
            cutlineLabel.hidden = true
        }
        
        if isEdit {
            selectedBtn.hidden = false
            structuredBtn.hidden = true
            shareBtn.hidden = true
            hasNewLabel.hidden = true
        }else{
            selectedBtn.hidden = true
            
            if recycle {
                return
            }
            
            structuredBtn.hidden = false
            shareBtn.hidden = false
            if hasNew {
                hasNewLabel.hidden = false
            }
        }
    }
    
    func isRecycle(recycle:Bool) {
        self.recycle = recycle
    }
}
