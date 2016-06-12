//
//  SelectContactsTableViewCell.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/7/16.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class SelectContactsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var selectedImageview: UIImageView!
    @IBOutlet weak var headKuang: UIImageView!
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bottomLine: UILabel!
    @IBOutlet weak var roletypeIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
