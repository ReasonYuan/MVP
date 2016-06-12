//
//  AgeView.swift
//  DoctorPlus_ios
//
//  Created by chenjie on 15/12/16.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import UIKit

class AgeView: UIView {
    @IBOutlet weak var firstBtn: UIButton!
    @IBOutlet weak var secondBtn: UIButton!
    @IBOutlet weak var thirdBtn: UIButton!
    @IBOutlet weak var fourthBtn: UIButton!
    @IBOutlet weak var fifthBtn: UIButton!
    @IBOutlet weak var sixthBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    /// 传进来的关键字
    var mKeys = JavaUtilArrayList()
    /// 返回给外层的字典
    var result = [String:JavaUtilArrayList]()
    /// 选中的关键字
    var selectedKeys = [String]()
    
    
    var startAge = 0
    var endAge = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("AgeView", owner: self, options: nil)
        let view = nibs.lastObject as! UIView
        view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height)
        self.addSubview(view)
        UITools.setRoundBounds(11, view: titleLabel)
        
        addResetNotification()
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func btnClick(sender: AnyObject) {
        (sender as! UIButton).selected = !(sender as! UIButton).selected
    }
    
    //添加重置选择的通知
    func addResetNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onResetFilterKeys", name: ChoseFilterKeysView.FilterNotificationKey, object: nil)
    }
    
    //重置选择的操作
    func onResetFilterKeys() {
        initBtn()
    }
    var set = Set<Int>()
    //设置筛选的数据
    //keys : ArrayList<ComFqHalcyonEntityPracticeFilterItem>
    func setKeys(keys:JavaUtilArrayList) {
        mKeys = keys
        if keys.size() > 0 {
            for var i:Int32 = 0 ; i < keys.size() ; i++ {
                let item = mKeys.getWithInt(i) as! ComFqHalcyonEntityPracticeFilterItem
                let str = item.getItemsName() as NSString
                let index:Int = Int(str.indexOfString("~"))
                if index > 0 {
                    let start =  Int(str.substringToIndex(index))
                    let end = Int(str.substringFromIndex(index + 1))
                    set.insert(start!)
                    set.insert(end!)
                }else{
                    set.insert(Int(str as String)!)
                }
                
                
            }
            
            startAge = set.sort()[0]
            endAge = set.sort()[set.sort().count - 1]
        }
        print(startAge)
        
        print(endAge)
        
        initBtn()
    }
    
    /**
     获取单项的名字
     
     - parameter i: 某项
     
     - returns: title
     */
    private func getItemName(i:Int32) -> String{
        let item = mKeys.getWithInt(i) as! ComFqHalcyonEntityPracticeFilterItem
        return item.getItemsName()
    }
    
    //    /**
    //     初始化Btn状态
    //     */
    //    private func initBtn(){
    //        firstBtn.selected = true
    //        secondBtn.selected = true
    //        thirdBtn.selected = true
    //        fourthBtn.selected = true
    //        fifthBtn.selected = true
    //        sixthBtn.selected = true
    //        let k = mKeys.size()
    //        if k >= 6{
    //            firstBtn.setTitle(getItemName(0), forState: UIControlState.Normal)
    //            secondBtn.setTitle(getItemName(1), forState: UIControlState.Normal)
    //            thirdBtn.setTitle(getItemName(2), forState: UIControlState.Normal)
    //            fourthBtn.setTitle(getItemName(3), forState: UIControlState.Normal)
    //            fifthBtn.setTitle(getItemName(4), forState: UIControlState.Normal)
    //            sixthBtn.setTitle(getItemName(5), forState: UIControlState.Normal)
    //        }else if k == 5{
    //            firstBtn.setTitle(getItemName(0), forState: UIControlState.Normal)
    //            secondBtn.setTitle(getItemName(1), forState: UIControlState.Normal)
    //            thirdBtn.setTitle(getItemName(2), forState: UIControlState.Normal)
    //            fourthBtn.setTitle(getItemName(3), forState: UIControlState.Normal)
    //            fifthBtn.setTitle(getItemName(4), forState: UIControlState.Normal)
    //            sixthBtn.hidden = true
    //
    //            sixthBtn.enabled = false
    //
    //        }else if k == 4{
    //            firstBtn.setTitle(getItemName(0), forState: UIControlState.Normal)
    //            secondBtn.setTitle(getItemName(1), forState: UIControlState.Normal)
    //            thirdBtn.setTitle(getItemName(2), forState: UIControlState.Normal)
    //            fourthBtn.setTitle(getItemName(3), forState: UIControlState.Normal)
    //            fifthBtn.hidden = true
    //            sixthBtn.hidden = true
    //
    //            fifthBtn.enabled = false
    //            sixthBtn.enabled = false
    //        }else if k == 3{
    //            firstBtn.setTitle(getItemName(0), forState: UIControlState.Normal)
    //            secondBtn.setTitle(getItemName(1), forState: UIControlState.Normal)
    //            thirdBtn.setTitle(getItemName(2), forState: UIControlState.Normal)
    //            fourthBtn.hidden = true
    //            fifthBtn.hidden = true
    //            sixthBtn.hidden = true
    //
    //            fourthBtn.enabled = false
    //            fifthBtn.enabled = false
    //            sixthBtn.enabled = false
    //
    //        }else if k == 2{
    //            firstBtn.setTitle(getItemName(0), forState: UIControlState.Normal)
    //            secondBtn.setTitle(getItemName(1), forState: UIControlState.Normal)
    //            thirdBtn.hidden = true
    //            fourthBtn.hidden = true
    //            fifthBtn.hidden = true
    //            sixthBtn.hidden = true
    //
    //            thirdBtn.enabled = false
    //            fourthBtn.enabled = false
    //            fifthBtn.enabled = false
    //            sixthBtn.enabled = false
    //        }else if k == 1{
    //            firstBtn.setTitle(getItemName(0), forState: UIControlState.Normal)
    //            secondBtn.hidden = true
    //            thirdBtn.hidden = true
    //            fourthBtn.hidden = true
    //            fifthBtn.hidden = true
    //            sixthBtn.hidden = true
    //
    //            secondBtn.enabled = false
    //            thirdBtn.enabled = false
    //            fourthBtn.enabled = false
    //            fifthBtn.enabled = false
    //            sixthBtn.enabled = false
    //
    //        }else if k == 0{
    //            firstBtn.hidden = true
    //            secondBtn.hidden = true
    //            thirdBtn.hidden = true
    //            fourthBtn.hidden = true
    //            fifthBtn.hidden = true
    //            sixthBtn.hidden = true
    //
    //            firstBtn.enabled = false
    //            secondBtn.enabled = false
    //            thirdBtn.enabled = false
    //            fourthBtn.enabled = false
    //            fifthBtn.enabled = false
    //            sixthBtn.enabled = false
    //        }
    //
    //    }
    
    
    func getResult() -> [String:JavaUtilArrayList]{
        selectedKeys.removeAll()
        if firstBtn.selected{
            selectedKeys.append(firstBtn.titleForState(UIControlState.Normal)!)
        }
        if secondBtn.selected{
            selectedKeys.append(secondBtn.titleForState(UIControlState.Normal)!)
        }
        if thirdBtn.selected{
            selectedKeys.append(thirdBtn.titleForState(UIControlState.Normal)!)
        }
        if fourthBtn.selected{
            selectedKeys.append(fourthBtn.titleForState(UIControlState.Normal)!)
        }
        if fifthBtn.selected{
            selectedKeys.append(fifthBtn.titleForState(UIControlState.Normal)!)
        }
        if sixthBtn.selected{
            selectedKeys.append(sixthBtn.titleForState(UIControlState.Normal)!)
        }
        let list = JavaUtilArrayList()
        for item in selectedKeys {
            list.addWithId(item)
        }
        result = [FilterCategory.Age.rawValue:list]
        
        return result
    }
    
    
    func initBtn(){
        
        firstBtn.selected = true
        secondBtn.selected = true
        thirdBtn.selected = true
        fourthBtn.selected = true
        fifthBtn.selected = true
        sixthBtn.selected = true
        
        if startAge != 0 && startAge != 0{
            let k = endAge - startAge
            if k >= 5{
                let x:Int = k/5
                firstBtn.setTitle("\(startAge)-\(startAge+x)", forState: UIControlState.Normal)
                secondBtn.setTitle("\(startAge+x)-\(startAge+2*x)", forState: UIControlState.Normal)
                thirdBtn.setTitle("\(startAge+2*x)-\(startAge+3*x)", forState: UIControlState.Normal)
                fourthBtn.setTitle("\(startAge+3*x)-\(startAge+4*x)", forState: UIControlState.Normal)
                fifthBtn.setTitle("\(startAge+4*x)-\(endAge)", forState: UIControlState.Normal)
                sixthBtn.setTitle("不详", forState: UIControlState.Normal)
            }else if k == 4{
                firstBtn.setTitle("\(startAge)-\(startAge+1)", forState: UIControlState.Normal)
                secondBtn.setTitle("\(startAge+1)-\(startAge+2)", forState: UIControlState.Normal)
                thirdBtn.setTitle("\(startAge+2)-\(startAge+3)", forState: UIControlState.Normal)
                fourthBtn.setTitle("\(startAge+3)-\(startAge+4)", forState: UIControlState.Normal)
                fifthBtn.setTitle("不详", forState: UIControlState.Normal)
                sixthBtn.hidden = true
                sixthBtn.selected = false
                
            }else if k == 3{
                firstBtn.setTitle("\(startAge)-\(startAge+1)", forState: UIControlState.Normal)
                secondBtn.setTitle("\(startAge+1)-\(startAge+2)", forState: UIControlState.Normal)
                thirdBtn.setTitle("\(startAge+2)-\(startAge+3)", forState: UIControlState.Normal)
                fourthBtn.setTitle("不详", forState: UIControlState.Normal)
                fifthBtn.hidden = true
                sixthBtn.hidden = true
                
                fifthBtn.selected = false
                sixthBtn.selected = false
                
            }else if k == 2{
                firstBtn.setTitle("\(startAge)-\(startAge+1)", forState: UIControlState.Normal)
                secondBtn.setTitle("\(startAge+1)-\(startAge+2)", forState: UIControlState.Normal)
                thirdBtn.setTitle("不详", forState: UIControlState.Normal)
                fourthBtn.hidden = true
                fifthBtn.hidden = true
                sixthBtn.hidden = true
                
                fifthBtn.selected = false
                fourthBtn.selected = false
                sixthBtn.selected = false
                
            }else if k == 1{
                firstBtn.setTitle("\(startAge)-\(startAge+1)", forState: UIControlState.Normal)
                secondBtn.setTitle("不详", forState: UIControlState.Normal)
                thirdBtn.hidden = true
                fourthBtn.hidden = true
                fifthBtn.hidden = true
                sixthBtn.hidden = true
                
                thirdBtn.selected = false
                fourthBtn.selected = false
                fifthBtn.selected = false
                sixthBtn.selected = false
                
            }else if k == 0{
                firstBtn.setTitle("\(startAge)", forState: UIControlState.Normal)
                secondBtn.setTitle("不详", forState: UIControlState.Normal)
                thirdBtn.hidden = true
                fourthBtn.hidden = true
                fifthBtn.hidden = true
                sixthBtn.hidden = true
                
                thirdBtn.selected = false
                fourthBtn.selected = false
                fifthBtn.selected = false
                sixthBtn.selected = false
                
            }
        }else {
            firstBtn.setTitle("不详", forState: UIControlState.Normal)
            secondBtn.hidden = true
            thirdBtn.hidden = true
            fourthBtn.hidden = true
            fifthBtn.hidden = true
            sixthBtn.hidden = true
            
            secondBtn.selected = false
            thirdBtn.selected = false
            fourthBtn.selected = false
            fifthBtn.selected = false
            sixthBtn.selected = false

        }
        
    }
    
    
}
