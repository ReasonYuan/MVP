//
//  TrashCell.swift
//  DoctorPlus_ios
//
//  Created by 廖敏 on 15/7/1.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class TrashCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var deleteBtn: UIButton!
    
    @IBOutlet weak var resumeBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
