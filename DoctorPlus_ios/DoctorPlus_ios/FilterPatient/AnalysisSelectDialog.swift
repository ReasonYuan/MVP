//
//  AnalysisSelectDialog.swift
//  DoctorPlus_ios
//
//  Created by chenjie on 15/12/16.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import UIKit

protocol AnalysisSelectDialogDelegate{
    func sure(selectedStrs:[String])
}

class AnalysisSelectDialog: CustomIOS7AlertView,UITableViewDelegate,UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sureBtn: UIButton!
    @IBOutlet weak var selectAllImage: UIImageView!
    @IBOutlet weak var btnSelectAll: UIButton!
    
    var oldAnalysisList:[String]!
    var map = [String:Bool]()
    var delegate:AnalysisSelectDialogDelegate!
    
    init(analysisList:[String],delegate:AnalysisSelectDialogDelegate) {
        super.init()
        let highlightImage = UITools.imageByApplyingAlpha(0.7, image: UIImage(named:"dialog_sure.png")!)
        sureBtn.setBackgroundImage(highlightImage, forState: UIControlState.Highlighted)
        self.oldAnalysisList = analysisList
        self.delegate = delegate
        initBtnState()
        
    }
    /**
     设置全选btn的状态
     
     - parameter yes: true false
     */
    private func setSelectedAllState(yes:Bool){
        if yes {
           selectAllImage.image = UIImage(named:"select_all_selected.png")
            btnSelectAll.setTitleColor(UITools.colorWithHexString("#0181c0"), forState: UIControlState.Normal)
        }else{
            selectAllImage.image = UIImage(named:"select_all_normal.png")
            btnSelectAll.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        }
    }
    
    /**
     初始化Btn为全选状态
     */
    func initBtnState(){
        setSelectedAllState(true)
        for str in oldAnalysisList {
            map.updateValue(true, forKey: str)
        }
    }
    
    @IBAction func sure(sender: AnyObject) {
        self.cancel()
        var newAnalysisList = [String]()
        for str in oldAnalysisList {
            if map[str] != nil && map[str] == true {
                newAnalysisList.append(str)
            }
        }
        delegate.sure(newAnalysisList)
    }
    
    
    @IBAction func selectedAll(sender: AnyObject) {
        initBtnState()
        tableView.reloadData()
        
    }
    
    @IBAction func clearAll(sender: AnyObject) {
        setSelectedAllState(false)
        for str in oldAnalysisList {
            map.updateValue(false, forKey: str)
        }
        tableView.reloadData()

    }
    

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return oldAnalysisList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("AnalysisDialogTableViewCell") as? AnalysisDialogTableViewCell
        if cell == nil {
            
            let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("AnalysisDialogTableViewCell", owner: self, options: nil)
            cell = nibs.lastObject as? AnalysisDialogTableViewCell
        }
        cell?.button.setTitle(oldAnalysisList[indexPath.row], forState: UIControlState.Normal)
        UITools.setBorderWidthWithView(1, tmpColor: UITools.colorWithHexString("#c1c1c1").CGColor, view: (cell?.button)!)
        cell?.button.tag = indexPath.row
        cell?.button.addTarget(self, action: "btnClick:", forControlEvents: UIControlEvents.TouchUpInside)
        let selected = map[oldAnalysisList[indexPath.row]]
        if selected != nil && selected == true {
            cell?.button.selected = true
        }else {
            cell?.button.selected = false
        }

        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    func btnClick(sender:UIButton){
        sender.selected = !sender.selected
        let index = sender.tag
        let str = oldAnalysisList[index]
        map.updateValue(sender.selected, forKey: str)
        
        //判断是否全选
        var newAnalysisList = [String]()
        for str in oldAnalysisList {
            if map[str] != nil && map[str] == true {
                newAnalysisList.append(str)
            }
        }
        if newAnalysisList.count == oldAnalysisList.count {
            setSelectedAllState(true)
        }else{
            setSelectedAllState(false)
        }
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func getXibName() -> String {
        return "AnalysisSelectDialog"
    }
    
    
    
   }
