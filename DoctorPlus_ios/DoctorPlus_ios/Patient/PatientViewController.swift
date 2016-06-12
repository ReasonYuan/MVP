//
//  PatientView.swift
//  DoctorPlus_ios
//
//  Created by Monkey on 15/11/27.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import UIKit
import SnapKit

class PatientViewController: BaseViewController ,PatientNavigationDelegate,UISearchBarDelegate{
    
    var searchBar:UISearchBar?
    var patientNavigation:PatientNavigation?
    var recycleView = RecycleContentsView()
    var mypatientContentView = MyPatientContentsView()
    
    var selectedViewType:PatientNavigationSelectedType = .MyPatient
    var isEdit = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initInfo()
        addWidget()
        setMypatientAdapter()
        setRecycleAdapter()
        patientNavigation!.delegate = self
    }
    
    func initInfo() {
        setTittle("行医生涯")
        setRightBtnTittle("编辑")
        self.containerView.backgroundColor = UITools.colorWithHexString("#F1F1F1")
    }
    
    func addWidget() {

        setSearchBarView()
        setPatientNavigationView()
        setContentView(mypatientContentView)
        setContentView(recycleView)
        
    }
    
    /**
     设置搜索框
     */
    func setSearchBarView() {
        searchBar = UISearchBar()
        searchBar?.delegate = self
        containerView.addSubview(searchBar!)
        searchBar!.backgroundImage = UITools.imageWithColor(UIColor.whiteColor())
        searchBar!.placeholder = "请输入搜索关键词"
        searchBar!.snp_makeConstraints { (make) -> Void in
            make.height.equalTo(30)
            make.top.equalTo(containerView).offset(6)
            make.left.equalTo(containerView).offset(8)
            make.right.equalTo(containerView).offset(-8)
        }
    }
    
    /**
     设置导航
     */
    func setPatientNavigationView() {
        patientNavigation = PatientNavigation()
        containerView.addSubview(patientNavigation!)
        patientNavigation!.snp_makeConstraints { (make) -> Void in
            make.height.equalTo(30)
            make.top.equalTo(searchBar!).offset(35)
            make.left.equalTo(containerView).offset(8)
            make.right.equalTo(containerView).offset(-8)
        }
    }
    
    //设置显示的内容
    func setContentView(baseView:ContentsBaseView) {
        
        containerView.addSubview(baseView)
        baseView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(patientNavigation!).offset(30)
            make.left.equalTo(containerView).offset(8)
            make.right.equalTo(containerView).offset(-8)
            make.bottom.equalTo(containerView).offset(0)
        }
    }
    
    func setRecycleAdapter() {
        let adapter = RecycleContentsAdapter()
        recycleView.setContentsAdapter(adapter)
        recycleView.onStartFetchData()
        recycleView.hidden = true
    }
    
    func setMypatientAdapter() {
        let adapter = MyPatientAdapter()
        mypatientContentView.setContentsAdapter(adapter)
        mypatientContentView.onStartFetchData()
    }
    
    func selectChanged(selectedType: PatientNavigationSelectedType) {
        selectedViewType = selectedType
        switch selectedType {
        case .MyPatient:
            mypatientContentView.hidden = false
            recycleView.hidden = true
        case .Recycle :
            mypatientContentView.hidden = true
            recycleView.hidden = false
        }
    }
    
    override func onRightBtnOnClick(sender: UIButton) {
        switch selectedViewType {
        case .MyPatient:
            mypatientContentView.startOptional()
            isEdit = mypatientContentView.getOptionalStatus()
        case .Recycle :
            recycleView.startOptional()
            isEdit = recycleView.getOptionalStatus()
        }
        
        if isEdit {
            setRightBtnTittle("完成")
            patientNavigation?.clickEnable = false
        }else{
            setRightBtnTittle("编辑")
            patientNavigation?.clickEnable = true
        }
    }
    
    //搜索跳转
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        let key = searchBar.text ?? ""
        if key.characters.count == 0 {
            return
        }
        let controller = SearchPatientController()
        controller.keys = key
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
}