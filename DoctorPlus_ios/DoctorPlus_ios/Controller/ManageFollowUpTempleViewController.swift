//
//  ManageFollowUpTempleViewController.swift
//  DoctorPlus_ios
//
//  Created by monkey on 15-5-13.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class ManageFollowUpTempleViewController:BaseViewController,UITableViewDelegate,UITableViewDataSource,ComFqHalcyonLogic2FollowUpTempleListLogic_FollowUpTempleListLogicInterface,ComFqHalcyonLogic2DeleteFollowUpTempleLogic_DeleteFollowUpTempleLogicInterface{

    var templeList = [ComFqHalcyonEntityFollowUpTemple]()
    var mDialog:CustomIOS7AlertView?
    var delTemplePosition:Int?
    
    @IBOutlet weak var templeTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setTittle("管理随访模板")
        hiddenRightImage(true)
        
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        getTempleList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func getXibName() -> String {
        return "ManageFollowUpTempleViewController"
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.rowHeight = 44
        return templeList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("") as? ManageFollowUpTempleTableViewCell
        if cell == nil {
            let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("ManageFollowUpTempleTableViewCell", owner: self, options: nil)
            cell = nibs.lastObject as? ManageFollowUpTempleTableViewCell
            UITools.setButtonStyle(cell!.delTempleBtn, buttonColor: Color.color_grey, textSize: 15, textColor: UIColor.blackColor(), isOpposite: true)
            
            cell!.delTempleBtn.tag = indexPath.row
            cell!.delTempleBtn.addTarget(self, action: Selector("delTempleBtnClick:"), forControlEvents: UIControlEvents.TouchUpInside)
        }
        cell!.templeName.text = templeList[indexPath.row].getTempleName()
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let controller = AddFollowUpTempleViewController()
        controller.templeStyle = controller.FROM_EDIT
        controller.mCurrentId = templeList[indexPath.row].getmTempleId()

        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    /**获取随访模板列表*/
    func getTempleList(){
    
        let logic = ComFqHalcyonLogic2FollowUpTempleListLogic(comFqHalcyonLogic2FollowUpTempleListLogic_FollowUpTempleListLogicInterface: self)
        logic.getTempleList()
    }
    
    /**获取随访模板列表错误的回调*/
    func onDataErrorWithInt(code: Int32, withNSString msg: String!) {
        
    }
    
    /**获取随访模板列表结果的回调*/
    func onDataReturnWithJavaUtilArrayList(mTempleList: JavaUtilArrayList!) {
        templeList = [ComFqHalcyonEntityFollowUpTemple]()
        print("fsfas\(templeList.count)", terminator: "")
        
        for var i:Int32 = 0 ; i < mTempleList.size(); i++ {
            let temple: ComFqHalcyonEntityFollowUpTemple = mTempleList.getWithInt(i) as! ComFqHalcyonEntityFollowUpTemple
            templeList.append(temple)
        }
        templeTableView.reloadData()
    }
    
    func onErrorWithInt(code: Int32, withJavaLangThrowable error: JavaLangThrowable!) {
        
    }
    
    /**
    删除模板的点击事件
    */
    @IBAction func delTempleBtnClick(sender:UIButton){
        delTemplePosition = sender.tag
        mDialog = UIAlertViewTool.getInstance().showNewDelDialog("确定删除该模板？", target: self, actionOk: "sureDelTemple", actionCancle: "cancelDelTemple")
        
    }
    
    /**确认删除模板事件*/
    func sureDelTemple(){
        let templeId = templeList[delTemplePosition!].getmTempleId()
        delTempleLogic(templeId)
        mDialog?.close()
    }
    
    /**取消删除模板事件*/
    func cancelDelTemple(){
        mDialog?.close()
    }
    
    /**
    删除模板的逻辑
    */
    func delTempleLogic(templeId:Int32){
        let logic = ComFqHalcyonLogic2DeleteFollowUpTempleLogic(comFqHalcyonLogic2DeleteFollowUpTempleLogic_DeleteFollowUpTempleLogicInterface: self, withInt: templeId)
        logic.deleteTemple()
    }
    
    /**
    删除失败的回调
    */
    func onDeleteErrorWithInt(code: Int32, withNSString msg: String!) {
        
    }
    
    /**
    删除成功的回调
    */
    func onDeleteSuccessful() {
        templeList.removeAtIndex(delTemplePosition!)
        templeTableView.reloadData()
    }
    
    /**
    添加模板按钮的点击事件
    */
    @IBAction func onAddTempleBtnClick() {
        let controller = AddFollowUpTempleViewController()
        controller.templeStyle = controller.ADD_TEMPLE
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
