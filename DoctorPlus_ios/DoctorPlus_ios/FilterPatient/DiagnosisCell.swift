//
//  DiagnosisCell.swift
//  DoctorPlus_ios
//
//  Created by 王曦 on 15/12/16.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import UIKit

class DiagnosisCell: UITableViewCell {

    @IBOutlet weak var tittle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        UITools.setRoundBounds(2.0, view: tittle)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
