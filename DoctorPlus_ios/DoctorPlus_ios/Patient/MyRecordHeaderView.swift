//
//  MyRecordHeaderView.swift
//  DoctorPlus_ios
//
//  Created by Monkey on 15/12/4.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import UIKit

protocol MyRecordHeaderViewDelegate : NSObjectProtocol {

    func onSectionBtnClickListener(section:Int)
    
}

class MyRecordHeaderView: UIView {
    
    @IBOutlet weak var recordTypeLabel: UILabel!
    @IBOutlet weak var disclosureBtn: UIButton!
    
    var delegate:MyRecordHeaderViewDelegate!
    var section:Int!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("MyRecordHeaderView", owner: self, options: nil)
        let view = nibs.lastObject as! UIView
        view.frame = frame
        self.addSubview(view)
        let tapGesture = UITapGestureRecognizer(target: self, action: "btnTap:")
        self.addGestureRecognizer(tapGesture)
        disclosureBtn.addGestureRecognizer(tapGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func btnTap(sender: UITapGestureRecognizer) {
        delegate.onSectionBtnClickListener(section)
    }
    

}
