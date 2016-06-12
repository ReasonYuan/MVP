//
//  NormalExamUIView.swift
//  DoctorPlus_ios
//
//  Created by monkey on 15-5-26.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class NormalExamUIView: UIView,UITableViewDataSource,UITableViewDelegate {
    
    var recordItem: ComFqHalcyonEntityRecordItem?
    var examList = [ComFqHalcyonEntityRecordItem_RecordExamItem]()
    var navigationController:UINavigationController?
    var patientId:Int32 = 0
    @IBOutlet weak var tableView: UITableView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("NormalExamUIView", owner: self, options: nil)
        let view = nibs.lastObject as! UIView
        view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height)
        self.addSubview(view)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if recordItem == nil {
            return 0
        }
        
        return Int(recordItem!.getExams().size())
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("NormalExamTableViewCell") as? NormalExamTableViewCell
        if cell == nil {
            let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("NormalExamTableViewCell", owner: self, options: nil)
            cell = nibs.lastObject as? NormalExamTableViewCell
        }
        let item = examList[indexPath.row]
        cell?.assayName.text = item.getName()
        cell?.assayResult.text = "\(item.getExamValus()) \(item.getValueState())"
        cell?.assayRefvalue.text = item.getExpectValue()
        cell?.assayUnit.text = item.getUnit()
        
        if (item.getExamState() == ComFqHalcyonEntityRecordItem_EXAM_STATEEnum.values().objectAtIndex(UInt(ComFqHalcyonEntityRecordItem_EXAM_STATE_M.rawValue)) as! ComFqHalcyonEntityRecordItem_EXAM_STATEEnum) {
            cell?.assayName.textColor = Color.color_grey
            cell?.assayResult.textColor = Color.color_grey
            cell?.assayRefvalue.textColor = Color.color_grey
            cell?.assayUnit.textColor = Color.color_grey
        }else {
            cell?.assayName.textColor = Color.color_orange
            cell?.assayResult.textColor = Color.color_orange
            cell?.assayRefvalue.textColor = Color.color_orange
            cell?.assayUnit.textColor = Color.color_orange
        }
        return cell!
    }
    
    func setDatas(recordItem: ComFqHalcyonEntityRecordItem?){
        if recordItem == nil {
            return
        }
        let tmpList = recordItem?.getExams()
        for var i:Int32 = 0 ; i < tmpList?.size() ; i++ {
            examList.append(tmpList!.getWithInt(i) as! ComFqHalcyonEntityRecordItem_RecordExamItem)
        }
        self.recordItem = recordItem
        self.tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let controller = ExamChartViewController()
        let exam = examList[indexPath.row]
        controller.examName = exam.getName()
        controller.patientId = patientId
        navigationController?.pushViewController(controller, animated: true)
    }
}
