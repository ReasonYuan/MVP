//
//  FQControllerView.swift
//  DoctorPlus_ios
//
//  Created by monkey on 15-5-19.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

protocol FQControllerViewDelegate:NSObjectProtocol{
    
    func onShareBtnClickListener()
    func onRenameBtnClickListener()
    func onDelBtnClickListener()
}

class FQControllerView: UIView {

    weak var delegate:FQControllerViewDelegate?
    
    class func getInstance() -> FQControllerView{
        let nibView:NSArray = NSBundle.mainBundle().loadNibNamed("FQControllerView", owner: nil, options: nil)
        return nibView.objectAtIndex(0) as! FQControllerView
    }
    
    @IBAction func onShareBtnClick() {
        delegate?.onShareBtnClickListener()
    }
    
    
    @IBAction func onRenameBtnClick() {
        delegate?.onRenameBtnClickListener()
    }
    
    
    @IBAction func onDelBtnClick() {
        delegate?.onDelBtnClickListener()
    }
}
