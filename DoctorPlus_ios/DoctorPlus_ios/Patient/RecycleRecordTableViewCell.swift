//
//  RecordTableViewCell.swift
//  DoctorPlus_ios
//
//  Created by Monkey on 15/12/2.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import UIKit

class RecycleRecordTableViewCell: UITableViewCell {
    
    @IBOutlet weak var recordTypeNameLabel: UILabel!
    @IBOutlet weak var recordContentText: UILabel!
    
    @IBOutlet weak var selectedBtn: UIButton!
    
    var record:ComFqHalcyonEntityPracticeRecordAbstract?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setCellContent(item:ComFqHalcyonEntityPracticeRecordAbstract) {
        self.record = item
        recordTypeNameLabel.text = record?.getTypeName()
        recordContentText.text = record?.getInfoAbstract()
    }
    
    func setEditState(isEdit:Bool) {
        if isEdit {
            selectedBtn.hidden = false
        }else{
            selectedBtn.hidden = true
            selectedBtn.selected = false
        }
    }
    
    func setItemSelected(isSelected:Bool) {
        selectedBtn.selected = isSelected
        record?.setSelectedWithBoolean(selectedBtn.selected)
    }
    
    @IBAction func onRecordSelectedBtnClickListener(sender: UIButton) {
        if sender.selected {
            selectedBtn.selected = false
        }else{
            selectedBtn.selected = true
        }
        record?.setSelectedWithBoolean(selectedBtn.selected)
    }
    
}
