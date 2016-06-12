//
//  ManageViewController.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/7/21.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class ManageViewController: BaseViewController {

    @IBOutlet weak var headKuang: UIImageView!
    @IBOutlet weak var headImg: UIImageView!
    var contact:ComFqHalcyonEntityContacts!
    override func viewDidLoad() {
        super.viewDidLoad()
        setTittle("管理")
        hiddenRightImage(true)
        UITools.setBorderWithHeadKuang(headKuang)
        let rect:CGRect? = headImg.bounds
        UITools.setRoundBounds(CGRectGetHeight(rect!)/2, view: headImg)

        let photo:ComFqHalcyonEntityPhoto! = ComFqHalcyonEntityPhoto()
        photo.setImageIdWithInt(contact.getImageId())
        ApiSystem.getHeadImageWithComFqHalcyonEntityPhoto(photo, withComFqLibCallbackICallback: WapperCallback(onCallback: { (data) -> Void in
            let path:NSString? = data as? NSString
            if(path != nil){
                self.headImg.image = UITools.getImageFromFile(path!)
            }
        }), withBoolean: false, withInt: Int32(2))

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func getXibName() -> String {
        return "ManageViewController"
    }
    
    @IBAction func addContacts(sender: AnyObject) {
        let controller = SelectContactViewController()
        controller.isCreatGroup = true

        controller.ints = JavaUtilArrayList()
        controller.ints.addWithId(JavaLangInteger(int: contact.getUserId()))
        controller.contacts = contact
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
