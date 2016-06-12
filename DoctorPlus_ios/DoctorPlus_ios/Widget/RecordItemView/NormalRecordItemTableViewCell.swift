//
//  NormalRecordItemTableViewCell.swift
//  DoctorPlus_ios
//
//  Created by monkey on 15-5-22.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

let EDIT_MODEL_KEY = "change_model"

class NormalRecordItemTableViewCell: UITableViewCell{

    
    @IBOutlet weak var recordItemTitle: UILabel!
    @IBOutlet weak var recordItemContent: UITextView!
    var tableView:UITableView?
    override func awakeFromNib() {
        super.awakeFromNib()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onModelChanged:", name:EDIT_MODEL_KEY, object: nil)
        recordItemContent.userInteractionEnabled = false
        // Initialization code
    }
    
    func onModelChanged(notification:NSNotification){
        self.recordItemContent.userInteractionEnabled = notification.object as! Bool
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}
