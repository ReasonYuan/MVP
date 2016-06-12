//
//  LoadingView.swift
//  DoctorPlus_ios
//
//  Created by chenjie on 15/11/25.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import UIKit

class LoadingView: UIView {
    
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var bottomImageView: UIImageView!
    
    init(frame: CGRect,msg:String) {
        super.init(frame: frame)
        let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("LoadingView", owner: self, options: nil)
        let view = nibs.lastObject as! UIView
        view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height)
        self.addSubview(view)
        
    
        UITools.setFrameAnimation(bottomImageView, imageNames: ["loading_1.png","loading_2.png","loading_3.png","loading_4.png","loading_5.png","loading_6.png","loading_7.png","loading_8.png","loading_9.png"])
        
        topImageView.alpha = 1
        UIView.animateWithDuration(1, delay: 0, options: [UIViewAnimationOptions.Repeat,UIViewAnimationOptions.Autoreverse], animations: { () -> Void in
            self.topImageView.alpha = 0.5
            }) { (complet) -> Void in
                
        }

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

 

}
