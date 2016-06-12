//
//  RecordTableViewCell.swift
//  DoctorPlus_ios
//
//  Created by monkey on 15-5-12.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class RecordTableViewCell: UITableViewCell {
    @IBOutlet weak var recordFolderName: UILabel!
    @IBOutlet weak var imgBg: UIImageView!
    @IBOutlet weak var recordType: UIImageView!
    @IBOutlet weak var shareFrom: UILabel!
    @IBOutlet weak var fromLine: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var surveyRecord: UIButton!
    @IBOutlet weak var unRecongLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
