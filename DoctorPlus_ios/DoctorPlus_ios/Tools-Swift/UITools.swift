//
//  UITools.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-4-29.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import Foundation
import UIKit
import HitalesSDK
import RealmSwift
import DataCache

var db:FMDatabase!
class UITools : NSObject {
    
    class func setRealmCachePath(){
        DataCache.path = FileSystem.getUserCachePath() + "/cache.realm"
    }
    
    /**
     设置btn的颜色，两种不同的点击状态
     isOpposite 表示按钮两种状态是否是相反的  （false 表示默认normal是填充满的 按下是空的）（true 表示默认normal是空的 按下是填充满的）
     
     **/
    class func setButtonWithColor(colorType:ColorType,btn:UIButton,isOpposite yes:Bool) {
        switch colorType {
        case .EMERALD:
            btn.titleLabel?.font = UIFont.systemFontOfSize(23)
            if !yes {
                btn.setTitleColor(Color.color_emerald, forState: UIControlState.Highlighted)
                btn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                //                Tools.createNinePathImageForImage(UIImage(named: "btn_gray_pressed.png"), leftMargin: 15, rightMargin: 15, topMargin: 15, bottomMargin: 5)
                btn.setBackgroundImage( Tools.createNinePathImageForImage(UIImage(named: "btn_green_normal.png"), leftMargin: 15, rightMargin: 15, topMargin: 15, bottomMargin: 5), forState: UIControlState.Normal)
                btn.setBackgroundImage(Tools.createNinePathImageForImage(UIImage(named: "btn_gray_pressed.png"), leftMargin: 15, rightMargin: 15, topMargin: 15, bottomMargin: 5), forState: UIControlState.Highlighted)
            }else {
                btn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
                btn.setTitleColor(Color.color_emerald, forState: UIControlState.Normal)
                btn.setBackgroundImage(Tools.createNinePathImageForImage(UIImage(named: "btn_gray_pressed.png"), leftMargin: 15, rightMargin: 15, topMargin: 15, bottomMargin: 5), forState: UIControlState.Normal)
                btn.setBackgroundImage(Tools.createNinePathImageForImage(UIImage(named: "btn_green_normal.png"), leftMargin: 15, rightMargin: 15, topMargin: 15, bottomMargin: 5), forState: UIControlState.Highlighted)
            }
            
        default:
            return
        }
    }
    
    /**
     设置btn的颜色，两种不同的点击状态  btn的背景色为医加绿
     isOpposite 表示按钮两种状态是否是相反的  （false 表示默认normal是填充满的 按下是空的）（true 表示默认normal是空的 按下是填充满的）
     
     **/
    class func setButtonWithBackGroundColor(colorType:ColorType,btn:UIButton,isOpposite yes:Bool) {
        switch colorType {
        case .EMERALD:
            btn.titleLabel?.font = UIFont.systemFontOfSize(23)
            if !yes {
                btn.setTitleColor(Color.color_emerald, forState: UIControlState.Highlighted)
                btn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                btn.setBackgroundImage(UITools.imageWithColor(Color.color_emerald), forState: UIControlState.Normal)
                btn.setBackgroundImage(UITools.imageWithColor(UIColor.whiteColor()), forState: UIControlState.Highlighted)
                btn.layer.borderWidth = 1.0
                btn.layer.borderColor = Color.color_emerald.CGColor
            }else {
                btn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
                btn.setTitleColor(Color.color_emerald, forState: UIControlState.Normal)
                btn.setBackgroundImage(UITools.imageWithColor(UIColor.whiteColor()), forState: UIControlState.Normal)
                btn.setBackgroundImage(UITools.imageWithColor(Color.color_emerald), forState: UIControlState.Highlighted)
            }
            
        default:
            return
        }
    }
    
