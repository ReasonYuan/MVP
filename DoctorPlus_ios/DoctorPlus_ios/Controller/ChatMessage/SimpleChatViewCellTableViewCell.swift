//
//  SimpleChatViewCellTableViewCell.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-7-1.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class SimpleChatViewCellTableViewCell: ChatBaseCell {

    @IBOutlet weak var userHead: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var headBtn: UIButton!
    @IBOutlet weak var iconLeft: UIImageView!
    var imagesView:FullScreenImageZoomView!
    
    override func initData(entity: ComFqHalcyonEntityChartEntity, headView: UIView) {
        super.initData(entity, headView: headView)
        headBtn.addTarget(self, action: "headOnClick", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    override func initData(entity: ComFqHalcyonEntityChartEntity){
        super.initData(entity, headView: userHead)
        headBtn.addTarget(self, action: "headOnClick", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    override func setData(entity: ComFqHalcyonEntityChartEntity) {
        let messageType = entity.getMessageType()
        if messageType == 1 {
            initNormalMessage()
        }
        
        if messageType == 4  {
            initImageMessage()
        }
        
    }

    /**
    初始化发送图片的信息
    
    */
    func initImageMessage(){
        var removeView:UIView?
        for views in self.subviews {
            if (views ).tag == 1 {
                removeView = (views )
            }
        }
        removeView?.removeFromSuperview()
        
        UITools.setRoundBounds(20.0, view: userHead)
//        UITools.setBorderWithView(1.0, tmpColor: Color.color_violet.CGColor, view: userHead)
        name.text = MessageTools.dateFormatTimer(entity.getmSendTime())
        content.subviews.map{$0.removeFromSuperview()}
        
        let tmpView = UIView(frame: CGRectMake(56 + 9, 38,CGFloat(entity!.getImageWidth()), CGFloat(entity!.getImageHeight())))
        let imageView = UIImageView(frame: CGRectMake(0, 0,CGFloat(entity!.getImageWidth()), CGFloat(entity!.getImageHeight())))
        imageView.backgroundColor = Color.color_chat_left_color
        
        let imageBtn = UIButton(frame: imageView.frame)
        imageBtn.addTarget(self, action: "imageBtnClick", forControlEvents: UIControlEvents.TouchUpInside)
        let chatImage = UIImageView(frame: CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height ))
        
        if entity!.getMessageImageId() != 0 {
            chatImage.downLoadImageWidthImageId(entity?.getMessageImageId(), callback: { (view, path) -> Void in
                let tmpView = view as! UIImageView
                UITools.getThumbnailImageFromFile(path, width: tmpView.frame.size.width, callback: { (image) -> Void in
                    tmpView.image = image
                })
                
            })
            
        }
        self.iconLeft.hidden  = true
        imageView.addSubview(chatImage)
        tmpView.addSubview(imageView)
        tmpView.addSubview(imageBtn)
        addSubview(tmpView)
        tmpView.tag = 1
        UITools.setRoundBounds(3.0, view: imageView)
        tmpView.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: tmpView, attribute:
            NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: content, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: tmpView, attribute:
            NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: content, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: tmpView, attribute:
            NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: CGFloat(entity!.getImageWidth())))
        addConstraint(NSLayoutConstraint(item: tmpView, attribute:
            NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: CGFloat(entity!.getImageHeight())))
    }
    
    /**
    初始化普通聊天文字信息
    */
    func initNormalMessage(){
        var removeView:UIView?
        for views in self.subviews {
            if (views ).tag == 1 {
                removeView = (views )
            }
        }
        removeView?.removeFromSuperview()
        
        self.iconLeft.hidden = false
        name.text = MessageTools.dateFormatTimer(entity.getmSendTime())
        content.subviews.map{$0.removeFromSuperview()}
        
        if MessageTools.calculateHeightForCell(entity) < 18 {
            
            content.textAlignment = NSTextAlignment.Left
            let width = MessageTools.calculateWidthForCell(entity)
            
            let textLabel = UILabel(frame: CGRectMake(5, 5, width, 18))
            textLabel.text = entity?.getMessage()
            textLabel.font = UIFont.systemFontOfSize(13.0)
            textLabel.textColor = UITools.colorWithHexString("#333333")
            
            let imageView = UIImageView(frame: CGRectMake(0, 0,width + 10, 28))
            imageView.backgroundColor = Color.color_chat_left_color
            
            imageView.addSubview(textLabel)
            content.addSubview(imageView)
            UITools.setRoundBounds(3.0, view: imageView)
            
        }else{
            
            let textLabel =  UILabel(frame: CGRectMake(5, 5,ScreenWidth - 112 - 10, MessageTools.calculateHeightForCell(entity)))
            textLabel.numberOfLines = 0
            textLabel.font = UIFont.systemFontOfSize(13.0)
            textLabel.text = entity?.getMessage()
            textLabel.sizeToFit()
            textLabel.textAlignment = NSTextAlignment.Left
            textLabel.textColor = UITools.colorWithHexString("#333333")

            let imageView = UIImageView(frame: CGRectMake(0, 0,ScreenWidth - 112, textLabel.frame.size.height + 10))
            imageView.backgroundColor = Color.color_chat_left_color
            
            imageView.addSubview(textLabel)
            content.addSubview(imageView)
            UITools.setRoundBounds(3.0, view: imageView)
       
        }

    }
    
    /**图片点击事件**/
    func imageBtnClick(){
        let imageId = entity!.getMessageImageId()
        var imageList = [ComFqHalcyonEntityPhotoRecord]()
        let photoRecord = ComFqHalcyonEntityPhotoRecord()
        let path = ComFqHalcyonExtendFilesystemFileSystem.getInstance().getImgTempPath()
        photoRecord.setImageIdWithInt(imageId)
        photoRecord.setLocalPathWithNSString(path + entity!.getImagePath())
        imageList.append(photoRecord)
        print(imageId)
        print(path + entity!.getImagePath())
        showImages(imageList)
    }
    
    func showImages(imageList:Array<ComFqHalcyonEntityPhotoRecord>){
        if imagesView != nil {
            imagesView.removeFromSuperview()
            imagesView = nil
        }
        if imagesView == nil {
            imagesView = FullScreenImageZoomView(frame: CGRectMake(0, 0, ScreenWidth, ScreenHeight))
            Tools.getCurrentViewController(self).view.addSubview(imagesView)
        }
        
        let pagePhotoRecords = imageList
        if pagePhotoRecords.count > 0 {
            imagesView.setDatas(0, pagePhotoRecords: pagePhotoRecords)
            imagesView.showOrHiddenView(true)
        }
        
    }
    

}
