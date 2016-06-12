//
//  ExplorationSearchViewController.swift
//  DoctorPlus_ios
//
//  Created by monkey on 15-7-17.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class ExplorationSearchViewController: BaseViewController,UITableViewDataSource,UITableViewDelegate,ComFqHalcyonLogicPracticeSearchLogic_SearchCallBack,RecordPatientEvent{

    
    @IBOutlet weak var tableView: UITableView!
    //搜索页数
    var page:Int32! = 1
    
    //搜索关键字
    var searchKey:String! = ""
    
    //搜索参数
    var params:ComFqHalcyonEntityPracticeSearchParams!
    
    //搜索逻辑
    var searchLogic: ComFqHalcyonLogicPracticeSearchLogic!
    
    //病案列表
    var patientsList: JavaUtilArrayList!
    
    //病历记录列表
    var recordsList: JavaUtilArrayList!
    
    //筛选列表
    var filtersList: JavaUtilArrayList!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setTittle("搜索")
        setRightBtnTittle("筛选")
        
        tableView.registerNib(UINib(nibName: "PatientViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PatientViewCell")
        tableView.registerNib(UINib(nibName: "RecordViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "RecordViewCell")
    }

    //调用搜索接口的方法
    func startSearchLogic(page:Int32){
        params = ComFqHalcyonEntityPracticeSearchParams()
        params.setNeedFiltersWithInt(1)
        params.setResponseTypeWithInt(0)
        params.setKeyWithNSString(searchKey)
        params.setPageWithInt(page)
        searchLogic = ComFqHalcyonLogicPracticeSearchLogic(comFqHalcyonLogicPracticeSearchLogic_SearchCallBack: self)
        searchLogic.searchWithComFqHalcyonEntityPracticeSearchParams(params)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        //调用搜索接口
        startSearchLogic(page)
    }
    
    //搜索成功的回调
    func searchRetrunDataWithJavaUtilArrayList(patients: JavaUtilArrayList!, withJavaUtilArrayList records: JavaUtilArrayList!, withJavaUtilArrayList filters: JavaUtilArrayList!) {
        patientsList = patients
        recordsList = records
        filtersList = filters
        tableView.reloadData()
    }
    
    //搜索失败的回调
    func searchErrorWithInt(code: Int32, withNSString msg: String!) {
        print(msg)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func getXibName() -> String {
        return "ExplorationSearchViewController"
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(patientsList != nil && recordsList != nil){
            if patientsList.size() > 0 && recordsList.size() > 0 {
                
                if section == 0 {
                    return Int(patientsList.size()) > 5 ? 5 : Int(patientsList.size())
                }else{
                    return Int(recordsList.size()) > 5 ? 5 : Int(recordsList.size())
                }
                
            }else{
                if patientsList.size() > 0 {
                    return Int(patientsList.size()) > 5 ? 5 : Int(patientsList.size())
                }else if recordsList.size() > 0 {
                    return Int(recordsList.size()) > 5 ? 5 : Int(recordsList.size())
                }
            }
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let contentCell = tableView.dequeueReusableCellWithIdentifier("PatientViewCell") as! PatientViewCell
            contentCell.initData(patientsList.getWithInt(Int32(indexPath.row)) as! ComFqHalcyonEntityPracticePatientAbstract, indexPath: indexPath, event: self)
            return contentCell
        }else{
            let contentCell = tableView.dequeueReusableCellWithIdentifier("RecordViewCell") as! RecordViewCell
            contentCell.initData(recordsList.getWithInt(Int32(indexPath.row)) as! ComFqHalcyonEntityPracticeRecordAbstract, indexPath: indexPath, event: self)
            return contentCell
        }
        
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = PatientSearchCellHeadView(frame: CGRectMake(0, 0, ScreenWidth, tableView.sectionHeaderHeight))
        if(patientsList != nil && recordsList != nil){
            if patientsList.size() > 0 && recordsList.size() > 0 {
                if section == 0 {
                    view.type.text = "病案"
                    view.headIcon.image = UIImage(named: "ic_patient.png")
                }else if section == 1 {
                    view.type.text = "记录"
                    view.headIcon.image = UIImage(named: "ic_record_item.png")
                }
            }else{
                if patientsList.size() > 0 {
                    view.type.text = "病案"
                    view.headIcon.image = UIImage(named: "ic_patient.png")
                }else if recordsList.size() > 0 {
                    view.type.text = "记录"
                    view.headIcon.image = UIImage(named: "ic_record_item.png")
                }
            }
        }
        return view
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = PatientSearchCellFooterView(frame: CGRectMake(0, 0, ScreenWidth, tableView.sectionFooterHeight))
        view.tag = section
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "footTapGesture:"))
        if(patientsList != nil && recordsList != nil){
            if patientsList.size() > 0 && recordsList.size() > 0 {
                if section == 0 {
                    if Int(patientsList.size()) > 5 {
                        view.hidden = false
                    }else{
                        view.hidden = true
                    }
                }else{
                    if Int(recordsList.size()) > 5 {
                        view.hidden = false
                    }else{
                        view.hidden = true
                    }
                }
            }else{
                if patientsList.size() > 0 {
                    if Int(patientsList.size()) > 5 {
                        view.hidden = false
                    }else{
                        view.hidden = true
                    }
                }else{
                    if Int(recordsList.size()) > 5 {
                        view.hidden = false
                    }else{
                        view.hidden = true
                    }
                }
            }
        }
        return view
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 24
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if(patientsList != nil && recordsList != nil){
            if(patientsList.size() > 0 && recordsList.size() > 0){
                return 2
            }
        }
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 105
    }
    
    func footTapGesture(tapGesture:UITapGestureRecognizer){
        let curView = tapGesture.view
        let tag = curView!.tag as Int
        let control = MorePatientViewController()
        switch tag {
        case 0:
            /**病案查看更多**/
            print(tag)
            control.isPatient = true
            self.navigationController?.pushViewController(control, animated: true)
        case 1:
            /**记录查看更多**/
            print(tag)
            control.isPatient = false
            self.navigationController?.pushViewController(control, animated: true)
        default:
            return
        }
    }
    /*实现RecordPatientEvent方法*/
    func onRPItemClear(indexPath: NSIndexPath!) {
        
    }
    
    func onRPItemClick(indexPath: NSIndexPath!) {
        
    }
    
    func onRPItemRecover(indexPath: NSIndexPath!) {
        
    }
    
    func onRPItemRemove(indexPath: NSIndexPath!) {
        
    }
    
    func onRPItemShare(indexPath: NSIndexPath!) {
        
    }
    
    func onRPItemStruct(indexPath: NSIndexPath!) {
        
    }
    
    func onRPItemCloud(indexPath: NSIndexPath!) {
        
    }
}
