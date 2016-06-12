//
//  UserDescriptionViewController.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-5-14.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class UserDescriptionViewController: BaseViewController {
    var descriptionText:String = ""
    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setTittle("个人简介")
        hiddenRightImage(true)
        textView.text = descriptionText
        setBorderWidth()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func getXibName() -> String {
        return "UserDescriptionViewController"
    }
    
    func setBorderWidth(){
        textView.layer.backgroundColor = UIColor.whiteColor().CGColor
        textView.layer.borderColor = UIColor.blackColor().CGColor
        textView.layer.borderWidth = 1.0
    }
}
