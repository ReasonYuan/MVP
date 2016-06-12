//
//  MyRecordTypeListContentsView.swift
//  DoctorPlus_ios
//
//  Created by Monkey on 15/12/4.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import Foundation

class MyRecordTimeListContentsView :ContentsBaseView,ContentsBaseViewDelegate,ThreeBtnOptionalViewDelegate{
    
    var optView:ThreeBtnOptionalView!
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
    
    func onSetContentsTableCell(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell? {
        let cell = contentTableView.dequeueReusableCellWithIdentifier("MyRecordTableViewCell") as! MyRecordTableViewCell
        cell.isEdit = getOptionalStatus()
        let item = adapter?.getItem(indexPath.section, rowIndex: indexPath.row) as! ComFqHalcyonEntityPracticeRecordAbstract

        cell.initData(item)
        cell.setItemSelected(item.isSelected())
        return cell
    }
    
    func onSetHeightForHeaderInSection(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func onSetHeightForRowAtIndexPath(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 120
    }
    
    func onSetTimeTableHeader(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView = TimeHeaderView(frame: CGRectMake(0, 0, tableView.frame.size.width, 30))
        headView.timeLable.text = adapter!.sections[section]
        return headView
    }
    
    func onItemClickListener(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        (adapter as! MyRecordAdapter).pushController(self,indexPath: indexPath)
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
    
    func startOptional() {
        optView.startOptional()
    }
    
    func getOptionalStatus() -> Bool {
        return optView.isShow ?? false
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