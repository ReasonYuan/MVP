//
//  HotHospitalTableViewCell.swift
//  DoctorPlus_ios
//
//  Created by monkey on 15-5-4.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class HotHospitalTableViewCell: UITableViewCell {


    @IBOutlet weak var mHospitalName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        mHospitalName.textColor = UITools.colorWithHexString("#666666")
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
