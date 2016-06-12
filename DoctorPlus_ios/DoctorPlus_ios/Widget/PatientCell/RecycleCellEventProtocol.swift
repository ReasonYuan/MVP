//
//  RecycleCellEventProtocol.swift
//  DoctorPlus_ios
//
//  Created by reason on 15/10/22.
//  Copyright (c) 2015年 YiYiHealth. All rights reserved.
//

protocol RecycleCellEventProtocol : PatientCellEventProtocol {
    
    func onCellRecover(indexPath:NSIndexPath)
    
}
