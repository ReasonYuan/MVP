//
//  TimeHeaderView.swift
//  DoctorPlus_ios
//
//  Created by Monkey on 15/11/30.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import UIKit

class TimeHeaderView: UIView {

    @IBOutlet weak var timeLable: UILabel!
    override init(frame: CGRect) {
        super.init(frame: frame)
        let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("TimeHeaderView", owner: self, options: nil)
        let view = nibs.lastObject as! UIView
        view.frame = frame
        self.addSubview(view)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
