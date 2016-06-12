//
//  SearchPatientHeadView.swift
//  DoctorPlus_ios
//
//  Created by sunning on 15/12/11.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import UIKit

protocol SearchPatientHeadViewDelegate : NSObjectProtocol {
    
    func opendSearchPatientHeadView(searchPatientHeadView: SearchPatientHeadView, sectionOpened: Int)
    func closedSearchPatientHeadView(searchPatientHeadView: SearchPatientHeadView, sectionClosed: Int)
    func headViewClicked(searchPatientHeadView: SearchPatientHeadView, sectionClicked: Int)
    func headViewSelected(searchPatientHeadView: SearchPatientHeadView, sectionSelected: Int,isSelected:Bool)
}

class SearchPatientHeadView: UIView {

    @IBOutlet weak var patientSelectBtn: UIButton!
    @IBOutlet weak var recordAbstractLabel: myUILabel!
    @IBOutlet weak var recordTitleLabel: UILabel!
    @IBOutlet weak var patientTitleLabel: UILabel!
    @IBOutlet weak var statusIcon: UIImageView!
    @IBOutlet weak var headIcon: UIImageView!
    
    var delegate:SearchPatientHeadViewDelegate!
    var section:Int!
    var HeaderOpen = false
    @IBAction func btnClicked(sender: AnyObject) {
        isSelect(sender as! UIButton)
    }
    
    func isSelect(sender: UIButton){
        if sender.selected {
            sender.setImage(UIImage(named: "friend_unselect.png"), forState: UIControlState.Normal)
            sender.selected = false
            delegate.headViewSelected(self, sectionSelected: section,isSelected: false)
        }else{
            patientSelectBtn.setImage(UIImage(named: "friend_select.png"), forState: UIControlState.Normal)
            sender.selected = true
            delegate.headViewSelected(self, sectionSelected: section,isSelected: true)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("SearchPatientHeadView", owner: self, options: nil)
        let view = nibs.lastObject as! UIView
        view.frame = frame
        let tapGesture = UITapGestureRecognizer(target: self, action: "btnTap:")
        self.addGestureRecognizer(tapGesture)
        self.backgroundColor = UIColor(red: CGFloat(241.0/255.0), green: CGFloat(241.0/255.0), blue: CGFloat(241.0/255.0), alpha: CGFloat(1))
        recordAbstractLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        recordAbstractLabel.numberOfLines = 0
        recordAbstractLabel.verticalAlignment = VerticalAlignmentTop
        if patientSelectBtn.selected {
            patientSelectBtn.setImage(UIImage(named: "friend_select.png"), forState: UIControlState.Normal)
        }else{
            patientSelectBtn.setImage(UIImage(named: "friend_unselect.png"), forState: UIControlState.Normal)
        }
        self.addSubview(view)
    }
    
    func btnTap(sender: UITapGestureRecognizer){
//        toggleOpen(true)
        delegate.headViewClicked(self, sectionClicked: section)
    }
    
    func toggleOpen(userAction: Bool) {
        // 如果userAction传入的值为真，将给委托传递相应的消息
        if userAction {
            if HeaderOpen {
                delegate.closedSearchPatientHeadView(self, sectionClosed: section)
                
            }else {
                delegate.opendSearchPatientHeadView(self, sectionOpened: section)
            }
            HeaderOpen = !HeaderOpen
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
