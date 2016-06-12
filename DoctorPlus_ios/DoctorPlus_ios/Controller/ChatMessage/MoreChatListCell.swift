//
//  MoreChatListCell.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-7-7.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class MoreChatListCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var head: UIImageView!
    @IBOutlet weak var lastMessage: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var messageCount: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        for view in self.subviews {
//            if object_getClassName(view) == "UITablewViewCellDeleteConfirmationView" {
//                (view.subviews.first as UIView).backgroundColor = Color.color_violet
//            }
//        }
//    }
//    
//    override func willTransitionToState(state: UITableViewCellStateMask) {
//        super.willTransitionToState(state)
//        if state & UITableViewCellStateMask.ShowingDeleteConfirmationMask == UITableViewCellStateMask.ShowingDeleteConfirmationMask {
//            for view in self.subviews {
//                
//                if NSStringFromClass(view.classForCoder) == "UITableViewCellContentView" {
//                    (view.subviews.last as UIView).backgroundColor = Color.color_violet
//                }
//            }
//        }
//    }
}
