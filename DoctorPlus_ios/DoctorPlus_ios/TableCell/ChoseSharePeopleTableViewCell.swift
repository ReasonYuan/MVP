//
//  ChoseSharePeopleTableViewCell.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/5/20.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class ChoseSharePeopleTableViewCell: UITableViewCell {

    @IBOutlet weak var selectedImageview: UIImageView!
    @IBOutlet weak var headKuang: UIImageView!
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bottomLine: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
