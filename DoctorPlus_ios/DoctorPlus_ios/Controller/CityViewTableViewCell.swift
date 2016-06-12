//
//  CityViewTableViewCell.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/7/17.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class CityViewTableViewCell: UITableViewCell {

    @IBOutlet weak var rightIcon: UIImageView!
    @IBOutlet weak var cityName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        cityName.textColor = UITools.colorWithHexString("#666666")
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
