//
//  ChatProgressView.swift
//  DoctorPlus_ios
//
//  Created by 王曦 on 15/12/3.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import Foundation
class ChatProgressView:UIView {
    let progressWidth:CGFloat = 40.0
    let progressHeight:CGFloat = 40.0
    var progressLabel:UILabel!
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(red: 76/255.0, green: 79/255.0, blue: 87/255.0, alpha: 0.7)
//        self.alpha = 0.5
        progressLabel = UILabel(frame: CGRectMake(frame.width/2 - progressWidth/2 + 5,frame.height/2 - progressHeight/2,progressWidth,progressHeight))
        progressLabel.textColor = UIColor.whiteColor()
        progressLabel.text = "0%"
        progressLabel.font = UIFont.systemFontOfSize(15.0)
        addSubview(progressLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}