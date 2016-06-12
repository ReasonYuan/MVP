//
//  PatientSearchCellHeadView.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-7-13.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class PatientSearchCellHeadView: UIView {
    var tmpHeight:CGFloat = 0.0
    @IBOutlet weak var headIcon: UIImageView!
    @IBOutlet weak var type: UILabel!
    var section :Int = 0
    var row :Int = 0
    override init(frame: CGRect) {
        super.init(frame: frame)
        let view = NSBundle.mainBundle().loadNibNamed("PatientSearchCellHeadView", owner: self, options: nil)[0] as! UIView
        view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height)
        tmpHeight = frame.size.height
        self.addSubview(view)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
