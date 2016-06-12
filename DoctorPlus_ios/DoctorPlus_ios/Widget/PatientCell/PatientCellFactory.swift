//
//  PatientCellFactory.swift
//  DoctorPlus_ios
//
//  Created by reason on 15/10/22.
//  Copyright (c) 2015年 YiYiHealth. All rights reserved.
//

import Foundation

/**
CELL的类型
*/
enum CELL_TYPE{
   case CASE     //病例
   case RECORD   //记录
   case PATIENT  //患者
}


class PatientCellFactory{
   
    /**
    根据类型得到cell
    - parameter type: cell的类型
    - returns: 满足类型的cell
    */
    class func createCell(type:CELL_TYPE) -> PatientCell{
        switch(type){
        case CELL_TYPE.CASE:
            return CaseCell()
        case CELL_TYPE.RECORD:
            return RecordCell()
        case CELL_TYPE.PATIENT:
            return SuffererViewCell()
        default:
            return CaseCell()
        }
    }
    
    
    /**
    根据类型得到回收站的cell
    - parameter type: cell的类型
    - returns: 满足类型的cell
    */
    class func createRecycleCell(type:CELL_TYPE) -> PatientCell{
        if(type == CELL_TYPE.CASE){
            return RecycleCaseCell()
        }else{
            return RecycleRecordCell()
        }
    }
    
    
}

