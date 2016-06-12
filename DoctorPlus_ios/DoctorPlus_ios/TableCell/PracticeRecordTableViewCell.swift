//
//  PracticeRecordTableViewCell.swift
//  DoctorPlus_ios
//
//  Created by monkey on 15-7-3.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class PracticeRecordTableViewCell: UITableViewCell {

    
    @IBOutlet weak var recordTypeName: UILabel!
    @IBOutlet weak var abstruteLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
