//
//  FilterPatientViewController.swift
//  DoctorPlus_ios
//
//  Created by monkey on 15-7-6.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class FilterPatientViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setTittle("筛选病案")
        setRightBtnTittle("确认")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func getXibName() -> String {
        return "FilterPatientViewController"
    }
    
    @IBAction func clickListener1(sender: UIButton) {
        isSelected(sender)
    }
    
    @IBAction func clickListener2(sender: UIButton) {
        isSelected(sender)
    }
    
    @IBAction func clickListener3(sender: UIButton) {
        isSelected(sender)
    }
    
    @IBAction func clickListener4(sender: UIButton) {
        isSelected(sender)
    }
    
    @IBAction func clickListener5(sender: UIButton) {
        isSelected(sender)
    }
    
    func isSelected(sender: UIButton){
        if sender.selected {
            sender.selected = false
        }else{
            sender.selected = true
        }
    }
    
    override func onRightBtnOnClick(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
