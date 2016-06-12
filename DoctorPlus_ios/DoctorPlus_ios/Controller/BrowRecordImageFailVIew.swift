//
//  BrowRecordImageFailVIew.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-5-28.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class BrowRecordImageFailVIew: UIView {
    @IBOutlet weak var imageView: UIImageView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        let view = NSBundle.mainBundle().loadNibNamed("BrowRecordImageFailVIew", owner: self, options: nil)[0] as! UIView
        view.frame = CGRectMake(10, 0, frame.size.width - 20, frame.size.height)
        self.addSubview(view)
     
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}
