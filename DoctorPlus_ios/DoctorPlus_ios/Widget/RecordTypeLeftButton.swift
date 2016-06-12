//
//  RecordTypeLeftButton.swift
//  TestSwift
//
//  Created by 王曦 on 15/12/8.
//  Copyright © 2015年 王曦. All rights reserved.
//

import Foundation
import UIKit
class RecordTypeLeftButton:UIButton {
    var btnNormalBackGroudImage:UIImage!
    var btnNotEnableBackGroudImage:UIImage!
    init(frame: CGRect,tittle:String) {
        super.init(frame: frame)
        btnNormalBackGroudImage = UIImage(imageLiteral: "circle_black_solid.png")
        btnNotEnableBackGroudImage = UIImage(imageLiteral: "circle_gray_hollow.png")
        initBtnBackGroudWithTittle(tittle)
    }
    
    func initBtnBackGroudWithTittle(tittle:String){
        self.setBackgroundImage(btnNormalBackGroudImage, forState: UIControlState.Normal)
        self.setBackgroundImage(UITools.imageByApplyingAlpha(0.7, image: btnNormalBackGroudImage), forState: UIControlState.Highlighted)
        self.setBackgroundImage(btnNotEnableBackGroudImage, forState: UIControlState.Disabled)
        self.setTitle(tittle, forState: UIControlState.Normal)
        self.titleLabel?.font = UIFont.systemFontOfSize(12.0)
        self.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.setTitleColor(UITools.colorWithHexString("#c1c1c1"), forState: UIControlState.Disabled)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}