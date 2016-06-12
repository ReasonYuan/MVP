//
//  HomeMonthView.swift
//  DoctorPlus_ios
//
//  Created by 廖敏 on 15/4/30.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class HomeMonthViewInfo : NSObject {
    var mRangeRect:CGRect! = CGRectMake(0, 0, 40, 50)
    var group:Int! = 0
    var view:HomeMonthView?
    var max:CGFloat!
    var min:CGFloat!
    var monthNum:String!
    var monthVal:String!
    
    init(frame: CGRect,monthNum:String,monthVal:String) {
        super.init()
        self.mRangeRect = frame
        self.monthNum = monthNum
        self.monthVal = monthVal
        max = mRangeRect.origin.x + mRangeRect.size.width
        min = mRangeRect.origin.x
    }
    
    func contain(startX:CGFloat,endX:CGFloat,contentSizeX:CGFloat) -> Bool{
        return startX <= 0 || endX >= contentSizeX || (startX >= min && startX <= max) || (endX >= min && endX <= max)
    }
    
    func offset(startX:CGFloat,endX:CGFloat){
        if view != nil {
            let frame = view!.frame
            let oldX = frame.origin.x
            var newX:CGFloat!
            repeat {
                if( (startX + frame.size.width) >= max){
                    newX = max - startX - frame.size.width
                    break
                }
                if(min >= startX ){
                    newX =  min  - startX
                    break
                }
                newX = CGFloat(0)
            } while (false)
            if oldX != newX {
                view!.frame = CGRectMake(newX, frame.origin.y, frame.size.width, frame.size.height)
            }
        }
    }
}

class HomeMonthView : UIButton {
    
    var mMonthVal:UILabel!
    var mMonthNum:UILabel!

    
    init() {
        super.init(frame:CGRectMake(0, 0, 50, Home_month_heigth))

        self.backgroundColor = UIColor.clearColor()
        mMonthVal = UILabel(frame: CGRectMake(0, 0, 50, Home_month_heigth))
        self.addSubview(mMonthVal)
        mMonthNum = UILabel(frame: CGRectMake(0, 0, 50, Home_month_heigth))
        self.addSubview(mMonthNum)
    }
    
    func setInfo(monthNum:String,monthVal:String){
        mMonthNum.text = monthNum
        mMonthVal.text = monthVal

        let maxFontSize = Tools.getMaxFontSizeInRect(CGRectMake(0, 0, 1000, Home_month_heigth))
        mMonthNum.font = UIFont.boldSystemFontOfSize(maxFontSize)
        mMonthVal.font = UIFont.boldSystemFontOfSize(maxFontSize)
        let sizeNum = HomeMonthView.measureSize(monthNum, font: mMonthNum.font)
        
        let margin:CGFloat = 5
        mMonthNum.frame = CGRectMake(margin, 0, sizeNum.width+margin, Home_month_heigth)
        
        let sizeValue = HomeMonthView.measureSize(monthVal, font: mMonthNum.font)

        mMonthVal.frame = CGRectMake(sizeNum.width+margin*2, 0, sizeValue.width, Home_month_heigth)

        self.frame = CGRectMake(0, 0, mMonthVal.frame.origin.x + mMonthVal.frame.size.width, Home_month_heigth)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func measureSize(text:NSString,font:UIFont)->CGSize{
        return text.sizeWithAttributes([NSFontAttributeName:font])
    }

}
