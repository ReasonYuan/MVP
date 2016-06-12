//
//  DashedLineView.swift
//  DoctorPlus_ios
//
//  Created by Monkey on 15/12/16.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import UIKit

class DashedLineView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UITools.colorWithHexString("#F1F1F1")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
    
        let context = UIGraphicsGetCurrentContext()
        let lengths: [CGFloat] = [2.0, 2.0]
        CGContextSetStrokeColorWithColor(context, UITools.colorWithHexString("#919191").CGColor)
        CGContextSetLineDash(context, 0, lengths, 1);
        CGContextMoveToPoint(context, 0, 0);
        CGContextAddLineToPoint(context, ScreenWidth, 0);
        CGContextStrokePath(context);
    }

}
