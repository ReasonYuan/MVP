//
//  SwitchView.swift
//  DoctorPlus_ios
//
//  Created by chenjie on 15/11/30.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import UIKit
protocol SwitchViewDelegate{
    /**
     switchView状态改变
     
     - parameter switchView: 状态改变的switchView 
     */
    func switchViewStateChanged(switchView:SwitchView)
}

class SwitchView: UIView {
    
    var onImage:UIImage?
    var offImage:UIImage?
    var on:Bool = false
    var delegate:SwitchViewDelegate?
    @IBOutlet weak var imageView: UIImageView!
    
    init(frame: CGRect,onImageName:String,offImageName:String) {
        super.init(frame: frame)
        self.onImage = UIImage(named:onImageName)
        self.offImage = UIImage(named:offImageName)
        let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("SwitchView", owner: self, options: nil)
        let view = nibs.lastObject as! UIView
        view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height)
        self.addSubview(view)
        setImage(on)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /**
     设置switchview开关
     
     - parameter on: true开 false 关
     */
    func setON(on:Bool){
        self.on = on
        setImage(on)
        
    }
    
    /**
     设置图片
     
     - parameter on: ture为onImage false为offImage
     */
    private func setImage(on:Bool){
        if on {
            imageView.image = onImage
        }else{
            imageView.image = offImage
        }
    }
    
    @IBAction func onClick(sender: AnyObject) {
        setON(!self.on)
        delegate?.switchViewStateChanged(self)
        
    }
    
    
}
