//
//  SelectFollowUpTemplateViewController.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/5/13.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class SelectFollowUpTemplateViewController:BaseViewController,UITableViewDelegate,UITableViewDataSource,ComFqHalcyonLogic2FollowUpTempleListLogic_FollowUpTempleListLogicInterface {

    @IBOutlet weak var tableView: UITableView!
    var templist = JavaUtilArrayList()
    var mPatient:ComFqHalcyonEntityContacts!
    override func viewDidLoad() {
        super.viewDidLoad()
        setTittle("发送随访")
        hiddenRightImage(true)
        getTempleList()
    }
    
    func getTempleList(){
        let logic = ComFqHalcyonLogic2FollowUpTempleListLogic(comFqHalcyonLogic2FollowUpTempleListLogic_FollowUpTempleListLogicInterface: self)
        logic.getTempleList()
    }
    func onErrorWithInt(code: Int32, withJavaLangThrowable error: JavaLangThrowable!) {
        UIAlertViewTool.getInstance().showAutoDismisDialog("获取数据失败！", width: 210, height: 120)
    }
    
    func onDataErrorWithInt(code: Int32, withNSString msg: String!) {
        UIAlertViewTool.getInstance().showAutoDismisDialog("获取数据失败！", width: 210, height: 120)
    }
    
    func onDataReturnWithJavaUtilArrayList(mTempleList: JavaUtilArrayList!) {
        templist = mTempleList
        tableView.reloadData()
    }
    

    override func getXibName() -> String {
        return "SelectFollowUpTemplateViewController"
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("SelectFollowUpTemplateTableViewCell") as? SelectFollowUpTemplateTableViewCell
        if (cell == nil) {
            let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("SelectFollowUpTemplateTableViewCell", owner: self, options: nil)
            cell = nibs.lastObject as? SelectFollowUpTemplateTableViewCell
        }
        let mFollowUpTemple:ComFqHalcyonEntityFollowUpTemple = templist.getWithInt(Int32(indexPath.row)) as! ComFqHalcyonEntityFollowUpTemple
        
        cell?.followUpTemplateName.text = mFollowUpTemple.getTempleName()

        return cell!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  Int(templist.size())
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let mFollowUpTemple:ComFqHalcyonEntityFollowUpTemple = templist.getWithInt(Int32(indexPath.row)) as! ComFqHalcyonEntityFollowUpTemple
        let controller:SettingFollowUpViewController! = SettingFollowUpViewController()
        controller.mPatient = mPatient
        controller.followUpTemple = mFollowUpTemple
        self.navigationController?.pushViewController(controller, animated: true)
    }
   
}
