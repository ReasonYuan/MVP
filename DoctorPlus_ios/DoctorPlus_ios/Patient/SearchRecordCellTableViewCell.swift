//
//  SearchRecordCellTableViewCell.swift
//  DoctorPlus_ios
//
//  Created by sunning on 15/12/4.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import UIKit

protocol SearchRecordCellTableViewCellDelegate : NSObjectProtocol {
    func SearchRecordCellSelected(isSelected:Bool,section:Int,index:Int)
}

class SearchRecordCellTableViewCell: UITableViewCell {

    @IBOutlet weak var recordSelectBtn: UIButton!
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var recordTitleLabel: UILabel!
    
    @IBOutlet weak var recordAbstractTitleLabel: UILabel!
    var delegate: SearchRecordCellTableViewCellDelegate?
    @IBOutlet weak var recordAbstractTextView: myUILabel!
    @IBOutlet weak var downLoadIcon: UIImageView!
    @IBOutlet weak var attachmentIcon: UIImageView!
    var section:Int!
    var index:Int!
    override func awakeFromNib() {
        super.awakeFromNib()
        recordAbstractTextView.lineBreakMode = NSLineBreakMode.ByWordWrapping
        recordAbstractTextView.numberOfLines = 0
        recordAbstractTextView.verticalAlignment = VerticalAlignmentTop
        if recordSelectBtn.selected {
            recordSelectBtn.setImage(UIImage(named: "friend_select.png"), forState: UIControlState.Normal)
        }else{
            recordSelectBtn.setImage(UIImage(named: "friend_unselect.png"), forState: UIControlState.Normal)
        }
        view.backgroundColor = UIColor(red: 222.0/255.0, green: 222.0/255.0, blue: 222.0/255.0, alpha: 1)
    }

    @IBAction func btnClicked(sender: AnyObject) {
        isSelect(sender as! UIButton)
    }
    
    
    func isSelect(sender: UIButton){
        if sender.selected {
            sender.setImage(UIImage(named: "friend_unselect.png"), forState: UIControlState.Normal)
            sender.selected = false
            delegate!.SearchRecordCellSelected(false, section: section, index: index)
        }else{
            recordSelectBtn.setImage(UIImage(named: "friend_select.png"), forState: UIControlState.Normal)
            sender.selected = true
            delegate!.SearchRecordCellSelected(true, section: section, index: index)
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
