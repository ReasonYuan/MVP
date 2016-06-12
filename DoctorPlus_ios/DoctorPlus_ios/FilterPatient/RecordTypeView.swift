//
//  RecordTypeView.swift
//  DoctorPlus_ios
//
//  Created by chenjie on 15/12/16.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import UIKit

class RecordTypeView: UIView,AnalysisSelectDialogDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ruyuanBtn: UIButton!
    @IBOutlet weak var operationBtn: UIButton!
    @IBOutlet weak var analysisBtn: UIButton!
    @IBOutlet weak var checkBtn: UIButton!
    @IBOutlet weak var leaveHosBtn: UIButton!
    @IBOutlet weak var otherBtn: UIButton!
    
    var analysisSelectDialog:AnalysisSelectDialog!
    
    var ruyuanSelected = false
    var operationSelected = false
    var analysisSelected = false
    var checkSelected = false
    var leaveHosSelected = false
    var otherSlected = false
    
    /// 传进来的关键字
    var mKeys = JavaUtilArrayList()
    /// 返回给外层的字典
    var result = [String:[String:[String]]]()
    /// 选中的关键字
    var selectedKeys = [String:[String]]()
    
    var analysisArray = [String]()
    /// 选中的化验项
    var analysisSelectedStrs = [String]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("RecordTypeView", owner: self, options: nil)
        let view = nibs.lastObject as! UIView
        view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height)
        self.addSubview(view)
        UITools.setRoundBounds(11, view: titleLabel)
        ruyuanBtn.enabled = false
        operationBtn.enabled = false
        analysisBtn.enabled = false
        checkBtn.enabled = false
        leaveHosBtn.enabled = false
        otherBtn.enabled = false
       
        
        
        addResetNotification()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     所有按钮的点击事件
     
     - parameter sender: Btn
     */
    @IBAction func btnClick(sender: AnyObject) {
        if sender as! UIButton == analysisBtn {
            //添加界面选择
            
            analysisSelectDialog.show()
        }else{
            (sender as! UIButton).selected = !(sender as! UIButton).selected
        }
        
        
    }
    
    /**
    添加重置选择的通知
    */
    func addResetNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onResetFilterKeys", name: ChoseFilterKeysView.FilterNotificationKey, object: nil)
    }
    
    /**
    重置选择的操作
    */
    func onResetFilterKeys() {
        initBtn()
        
    }
    
    
    
    /**
     是否选择完全
     
     - parameter isAll: 是否选择完全
     */
    func analysisSelectedAll(isAll:Bool){
        analysisBtn.selected = true
        if !isAll{
            analysisBtn.setBackgroundImage(UIImage(named: "record_type_selected2.png"), forState: UIControlState.Selected)
        }else{
            analysisBtn.setBackgroundImage(UIImage(named: "record_type_selected.png"), forState: UIControlState.Selected)
        }
    }
    
    
    /**
     返回需要的数据
     */
    func getResult() -> [String:[String:[String]]]{
        if ruyuanBtn.selected {
            selectedKeys.updateValue([""], forKey: "入院")
        }
        
        if operationBtn.selected {
            selectedKeys.updateValue([""], forKey: "手术")
        }
        
        if analysisBtn.selected {
            selectedKeys.updateValue(analysisSelectedStrs, forKey: "化验")
        }
        
        if checkBtn.selected {
            selectedKeys.updateValue([""], forKey: "检查")
        }
        
        if leaveHosBtn.selected{
            selectedKeys.updateValue([""], forKey: "出院")
        }
        
        if otherBtn.selected {
             selectedKeys.updateValue([""], forKey: "其他")
        }
        
        result = [FilterCategory.RecordType.rawValue:selectedKeys]
        
        return result
    }
    

    //设置筛选的数据
    //keys : ArrayList<ComFqHalcyonEntityPracticeFilterItem>
    func setKeys(keys:JavaUtilArrayList) {
        var item:ComFqHalcyonEntityPracticeFilterItem!
        var map:JavaUtilHashMap?
        if keys.size() > 0 {
            item = keys.getWithInt(0) as! ComFqHalcyonEntityPracticeFilterItem
            map = item.getItemsMap() as? JavaUtilHashMap
            
        }
        if map == nil {
            return
        }
        if (map!.getWithId("入院") as! JavaUtilArrayList).size() > 0 {
            ruyuanSelected = true
        }
        if (map!.getWithId("手术") as! JavaUtilArrayList).size() > 0 {
            operationSelected = true
        }
        let analysisList = map!.getWithId("化验") as! JavaUtilArrayList
        if analysisList.size() > 0 {
            for var i:Int32 = 0 ; i < analysisList.size() ; i++ {
                analysisArray.append(analysisList.getWithInt(i) as! String)
            }
            analysisSelectedStrs = analysisArray
            analysisSelectDialog = AnalysisSelectDialog(analysisList: analysisArray,delegate:self)
            analysisSelected = true
        }
        if (map!.getWithId("检查") as! JavaUtilArrayList).size() > 0 {
            checkSelected = true
        }
        if (map!.getWithId("出院") as! JavaUtilArrayList).size() > 0 {
            leaveHosSelected = true
        }
        if (map!.getWithId("其他") as! JavaUtilArrayList).size() > 0 {
            otherSlected = true
        }
        
        initBtn()
    }
    
    func sure(selectedStrs: [String]) {
        analysisSelectedStrs = selectedStrs
        if selectedStrs.count == 0 {
            analysisBtn.selected = false
        }else if selectedStrs.count == analysisArray.count {
            analysisSelectedAll(true)
        }else{
            analysisSelectedAll(false)
        }
        
        getResult()
    }
    
    /**
     初始化Btn
     */
    private func initBtn(){
        if ruyuanSelected {
            ruyuanBtn.enabled = true
            ruyuanBtn.selected = true
        }else{
            ruyuanBtn.enabled = false
        }
        
        if operationSelected {
            operationBtn.enabled = true
            operationBtn.selected = true
        }else{
            operationBtn.enabled = false
        }
        
        if analysisSelected {
            analysisBtn.enabled = true
            analysisSelectedAll(true)
            analysisBtn.selected = true
        }else{
            analysisBtn.enabled = false
        }
        
        if checkSelected {
            checkBtn.enabled = true
            checkBtn.selected = true
        }else{
            checkBtn.enabled = false
        }
        
        if leaveHosSelected {
            leaveHosBtn.enabled = true
            leaveHosBtn.selected = true
        }else{
            leaveHosBtn.enabled = false
        }
        
        if otherSlected {
            otherBtn.enabled = true
            otherBtn.selected = true
        }else{
            otherBtn.enabled = false
        }
    }
}
