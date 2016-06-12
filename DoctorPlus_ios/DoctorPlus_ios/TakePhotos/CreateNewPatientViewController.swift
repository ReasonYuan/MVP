//
//  CreateNewPatientViewController.swift
//  DoctorPlus_ios
//
//  Created by Monkey on 15/12/24.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import UIKit

enum FromType {

    case FromPatient
    case FromCamera
}

class CreateNewPatientViewController: BaseViewController ,UITableViewDelegate,UITableViewDataSource,ComFqHalcyonLogic2CreatePatientLogic_CreateMedicalCallBack,ComFqHalcyonLogic2AddRecordLogic_AddRecordCallBack{

    @IBOutlet weak var typeTableView: UITableView!
    var typeList = ["入院记录","化验记录","手术记录","检查记录","出院记录","其他记录"]
    
    var fromType:FromType = .FromPatient
    
    init(from:FromType) {
        super.init()
        fromType = from
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setRightBtnTittle("确定")
        typeTableView.registerNib(UINib(nibName: "CreateNewPatientTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier:
            "CreateNewPatientTableViewCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func getXibName() -> String {
        return "CreateNewPatientViewController"
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return typeList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CreateNewPatientTableViewCell") as! CreateNewPatientTableViewCell
        cell.setData(typeList[indexPath.row])
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50   
    }
    
    //新建病案的逻辑
    func createPatientLogic() {
        let logic = ComFqHalcyonLogic2CreatePatientLogic(comFqHalcyonLogic2CreatePatientLogic_CreateMedicalCallBack: self)
        logic.createMedicalWithNSString("")
    }
    
    //添加记录的逻辑
    func addRecordLogic() {
        let logic = ComFqHalcyonLogic2AddRecordLogic(comFqHalcyonLogic2AddRecordLogic_AddRecordCallBack: self)
    }
    
    //如果是从病案界面跳转过来，则在创建成功后返回该病案
    func returnPatientBack() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //创建病案失败的回调
    func createMedicalErrorWithInt(code: Int32, withNSString msg: String!) {
        FQToast.makeError().show("创建病案失败", superview: self.view)
    }
    
    //创建病案成功的回调
    func createMedicalSuccessWithInt(code: Int32, withComFqHalcyonEntityPatient medical: ComFqHalcyonEntityPatient!) {
        switch fromType {
        case FromType.FromPatient:
            returnPatientBack()
        case FromType.FromCamera:
            addRecordLogic()
        }
    }

    func AddRecordErrorWithInt(code: Int32, withNSString msg: String!) {
        FQToast.makeError().show("添加病历失败", superview: self.view)
    }
    
    func AddRecordSuccessWithInt(code: Int32, withComFqHalcyonEntityPatient medical: ComFqHalcyonEntityPatient!, withNSString msg: String!) {
        
    }
    
    override func onRightBtnOnClick(sender: UIButton) {
        createPatientLogic()
    }
}
