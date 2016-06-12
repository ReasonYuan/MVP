//
//  SearchRecordItemViewController.swift
//  DoctorPlus_ios
//
//  Created by monkey on 15-7-6.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class SearchRecordItemViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setTittle("搜索病例记录")
        hiddenRightImage(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func getXibName() -> String {
        return "SearchRecordItemViewController"
    }
    
    @IBAction func filterRecordItemClickListener() {
        
        self.navigationController?.pushViewController(FilterRecordItemViewController(), animated: true)
    }
    
    
}
