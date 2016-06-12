//
//  ContactsTableViewCell.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/5/11.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class ContactsTableViewCell: UITableViewCell {

    @IBOutlet weak var contactsHeadImage: UIImageView!
    @IBOutlet weak var contactsName: UILabel!
    @IBOutlet weak var roletypeIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
