//
//  PersionChart.swift
//  Care
//
//  Created by 廖敏 on 15/8/26.
//  Copyright (c) 2015年 YiYiHealth. All rights reserved.
//

import UIKit

enum PersionChartType{
    case None,Organ,Blood
}

//private class OrganPart:UIImageView{
//    var part:Organ? = .None {
//        didSet{
//           
//        }
//    }
//
//    private func onSetPary(){
//        if let _part = part {
//            switch _part {
//            case Organ.Head:
//                    break
//            case Organ.Neck:
//                    break
//            case Organ.Chest:
//                break
//            case Organ.Heart:
//                break
//            case Organ.Abdomen:
//                break
//            case Organ.AbdomenUp:
//                break
//            case Organ.AbdomenDown:
//                break
//            case Organ.Knee:
//                break
//
//            default:
//                self.image = nil
//            }
//        }else{
//            self.image = nil
//        }
//    }
//}

enum Organ {
    case None
    case Head            //头
    case Neck            //颈部
    case Chest           //胸部
    case Heart           //心脏
    case Abdomen         //腹部
    case AbdomenUp       //上腹部
    case AbdomenDown     //下腹部
    case KneeLeft        //膝盖
    case KneeRight        //膝盖
    
    static func organ(str:String)->Organ{
        switch str {
        //头部
        case "眼":
            fallthrough
        case "头部":
            fallthrough
        case "耳鼻喉":
            return .Head
            
        //颈部
        case "颈部":
            return .Neck
            
        //胸部
        case "胸部":
            return .Chest
            
        //心脏
        case "心脏":
            return .Heart
            
        //腹部
        case "腹部":
            fallthrough
        case "腰部":
            return .Abdomen
            
        //上腹部
        case "上腹部":
            return .AbdomenUp
            
        //下腹部
        case "下腹部":
            return .AbdomenDown
    
        //膝盖
        case "膝盖":
            return .KneeLeft
        default:
            return .None
        }
    }
}


class PersionChart: UIView {
    
    //图片的类型，null,器官图，血液图
    private var _type:PersionChartType! = .Organ
    var type:PersionChartType{
        get{
            return self._type
        }
        set{
            self.setType(newValue)
        }
    }
    
    private var organs:[Organ:UIImageView] = [Organ:UIImageView]()
    
    private static let orgs = [Organ.Head,Organ.Neck,Organ.Chest,
        Organ.Heart,Organ.Abdomen,Organ.AbdomenUp,Organ.AbdomenDown,Organ.KneeLeft,Organ.KneeRight
    ]
    private static let images = ["organ_head.png","organ_point.png","organ_chest.png","organ_heart.png","organ_abdomen.png","organ_abdomen_up.png","organ_abdomen_down.png","organ_point.png","organ_point.png"]
    
    //人物图片分辨率 354x790
    private static let organsFrame:[CGRect] = [ //center.x,center.y,width,height
        CGRect(x: 176.5,y: 48.5,width: 75,height: 85),
        CGRect(x: 176.5,y: 103.5,width: 104.5,height: 29),
        CGRect(x: 177,y: 199,width: 128,height: 118),
        CGRect(x: 192.5,y: 202,width: 57,height: 52),
        CGRect(x: 174,y: 319,width: 118,height: 131),
        CGRect(x: 174,y: 288,width: 114,height: 78),
        CGRect(x: 174,y: 356,width: 114,height: 78),
        CGRect(x: 127,y: 558,width: 25,height: 25),
        CGRect(x: 227,y: 558,width: 25,height: 25),
        ]
   
    /// 器官图
    @IBOutlet weak var image: UIImageView!
    
    /// 血液图
    @IBOutlet weak var blood: UIImageView!
    
    class func create()->PersionChart {
//        CGSize
        let instance =  NSBundle.mainBundle().loadNibNamed("PersionChart", owner: nil, options: nil)[0] as! PersionChart
        
        for i in 0...orgs.count-1 {
            let org = orgs[i]
            let organ = UIImageView(frame: organsFrame[i])
            organ.contentMode = UIViewContentMode.ScaleAspectFit
            instance.addSubview(organ)
            instance.organs[org] = organ
            organ.image = UIImage(named: images[i])
        }
        return instance
    }

    func setType(type:PersionChartType){
        _type = type
    }
    
    func showOrgan(str:String){
        let or = Organ.organ(str)
        if( or == Organ.None ){ //显示血液图
            UIView.animateWithDuration(0.5, animations: { [weak self]() -> Void in
                self?.image.alpha = 0
                self?.blood.alpha = 1
            })
        }else{ //显示人体器官图
            UIView.animateWithDuration(0.5, animations: { [weak self]() -> Void in
                self?.image.alpha = 1
                self?.blood.alpha = 0
                })
        }
        var array:[Organ] = [Organ]()
        if or == Organ.KneeLeft {
            array.append(Organ.KneeLeft)
            array.append(Organ.KneeRight)
        }else{
            array.append(or)
        }
        for org in PersionChart.orgs{
            var isShow = false
            for rr in array {
                if(rr == org){
                    isShow = true
                    break
                }
            }
            let imageView = organs[org]
            imageView?.hidden = !isShow
        }

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
         //人物图片分辨率 345x790
        let frame = self.frame
        var offsetX :CGFloat = 0.0
        var offsetY :CGFloat = 0.0
        var scale:CGFloat = 1.0
        if (frame.size.width / frame.size.height > 354 / 790.0){ //x>y offsetY = 0
            scale = frame.size.height / 790.0
            let scaledX = scale * 354.0
            offsetX = (frame.size.width - scaledX) / 2.0
        }else{
            scale = frame.size.width / 354.0
            let scaledY = scale * 790.0
            offsetY = (frame.size.height - scaledY) / 2.0
        }
        for i in 0...PersionChart.orgs.count-1 {
            let org = PersionChart.orgs[i]
            let imageView = organs[org]
            let f = PersionChart.organsFrame[i]
            let width = f.size.width*scale
            let heigth = f.size.height*scale
            imageView?.frame = CGRectMake(offsetX+f.origin.x*scale-width/2.0, offsetY+f.origin.y*scale-heigth/2.0, width, heigth)
        }
    }
   
    
}
