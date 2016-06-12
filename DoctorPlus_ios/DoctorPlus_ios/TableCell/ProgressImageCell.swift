//
//  ProgressImageCell.swift
//  DoctorPlus_ios
//
//  Created by 王曦 on 15/12/9.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import UIKit

class ProgressImageCell: UITableViewCell {
//    var imageprogress:UIImageViewWithProgress?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        imageprogress = UIImageViewWithProgress(frame: CGRectMake(0, 0, ScreenWidth, 200))
        print("初始化cell")
//        self.contentView.addSubview(imageprogress!)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
