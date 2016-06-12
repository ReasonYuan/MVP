//
//  PatientSearchPatientCell.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-7-13.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class PatientSearchPatientCell: UITableViewCell {

   
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var count: UILabel!
    @IBOutlet weak var head: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