    /**
     设置Button的样式
     btn:要设置的UIButton;
     buttonColor:Button的颜色;
     textSize:Button的文字大小;
     textColor:Button的文字颜色;
     isOpposite:表示按钮两种状态是否是相反的  （false 表示默认normal是填充满的 按下是空的）（true 表示默认normal是空的 按下是填充满的）如果不传入该参数，则默认是填充的
     radius:设置Button的圆角（如果不传入该参数，则默认是直角）
     */
    class func setButtonStyle(btn:UIButton,buttonColor:UIColor,textSize:CGFloat,textColor:UIColor,isOpposite:Bool = false, radius:CGFloat = 0){
        btn.titleLabel?.font = UIFont.systemFontOfSize(textSize)
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = radius
        if !isOpposite {
            /**常态是只有边框的，点击有填充色*/
            btn.setTitleColor(textColor, forState: UIControlState.Highlighted)
            btn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            btn.setBackgroundImage(UITools.imageWithColor(buttonColor), forState: UIControlState.Normal)
            btn.setBackgroundImage(UITools.imageWithColor(UIColor.whiteColor()), forState: UIControlState.Highlighted)
            btn.layer.borderWidth = 1.0
            btn.layer.borderColor = buttonColor.CGColor
        } else {
            /**常态是有填充色的，点击只有边框*/
            btn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
            btn.setTitleColor(textColor, forState: UIControlState.Normal)
            btn.setBackgroundImage(UITools.imageWithColor(UIColor.whiteColor()), forState: UIControlState.Normal)
            btn.setBackgroundImage(UITools.imageWithColor(buttonColor), forState: UIControlState.Highlighted)
            btn.layer.borderWidth = 1.0
            btn.layer.borderColor = buttonColor.CGColor
        }
    }
    
    /**为view设置圆角**/
    class func setRoundBounds(radius:CGFloat,view:UIView) {
        view.layer.masksToBounds = true
        view.layer.cornerRadius = radius
    }
    
    /**根据url生成相应的二维码**/
    class func createQrCode(url:String,imageview:UIImageView) -> UIImage{
        return QRCodeGenerator.qrImageForString(url, imageSize: imageview.bounds.size.width)
    }
    
    /**为UIVIew设置某个颜色的边框**/
    class func setBorderWithView(width:CGFloat,tmpColor:CGColorRef,view:UIView){
        view.layer.borderColor = tmpColor
        view.layer.borderWidth = width
//        view.layer.backgroundColor = UIColor(red:220/255.0,green:220/255.0,blue:220/255.0,alpha:1).CGColor
    }
    
    /**为UIVIew设置某个颜色的边框**/
    class func setBorderWidthWithView(width:CGFloat,tmpColor:CGColorRef,view:UIView){
        view.layer.borderColor = tmpColor
        view.layer.borderWidth = width
        view.layer.backgroundColor = UIColor.clearColor().CGColor
    }
    
    class func setBtnWithOneRound(btn:UIButton,corners: UIRectCorner){
        let maskPath = UIBezierPath(roundedRect: btn.bounds, byRoundingCorners: corners, cornerRadii: CGSizeMake(9, 9))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = btn.bounds
        maskLayer.path = maskPath.CGPath
        btn.layer.mask = maskLayer
    }
    
    /**
     设置按钮选中和未选中的样式
     btn:按钮
     selectedColor:选中的显示颜色
     unSelectedColor:未选中的颜色
     */
    class func setSelectBtnStyle(btn:UIButton,selectedColor:UIColor,unSelectedColor:UIColor){
        /**常态是只有边框的，选中时有填充色*/
        btn.setTitleColor(unSelectedColor, forState: UIControlState.Normal)
        btn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
        btn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
        btn.setBackgroundImage(UITools.imageWithColor(UIColor.whiteColor()), forState: UIControlState.Normal)
        btn.setBackgroundImage(UITools.imageWithColor(selectedColor), forState: UIControlState.Selected)
        btn.layer.borderWidth = 1.0
        btn.layer.borderColor = unSelectedColor.CGColor
    }
    
