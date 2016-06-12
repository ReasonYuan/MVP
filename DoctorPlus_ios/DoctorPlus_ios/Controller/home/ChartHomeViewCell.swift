//
//  ChartHomeViewCell.swift
//  DoctorPlus_ios
//
//  主页TableView内嵌的cell，主要有分隔线、两边的边距和装载具体view的容器
//
//  Created by reason on 15/11/30.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import UIKit

class ChartHomeViewCell: UITableViewCell {

    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var view: HomeBaseView!    //cell的核心view，即图表控件
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        UITools.setRoundBounds(9.0, view: titleLabel)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    /**
     添加子控件
     - parameter view: 要添加的控件
     */
    func addView(view: UIView) {
        containerView.addSubview(view)
//        UITools.addChildViewFullInParent(view, parent: containerView)
    }
    
    /**
     隐藏上方分隔线
     */
    func hiddenDivider(hidden:Bool) {
        contentView.viewWithTag(11)?.hidden = hidden
        titleLabel.hidden = hidden
    }
    
    /**
     得到容器大小
     - returns: 容器大小
     */
    func getContainerFrame() -> CGRect {
        return containerView.frame
    }
    
    func getContainerWidth() -> CGFloat{
        return containerView.frame.width
    }
    
    /**
     移除所有子控件
     */
    func clearAllSubView() {
        let arys = containerView.subviews
        for view in arys {
            view.removeFromSuperview()
        }
    }
    
}
