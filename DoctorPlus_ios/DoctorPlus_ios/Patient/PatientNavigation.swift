//
//  PatientNavigation.swift
//  DoctorPlus_ios
//
//  Created by Monkey on 15/11/27.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import Foundation

protocol PatientNavigationDelegate : NSObjectProtocol{
    func selectChanged(selectedType:PatientNavigationSelectedType)
}

enum PatientNavigationSelectedType {
    
    case MyPatient
    case Recycle
}

class PatientNavigation:UIView {
    
    @IBOutlet weak var mypatientBtn: UIButton!
    @IBOutlet weak var mypatientLabel: UILabel!
    @IBOutlet weak var recycleBtn: UIButton!
    @IBOutlet weak var recycleLable: UILabel!
    
    var btnArray = [UIButton]()
    var labelArray = [UILabel]()
    var clickEnable = true
    weak var delegate:PatientNavigationDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("PatientNavigation", owner: self, options: nil)
        let view = nibs.lastObject as! UIView
        view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height)
        self.addSubview(view)
        
        initInfo()
    }
    
    func initInfo() {
        btnArray.append(mypatientBtn)
        btnArray.append(recycleBtn)
        labelArray.append(mypatientLabel)
        labelArray.append(recycleLable)
        
        mypatientBtn.selected = true
        selectedCtrl(mypatientBtn)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func btnClickListener(sender: UIButton) {
        selectedCtrl(sender)
    }
    
    func selectedCtrl(btn:UIButton) {
        
        if !clickEnable {
            return
        }
        
        if btn.selected {
            return
        }
        
        for (index,item) in btnArray.enumerate() {
            item.selected = false
            labelArray[index].hidden = true
        }
        
        switch btn {
        case mypatientBtn:
            mypatientBtn.selected = true
            mypatientLabel.hidden = false
            delegate?.selectChanged(.MyPatient)
        case recycleBtn:
            recycleBtn.selected = true
            recycleLable.hidden = false
            delegate?.selectChanged(.Recycle)
        default:
            break
        }
    }
    
}
