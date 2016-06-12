//
//  ChooseMemberViewController.swift
//  Care
//
//  Created by AppleBar on 15/8/27.
//  Copyright (c) 2015年 YiYiHealth. All rights reserved.
//

import UIKit

var relationShipInstance:ComFqHalcyonEntityPracticeMyRelationship?

class ChooseMemberViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource,ComFqHalcyonLogicPracticeGetMemberListLogic_GetMemberListCallBack{
     //MARK:-------------定义变量

    class func getRelationShipInstance()->ComFqHalcyonEntityPracticeMyRelationship?{
        return relationShipInstance
    }
    
    @IBOutlet weak var tableView: UITableView!
    var suffererEntity: ComFqHalcyonEntityPracticeSuffererAbstract!
    var relationshipArray = [ComFqHalcyonEntityPracticeMyRelationship]()
    var index = -1
    var patientListlogic : ComFqHalcyonLogicPracticePatientUpdateListLogic!
    //MARK:-------------初始化
    override func viewDidLoad() {
        super.viewDidLoad()
        getMemberListLogic()
        let title = suffererEntity.getSuffererName()
        setTittle(title == nil ? "":title)
        hiddenRightImage(true)
        tableView.registerNib(UINib(nibName: "ChooseMemberTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "ChooseMemberTableViewCell")
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.backgroundColor = UIColor(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha:1.0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func getXibName() -> String {
        return "ChooseMemberViewController"
    }

    // MARK:-------------调用 获取成员列表 接口
     func getMemberListLogic(){
        let logic = ComFqHalcyonLogicPracticeGetMemberListLogic(comFqHalcyonLogicPracticeGetMemberListLogic_GetMemberListCallBack: self)
        logic.getMemberListWithInt(suffererEntity.getSuffererId())
    }
    


    
    // MARK:-------------tableview delegate&datasource method
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ChooseMemberTableViewCell") as? ChooseMemberTableViewCell
        cell?.nameLabel.text = relationshipArray[indexPath.row].getRelName()
        cell?.cellBtn.tag = indexPath.row
        cell?.cellBtn.addTarget(self, action: "btnClicked:", forControlEvents: UIControlEvents.TouchUpInside)
        let relations  = relationshipArray[indexPath.row].getIdentityId()
        switch relations {
        case 1:
            cell?.relationShipIcon.image = UIImage(named: "icon_relationship_me.png")
        case 2:
            cell?.relationShipIcon.image = UIImage(named: "icon_relationship_father.png")
        case 3:
            cell?.relationShipIcon.image = UIImage(named: "icon_relationship_mother.png")
        case 4:
            cell?.relationShipIcon.image = UIImage(named: "icon_relationship_fatherinlaw.png")
        case 5:
            cell?.relationShipIcon.image = UIImage(named: "icon_relationship_motherinlaw.png")
        case 6:
            cell?.relationShipIcon.image = UIImage(named: "icon_relationship_daughter.png")
        case 7:
            cell?.relationShipIcon.image = UIImage(named: "icon_relationship_son.png")
        case 8:
            cell?.relationShipIcon.image = UIImage(named: "icon_relationship_spouse.png")
        case 9:
            cell?.relationShipIcon.image = UIImage(named: "icon_relationship_grandson.png")
        case 10:
            cell?.relationShipIcon.image = UIImage(named: "icon_relationship_granddaughter.png")
        default:
            print("")
        }
        return cell!
    }
    
    func btnClicked(sender:AnyObject){
        index = sender.tag
        let controller = ExplorationRecordListViewController()
        let patientItem = ComFqHalcyonEntityPracticePatientAbstract()
        patientItem.setPatientIdWithInt(relationshipArray[index].getPatientId())
        controller.patientItem = patientItem
        controller.isMyPatientRecord = true
        relationShipInstance = relationshipArray[index]
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return relationshipArray.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        tableView.deselectRowAtIndexPath(indexPath, animated: true)
//        index = indexPath.row
//        var cell = tableView.cellForRowAtIndexPath(indexPath) as? ChooseMemberTableViewCell
//        var controller = ExplorationRecordListViewController()
//        var patientItem = ComFqHalcyonEntityPracticePatientAbstract()
//        patientItem.setPatientIdWithInt(relationshipArray[index].getPatientId())
//        controller.patientItem = patientItem
//        relationShipInstance = relationshipArray[index]
//        self.navigationController?.pushViewController(controller, animated: true)
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    //MARK: ----------the call back method of getmemberlistlogic
    func getMemberListErrorWithInt(errorCode: Int32, withNSString msg: String!) {
        FQToast.makeError().show("获取成员失败", superview: self.view)
    }
    
    func getMemberListSuccessWithJavaUtilArrayList(memberList: JavaUtilArrayList!) {
        let count = memberList.size()
        for var i:Int32 = 0 ; i < count ; i++ {
            relationshipArray.append(memberList.getWithInt(i) as! ComFqHalcyonEntityPracticeMyRelationship)
        }
        tableView.reloadData()
    }
  
    deinit{
        relationShipInstance = nil
    }
    
}
