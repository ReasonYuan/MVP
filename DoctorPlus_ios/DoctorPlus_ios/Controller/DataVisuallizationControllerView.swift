//
//  DataVisuallizationControllerView.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-5-22.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class DataVisuallizationControllerView: BaseViewController,iCarouselDataSource, iCarouselDelegate {
    
    @IBOutlet weak var carousel: iCarousel!
    @IBOutlet weak var backGroudView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        hiddenRightImage(true)
        setTittle("数据可视化(Demo)")
        carousel.delegate = self
        carousel.dataSource = self
        carousel.type = .CoverFlow2
        carousel.pagingEnabled = true
        carousel.scrollToItemAtIndex(1, animated: true)
        blur()
    }
    
    func blur(){
        if(IOS_VERSION >= 8){
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.alpha = 0.5
        blurView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight - 70)
        self.backGroudView.addSubview(blurView)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
    
    override func getXibName() -> String {
        return "DataVisuallizationControllerView"
    }
    
    
    func numberOfItemsInCarousel(carousel: iCarousel!) -> Int
    {
        return 3
    }
    
    func carousel(carousel: iCarousel!, viewForItemAtIndex index: Int, reusingView view: UIView!) -> UIView! {
        var tmpView = view
        if (tmpView == nil)
        {
            if IOS_STYLE == UIUserInterfaceIdiom.Pad {
                tmpView = DataVisuallizationView(frame: CGRectMake(0, 0 , ScreenWidth*4/7 ,ScreenHeight*5/7))
            }else{
                tmpView = DataVisuallizationView(frame: CGRectMake(0, 0 , ScreenWidth*4/7 ,ScreenHeight*4/7))
            }
            
        }
        
        switch index {
        case 0:
            (tmpView as! DataVisuallizationView).imageView.image = UIImage(named: "analysis_medicinal.jpg")
            (tmpView as! DataVisuallizationView).tittle.text = "药物分析图表"
        case 1:
            (tmpView as! DataVisuallizationView).imageView.image = UIImage(named: "analysis_exam.jpg")
            (tmpView as! DataVisuallizationView).tittle.text = "化验项分析图表"
        case 2:
            (tmpView as! DataVisuallizationView).imageView.image = UIImage(named: "analysis_map.jpg")
            (tmpView as! DataVisuallizationView).tittle.text = "地区分布比重图"
        default:
            (tmpView as! DataVisuallizationView).imageView.image = nil
        }
        return tmpView
    }
    
    func carousel(mCarousel: iCarousel!, valueForOption option: iCarouselOption, withDefault value: CGFloat) -> CGFloat
    {
        if (option == .Spacing)
        {
            if IOS_STYLE == UIUserInterfaceIdiom.Pad {
                return value * 4.0
            }else{
                return value * 3.0
            }
        }
        return value
    }
    
    func carousel(mCarousel: iCarousel!, didSelectItemAtIndex index: Int) {
                print("\(index)")
        
        switch index {
        case 0:
            self.navigationController?.pushViewController(MedicalAnalysisViewController(), animated: true)
        case 1:
            self.navigationController?.pushViewController(ExamAnalysisViewController(), animated: true)
        case 2:
            let controller = DataVisualizationViewController()
            controller.entity = ComFqHalcyonEntityVisualizeVisualMap()
            self.navigationController?.pushViewController(controller, animated: true)
        default:
            return
            
        }

    }
    
    func carouselCurrentItemIndexDidChange(mCarousel: iCarousel!) {
        self.backGroudView.image =  (mCarousel.currentItemView as! DataVisuallizationView).imageView.image!
    }
    
    override func onLeftBtnOnClick(sender: UIButton) {
        carousel.removeFromSuperview()
        super.onLeftBtnOnClick(sender)
       
    }
}
