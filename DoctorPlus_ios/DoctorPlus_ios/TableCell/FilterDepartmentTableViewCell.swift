//
//  FilterDepartmentTableViewCell.swift
//  DoctorPlus_ios
//
//  Created by monkey on 15-7-1.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class FilterDepartmentTableViewCell: UITableViewCell {

    @IBOutlet weak var selectedImg: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
