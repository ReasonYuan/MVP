//
//  progressView.swift
//  DoctorPlus_ios
//
//  Created by sunning on 15/12/25.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import UIKit

class progressView: UIView{

    @IBOutlet weak var progressLabel: UILabel!

    @IBOutlet weak var imageView: UIImageView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("progressView", owner: self, options: nil)
        let view = nibs.lastObject as! UIView
        view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height )
        imageView.hidden = true
        progressLabel.hidden = true
        self.alpha = 1.0
        self.userInteractionEnabled = false
        self.addSubview(view)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
