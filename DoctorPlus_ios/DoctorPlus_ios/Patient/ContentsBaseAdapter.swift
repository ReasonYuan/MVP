//
//  ContentsBaseAdapter.swift
//  DoctorPlus_ios
//
//  Created by Nan on 15/10/22.
//  Copyright (c) 2015年 YiYiHealth. All rights reserved.
//

import Foundation

protocol ContentsBaseAdapterDelegate {
    
    //当取得数据后通知观察者
    func onDataChanged()
    //出错后通知观察者
    func onBaseAdapterError(code:Int,msg:String)
    
}

class ContentsBaseAdapter:NSObject {
    
    //分组的数据(病案)
    var sectionsPatient = [ComFqHalcyonEntityPracticeRecordAbstract_PatientInfo]()
    //分组的数据
    var sections = [String]()
    //组里面的实际数据
    var rowsInSections = [Array<Any>]()
    
    //内容观察者
    var contentsObservers:[ContentsBaseAdapterDelegate] = []
    
    //注册内容监听、观察者
    //param: observer 观察者
    func registerContentsObserver(observer:ContentsBaseAdapterDelegate){
        contentsObservers.append(observer)
    }
    
    func fetchData(){
        //TODO fetching data
    }
    
    //设置分组的数据
    func setItems(sections:[String]) {
        
        self.sections = sections
        
    }
    
    //移除某个数据
    func removeItem(sectionIndex:Int,rowIndex:Int) {
        
        rowsInSections[sectionIndex].removeAtIndex(rowIndex)
        
        if rowsInSections[sectionIndex].count == 0 {
            sections.removeAtIndex(sectionIndex)
            rowsInSections.removeAtIndex(sectionIndex)
        }
        
//        protectedNotifyDataChanged()
    }
    
    //得到某个item
    func getItem(sectionIndex:Int,rowIndex:Int) -> Any {
        return rowsInSections[sectionIndex][rowIndex]
    }
    
    
    //在已经存在的组里添加数据,通过组的位置添加
    func addItems(sectionIndex:Int,items:[Any]) {
        
        rowsInSections[sectionIndex] += items
        
//        protectedNotifyDataChanged()
    }
    
    //直接添加组和组里的数据
    func addItems(sections:[String],rows:Dictionary<String,Array<Any>>) {
        
        for item in sections {
            var isExist = false
            var secIndex = 0
            for (index,sec) in self.sections.enumerate() {
                if item == sec {
                    isExist = true
                    secIndex = index
                    break
                }
            }
            if !isExist {
                self.sections.append(item)
                self.rowsInSections.append(rows[item]!)
            }else{
                rowsInSections[secIndex] += rows[item]!
            }
        }
        
//        protectedNotifyDataChanged()
    }
    
    
    //直接添加组和组里的数据(病案)
    func addItems(sections:[ComFqHalcyonEntityPracticeRecordAbstract_PatientInfo],rows:Dictionary<ComFqHalcyonEntityPracticeRecordAbstract_PatientInfo,Array<Any>>) {
        
        for item in sections {
            var isExist = false
            var secIndex = 0
            for (index,sec) in self.sectionsPatient.enumerate() {
                if item == sec {
                    isExist = true
                    secIndex = index
                    break
                }
            }
            if !isExist {
                self.sectionsPatient.append(item)
                self.rowsInSections.append(rows[item]!)
            }else{
                rowsInSections[secIndex] += rows[item]!
            }
        }
        
        //        protectedNotifyDataChanged()
    }

    //获取组数
    func getSectionsNumber() -> Int{
        return sections.count
    }
    
    //获取组里的元素的个数
    func getRowsInSectionNumber(sectionIndex:Int) -> Int {
        return rowsInSections[sectionIndex].count
    }
    
    //通知数据改变
    func protectedNotifyDataChanged(){
        //notify observers
        for observer in contentsObservers {
            observer.onDataChanged()
        }
    }
    
    //通知数据改变
    func protectedNotifyError(code:Int, msg:String){
        //notify observers
        for observer in contentsObservers {
            observer.onBaseAdapterError(
                code, msg: msg)
        }
    }
}

