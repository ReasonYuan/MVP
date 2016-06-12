//
//  PatientShareTableViewCell.swift
//  DoctorPlus_ios
//
//  Created by monkey on 15-5-11.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class PatientShareTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var patientTime: UILabel!
    @IBOutlet weak var recordCount: UILabel!
    @IBOutlet weak var patientFrom: UILabel!
    @IBOutlet weak var patientName: UILabel!
    @IBOutlet weak var overviewBtn: UIButton!
    @IBOutlet weak var bgImg: UIImageView!
    @IBOutlet weak var cutLineLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgImg.image = Tools.createNinePathImageForImage(UIImage(named: "patient_normal_unselected.png"), leftMargin: 40, rightMargin: 40, topMargin: 50, bottomMargin: 10)
        bgImg.highlightedImage = Tools.createNinePathImageForImage(UIImage(named: "patient_normal_selected.png"), leftMargin: 40, rightMargin: 40, topMargin: 50, bottomMargin: 10)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
