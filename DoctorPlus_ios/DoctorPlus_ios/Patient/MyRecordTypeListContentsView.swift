//
//  MyRecordTypeListContentsView.swift
//  DoctorPlus_ios
//
//  Created by Monkey on 15/12/4.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import UIKit

class MyRecordTypeListContentsView :ContentsBaseView,ContentsBaseViewDelegate,MyRecordHeaderViewDelegate,ThreeBtnOptionalViewDelegate,RecordTypeBtnDelegate{

    var optView:ThreeBtnOptionalView!
    var leftMenu:RecordTypeLeftMenu?
    var indetifyDialog:IndetifyDialog!
    //去身份化
    var didSendInfo:Bool = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentsBaseViewDelegate = self
        let cellNib = UINib(nibName: "MyRecordTableViewCell", bundle: NSBundle.mainBundle())
        contentTableView.registerNib(cellNib, forCellReuseIdentifier: "MyRecordTableViewCell")
        optView = ThreeBtnOptionalView(frame: CGRect(x: 0, y: ScreenHeight - 150, width: ScreenWidth - 16, height: 80))
        optView.optDelegate = self
        self.addSubview(optView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addMenu() {
        leftMenu = RecordTypeLeftMenu(frame: CGRectMake(-65, 0, 65, ScreenHeight - 70), btnDelegate: self)
        self.superview?.addSubview(leftMenu!)
    }
    
    func onSetContentsTableCell(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell? {
        let cell = contentTableView.dequeueReusableCellWithIdentifier("MyRecordTableViewCell") as! MyRecordTableViewCell
        let item = adapter?.getItem(indexPath.section, rowIndex: indexPath.row) as! ComFqHalcyonEntityPracticeRecordAbstract
        
        cell.isEdit = getOptionalStatus()
        cell.initData(item )
        cell.setItemSelected(item.isSelected())
        return cell
    }
    
    func onSetHeightForHeaderInSection(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    func onSetHeightForRowAtIndexPath(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 120
    }
    
    func onSetTimeTableHeader(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView = MyRecordHeaderView(frame: CGRectMake(0, 0, tableView.frame.size.width, 30))
        headView.delegate = self
        headView.section = section
        headView.recordTypeLabel.text = adapter?.sections[section]
        if section != 0 && adapter?.rowsInSections[section].count == 0 {
            leftMenu?.setBtnNotEnable(section-1)
        }
        
        return headView
    }
    
    func onItemClickListener(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        (adapter as! MyRecordAdapter).pushController(self,indexPath: indexPath)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (adapter as! MyRecordAdapter).tmpDatas[section].count
    }
    
    /**
     打开分组的操作
     
     - parameter sectionOpened:      分组的位置
     */
    func opendMyRecordView(sectionOpened: Int) {
        
        (adapter as! MyRecordAdapter).tmpDatas[sectionOpened] = (adapter?.rowsInSections[sectionOpened])!
        (adapter as! MyRecordAdapter).sectionIsOpen[sectionOpened] = true
        contentTableView.insertRowsAtIndexPaths(getIndexPaths(sectionOpened), withRowAnimation: UITableViewRowAnimation.Top)
        
    }
    
    /**
     关闭分组的操作
     
     - parameter sectionClosed:      分组的位置
     */
    func closedMyRecordView(sectionClosed: Int) {
        
        (adapter as! MyRecordAdapter).tmpDatas[sectionClosed] = [Any]()
        (adapter as! MyRecordAdapter).sectionIsOpen[sectionClosed] = false
        contentTableView.deleteRowsAtIndexPaths(getIndexPaths(sectionClosed), withRowAnimation: UITableViewRowAnimation.Top)
        
    }
    
    func getIndexPaths(section:Int) -> Array<NSIndexPath>{
        var resultArray = [NSIndexPath]()
        for i in 0 ..< (adapter?.rowsInSections[section].count)! {
            resultArray.append(NSIndexPath(forRow: i, inSection: section))
        }
        return resultArray
    }
    
    func startOptional() {
        optView.startOptional()
    }
    
    func getOptionalStatus() -> Bool {
        return optView.isShow ?? false
    }
    
    //筛选按钮点击事件
    func onFirstItemClickListener(sender: UIButton) {
        let controller = FilterSearchViewController()
        let patientId = (adapter as! MyRecordAdapter).patientItem.getPatientId()
        controller.setFilterParamPatientId(patientId)
        Tools.getCurrentViewController().navigationController?.pushViewController(controller, animated: true)
    }
    
    //分享按钮点击事件
    func onSecondItemClickListener(sender: UIButton) {
        let result = (adapter as! MyRecordAdapter).getAllSelectedItem()
        if result.count == 0 {
            return
        }
        
        indetifyDialog = UIAlertViewTool.getInstance().showRemoveIndetifyDialog(didSendInfo, target: self, actionOk: "sendClick", actionCancle: "cancel", actionRemoveIndentify: "secretProtocolClick", selecBtn: "withInfoBtnClick")
    }
    
    //添加病例按钮点击事件
    func onThreadItemClickListener(sender: UIButton) {
        let controller = ScannerViewController()
        Tools.getCurrentViewController().navigationController?.pushViewController(controller, animated: true)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        //        print("gundong")
        leftMenu!.scrollState = .RUNNING
    }
    
    func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
        //        print("开始滚")
        leftMenu!.scrollState = .START
        leftMenu!.show { (ok) -> () in
            print("show_wancheng")
        }
        //
    }
    
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
                print("结束滚")
        leftMenu!.scrollState = .STOP
        leftMenu!.startTimerCloseMenu()
        
    }
    
    func btnOnClick(sender: UIButton) {
        
        let section = sender.tag + 1
        if !(adapter as! MyRecordAdapter).sectionIsOpen[section] {
            opendMyRecordView(section)
        }
        
        contentTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: section), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        leftMenu!.close { (ok) -> () in
            
        }
    }
    
    func onSectionBtnClickListener(section: Int) {
        toggleOpen(section)
    }
    
    func toggleOpen(section:Int) {
        let openState = (adapter as! MyRecordAdapter).sectionIsOpen[section]
        if openState {
            closedMyRecordView(section)
        }else {
            opendMyRecordView(section)
        }
        (adapter as! MyRecordAdapter).sectionIsOpen[section] = !openState
    }
    
    //确认分享
    func sendClick(){
        let result = (adapter as! MyRecordAdapter).getAllSelectedItem()
        let controller = MoreChatListViewController()
        controller.type = 2;
        let recordList = JavaUtilArrayList()
        for item in result{
            recordList.addWithId(item)
        }
        
        controller.recordList = recordList
        controller.didSendInfo = didSendInfo
        Tools.getCurrentViewController(self).navigationController?.pushViewController(controller, animated: true)
        indetifyDialog.alertView?.close()
        didSendInfo = true
    }
    
    //取消分享
    func cancel(){
        indetifyDialog.alertView?.close()
    }
    //查看协议
    func secretProtocolClick(){
        indetifyDialog.alertView?.close()
        Tools.getCurrentViewController(self).navigationController?.pushViewController(ProtocolViewController() , animated: true)
    }
    //是否包含身份信息
    func withInfoBtnClick(){
        didSendInfo = !didSendInfo;
        
        if didSendInfo{
            indetifyDialog.selectBtn?.setBackgroundImage(UIImage(named: "icon_circle_yes.png"), forState: UIControlState.Normal)
        }else{
            indetifyDialog.selectBtn?.setBackgroundImage(UIImage(named: "icon_circle_no.png"), forState: UIControlState.Normal)
        }
        
    }
}