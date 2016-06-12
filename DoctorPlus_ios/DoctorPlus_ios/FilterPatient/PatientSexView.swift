//
//  PatientSexView.swift
//  DoctorPlus_ios
//
//  Created by chenjie on 15/12/16.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import UIKit

class PatientSexView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var undefinitionBtn: UIButton!
    @IBOutlet weak var manBtn: UIButton!
    @IBOutlet weak var womanBtn: UIButton!
    
    
    //三个初始化状态
    var manSelected = false
    var undefinitSeleted = false
    var womanSelected = false
    
    /// 传进来的关键字
    var mKeys = JavaUtilArrayList()
    /// 返回给外层的字典
    var result = [String:JavaUtilArrayList]()
    /// 选中的关键字
    var selectedKeys = [String]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("PatientSexView", owner: self, options: nil)
        let view = nibs.lastObject as! UIView
        view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height)
        self.addSubview(view)
        

        
        initView()
        
        addResetNotification()
        
    }
    
    /**
     初始化视图
     */
    func initView(){
        UITools.setRoundBounds(11, view: titleLabel)
        setBtnTitleColor(undefinitionBtn)
        setBtnTitleColor(manBtn)
        setBtnTitleColor(womanBtn)
    }
    
    
    //添加重置选择的通知
    func addResetNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onResetFilterKeys", name: ChoseFilterKeysView.FilterNotificationKey, object: nil)
    }
    
    //重置选择的操作
    func onResetFilterKeys() {
        print("-------------------sex keys reset")
        initBtn()
        
    }
    
  
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @IBAction func btnClick(sender: AnyObject) {
        (sender as! UIButton).selected = !(sender as! UIButton).selected
    }
    
    /**
     设置btn的文字状态
     
     - parameter btn: btn
     */
    func setBtnTitleColor(btn:UIButton){
        btn.setTitleColor(UITools.colorWithHexString("#c1c1c1"), forState: UIControlState.Normal)
        btn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
        btn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
        btn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Disabled)
    }
    
    
    //设置筛选的数据
    //keys : ArrayList<ComFqHalcyonEntityPracticeFilterItem>
    func setKeys(keys:JavaUtilArrayList) {
        mKeys = keys
        initBtn()
        
       
    }
    
    
    /**
     初始化Btn状态
     */
    private func initBtn(){
        for var i:Int32 = 0 ; i < mKeys.size() ; i++ {
            let item = mKeys.getWithInt(i) as! ComFqHalcyonEntityPracticeFilterItem
            if item.getItemsName() == "男"{
                manSelected = true
            }else if item.getItemsName() == "女"{
                womanSelected = true
            }else if item.getItemsName() == "未定义"{
                undefinitSeleted = true
            }
            
        }
        if manSelected{
            manBtn.selected = manSelected
        }else{
            manBtn.enabled = false
        }
        if womanSelected {
            womanBtn.selected = womanSelected
        }else{
            womanBtn.enabled = false
        }
        
        if undefinitSeleted{
            undefinitionBtn.selected = undefinitSeleted
        }else{
            undefinitionBtn.enabled = false
        }
    }
    
    /**
     获取选择好的关键字
     
     - returns: [性别:关键字]
     */
    func getResult() -> [String:JavaUtilArrayList]{
        selectedKeys.removeAll()
        if manBtn.selected {
            selectedKeys.append("男")
        }
        
        if womanBtn.selected{
            selectedKeys.append("女")
        }
        
        if undefinitionBtn.selected{
            
            selectedKeys.append("未定义")
        }
        
        let list = JavaUtilArrayList()
        for item in selectedKeys {
            list.addWithId(item)
        }
        
        result = [FilterCategory.Gender.rawValue:list]
     
        return result
    }
    
    
    
    

  
}
