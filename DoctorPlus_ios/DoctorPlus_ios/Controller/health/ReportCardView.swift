//
//  ReportCardView.swift
//  Care
//
//  Created by 廖敏 on 15/8/26.
//  Copyright (c) 2015年 YiYiHealth. All rights reserved.
//

import UIKit

class ReportCardView: UIView {
    private var sorelable:UILabel!
    var lableBg:UIView!
    let colors:[UIColor] = [Tools.colorWithHexString("#6dc973"),Tools.colorWithHexString("#dfd052"),Tools.colorWithHexString("#e98134"),Tools.colorWithHexString("#f6294f")]
    var lable:UILabel!
    var score:String = "A"{
        didSet{
            switch self.score {
                case "A":
                    lableBg.backgroundColor = colors[0]
                    break
                case "B":
                    lableBg.backgroundColor = colors[1]
                    break
                case "C":
                    lableBg.backgroundColor = colors[2]
                    break
                case "D":
                    lableBg.backgroundColor = colors[3]
                    break
                default:
                    lableBg.backgroundColor = UIColor.greenColor()
            }
            sorelable.text = score
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        let lableWidth = frame.size.width * 324 / 375.0
        let lableBgWidth = frame.size.width - lableWidth
        lableBg = UIView(frame: CGRectMake(0, 0, lableBgWidth, frame.size.height))
        score = "A"
        lableBg.backgroundColor = colors[0]
        lable = UILabel(frame: CGRectMake(lableBgWidth, 0, lableWidth, frame.size.height))
        self.addSubview(lableBg)
        self.addSubview(lable)
        lable.textAlignment = NSTextAlignment.Center
        lable.backgroundColor = Tools.colorWithHexString("#f1f1f1")
        lable.font = UIFont.systemFontOfSize(18)
        lable.text = "胃胃胃胃胃胃胃胃胃胃胃胃胃胃胃胃胃胃"
        lable.numberOfLines = 2
        lableBg.backgroundColor = UIColor.greenColor()
        lable.textColor = Tools.colorWithHexString("#333333")
        sorelable = UILabel(frame: lableBg.bounds)
        lableBg.addSubview(sorelable)
        sorelable.textAlignment = NSTextAlignment.Center
        sorelable.backgroundColor = UIColor.clearColor()
        sorelable.font = UIFont.boldSystemFontOfSize(18)
        sorelable.textColor = UIColor.whiteColor()
        sorelable.text = score
        
        self.layer.shadowRadius = 3.0
        self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSizeMake(0, 0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

}
