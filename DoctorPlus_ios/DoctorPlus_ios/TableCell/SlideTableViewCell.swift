//
//  SlideTableViewCell.swift
//  DoctorPlus_ios
//
//  Created by liaomin on 15-7-21.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class SlideTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
       //self.backgroundColor = UIColor(red: 92/255.0, green: 92/255.0, blue: 92/255.0, alpha: 0.85)
    
        // Initialization code
     }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
