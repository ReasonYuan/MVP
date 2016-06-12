//
//  MyPatientAdapter.swift
//  DoctorPlus_ios
//
//  Created by Monkey on 15/11/30.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import Foundation

class MyPatientAdapter:ContentsBaseAdapter ,ComFqHalcyonLogicPracticePatientUpdateListLogic_PatientListCallback,ComFqHalcyonLogicPracticeRecycleLogic_Remove2RecycleCallBack{
    
    override func fetchData() {
        let logic = ComFqHalcyonLogicPracticePatientUpdateListLogic(comFqHalcyonLogicPracticePatientUpdateListLogic_PatientListCallback: self)
        logic.requestPatientListWithInt(1, withInt: 20)
    }
    
    func loadPatientErrorWithInt(code: Int32, withNSString msg: String!) {
        
    }
    
    func loadPatientSuccessWithJavaUtilArrayList(keys: JavaUtilArrayList!, withJavaUtilHashMap map: JavaUtilHashMap!) {
        var keysList = [String]()
        var contentDic = Dictionary<String,Array<Any>>()
        
        for i in 0..<keys.size() {
            keysList.append(keys.getWithInt(i) as! String)
        }
        
        for item in keysList {
            let list = map.getWithId(item) as! JavaUtilArrayList
            var contentList = Array<Any>()
            for var i:Int32 = 0 ; i < list.size() ; i++ {
                contentList.append(list.getWithInt(i) as! ComFqHalcyonEntityPracticePatientAbstract)
            }
            contentDic[item] = contentList
        }
        addItems(keysList, rows: contentDic)
        protectedNotifyDataChanged()
    }
    
    func loadPatientSuccessWithJavaUtilHashMap(map: JavaUtilHashMap!) {
        
        var keysList = [String]()
        var contentDic = Dictionary<String,Array<Any>>()
        
        let set = map.keySet()
        let iterator = set.iterator()
        while iterator.hasNext() {
            keysList.append(iterator.next() as! String)
        }
        
        for item in keysList {
            let list = map.getWithId(item) as! JavaUtilArrayList
            var contentList = Array<Any>()
            for var i:Int32 = 0 ; i < list.size() ; i++ {
                contentList.append(list.getWithInt(i) as! ComFqHalcyonEntityPracticePatientAbstract)
            }
            contentDic[item] = contentList
        }
        addItems(keysList, rows: contentDic)
        protectedNotifyDataChanged()
    }
    
    /**
     获取所有选中的item
     
     - returns: 返回选中的列表
     */
    func getAllSelectedItem() -> Array<ComFqHalcyonEntityPracticePatientAbstract>{
        
        var result = Array<ComFqHalcyonEntityPracticePatientAbstract>()
        
        for items in rowsInSections {
            
            for item in items {
                let tmp = item as! ComFqHalcyonEntityPracticePatientAbstract
                if tmp.isSelected() {
                    result.append(tmp)
                }
            }
        }
        
        return result
    }
    
    //获取某个item的位置
    func getItemPosition(item:ComFqHalcyonEntityPracticePatientAbstract) -> (section:Int,row:Int) {
        
        for (section,items) in rowsInSections.enumerate() {
            for (row,tmp) in items.enumerate() {
                if (tmp as! ComFqHalcyonEntityPracticePatientAbstract) === item {
                    return (section,row)
                }
            }
        }
        
        return (-1,-1)
    }
    
    /**
     删除选中项
     */
    func deleteSelectedItems() {
        for item in getAllSelectedItem() {
            var section = -1
            var row = -1
            (section,row) = getItemPosition(item)
            if section != -1 && row != -1 {
                removeItem(section, rowIndex: row)
            }
        }
    }
    
    /**
     删除数据的逻辑
     */
    func deleteSelectedItemsLogic() {
        
        let selectedArray = JavaUtilArrayList()
        for item in getAllSelectedItem() {
            selectedArray.addWithId(item as ComFqHalcyonEntityPracticePatientAbstract)
        }
        
        let logic = ComFqHalcyonLogicPracticeRecycleLogic(comFqHalcyonLogicPracticeRecycleLogic_Remove2RecycleCallBack: self)
        logic.removePatientDataWithJavaUtilArrayList(selectedArray)
    }
    
    func removeSuccess() {
        deleteSelectedItems()
    }
    
    func removeErrorWithInt(code: Int32, withNSString msg: String!) {
        print("删除数据失败")
    }
}