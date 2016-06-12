//
//  RecycleContentsAdapter.swift
//  DoctorPlus_ios
//
//  Created by Nan on 15/10/22.
//  Copyright (c) 2015年 YiYiHealth. All rights reserved.
//

import Foundation

//回收站
class RecycleContentsAdapter : ContentsBaseAdapter ,ComFqHalcyonLogicPracticeRecycleLogic_RecycleCallBack{
    
    override func fetchData() {
        let logic = ComFqHalcyonLogicPracticeRecycleLogic(comFqHalcyonLogicPracticeRecycleLogic_RecycleCallBack: self)
        logic.loadRecyleListWithInt(1, withInt: 20)
    }
    
    func recycleDatasWithJavaUtilArrayList(keys: JavaUtilArrayList!, withJavaUtilHashMap recyDataMap: JavaUtilHashMap!) {
        
        var keysList = [String]()
        var contentDic = Dictionary<String,Array<Any>>()
        
        for var i:Int32 = 0 ; i < keys.size() ; i++ {
            keysList.append(keys.getWithInt(i) as! String)
        }
        
        for item in keysList {
            let list = recyDataMap.getWithId(item) as! JavaUtilArrayList
            var contentList = Array<Any>()
            for var i:Int32 = 0 ; i < list.size() ; i++ {
                contentList.append(list.getWithInt(i) as! ComFqHalcyonEntityPracticeRecordData)
            }
            contentDic[item] = contentList
        }
        
        addItems(keysList, rows: contentDic)
        protectedNotifyDataChanged()
    }
    
    func recycleErrorWithInt(code: Int32, withNSString msg: String!) {
        protectedNotifyError(Int(code), msg: msg)
    }
    
    func recycelClearDataSuccess() {
        deleteSelectedItems()
        protectedNotifyDataChanged()
    }
    
    func recycelRestoreDataSuccess() {
        deleteSelectedItems()
        protectedNotifyDataChanged()
    }
    
    /**
     获取所有选中的item
     
     - returns: 返回选中的列表
     */
    func getAllSelectedItem() -> Array<ComFqHalcyonEntityPracticeRecordData>{
        
        var result = Array<ComFqHalcyonEntityPracticeRecordData>()
        
        for items in rowsInSections {
            
            for item in items {
                let tmp = item as! ComFqHalcyonEntityPracticeRecordData
                if tmp.isSelected() {
                    result.append(tmp)
                }
            }
        }
        
        return result
    }
    
    //获取某个item的位置
    func getItemPosition(item:ComFqHalcyonEntityPracticeRecordData) -> (section:Int,row:Int) {
        
        for (section,items) in rowsInSections.enumerate() {
            for (row,tmp) in items.enumerate() {
                if (tmp as! ComFqHalcyonEntityPracticeRecordData) === item {
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
     还原所有选中项的逻辑
     */
    func restoreSelectedItemsLogic() {
        
        if getAllSelectedItem().count == 0 {
            return
        }
        
        let logic = ComFqHalcyonLogicPracticeRecycleLogic(comFqHalcyonLogicPracticeRecycleLogic_RecycleCallBack: self)
        logic.retoreDataWithJavaUtilArrayList(getAllSelectedItemWithJava())
    }
    
    /**
     删除所有选中的item的逻辑
     */
    func deleteSelectedItemLogic() {
        
        let logic = ComFqHalcyonLogicPracticeRecycleLogic(comFqHalcyonLogicPracticeRecycleLogic_RecycleCallBack: self)
        logic.clearDataWithJavaUtilArrayList(getAllSelectedItemWithJava())
        
    }
    
    func getAllSelectedItemWithJava() -> JavaUtilArrayList {
        let selectedArray = JavaUtilArrayList()
        for item in getAllSelectedItem() {
            selectedArray.addWithId(item)
        }
        
        return selectedArray
    }
}