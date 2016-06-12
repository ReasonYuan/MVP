//
//  PatientSearchCellFooterView.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-7-13.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class PatientSearchCellFooterView: UIView {
    var tmpHeight:CGFloat = 0.0
    var section :Int = 0
    var row :Int = 0
    @IBOutlet weak var more: UILabel!
    override init(frame: CGRect) {
        super.init(frame: frame)
        let view = NSBundle.mainBundle().loadNibNamed("PatientSearchCellFooterView", owner: self, options: nil)[0] as! UIView
        view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height)
        tmpHeight = frame.size.height
        self.addSubview(view)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
