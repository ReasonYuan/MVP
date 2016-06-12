//
//  SelectFollowUpPatientViewController.swift
//  DoctorPlus_ios
//
//  Created by monkey on 15-5-13.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class SelectFollowUpPatientViewController: BaseViewController ,UITableViewDataSource,UITableViewDelegate,ComFqHalcyonLogic2ContactLogic_ContactLogicInterface{

    @IBOutlet weak var tableView: UITableView!
    var mList:JavaUtilArrayList! = JavaUtilArrayList()
    var logic:ComFqHalcyonLogic2ContactLogic?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTittle("发送随访")
        hiddenRightImage(true)
        getdata()
    }
    
    func getdata(){
        logic = ComFqHalcyonLogic2ContactLogic(comFqHalcyonLogic2ContactLogic_ContactLogicInterface: self, withInt: ComFqLibToolsConstants.getUser().getUserId())
    }
    /**获取患者好友失败回调*/
    func onErrorWithInt(code: Int32, withJavaLangThrowable e: JavaLangThrowable!) {
        UIAlertViewTool.getInstance().showAutoDismisDialog("获取数据失败！", width: 210, height: 120)
    }
    /**获取患者好友成功回调*/
    func onDataReturnWithJavaUtilHashMap(mHashPeerList: JavaUtilHashMap!) {
        mList = ComFqLibToolsConstants_contactsMap_.getWithId(JavaLangInteger(int: ComFqLibToolsConstants_ROLE_PATIENT)) as! JavaUtilArrayList
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func getXibName() -> String {
        return "SelectFollowUpPatientViewController"
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("SelectFollowUpPatientTableViewCell") as? SelectFollowUpPatientTableViewCell
        if cell == nil {
            let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("SelectFollowUpPatientTableViewCell", owner: self, options: nil)
            cell = nibs.lastObject as? SelectFollowUpPatientTableViewCell
        }
        cell?.headKuang.layer.masksToBounds = true
        let headKuangrect:CGRect? = cell?.headKuang.bounds
        cell?.headKuang.layer.cornerRadius = CGRectGetHeight(headKuangrect!)/2
        cell?.headKuang.layer.borderWidth = 1.0
        cell?.headKuang.layer.borderColor = UIColor(red: 98/255, green: 192/255, blue: 180/255, alpha: 1.0).CGColor
        cell?.headKuang.backgroundColor = UIColor(red: 253/255, green: 237/255, blue: 240/255, alpha: 1.0)
        cell?.headImageView.layer.masksToBounds = true
        let rect:CGRect? = cell?.headImageView.bounds
        cell?.headImageView.layer.cornerRadius = CGRectGetHeight(rect!)/2
        
        let mPatient:ComFqHalcyonEntityContacts! = mList.getWithInt(Int32(indexPath.row)) as! ComFqHalcyonEntityContacts
        cell?.nameLabel.text = mPatient.getName()
        let photo:ComFqHalcyonEntityPhoto! = ComFqHalcyonEntityPhoto()
        photo.setImageIdWithInt(mPatient.getImageId())
        ApiSystem.getHeadImageWithComFqHalcyonEntityPhoto(photo, withComFqLibCallbackICallback: WapperCallback(onCallback: { (data) -> Void in
            let path:NSString? = data as? NSString
            if(path != nil){
//                cell?.headImageView.image = UITools.getImageFromFile(path!)
                UITools.getThumbnailImageFromFile(path!, width: cell!.headImageView.frame.size.width,cache:true, callback: { (image) -> Void in
                    cell!.headImageView.image = image
                })
                
            }
        }), withBoolean: false, withInt: Int32(2))
        return cell!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.rowHeight = 60
        return Int(mList.size())
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
         let mPatient:ComFqHalcyonEntityContacts! = mList.getWithInt(Int32(indexPath.row)) as! ComFqHalcyonEntityContacts
        let controller:SelectFollowUpTemplateViewController! = SelectFollowUpTemplateViewController()
        controller.mPatient = mPatient
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
}