    /**
     设置按钮选中、未选中、不可点的样式
     btn:按钮
     selectedColor:选中的显示颜色
     unSelectedColor:未选中的颜色
     disabledColor:不可点时颜色
     */
    class func setBtnBackgroundColor(btn:UIButton,selectedColor:UIColor,unSelectedColor:UIColor,disabledColor:UIColor){
        /**常态是只有边框的，选中时有填充色*/
        btn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        //        btn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
        //        btn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
        btn.setBackgroundImage(UITools.imageWithColor(unSelectedColor), forState: UIControlState.Normal)
        btn.setBackgroundImage(UITools.imageWithColor(selectedColor), forState: UIControlState.Selected)
        btn.setBackgroundImage(UITools.imageWithColor(selectedColor), forState: UIControlState.Highlighted)
        btn.setBackgroundImage(UITools.imageWithColor(disabledColor), forState: UIControlState.Disabled)
        //        btn.layer.borderWidth = 1.0
        //        btn.layer.borderColor = unSelectedColor.CGColor
    }
    
    /**
     为UIVIew设置某个颜色的边框
     width:边框宽度
     borderColor:边框颜色
     backgroundColor:背景填充色
     view:需要设置边框的view
     **/
    class func setViewBorder(width:CGFloat,borderColor:UIColor,backgroundColor:UIColor,view:UIView){
        view.layer.borderColor = borderColor.CGColor
        view.layer.borderWidth = width
        view.layer.backgroundColor = backgroundColor.CGColor
    }
    
    /**设置头像背景为灰框淡红色的View**/
    class func setBorderWithHeadKuang(headKuang:UIView){
        headKuang.layer.masksToBounds = true
        let headKuangrect:CGRect? = headKuang.bounds
        headKuang.layer.cornerRadius = CGRectGetHeight(headKuangrect!)/2
        headKuang.layer.borderWidth = 1.0
        headKuang.layer.borderColor = UIColor.lightGrayColor().CGColor
        headKuang.backgroundColor = UIColor(red: 253/255, green: 237/255, blue: 240/255, alpha: 1.0)
    }
    
    class func getImageFromFile(filePath:NSString) -> UIImage?{
        let cache = Tools.getObjectForKey(filePath)
        if(cache != nil && cache.isKindOfClass(UIImage)){
            return cache as? UIImage
        }
        let fileData:NSData? = NSData(contentsOfFile:filePath as String)
        if fileData != nil {
            let image =  UIImage(data: fileData!)
            Tools.cacheObject(image, forKey: filePath)
            return image
        }
        return nil
    }
    
    class func getImageFromFile(filePath:NSString,callback:(image:UIImage?)->Void){
        Tools.runOnOtherThread({ () -> AnyObject! in
            return UITools.getImageFromFile(filePath)
            }, callback: { (obj) -> Void in
                callback(image: obj as? UIImage)
        })
    }
    
    class func getThumbnailImageFromFile(filePath:NSString,width:CGFloat,cache:Bool = true,callback:(image:UIImage?)->Void){
        Tools.runOnOtherThread({ () -> AnyObject! in
            return UIImage.createThumbnailImageFromFile(filePath as String, maxWidth: width, useCache: cache)
            }, callback: { (obj) -> Void in
                callback(image: obj as? UIImage)
        })
    }
    
    class func imageWithColor(color:UIColor) -> UIImage {
        let rect = CGRectMake(0.0, 0.0, 1.0, 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context,color.CGColor)
        CGContextFillRect(context, rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    /**保存图片到本地**/
    class func saveFileToLocal(data:NSData,path:String,fileName name:String) -> Bool{
        let fileManager = NSFileManager.defaultManager()
        do {
            try fileManager.createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil)
        } catch _ {
        }
        let filePath = path + name
        let  successful = fileManager.createFileAtPath(filePath, contents:data , attributes: nil)
        if successful {
            if Debug {
                print("------------------------------------------------")
                print("保存文件成功\n\(filePath)")
                print("------------------------------------------------")
            }
            return successful
        }
        return false
    }
    
