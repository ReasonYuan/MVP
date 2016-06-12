//
//  BrowRecordTopItem.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-5-19.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class BrowRecordTopItem: UIView {
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var centerLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    override init(frame: CGRect) {
        super.init(frame: frame)
        let view = NSBundle.mainBundle().loadNibNamed("BrowRecordTopItem", owner: self, options: nil)[0] as! UIView
        view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height)
        self.addSubview(view)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  

}
