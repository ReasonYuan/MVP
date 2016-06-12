//
//  MyRecordTableViewCell.swift
//  DoctorPlus_ios
//
//  Created by Monkey on 15/12/9.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import UIKit

class MyRecordTableViewCell: UITableViewCell {

    @IBOutlet weak var recIngImg: UIImageView!
    @IBOutlet weak var recStateImg: UIImageView!
    @IBOutlet weak var recStateLabel: UILabel!
    @IBOutlet weak var recordTypeLabel: UILabel!
    @IBOutlet weak var abstractLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var selectedBtn: UIButton!
    
    var record:ComFqHalcyonEntityPracticeRecordAbstract!
    var isEdit = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initData(record:ComFqHalcyonEntityPracticeRecordAbstract) {
        self.record = record
        initWidgets()
    }
    
    func initWidgets() {
        if record.getRecStatus() ==  ComFqLibRecordRecordConstants_CLOUD_REC_END{
            //识别完成
            
            recStateImg.hidden = true
            recStateLabel.hidden = true
            recIngImg.hidden = true
            recordTypeLabel.hidden = false
            contentLabel.hidden = false
            abstractLabel.hidden = false
            
            selectedBtn.hidden = !isEdit
            
            recordTypeLabel.text = record.getTypeName()
            contentLabel.text = record.getInfoAbstract()
            
        }else{
            
            recStateLabel.hidden = false
            recordTypeLabel.hidden = true
            contentLabel.hidden = true
            abstractLabel.hidden = true
            selectedBtn.hidden = true
            
            if record.getRecStatus() == ComFqLibRecordRecordConstants_CLOUD_REC_ING {
                recIngImg.hidden = false
                recStateImg.hidden = true
                recStateLabel.text = "AMD云识别中"
            }else{
                recIngImg.hidden = true
                recStateImg.hidden = false
                
                if record.getRecStatus() == ComFqLibRecordRecordConstants_CLOUD_REC_WAIT {
                    recStateImg.image = UIImage(named: "ocr_recognied.png")
                    recStateLabel.text = "OCR智能识别中"
                }else if record.getRecStatus() == ComFqLibRecordRecordConstants_CLOUD_REC_FAIL {
                    recStateLabel.text = "无法识别"
                }
                
            }
            
        }
        
    }
    
    @IBAction func onSelectedClickListener(sender: UIButton) {
        let selectState = record.isSelected()
        if selectState {
            sender.selected = false
        }else{
            sender.selected = true
        }
        record.setSelectedWithBoolean(!selectState)
    }
    
    func setItemSelected(isSelected:Bool) {
        selectedBtn.selected = isSelected
        record?.setSelectedWithBoolean(selectedBtn.selected)
    }
}
