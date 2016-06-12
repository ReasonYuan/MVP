//
//  RecycleContentsView.swift
//  DoctorPlus_ios
//
//  Created by Nan on 15/10/22.
//  Copyright (c) 2015年 YiYiHealth. All rights reserved.
//

import Foundation

class RecycleContentsView: ContentsBaseView,ContentsBaseViewDelegate ,RecycleOptionalViewDelegate{
    
    var optView:RecycleOptionalView?
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        self.contentsBaseViewDelegate = self
        contentTableView.registerNib(UINib(nibName: "MyPatientTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "MyPatientTableViewCell")
        contentTableView.registerNib(UINib(nibName: "RecycleRecordTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "RecycleRecordTableViewCell")
        optView = RecycleOptionalView(frame: CGRect(x: 0, y: ScreenHeight - 221, width: ScreenWidth - 16, height: 80))
        optView?.optDelegate = self
        self.addSubview(optView!)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func onSetContentsTableCell(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell? {
        
        let item = adapter?.getItem(indexPath.section, rowIndex: indexPath.row) as! ComFqHalcyonEntityPracticeRecordData
        
        if item.getCategory() == ComFqHalcyonEntityPracticeRecordData_CATEGORY_RECORD {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("RecycleRecordTableViewCell") as! RecycleRecordTableViewCell
            cell.setCellContent(item as! ComFqHalcyonEntityPracticeRecordAbstract)
            cell.setEditState(getOptionalStatus())
            cell.setItemSelected(item.isSelected())
            return cell
            
        }else{
            
            let cell = tableView.dequeueReusableCellWithIdentifier("MyPatientTableViewCell") as! MyPatientTableViewCell
            cell.isRecycle(true)
            cell.setCellContent(indexPath, patient: item as! ComFqHalcyonEntityPracticePatientAbstract)
            cell.setItemSelected(item.isSelected())
            cell.setCellStatus(getOptionalStatus())
            return cell
            
        }
    }
    
    func onSetTimeTableHeader(tableView:UITableView,viewForHeaderInSection section:Int) -> UIView? {

        let headView = TimeHeaderView(frame: CGRectMake(0, 0, tableView.frame.size.width, 30))
        headView.timeLable.text = adapter!.sections[section]
        
        return headView
    }
    
    func onSetHeightForHeaderInSection(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func onSetHeightForRowAtIndexPath(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let item = adapter?.getItem(indexPath.section, rowIndex: indexPath.row) as! ComFqHalcyonEntityPracticeRecordData
        if item.getCategory() == ComFqHalcyonEntityPracticeRecordData_CATEGORY_RECORD {
            return 120
        }else{
            return 170
        }
    }

    func startOptional() {
        optView?.startOptional()
        onRefreshUI()
        let isShow = optView?.isShow ?? false
        if !isShow {
            setAllItemSelected(false)
        }
    }
    
    func getOptionalStatus() -> Bool {
        return optView?.isShow ?? false
    }
    
    /**
     底部删除按钮的点击事件
     
     - parameter sender:
     */
    func onDeleteRecycleItemClickListener(sender: UIButton) {
       (adapter as! RecycleContentsAdapter).deleteSelectedItemLogic()
    }
    
    /**
     底部恢复数据的按钮点击事件
     
     - parameter sender: 
     */
    func onRestoreRecycleItemClickListener(sender: UIButton) {
        (adapter as! RecycleContentsAdapter).restoreSelectedItemsLogic()
    }
    
    func onSelectedAllRecycleItemClickListener(sender: UIButton) {
        setAllItemSelected(sender.selected)
        onRefreshUI()
    }
    
    /**
     设置全选或者取消全选
     
     - parameter selected: 是否全选
     */
    func setAllItemSelected(selected:Bool) {
        for items in (adapter?.rowsInSections)! {
            for item in items {
                let tmp = item as! ComFqHalcyonEntityPracticeRecordData
                tmp.setSelectedWithBoolean(selected)
            }
        }
    }
    
    func onItemClickListener(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}