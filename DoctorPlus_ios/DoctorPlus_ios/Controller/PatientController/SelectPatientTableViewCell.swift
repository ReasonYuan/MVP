//
//  SelectPatientTableViewCell.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/7/16.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

protocol SelectPatientTableViewCellDelegate:NSObjectProtocol
{
    func onCheckboxClick(cell:SelectPatientTableViewCell)
}

class SelectPatientTableViewCell: UITableViewCell {

    @IBOutlet weak var firstShowLabel: UILabel!

    @IBOutlet weak var touchView: UIView!
    @IBOutlet weak var secondShowLabel: UILabel!
    @IBOutlet weak var iconBtn: UIImageView!
    @IBOutlet weak var thirdShowLabel: UILabel!

    weak var delegate:SelectPatientTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    

    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var headIcon: UIImageView!
    
    @IBAction func onCheckBoxChick(sender: AnyObject) {
        if(delegate != nil) {
           delegate?.onCheckboxClick(self)
        }
    }
}
