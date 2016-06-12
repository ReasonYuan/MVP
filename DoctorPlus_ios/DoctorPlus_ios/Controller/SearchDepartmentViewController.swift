//
//  SearchDepartmentViewController.swift
//  DoctorPlus_ios
//
//  Created by monkey on 15-5-8.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

protocol SelectedDepartmentDelegate:NSObjectProtocol{

    func selectedDepartment(department:ComFqHalcyonEntityDepartment)
}

class SearchDepartmentViewController: BaseViewController ,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,ComFqHalcyonLogic2SearchDepartmentLogic_SearchDepartmentCallBack{
    
    let unSelectColor:UIColor = UIColor(red: CGFloat(145.0/255.0), green: CGFloat(145.0/255.0), blue: CGFloat(145.0/255.0), alpha: CGFloat(1))
    let selectColor:UIColor = UIColor(red: CGFloat(140.0/255.0), green: CGFloat(205.0/255.0), blue: CGFloat(197.0/255.0), alpha: CGFloat(1))
    
    var selectedPosition:Int = -1
    var departmentList = [ComFqHalcyonEntityDepartment]()
    
    var mDialog:CustomIOS7AlertView?
    var mDialogtextfield:UITextField?
    
    @IBOutlet weak var createDepartmentView: UIView!
    var delegate:SelectedDepartmentDelegate?
    
    @IBOutlet weak var departmentTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setTittle("搜索")
        hiddenRightImage(true)
        createDepartmentView.hidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func getXibName() -> String {
        return "SearchDepartmentViewController"
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedPosition = indexPath.row
        self.departmentTableView.reloadData()
        self.view.endEditing(true)
        delegate?.selectedDepartment(departmentList[selectedPosition])
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return departmentList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("HotHospitalTableViewCell") as? HotHospitalTableViewCell
        if cell == nil {
            let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("HotHospitalTableViewCell", owner: self, options: nil)
            cell = nibs.lastObject as? HotHospitalTableViewCell
        }
        
        if selectedPosition == indexPath.row {
            cell?.mHospitalName.textColor = selectColor
        } else {
            cell?.mHospitalName.textColor = unSelectColor
        }
        
        cell?.mHospitalName.text = departmentList[indexPath.row].getName()
        return cell!
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.endEditing(true)
        getSearchResult(searchBar.text!)
    }
    
    /**
    获取搜索科室的结果
    */
    func getSearchResult(name:String){
        let logic = ComFqHalcyonLogic2SearchDepartmentLogic(comFqHalcyonLogic2SearchDepartmentLogic_SearchDepartmentCallBack: self)
        logic.searchDepartmentWithNSString(name)
    }
    
    /**
    搜索科室失败
    */
    func onSearchDepartmentErrorWithInt(code: Int32, withNSString msg: String!) {
        
    }
    
    /**
    搜索科室成功
    */
    func onSearchDepartmentResultWithJavaUtilArrayList(mList: JavaUtilArrayList!) {
        departmentList = [ComFqHalcyonEntityDepartment]()
        if mList.size() == 0 {
            createDepartmentView.hidden = false
            return
        } else {
            createDepartmentView.hidden = true
        }
        for var i:Int32 = 0 ; i < mList.size() ; i++ {
            departmentList.append(mList.getWithInt(i) as! ComFqHalcyonEntityDepartment)
        }
        self.departmentTableView.reloadData()
    }
    
    
    @IBAction func createDepartmentClick() {
        self.view.endEditing(true)
//        let result = UIAlertViewTool.getInstance().showNewTextFieldDialog("新建科室", hint: "输入科室名称", target: self, actionOk: "sureClick", actionCancle: "cancelClick")
//        mDialog = result.alertView
//        mDialogtextfield = result.textField
        
        
    }
    
    func sureClick(){
        let str = mDialogtextfield?.text
        if str != nil {
            let department: ComFqHalcyonEntityDepartment! = ComFqHalcyonEntityDepartment()
            department.setNameWithNSString(str)
            delegate?.selectedDepartment(department)
            self.navigationController?.popViewControllerAnimated(true)
        }
        mDialog?.close()
    }
    
    func cancelClick(){
        mDialog?.close()
    }
    
}
