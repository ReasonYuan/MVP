//
//  ContactSearchTableViewCell.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/5/12.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class ContactSearchTableViewCell: UITableViewCell {

    @IBOutlet weak var headImage: UIImageView!
    @IBOutlet weak var headKuang: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var headBtn: UIButton!
    @IBOutlet weak var addBtn: UIButton!
    
    @IBOutlet weak var roletypeIcon: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
