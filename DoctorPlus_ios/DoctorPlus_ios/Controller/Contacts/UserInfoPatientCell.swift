//
//  UserInfoPatientCell.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-5-13.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class UserInfoPatientCell: UITableViewCell {

    @IBOutlet weak var tittle: UILabel!
    @IBOutlet weak var detail: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
