//
//  PatientSearchRecordCell.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-7-13.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class PatientSearchRecordCell: UITableViewCell {

    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var content: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
