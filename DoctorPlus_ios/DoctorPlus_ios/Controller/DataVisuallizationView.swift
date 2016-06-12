//
//  DataVisuallizationView.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-5-22.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class DataVisuallizationView: UIView {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tittle: UILabel!
    override init(frame: CGRect) {
        super.init(frame: frame)
        let view = NSBundle.mainBundle().loadNibNamed("DataVisuallizationView", owner: self, options: nil)[0] as! UIView
        view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height)
        self.addSubview(view)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
