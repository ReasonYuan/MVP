//
//  UnnormalExamTableViewCell.swift
//  DoctorPlus_ios
//
//  Created by monkey on 15-5-27.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class UnnormalExamTableViewCell: UITableViewCell {

    var titleLabelBg = UILabel()
    var labelList = [UILabel]()
    var labelWidth = 140
    var labelHeight = 30
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCellStyle(labelCount:Int){
        for i in 0..<labelCount{
            let labelX = i * labelWidth
            let label = UILabel(frame: CGRectMake(CGFloat(labelX), 0, CGFloat(labelWidth), CGFloat(labelHeight)))
            label.font = UIFont.systemFontOfSize(12)
            label.textAlignment = NSTextAlignment.Center
            label.layer.borderWidth = 0.5
            label.layer.borderColor = Color.color_grey.CGColor
            self.contentView.addSubview(label)
            labelList.append(label)
        }
    }
    
}
