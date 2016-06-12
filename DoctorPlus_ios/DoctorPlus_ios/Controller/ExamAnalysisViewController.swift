//
//  ExamAnalysisViewController.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/5/20.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class ExamAnalysisViewController: BaseViewController,UITableViewDataSource,UITableViewDelegate,ComFqHalcyonLogic2GetExamListLogic_GetExamListCallBack,ComFqHalcyonLogic2SearchHospitalLogic_SearchHospitalCallBack{

    var mExams = [ComFqHalcyonEntityExam]()
    var mHospitals = [ComFqHalcyonEntityHospital]()
    var mHosSelectedItem = -1
    var mExamSelectedItem = -1
    var hospital :ComFqHalcyonEntityHospital!
    var oldHospital:ComFqHalcyonEntityHospital!
    var exam:ComFqHalcyonEntityExam!
    var isHos = true
    @IBOutlet weak var examTextField: FQTexfield!
    @IBOutlet weak var hospitalTextFeild: FQTexfield!
    @IBOutlet weak var mTableView: UITableView!
    @IBOutlet weak var sureButton: UIButton!
    
    @IBAction func sureButtonClicked(sender: AnyObject) {
        let txt = selectExamButton.titleLabel?.text
        if(txt == nil || "" == txt){
            return
        }
        let data = ComFqHalcyonEntityVisualizeVisualData(comFqHalcyonEntityVisualizeVisualizeEntity_VISUALTYPEEnum: (ComFqHalcyonEntityVisualizeVisualizeEntity_VISUALTYPEEnum.values().objectAtIndex(UInt(ComFqHalcyonEntityVisualizeVisualizeEntity_VISUALTYPE_EXAMS.rawValue)) as! ComFqHalcyonEntityVisualizeVisualizeEntity_VISUALTYPEEnum))
        let controller = VisualChoosePatientViewController()
        controller.data = data
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBOutlet weak var selectHospitalButton: UIButton!
    @IBOutlet weak var selectExamButton: UIButton!
    
    @IBAction func selHosBtnClicked(sender: AnyObject) {
        hospitalTextFeild.becomeFirstResponder()
    }

    @IBAction func selExamBtnClicked(sender: AnyObject) {
        examTextField.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTittle("化验项分析图表")
        hiddenRightImage(true)
        sureButton.enabled = false
        UITools.setRoundBounds(5, view: sureButton)
        UITools.setButtonWithColor(ColorType.EMERALD, btn: sureButton, isOpposite: false)
        selectHospitalButton.titleLabel?.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        selectExamButton.titleLabel?.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        hospitalTextFeild.setNextTextField(examTextField)
        isHos = true
        getHosList()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "hospitalChange:", name: UITextFieldTextDidChangeNotification, object: hospitalTextFeild)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "examsChange:", name: UITextFieldTextDidChangeNotification, object: examTextField)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "examsBegin:", name: UITextFieldTextDidBeginEditingNotification, object: examTextField)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "hospitalBegin:", name: UITextFieldTextDidBeginEditingNotification, object: hospitalTextFeild)
    }

    override func getXibName() -> String {
        return "ExamAnalysisViewController"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "cell"
        var cell: UITableViewCell? = (tableView.dequeueReusableCellWithIdentifier(cellIdentifier))
        if(cell == nil){
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier)
        }
        cell!.textLabel!.font = UIFont.systemFontOfSize(14.0)
        var itemIndex:Int
        var name :String
        if(isHos){
            itemIndex = mHosSelectedItem
            name = mHospitals[indexPath.row].getName()
        }else{
            itemIndex = mExamSelectedItem
            name = mExams[indexPath.row].getExamName()
        }
        cell!.textLabel!.text = name
        if(indexPath.row == itemIndex){
            cell!.textLabel!.textColor = UIColor(red: 98/255, green: 192/255, blue: 180/255, alpha: 1.0)
        }else{
            cell!.textLabel!.textColor = UIColor.blackColor()
        }
        return cell!
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(isHos){
            return mHospitals.count
        }else{
            return mExams.count
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if(isHos){
            if(hospital != nil){
                oldHospital = hospital
            }
            hospital = mHospitals[indexPath.row]
            if(oldHospital == nil || !(hospital.getName() == oldHospital.getName())){
                selectHospitalButton.setTitle(hospital.getName(), forState: UIControlState.Normal)
                mHosSelectedItem = indexPath.row
                mTableView.reloadData()
                mExamSelectedItem = -1
                selectExamButton.setTitle("选择化验项", forState: UIControlState.Normal)
                sureButton.enabled = false
            }
        }else{
            exam = mExams[indexPath.row]
            selectExamButton.setTitle(exam.getExamName(), forState: UIControlState.Normal)
            mExamSelectedItem = indexPath.row
            mTableView.reloadData()
            sureButton.enabled = true
        }
    }
    
    func examsBegin(sender:NSNotification){
        if(hospital != nil){
            isHos = false
            getExamList(Int(hospital.getHospitalId()), keyExam: examTextField.text!)
        }else{
            UIAlertViewTool.getInstance().showAutoDismisDialog("请选择医院", width: 210, height: 120)
            hospitalTextFeild.becomeFirstResponder()
        }
    }
    
    func examsChange(sender:NSNotification){
        isHos = false
        getExamList(Int(hospital.getHospitalId()), keyExam: examTextField.text!)
    }
    
    func hospitalBegin(sender:NSNotification){
        isHos = true
        getHosList()
    }
    
    func hospitalChange(sender:NSNotification){
        isHos = true
        getHosList()
    }
    
    //获取医院列表
    func getHosList(){
        let hosLogic = ComFqHalcyonLogic2SearchHospitalLogic(comFqHalcyonLogic2SearchHospitalLogic_SearchHospitalCallBack: self)
        hosLogic.searchHDRHospital()
    }
    
    //获取医院列表回调
    func onSearchHospitalErrorWithInt(code: Int32, withNSString msg: String!) {
        UIAlertViewTool.getInstance().showAutoDismisDialog("搜索失败", width: 210, height: 120)
    }
    
    func onSearchHospitalResultWithJavaUtilArrayList(mList: JavaUtilArrayList!) {
        mTableView.dataSource = self
        mTableView.delegate = self
        mHospitals.removeAll(keepCapacity: true)
        for var i = 0; i < Int(mList.size()); i++ {
            mHospitals.append(mList.getWithInt(Int32(i)) as! ComFqHalcyonEntityHospital)
        }
        mTableView.reloadData()
    }
    

    
    //获取化验列表
    func getExamList(hosId :Int , keyExam:String){
        mExams.removeAll(keepCapacity: true)
        let examLogic = ComFqHalcyonLogic2GetExamListLogic(comFqHalcyonLogic2GetExamListLogic_GetExamListCallBack: self)
        examLogic.getExamListWithInt(Int32(hosId), withNSString: keyExam)
        mTableView.reloadData()
    }
    
    //化验列表回调
    func onGetExamListErrorWithInt(code: Int32, withNSString msg: String!) {
        UIAlertViewTool.getInstance().showAutoDismisDialog("搜索失败", width: 210, height: 120)
    }
    
    func onGetExamListResultWithJavaUtilArrayList(examList: JavaUtilArrayList!) {
        mExams.removeAll(keepCapacity: true)
        mTableView.dataSource = self
        mTableView.delegate = self
        for var i = 0; i < Int(examList.size()); i++ {
             mExams.append(examList.getWithInt(Int32(i)) as! ComFqHalcyonEntityExam)
        }
        mTableView.reloadData()
    }
    
}
