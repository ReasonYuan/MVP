//
//  AllRecordCell.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-6-1.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class AllRecordCell: UITableViewCell {


    @IBOutlet weak var icon4: UIImageView!
    @IBOutlet weak var icon3: UIImageView!
    @IBOutlet weak var icon2: UIImageView!
    @IBOutlet weak var icon1: UIImageView!
    @IBOutlet weak var btn4: UIButton!
    @IBOutlet weak var btn3: UIButton!
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var view4: UIView!
    @IBOutlet weak var view3: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view1: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        UITools.setRoundBounds(5.0, view: btn1)
        UITools.setRoundBounds(5.0, view: btn2)
        UITools.setRoundBounds(5.0, view: btn3)
        UITools.setRoundBounds(5.0, view: btn4)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
