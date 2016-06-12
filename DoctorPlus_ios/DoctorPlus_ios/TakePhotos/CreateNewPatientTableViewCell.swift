//
//  CreateNewPatientTableViewCell.swift
//  DoctorPlus_ios
//
//  Created by Monkey on 15/12/24.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import UIKit

class CreateNewPatientTableViewCell: UITableViewCell {

    
    @IBOutlet weak var typeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(type:String) {
        typeLabel.text = type
    }
}
