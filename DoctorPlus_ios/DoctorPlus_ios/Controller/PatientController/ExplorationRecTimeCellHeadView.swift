//
//  ExplorationRecTimeCellHeadView.swift
//  DoctorPlus_ios
//
//  Created by monkey on 15-7-19.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class ExplorationRecTimeCellHeadView: UIView {

    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let view = NSBundle.mainBundle().loadNibNamed("ExplorationRecTimeCellHeadView", owner: self, options: nil)[0] as! UIView
        view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height)
        self.addSubview(view)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
