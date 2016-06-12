//
//  MyRecordListViewController.swift
//  DoctorPlus_ios
//
//  Created by Monkey on 15/12/4.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import Foundation
import SnapKit

class MyRecordListViewController: BaseViewController ,ButtonCollectionDelegate,ComFqHalcyonLogicPracticeShareLogic_ShareSavePatientCallBack{

    var patientItem:ComFqHalcyonEntityPracticePatientAbstract!
    
    var timeView:MyRecordTimeListContentsView!
    var typeView:MyRecordTypeListContentsView!
    var buttonCollection:ButtonCollection!
    
    var isEdit = false
    var isFromChat = false
    var showViewType = MyRecordAdapterType.TimeAdapter
    var shareMsgId:Int32 = 0
    
    var isShareMyself = true
    
    init(patientItem:ComFqHalcyonEntityPracticePatientAbstract!,isFromChat:Bool = false,shareMsgId:Int32 = 0,isShareMyself:Bool = true) {
        super.init()
        self.patientItem = patientItem
        self.isFromChat = isFromChat
        self.shareMsgId = shareMsgId
        self.isShareMyself = isShareMyself
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setInfo()
        initWidgets()
        setContentView(timeView)
        setContentView(typeView)
    }
    
    func setInfo() {
        
        if isFromChat && !isShareMyself {
            setRightBtnTittle("保存")
        }else{
            setRightBtnTittle("编辑")
        }
        self.containerView.backgroundColor = UITools.colorWithHexString("#F1F1F1")
    }
    
    func initWidgets() {
        
        timeView = MyRecordTimeListContentsView()
        typeView = MyRecordTypeListContentsView()
        buttonCollection = ButtonCollection(frame: CGRect(x: ScreenWidth/2 - 30, y: ScreenHeight - 80, width: 60, height: 60), btnCount: 3, centerBtnImageList: ["show_menu.png","close_menu.png"], btnNormalList: ["type_mode.png","time_mode.png","struct_mode.png"], superView: self.view, delegate: self )
        typeView.hidden = true
        
    }
    
    func setContentView(contentView:ContentsBaseView) {
        
        containerView.addSubview(contentView)
        contentView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.containerView).offset(0)
            make.left.equalTo(containerView).offset(8)
            make.right.equalTo(containerView).offset(-8)
            make.bottom.equalTo(containerView).offset(0)
        }
        
        var adapter:MyRecordAdapter!
        
        if contentView === timeView {
            adapter = MyRecordAdapter(patientItem: patientItem, adapterType: MyRecordAdapterType.TimeAdapter)
        }else{
            adapter = MyRecordAdapter(patientItem: patientItem, adapterType: MyRecordAdapterType.TypeAdapter)
            typeView.addMenu()
        }
        
        contentView.setContentsAdapter(adapter)
        contentView.onStartFetchData()
    }
    
    /**
     选择类型模式
     
     - parameter sender:
     */
    func LeftOnClick(sender: UIButton) {
        
        if showViewType == MyRecordAdapterType.TypeAdapter {
            return
        }
        
        typeView.hidden = false
        timeView.hidden = true
        showViewType = MyRecordAdapterType.TypeAdapter
    }
    
    /**
     选择时间模式
     
     - parameter sender:
     */
    func RightOnClick(sender: UIButton) {
        
        if showViewType == MyRecordAdapterType.TimeAdapter {
            return
        }
        
        timeView.hidden = false
        typeView.hidden = true
        showViewType = MyRecordAdapterType.TimeAdapter
        typeView.leftMenu?.close({ (ok) -> () in
            
        })
    }
    
    /**
     查看结构化
     
     - parameter sender:
     */
    func UpOnClick(sender: UIButton) {
        let controller = StructuredViewController()
        controller.patientId = Int(patientItem!.getPatientId())
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func DownOnClick(sender: UIButton) {
        
    }
    
    override func onRightBtnOnClick(sender: UIButton) {
        
        if isFromChat && !isShareMyself {
            rightBtnCtrlFromChat()
            setRightBtnClickable(false)
        }else{
            rightBtnCtrlFromPatient()
        }
        
    }
    
    //从病案跳转过来时的操作
    func rightBtnCtrlFromPatient() {
        switch showViewType {
        case MyRecordAdapterType.TimeAdapter:
            timeView.startOptional()
            isEdit = timeView.getOptionalStatus()
            timeView.contentTableView.reloadData()
        case MyRecordAdapterType.TypeAdapter:
            typeView.startOptional()
            isEdit = typeView.getOptionalStatus()
            typeView.contentTableView.reloadData()
        }
        
        if isEdit {
            setRightBtnTittle("完成")
            buttonCollection.hidden()
        }else{
            setRightBtnTittle("编辑")
            buttonCollection.show()
        }
    }
    
    //从聊天界面跳过来的操作
    func rightBtnCtrlFromChat() {
        let logic = ComFqHalcyonLogicPracticeShareLogic(comFqHalcyonLogicPracticeShareLogic_ShareSavePatientCallBack: self)
        logic.saveSharedPatientWithInt(shareMsgId, withInt: patientItem.getPatientId())
    }
    
    func shareErrorWithInt(code: Int32, withNSString msg: String!) {
        FQToast.makeError().show("保存病案失败", superview: self.view)
        setRightBtnClickable(true)
    }
    
    func shareSavePatientSuccessWithInt(newPatientId: Int32) {
        FQToast.makeSystem().show("保存病案成功", superview: self.view)
        hiddenRightImage(true)
    }
}