    /**从本地获取图片**/
    class func getFileFromLocal(path:String,fileName name:String) -> NSData? {
        let fileManager = NSFileManager.defaultManager()
        var isDir:ObjCBool = false
        var directory = path
        fileManager.fileExistsAtPath(path, isDirectory:&isDir)
        let dirExsisted = fileManager.fileExistsAtPath(path)
        if isDir && dirExsisted {
            let imagePath =  path + "/" + name
            let fileExsited = fileManager.fileExistsAtPath(imagePath)
            if !fileExsited {
                return nil
            }
            let data = NSData.dataWithContentsOfMappedFile(imagePath) as! NSData
            
            if Debug {
                print("------------------------------------------------")
                print("获取本地文件成功\(data)")
                print("------------------------------------------------")
            }
            
            return data
        }
        return nil
    }
    
    /**
     设置帧动画
     
     - parameter imageView:  设置帧动画的imageview
     - parameter imageNames: 帧动画的图片名称，按播放顺序放入
     */
    class func setFrameAnimation(imageView:UIImageView,imageNames:[String]){
        var images:[UIImage]? = [UIImage]()
        for imagename in imageNames {
            let image = UIImage(named: imagename)
            images!.append(image!)
        }
        
        imageView.animationImages = images
        imageView.animationDuration = 0.5
        imageView.startAnimating()
        
    }
    
    /**
     修改图片透明度
     
     - parameter alpha: 透明度
     - parameter image: 修改的图片
     
     - returns: 改变透明度后的图片
     */
    class func imageByApplyingAlpha(alpha:CGFloat,image:UIImage)->UIImage{
        UIGraphicsBeginImageContextWithOptions(image.size, false, 0.0)
        
        let ctx = UIGraphicsGetCurrentContext()
        let area = CGRectMake(0, 0, image.size.width, image.size.height)
        
        CGContextScaleCTM(ctx, 1, -1);
        CGContextTranslateCTM(ctx, 0, -area.size.height);
        
        CGContextSetBlendMode(ctx, CGBlendMode.Multiply);
        
        CGContextSetAlpha(ctx, alpha);
        
        CGContextDrawImage(ctx, area, image.CGImage);
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        return newImage;
    }
    
    /**
     将十六进制字符颜色转为UIColor
     - parameter hexColor: 十六进制字符颜色，以＃开头，例如：＃ff00ab
     - returns: 转化而成的UIColor
     */
    class func colorWithHexString(var hexColor:String,alpha:CGFloat = 1.0) -> UIColor{
        if (hexColor.hasPrefix("#")) {
            hexColor = (hexColor as NSString).substringFromIndex(1)
        }
        
        if (hexColor.characters.count != 6) {
            print("不是十六进制颜色值",true)
            return UIColor.grayColor()
        }
        
        let rString = (hexColor as NSString).substringToIndex(2)
        let gString = ((hexColor as NSString).substringFromIndex(2) as NSString).substringToIndex(2)
        let bString = ((hexColor as NSString).substringFromIndex(4) as NSString).substringToIndex(2)
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        NSScanner(string: rString).scanHexInt(&r)
        NSScanner(string: gString).scanHexInt(&g)
        NSScanner(string: bString).scanHexInt(&b)
        
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: alpha)
    }
    
    /**
     用约束的形式将子控件填充满父控件
     - parameter child:  需要放置的子控件
     - parameter parent: 被填充的父控件
     */
    class func addChildViewFullInParent(child:UIView!,parent:UIView!){
        child.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(child)
        parent.addConstraint(NSLayoutConstraint(item: child, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: parent, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        parent.addConstraint(NSLayoutConstraint(item: child, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: parent, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
        parent.addConstraint(NSLayoutConstraint(item: child, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: parent, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0))
        parent.addConstraint(NSLayoutConstraint(item: child, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: parent, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0))
    }

    
}
enum ColorType {
    case EMERALD
    case GREEN
    case GRAY
    case BLUE
}

