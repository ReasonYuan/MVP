//
//  NormalExamTableViewCell.swift
//  DoctorPlus_ios
//
//  Created by monkey on 15-5-26.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class NormalExamTableViewCell: UITableViewCell {

    @IBOutlet weak var assayName: UILabel!
    @IBOutlet weak var assayResult: UILabel!
    @IBOutlet weak var assayRefvalue: UILabel!
    @IBOutlet weak var assayUnit: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
