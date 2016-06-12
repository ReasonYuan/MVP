//
//  SavedSearchResultTableViewCell.swift
//  DoctorPlus_ios
//
//  Created by Monkey on 15/12/16.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import UIKit

class SavedSearchResultTableViewCell: UITableViewCell {

    @IBOutlet weak var savedNameLabel: UILabel!
    @IBOutlet weak var visualBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(name:String) {
        savedNameLabel.text = name
    }
}
