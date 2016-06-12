//
//  MyContactsPatientViewController.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/8/26.
//  Copyright (c) 2015年 YiYiHealth. All rights reserved.
//

import UIKit

class MyContactsPatientViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource{
    var contacts = JavaUtilArrayList()
    @IBOutlet weak var tabView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setTittle("我的患者")
        hiddenRightImage(true)
        contacts.addAllWithJavaUtilCollection(ComFqLibToolsConstants_contactsPatientList_)
        tabView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func getXibName() -> String {
        return "MyContactsPatientViewController"
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return Int(contacts.size())
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("ContactsTableViewCell") as? ContactsTableViewCell
        if cell == nil {
            let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("ContactsTableViewCell", owner: self, options: nil)
            cell = nibs.lastObject as? ContactsTableViewCell
        }
        UITools.setRoundBounds(20.0, view: cell!.contactsHeadImage)
        UITools.setBorderWithView(1.0, tmpColor: Color.color_grey.CGColor, view:  cell!.contactsHeadImage)
        
        let photo = ComFqHalcyonEntityPhoto()
        photo.setImageIdWithInt(contacts.getWithInt(Int32(indexPath.row)).getImageId())
        
        cell?.contactsHeadImage.downLoadImageWidthImageId(photo.getImageId(), callback: { (view, path) -> Void in
            let tmpImageView = view as! UIImageView
            tmpImageView.image = UITools.getImageFromFile(path)
        })
        cell?.contactsName.text = contacts.getWithInt(Int32(indexPath.row)).getUsername()
        if contacts.getWithInt(Int32(indexPath.row)).getRole_type() == 1 {
            cell?.roletypeIcon.image = UIImage(named: "icon_doctor.png")
        }else{
            cell?.roletypeIcon.image = UIImage(named: "icon_patient.png")
        }
        return cell!
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.view.endEditing(true)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let row = indexPath.row
        let controller = UserInfoViewController()
        controller.mUser = contacts.getWithInt(Int32(row)) as? ComFqHalcyonEntityPerson
        controller.isFriend = true
        controller.mRelationId = Int(contacts.getWithInt(Int32(row)).getRelationId())
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
