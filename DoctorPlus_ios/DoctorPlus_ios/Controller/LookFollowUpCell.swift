//
//  LookFollowUpCell.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-5-14.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class LookFollowUpCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var roleType: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var name: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
