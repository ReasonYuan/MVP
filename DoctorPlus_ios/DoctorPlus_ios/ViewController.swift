//
//  ViewController.swift
//  DoctorPlus_ios
//
//  Created by 廖敏 on 15/4/24.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.pushViewController(LoginViewController(nibName:"LoginViewController",bundle:nil), animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

