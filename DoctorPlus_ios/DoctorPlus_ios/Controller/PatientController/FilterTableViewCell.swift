//
//  FilterTableViewCell.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/7/16.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class FilterTableViewCell: UITableViewCell {

    @IBOutlet weak var firstIcon: UIButton!
    @IBOutlet weak var secondIcon: UIButton!
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var thirdIcon: UIButton!
    @IBOutlet weak var thirdLabel: UILabel!
    
    var items = [ComFqHalcyonEntityPracticeFilterItem]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    @IBAction func first(sender: AnyObject) {
        isSelected(sender as! UIButton, idx:0)
    }
    
    @IBAction func second(sender: AnyObject) {
        isSelected(sender as! UIButton, idx:1)
    }
    
    @IBAction func third(sender: AnyObject) {
        isSelected(sender as! UIButton, idx:2)
    }
    func isSelected(sender: UIButton, idx:Int){
        if sender.selected {
            sender.selected = false
            sender.setBackgroundImage(UIImage(named: "friend_unselect.png"), forState: UIControlState.Normal)
        }else{
            sender.setBackgroundImage(UIImage(named: "friend_select.png"), forState: UIControlState.Normal)
            sender.selected = true
        }
        items[idx].setSelectedWithBoolean(sender.selected)
        NSNotificationCenter.defaultCenter().postNotificationName("FilterCellNotification", object: items[idx])
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
