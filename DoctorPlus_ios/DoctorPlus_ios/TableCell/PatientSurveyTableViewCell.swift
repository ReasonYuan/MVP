//
//  PatientSurveyTableViewCell.swift
//  DoctorPlus_ios
//
//  Created by monkey on 15-5-20.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class PatientSurveyTableViewCell: UITableViewCell {

    
    @IBOutlet weak var patientName: UILabel!
    @IBOutlet weak var tentativeDiag: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
