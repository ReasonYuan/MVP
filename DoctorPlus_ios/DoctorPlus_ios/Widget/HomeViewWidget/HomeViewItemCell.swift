//
//  HomeViewItemCell.swift
//  DoctorPlus_ios
//
//  Created by 廖敏 on 15/4/28.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class HomeViewItemCell: UICollectionViewCell {

    var mButton: UIButton!
    
    @IBOutlet weak var meffect: UIImageView!
    
    init() {
        super.init(frame:CGRectZero)
        self.onCreate()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.onCreate()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.onCreate()
    }
    
    func onCreate(){
        mButton = UIButton(type: UIButtonType.Custom)
        mButton.layer.borderWidth = 1
        mButton.layer.borderColor = Color.color_emerald.CGColor
    }
    
    func reSet(){
        mButton.setBackgroundImage(nil, forState: UIControlState.Normal)
        meffect.hidden = true
    }
    
    func showUnreadEffect(show:Bool){
        meffect.hidden = !show
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.addSubview(mButton)
//        HomeViewItemCell.addChildConstraints(mButton as UIView, parent: self.contentView, margin: 5)
    }


    override func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        if newSuperview != nil {
            let margin:CGFloat = 2 + 5*self.frame.size.width/70;
            mButton.frame = CGRectMake(margin, margin, self.frame.size.width - margin*2 , self.frame.size.height - margin*2)
            UITools.setRoundBounds(self.frame.size.width/6, view: mButton)
        }
    }
    
    
}
