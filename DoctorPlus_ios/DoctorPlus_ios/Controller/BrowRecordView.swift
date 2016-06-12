//
//  BrowRecordView.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-5-19.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit
import Foundation
class BrowRecordView: UIView {

    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var detail: UILabel!
    @IBOutlet weak var sType: UILabel!
    @IBOutlet weak var timer: UILabel!
    @IBOutlet weak var blackView: UIView!
    @IBOutlet weak var recognizing: UILabel!
    @IBOutlet weak var nothing: UILabel!
    @IBOutlet weak var line: UILabel!
    override init(frame: CGRect) {
        super.init(frame: frame)
        let view = NSBundle.mainBundle().loadNibNamed("BrowRecordView", owner: self, options: nil)[0] as! UIView
        view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height)
        self.addSubview(view)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   
}
