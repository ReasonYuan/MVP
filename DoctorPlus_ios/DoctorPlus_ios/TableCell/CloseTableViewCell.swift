//
//  CloseTableViewCell.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/5/25.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class CloseTableViewCell: UITableViewCell {
    
    @IBOutlet weak var rightCountLabel: UILabel!
    @IBOutlet weak var rightStatusLabel: UILabel!
    @IBOutlet weak var rightTimeLabel: UILabel!
    @IBOutlet weak var leftCountLabel: UILabel!
    @IBOutlet weak var leftStatusLabel: UILabel!
    @IBOutlet weak var leftTimeLabel: UILabel!
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var rightView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setTextSize(timeSize:CGFloat,countSize:CGFloat,statusSize:CGFloat){
        rightTimeLabel.font = UIFont.systemFontOfSize(timeSize)
        leftTimeLabel.font = UIFont.systemFontOfSize(timeSize)
        rightCountLabel.font = UIFont.systemFontOfSize(countSize)
        leftCountLabel.font = UIFont.systemFontOfSize(countSize)
        leftStatusLabel.font  = UIFont.systemFontOfSize(statusSize)
        rightStatusLabel.font  = UIFont.systemFontOfSize(statusSize)
    }
    
}
