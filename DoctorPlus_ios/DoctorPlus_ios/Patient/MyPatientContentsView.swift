//
//  MyPatientContentsView.swift
//  DoctorPlus_ios
//
//  Created by Monkey on 15/11/27.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import Foundation

class MyPatientContentsView :ContentsBaseView,ContentsBaseViewDelegate,MyPatientOptionalViewDelegate {
    
    
    var optView:MyPatientOptionalView?
    var indetifyDialog:IndetifyDialog!
    
    //去身份化
    var didSendInfo:Bool = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentsBaseViewDelegate = self
        contentTableView.registerNib(UINib(nibName: "MyPatientTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "MyPatientTableViewCell")
        optView = MyPatientOptionalView(frame: CGRect(x: 0, y: ScreenHeight - 221, width: ScreenWidth - 16, height: 80))
        optView?.optDelegate = self
        self.addSubview(optView!)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func onSetContentsTableCell(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell? {
        
        let item = adapter?.getItem(indexPath.section, rowIndex: indexPath.row) as! ComFqHalcyonEntityPracticePatientAbstract
        let cell = tableView.dequeueReusableCellWithIdentifier("MyPatientTableViewCell") as! MyPatientTableViewCell
        cell.setCellContent(indexPath, patient: item)
        cell.setCellStatus(getOptionalStatus())
        cell.setItemSelected(item.isSelected())
        return cell
    }
    
    func onSetTimeTableHeader(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView = TimeHeaderView(frame: CGRectMake(0, 0, tableView.frame.size.width, 30))
        headView.timeLable.text = adapter!.sections[section]
        return headView
    }
    
    func onSetHeightForHeaderInSection(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func onSetHeightForRowAtIndexPath(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 170  
    }
    
    func startOptional() {
        optView?.startOptional()
        onRefreshUI()
    }
    
    func getOptionalStatus() -> Bool {
        return optView?.isShow ?? false
    }
    
    /**
     底部添加病案按钮点击事件
     
     - parameter sender:
     */
    func onAddPatientClickListener(sender: UIButton) {
        let controller = CreateNewPatientViewController(from: FromType.FromPatient)
        Tools.getCurrentViewController().navigationController?.pushViewController(controller, animated: true)
    }
    
    /**
     底部删除按钮点击事件
     
     - parameter sender:
     */
    func onRecycleClickListener(sender: UIButton) {
        (adapter as! MyPatientAdapter).deleteSelectedItemsLogic()
    }
    
    /**
     底部全选按钮点击事件
     
     - parameter sender:
     */
    func onSelectedAllClickListener(sender: UIButton) {
        setAllItemSelected(sender.selected)
        onRefreshUI()
    }
    
    /**
     底部分享按钮点击事件
     
     - parameter sender:
     */
    func onShareClickListener(sender: UIButton) {
        let result = (adapter as! MyPatientAdapter).getAllSelectedItem()
        if result.count == 0 {
            return
        }
        
        indetifyDialog = UIAlertViewTool.getInstance().showRemoveIndetifyDialog(didSendInfo, target: self, actionOk: "sendClick", actionCancle: "cancel", actionRemoveIndentify: "secretProtocolClick", selecBtn: "withInfoBtnClick")
    }
    
   
    //确认分享
    func sendClick(){
        let result = (adapter as! MyPatientAdapter).getAllSelectedItem()
        let controller = MoreChatListViewController()
        controller.type = 2;
        let patientList = JavaUtilArrayList()
        for item in result{
            patientList.addWithId(item)
        }
        
        controller.patientList = patientList
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
    
    
    /**
     设置全选或者取消全选
     
     - parameter selected: 是否全选
     */
    func setAllItemSelected(selected:Bool) {
        for items in (adapter?.rowsInSections)! {
            for item in items {
                let tmp = item as! ComFqHalcyonEntityPracticePatientAbstract
                tmp.setSelectedWithBoolean(selected)
            }
        }
        onRefreshUI()
    }
    
    func onItemClickListener(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let patient = adapter?.getItem(indexPath.section, rowIndex: indexPath.row) as! ComFqHalcyonEntityPracticePatientAbstract
        let controller = MyRecordListViewController(patientItem: patient)
        Tools.getCurrentViewController().navigationController?.pushViewController(controller, animated: true)
    }
}