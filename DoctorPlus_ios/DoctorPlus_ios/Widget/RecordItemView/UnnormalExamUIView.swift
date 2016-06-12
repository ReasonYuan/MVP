//
//  UnnormalExamUIView.swift
//  DoctorPlus_ios
//
//  Created by monkey on 15-5-27.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit
protocol UnnormalExamUIViewDelegate : NSObjectProtocol{
    func onLookImgClick()
    func onToPatientClick()
    func onBackToAttachmentClick()
}
class UnnormalExamUIView: UIView,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var editTableView:UITableView!
    
    @IBOutlet weak var backToAttachmentBtn: UIButton!
    @IBOutlet weak var lookImageBtn: UIButton!
    @IBOutlet weak var tipsLabel: UILabel!
    @IBOutlet weak var backToPatientBtn: UIButton!
    
    var recordDTExamLogic:ComFqHalcyonUilogicRecordDTExamLogic!
    var tableView:UITableView?
    var frameWidth:CGFloat?
    var frameHeight:CGFloat?
    var recordItem:ComFqHalcyonEntityRecordItem?
    var otherExams:JavaUtilArrayList?
    var columnNum = 0
    var recordAbstract:ComFqHalcyonEntityPracticeRecordAbstract!
    var editTableViewWidth:CGFloat = 40
    
    var tableViewShowFrame = CGRectMake(0, 0, 40, ScreenHeight - 70)
    var tableViewHiddenFrame = CGRectMake(-40, 0, 40, ScreenHeight - 70)
    var scrollViewSmaleFrame =  CGRectMake(40, 0, ScreenWidth - 40, ScreenHeight - 70)
    var scrollViewBigFrame =  CGRectMake(0, 0, ScreenWidth, ScreenHeight - 70)
    weak var delegate:UnnormalExamUIViewDelegate?
    var isEditStatus = false
    
    
    @IBAction func backToAttachmentClick(sender: AnyObject) {
        delegate?.onBackToAttachmentClick()
    }
    
    @IBAction func onLookImageClicked(sender: AnyObject) {
        delegate?.onLookImgClick()
    }
    @IBAction func onToPatientClicked(sender: AnyObject) {
        delegate?.onToPatientClick()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("UnnormalExamUIView", owner: self, options: nil)
        let view = nibs.lastObject as! UIView
        tipsLabel.hidden = true
        editTableView.registerNib(UINib(nibName: "UnnormalExamEditTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "UnnormalExamEditTableViewCell")
        
        frameHeight = frame.size.height
        frameWidth = frame.size.width
        view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height)
        tableView = UITableView(frame: CGRectMake(0, 0, 0, 0))
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.separatorStyle = UITableViewCellSeparatorStyle.None
        
        scrollView.contentSize = CGSizeMake(frame.size.width, frame.size.height)
        scrollView.addSubview(tableView!)
        
        editTableView.frame = tableViewHiddenFrame
        scrollView.frame = scrollViewBigFrame
        editTableView.hidden = true
        editTableView.scrollEnabled = false
        backToAttachmentBtn.setImage(UIImage(named: "icon_attachment.png"), forState: UIControlState.Normal)
        backToAttachmentBtn.setImage(UIImage(named: "icon_attachment_highlight.png"), forState: UIControlState.Highlighted)
        lookImageBtn.setImage(UIImage(named: "icon_on.png"), forState: UIControlState.Normal)
        lookImageBtn.setImage(UIImage(named: "icon_on_highlight.png"), forState: UIControlState.Highlighted)
        self.addSubview(view)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == self.tableView {
            var cell = tableView.dequeueReusableCellWithIdentifier("UnnormalExamTableViewCell") as? UnnormalExamTableViewCell
            if cell == nil {
                cell = UnnormalExamTableViewCell()
                cell!.setCellStyle(columnNum)
            }
            cell?.selectionStyle = UITableViewCellSelectionStyle.None
            if indexPath.row == 0 {
                cell?.backgroundColor = UIColor(red: 180/255.0, green: 180/255.0, blue: 180/255.0, alpha: 1)
            }
            if recordDTExamLogic != nil {
                let contentList = recordDTExamLogic.getOtherExamOneItemWithInt(Int32(indexPath.row))
                for (index,item) in cell!.labelList.enumerate() {
                    item.text = contentList.getWithInt(Int32(index)) as? String
                }
            }
            
            return cell!
        }else if tableView == self.editTableView {
            let cell = tableView.dequeueReusableCellWithIdentifier("UnnormalExamEditTableViewCell") as! UnnormalExamEditTableViewCell
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if recordDTExamLogic == nil {
            return 0
        }
        return Int(recordDTExamLogic.getOtherExamCount())
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 30
    }
    
    //设置滑动范围
    func setStyle(columnNum:Int){
        let cellWidth = CGFloat(columnNum * 140)
        tableView?.frame = CGRectMake(0, 0, cellWidth, ScreenHeight - 70)
        scrollView.contentSize = CGSizeMake(cellWidth, ScreenHeight - 70)
    }
    
    func setDatas(recordDTExamLogic:ComFqHalcyonUilogicRecordDTExamLogic!){
        columnNum = Int(recordDTExamLogic.getOtherExamCloum())
        if(columnNum == 0){
            tipsLabel.hidden = false
        }else{
            tipsLabel.hidden = true
        }
        setStyle(columnNum)
        tableView?.reloadData()
    }
    
    func setEditTableViewShowOrHidden(isEdit:Bool){
        isEditStatus = isEdit
        if isEdit {
            
            if editTableView.hidden {
                editTableView.hidden = false
            }
            
            UIView.animateWithDuration(0.8, animations: { () -> Void in
                self.editTableView.frame = self.tableViewShowFrame
                self.scrollView.frame = self.scrollViewSmaleFrame
            }, completion: { (isFinish) -> Void in
                
            })
        }else{
            
            UIView.animateWithDuration(0.8, animations: { () -> Void in
                self.editTableView.frame = self.tableViewHiddenFrame
                self.scrollView.frame = self.scrollViewBigFrame
            }, completion: { (isFinish) -> Void in
                if isFinish{
                    self.editTableView.hidden = true
                }
            })
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == tableView {
            self.editTableView.setContentOffset(self.tableView!.contentOffset, animated: false)
        }
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == editTableView {
            
        }
    }
}
