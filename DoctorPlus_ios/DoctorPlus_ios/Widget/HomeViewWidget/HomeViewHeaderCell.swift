//
//  HomeViewHeaderCell.swift
//  DoctorPlus_ios
//
//  Created by 廖敏 on 15/4/28.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

var HomeViewHeaderCellFontSize:CGFloat = 0

class HomeViewHeaderCell: UICollectionViewCell {
    
    @IBOutlet weak var mImageBg: UIImageView!

    var mMonthLable: UILabel!
    
    var mWeekLable: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.addSubview(mMonthLable)
        self.contentView.addSubview(mWeekLable)
        // Initialization code
    }
    
    func showBg(){
        mImageBg.hidden = false
    }
    
    func reset(){
        mImageBg.hidden = true
    }
    
    func setMonthText(text:String!){
        mMonthLable.text = text
    }
    
    func setWeekText(text:String!){
        mWeekLable.text = text
    }
    
    
    init() {
        super.init(frame:CGRectZero)
        self.onCreate()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.onCreate()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.onCreate()
    }
    
    func onCreate(){
        mMonthLable = UILabel()
        mWeekLable = UILabel()
        mMonthLable.textAlignment = NSTextAlignment.Center
        mWeekLable.textAlignment = NSTextAlignment.Center
    }

    
    override func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        if newSuperview != nil {
            let frame = self.frame
            let maxHeigth =  frame.size.height*3/9
            let maxWidth =  frame.size.width/2
            if(HomeViewHeaderCellFontSize <= 0){
                HomeViewHeaderCellFontSize = Tools.getMaxFontSizeInRect(CGRect(x: 0 ,y: 0,width: maxWidth,height: frame.size.height*3/8))
            }
            mWeekLable.font = UIFont.systemFontOfSize(HomeViewHeaderCellFontSize)
            mMonthLable.font = UIFont.systemFontOfSize(HomeViewHeaderCellFontSize*3/4)

            mWeekLable.frame = CGRectMake(0, frame.size.height/2.0 - maxHeigth, frame.size.width, maxHeigth)
            mMonthLable.frame = CGRectMake(0, frame.size.height/2.0, frame.size.width, maxHeigth)

        }
    }
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        CGContextSetRGBStrokeColor(context,98/255.0,192/255.0,180/255.0,1)
        let lineWidth:CGFloat = 1
        CGContextSetLineWidth(context, lineWidth)
        CGContextSetLineCap(context, CGLineCap.Butt)
        CGContextMoveToPoint(context, 0, lineWidth)
        CGContextAddLineToPoint(context, rect.size.width, lineWidth)
        CGContextStrokePath(context)
        super.drawRect(rect)
    }

}
