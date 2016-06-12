//
//  ChooseMemberTableViewCell.swift
//  Care
//
//  Created by AppleBar on 15/8/27.
//  Copyright (c) 2015年 YiYiHealth. All rights reserved.
//

import UIKit

class ChooseMemberTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var relationShipIcon: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    @IBOutlet weak var cellBtn: UIButton!
    
}
