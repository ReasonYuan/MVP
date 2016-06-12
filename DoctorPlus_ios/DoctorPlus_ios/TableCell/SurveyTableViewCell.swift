//
//  SurveyTableViewCell.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/5/19.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class SurveyTableViewCell: UITableViewCell {

    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var keyLabel: UILabel!
    @IBOutlet weak var bottomLine: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
