//
//  CityViewController.swift
//  DoctorPlus_ios
//
//  Created by monkey on 15-5-7.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit


class CityViewController: BaseViewController,ComFqHalcyonLogic2RequestCSDLogic_ResCityInf,UITableViewDataSource,UITableViewDelegate{
    
    var cityList:JavaUtilArrayList = JavaUtilArrayList()
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setTittle("省份")
        hiddenRightImage(true)
        let logic = ComFqHalcyonLogic2RequestCSDLogic()
        logic.requestCityWithComFqHalcyonLogic2RequestCSDLogic_ResCityInf(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func getXibName() -> String {
        return "CityViewController"
    }
    
    /**
    返回城市列表的回调
    */
    func feedCityWithJavaUtilArrayList(citys: JavaUtilArrayList!) {
        cityList.addAllWithJavaUtilCollection(citys)
        tableView.reloadData()
    }
    
    /**
    逻辑出现错误的回调
    */
    func onErrorWithInt(code: Int32, withJavaLangThrowable error: JavaLangThrowable!) {
        UIAlertViewTool.getInstance().showAutoDismisDialog("获取城市列表失败", width: 200, height: 80)
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("CityViewTableViewCell") as? CityViewTableViewCell
        if cell == nil {
            
            let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("CityViewTableViewCell", owner: self, options: nil)
            cell = nibs.lastObject as? CityViewTableViewCell
        }
        let city:ComFqHalcyonEntityCity = cityList.getWithInt(Int32(indexPath.row)) as! ComFqHalcyonEntityCity
        cell?.cityName.text = city.getName()
        
        if city.getType() == 1 {
            cell?.rightIcon.hidden = true
        }else{
            cell?.rightIcon.hidden = false
        }
 
        return cell!
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(cityList.size())
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let city:ComFqHalcyonEntityCity = cityList.getWithInt(Int32(indexPath.row)) as! ComFqHalcyonEntityCity
        if city.getType() == 1 {
            let ctrlArray = (self.navigationController?.viewControllers)!
            let index:Int = ctrlArray.count - 2
            let popController:HospitalViewController = (self.navigationController?.viewControllers[index])! as! HospitalViewController
            popController.selectedCity = city
            self.navigationController?.popToViewController(popController, animated: true)
        }else{
            let controller = CityChildViewController()
            controller.childList = city.getChildren()
            controller.titleName = city.getName()
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
}
