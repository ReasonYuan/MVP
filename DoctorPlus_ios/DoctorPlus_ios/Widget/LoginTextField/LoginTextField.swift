//
//  LoginTextField.swift
//  DoctorPlus_ios
//
//  Created by sunning on 15/11/25.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import UIKit
import Foundation

class LoginTextField: UIView{
    
    @IBOutlet weak var middleIcon: UIImageView!
    
    @IBOutlet weak var leftIcon: UIImageView!

    @IBOutlet weak var textField: UITextField!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setProperty()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setProperty()
    }

    


    
    /**
     设置view样式及为其添加tap事件
     */
    func setProperty(){
        let tap = UITapGestureRecognizer(target: self, action: "clicked")
        self.addGestureRecognizer(tap)
        UITools.setRoundBounds(23.0, view: self)
        self.backgroundColor = UITools.colorWithHexString("#1f1f27")
    }
    
    /**
     view被点击时输入框获取焦点
     */
    func clicked(){
        textField.becomeFirstResponder()
    }
    
    /**
     输入框失去或获取到焦点时，view的状态
     
     - parameter state: 输入框是否获取到焦点，true为获取的焦点
     */
    func setInputState(state:Bool){
        if state {
            middleIcon.alpha = 0.0
            leftIcon.alpha = 1.0
        }else{
            middleIcon.alpha = 1.0
            leftIcon.alpha = 0.0
        }
    }
    
    /**
     设置输入框文字颜色
     
     - parameter color: 文字颜色
     */
    func setTextColor(color:UIColor){
        textField.textColor = color
    }
    
    /**
     设置输入框文字字体大小
     
     - parameter font: 字体
     */
    func setTextFont(font:UIFont){
        textField.font = font
    }
    
    /**
     设置view背景色
     
     - parameter color: view背景色，默认为黑色
     */
    func setBackground(color:UIColor){
        self.backgroundColor = color;
    }
    
    /**
     设置左边图标的图片
     
     - parameter name: 图片名称
     */
    func setLeftIconImg(name:String){
        self.leftIcon.image = UIImage(named: name)
    }
    /**
     设置中间图标的图片
     
     - parameter name: 图片名称
     */
    func setMiddleIconImg(name:String){
        self.middleIcon.image = UIImage(named: name)
    }
}
