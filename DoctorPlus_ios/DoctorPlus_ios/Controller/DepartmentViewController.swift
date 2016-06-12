//
//  DepartmentViewController.swift
//  DoctorPlus_ios
//
//  Created by monkey on 15-5-5.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class DepartmentViewController: BaseViewController ,UITableViewDataSource,UITableViewDelegate,ComFqHalcyonLogic2RequestCSDLogic_FeedSaveDepartment,SelectedDepartmentDelegate,SelectedDepartmentChildDelegate{

    let unSelectColor:UIColor = UIColor(red: CGFloat(145.0/255.0), green: CGFloat(145.0/255.0), blue: CGFloat(145.0/255.0), alpha: CGFloat(1))
    let selectColor:UIColor = UIColor(red: CGFloat(140.0/255.0), green: CGFloat(205.0/255.0), blue: CGFloat(197.0/255.0), alpha: CGFloat(1))
    
    var selectedPosition:Int = -1
    var departmentList = [ComFqHalcyonEntityDepartment]()
    var user = ComFqLibToolsConstants.getUser()
    var newSelectedDepartment:ComFqHalcyonEntityDepartment?
    
    @IBOutlet weak var sureBtn: UIButton!
    @IBOutlet weak var departmentTableView: UITableView!
    @IBOutlet weak var departmentLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        setTittle("科室")
        hiddenRightImage(true)
        sureBtn.enabled = false
        UITools.setRoundBounds(5, view: sureBtn)
        UITools.setButtonWithColor(ColorType.EMERALD, btn: sureBtn, isOpposite: false)
        getDepartmentList()
        if user.getDepartment().isEmpty {
            departmentLabel.text = "未指定科室"
        } else {
            departmentLabel.text = user.getDepartment()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func getXibName() -> String {
        return "DepartmentViewController"
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return departmentList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("DepartmentTableViewCell") as? DepartmentTableViewCell
        if cell == nil {
            
            let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("DepartmentTableViewCell", owner: self, options: nil)
            cell = nibs.lastObject as? DepartmentTableViewCell
        }
        
        if selectedPosition == indexPath.row {
            cell?.departNameLabel.textColor = selectColor
        }else{
            cell?.departNameLabel.textColor = unSelectColor
        }
        cell?.departNameLabel.text = departmentList[indexPath.row].getName()
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let controller = DepartmentChildViewController()
        selectedPosition = indexPath.row
        self.departmentTableView.reloadData()
        controller.titleName = departmentList[selectedPosition].getName()
        
        for var i:Int32 = 0; i < departmentList[selectedPosition].getChild().size() ; i++ {
        
            controller.childDepartmentList.append(departmentList[selectedPosition].getChild().getWithInt(i) as! ComFqHalcyonEntityDepartment)
        }
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    /**
        获取科室列表的回调
    */
    func feedDepartmentWithJavaUtilArrayList(departmets: JavaUtilArrayList!) {
        for var i:Int32 = 0; i < departmets.size(); i++ {
            departmentList.append(departmets.getWithInt(i) as! ComFqHalcyonEntityDepartment)
        }
        self.departmentTableView.reloadData()
    }
    
    /**
        获取科室列表错误的回调
    */
    func onErrorWithInt(code: Int32, withJavaLangThrowable error: JavaLangThrowable!) {
        
    }
    
    func getDepartmentList(){
    
        let logic = ComFqHalcyonLogic2RequestCSDLogic()
        logic.requestDepartmentWithComFqHalcyonLogic2RequestCSDLogic_FeedSaveDepartment(self)
    }
    
    /**
        搜索科室的点击事件
    */
    @IBAction func searchBtnClick() {
        let controller = SearchDepartmentViewController()
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    /**
    获取搜索时候选择的科室
    */
    func selectedDepartment(department: ComFqHalcyonEntityDepartment) {
        newSelectedDepartment = department
        departmentLabel.text = department.getName()
    }
    
    /**
    获取从科室列表中选择的科室
    */
    func selectedDepartmentChild(department: ComFqHalcyonEntityDepartment) {
        newSelectedDepartment = department
        departmentLabel.text = department.getName()
    }
    
    /**
    确认保存按钮点击事件
    */
    @IBAction func sureBtnClick() {
        let logic = ComFqHalcyonLogic2ResetDoctorInfoLogic()
        logic.reqModyDeptWithInt(newSelectedDepartment?.getDepartmentId() ?? 0, withInt: newSelectedDepartment?.getDepartmentId() ?? 0, withNSString: newSelectedDepartment?.getName())
        user.setDepartmentWithNSString(newSelectedDepartment?.getName())
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        if newSelectedDepartment != nil {
            if user.getDepartment() != newSelectedDepartment!.getName() {
                sureBtn.enabled = true
            } else {
                sureBtn.enabled = false
            }
        } else {
            sureBtn.enabled = false
        }
        
    }
    
}
