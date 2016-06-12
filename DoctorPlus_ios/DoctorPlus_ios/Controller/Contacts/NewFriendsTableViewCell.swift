//
//  NewFriendsTableViewCell.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/5/12.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class NewFriendsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var otherRefuse: UIButton!
    @IBOutlet weak var otherAccept: UIButton!
    @IBOutlet weak var refuseBtn: UIButton!
    @IBOutlet weak var acceptBtn: UIButton!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var msgLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var headKuang: UIImageView!
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var roletypeIcon: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    /**是否隐藏btn*/
    func hiddenBtn(yes:Bool){
        refuseBtn.hidden = yes
        acceptBtn.hidden = yes
    }
    /**是否隐藏otherbtn*/
    func hiddenoOtherBtn(yes:Bool){
        otherRefuse.hidden = yes
        otherAccept.hidden = yes
    }
    
    /**给statelabel设字并显示*/
    func setLabelText(str:String){
        stateLabel.hidden = false
        stateLabel.text = str
    }
    /**隐藏statuslabel*/
    func hiddenLabel(){
        stateLabel.hidden = true
    }
        
}
