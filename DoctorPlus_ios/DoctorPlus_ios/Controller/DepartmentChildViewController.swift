//
//  DepartmentChildViewController.swift
//  DoctorPlus_ios
//
//  Created by monkey on 15-5-11.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

protocol SelectedDepartmentChildDelegate:NSObjectProtocol {

    func selectedDepartmentChild(department:ComFqHalcyonEntityDepartment)
}

class DepartmentChildViewController: BaseViewController,UITableViewDataSource,UITableViewDelegate{

    var titleName:String = ""
    var childDepartmentList = [ComFqHalcyonEntityDepartment]()
    var _pickerView:DDMultiPickerView?
    var departmentNameList = [String]()
    var selectedIndex = 0
    var newSelectedDepartment:ComFqHalcyonEntityDepartment?
    var selectedPosition:Int = -1

    @IBOutlet weak var childDepartmentTableView: UITableView!
    weak var delegate:SelectedDepartmentChildDelegate?
    var user = ComFqLibToolsConstants.getUser()
    override func viewDidLoad() {
        super.viewDidLoad()

        setTittle(titleName)
//        setRightImage(isHiddenBtn: false, image: UIImage(named:"snapphoto_camera_ok.png")!)
        hiddenRightImage(true)
        
//        if childDepartmentList.count > 0 {
//            setDatas(childDepartmentList)
//        }
        
    }

    /**     **/
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return childDepartmentList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("DepartmentChildTableViewCell") as? DepartmentChildTableViewCell
        if cell == nil {
            
            let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("DepartmentChildTableViewCell", owner: self, options: nil)
            cell = nibs.lastObject as? DepartmentChildTableViewCell
        }
        
        if selectedPosition == indexPath.row {
            cell?.childDepartNameLabel.textColor = UIColor.blackColor()
        }else{
            cell?.childDepartNameLabel.textColor = UIColor.blackColor()
        }
        cell?.childDepartNameLabel.text = childDepartmentList[indexPath.row].getName()
        return cell!
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        newSelectedDepartment = childDepartmentList[indexPath.row]
        let logic = ComFqHalcyonLogic2ResetDoctorInfoLogic()
        logic.reqModyDeptWithInt(newSelectedDepartment?.getDepartmentId() ?? 0, withInt: newSelectedDepartment?.getDepartmentId() ?? 0, withNSString: newSelectedDepartment?.getName())
        user.setDepartmentWithNSString(newSelectedDepartment?.getName())
        let ctrlArray = (self.navigationController?.viewControllers)!
        let index:Int = ctrlArray.count - 3
        
        let popController:UserProfileViewController = (self.navigationController?.viewControllers[index])! as! UserProfileViewController
        popController.departmentBtn.text = newSelectedDepartment?.getName()
        self.navigationController?.popToViewController(popController, animated: true)
//        self.navigationController?.popToViewController(UserProfileViewController(), animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 54.0
    }
    
/**     var logic = ComFqHalcyonLogic2ResetDoctorInfoLogic()
        logic.reqModyDeptWithInt(newSelectedDepartment?.getDepartmentId() ?? 0, withInt: newSelectedDepartment?.getDepartmentId() ?? 0, withNSString: newSelectedDepartment?.getName())
        user.setDepartmentWithNSString(newSelectedDepartment?.getName())
        self.navigationController?.popViewControllerAnimated(true)
    **/
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func getXibName() -> String {
        return "DepartmentChildViewController"
    }

    /**
    构造显示的数据
    */
//    func setDatas(childDepartment:Array<ComFqHalcyonEntityDepartment>){
////        var tempList:Array<String> = [String]()
////        
////        for department in childDepartmentList {
////            tempList.append(department.getName())
////        }
////        
////        for i in 0...1000 {
////            departmentNameList += tempList
////        }
//        setPickView()
//    }
//    
//    /**
//    设置要显示的滚轴view
//    */
//    func setPickView(){
//
//        _pickerView = DDMultiPickerView(frame: CGRectMake(0, 70, ScreenWidth, ScreenHeight - 70))
//        _pickerView?.delegate = self
//        _pickerView?.dataSource = self
//        self.view.addSubview(_pickerView!)
//        if(childDepartmentList.count > 0){
//            _pickerView?.setSelectedRow(childDepartmentList.count/2, inComponent: 0, animated: false)
//        }
//        var offsetY = 70 + _pickerView!.frame.size.height / 2.0 - 30
//        var topLine = UIView(frame: CGRectMake(0, offsetY, ScreenWidth, 1))
//        topLine.backgroundColor = Color.color_emerald
//        self.view.addSubview(topLine)
//        var  bottomLine = UIView(frame:CGRectMake(0, offsetY + 60 - 1 , ScreenWidth , 1))
//        bottomLine.backgroundColor = Color.color_emerald
//        self.view.addSubview(bottomLine)
//    }
//    
//    func didSelectedAtIndexDel(index: Int) {
//        
//    }
//    
//    override func onRightBtnOnClick(sender: UIButton) {
//        delegate?.selectedDepartmentChild(childDepartmentList[selectedIndex])
//        self.navigationController?.popViewControllerAnimated(true)
//    }
//    
//    
//    func pickerView(pickerView: DDMultiPickerView!, customizeTableView tableView: UITableView!, inComponent component: Int) {
//        tableView.backgroundColor = UIColor.clearColor();
//    }
//    
//    func pickerView(pickerView: DDMultiPickerView!, didSelectRow row: Int, inComponent component: Int) {
//        selectedIndex = row
//    }
//    
//    func pickerView(pickerView: DDMultiPickerView!, heightForRowsInTableView tableView: UITableView!, inComponent component: Int) -> CGFloat {
//        return 60
//    }
//    
//    func pickerView(pickerView: DDMultiPickerView!, numberOfRowsInComponent component: Int) -> Int {
//        return childDepartmentList.count
//    }
//    
//    func pickerView(pickerView: DDMultiPickerView!, tableView: UITableView!, cellForRow row: Int, inComponent component: Int) -> UITableViewCell! {
//        var identifier = ( tableView.tag == kCSPickerViewFrontTableTag ? kCSPickerViewFrontCellIdentifier : kCSPickerViewBackCellIdentifier )
//        var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(identifier) as? UITableViewCell
//        if ( cell == nil ){
//            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: identifier)
//            cell!.textLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 25)
//            if(tableView.tag == kCSPickerViewFrontTableTag){
//                cell?.textLabel.textColor = UIColor.blackColor()
//            }else{
//                cell?.textLabel.textColor = UIColor.grayColor()
//            }
//        }
//        cell?.textLabel.text = childDepartmentList[row].getName()
//        return cell! as UITableViewCell
//    }
//    
//    func numberOfComponentsInPickerView(pickerView: DDMultiPickerView!) -> Int {
//        return 1
//    }
}
