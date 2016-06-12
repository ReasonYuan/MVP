//
//  CityChildViewController.swift
//  DoctorPlus_ios
//
//  Created by monkey on 15-5-8.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit


class CityChildViewController: BaseViewController,UITableViewDataSource,UITableViewDelegate {
    
    var titleName:String = ""
    var childList:JavaUtilArrayList!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTittle(titleName)
        hiddenRightImage(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func getXibName() -> String {
        return "CityChildViewController"
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("CityViewTableViewCell") as? CityViewTableViewCell
        if cell == nil {
            
            let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("CityViewTableViewCell", owner: self, options: nil)
            cell = nibs.lastObject as? CityViewTableViewCell
        }
        let city:ComFqHalcyonEntityCity = childList.getWithInt(Int32(indexPath.row)) as! ComFqHalcyonEntityCity
        cell?.cityName.text = city.getName()
        cell?.rightIcon.hidden = true
        
        return cell!
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(childList.size())
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let city:ComFqHalcyonEntityCity = childList.getWithInt(Int32(indexPath.row)) as! ComFqHalcyonEntityCity
        let ctrlArray = (self.navigationController?.viewControllers)!
        let index:Int = ctrlArray.count - 3
        let popController:HospitalViewController = (self.navigationController?.viewControllers[index])! as! HospitalViewController
        popController.selectedCityName.text = city.getName()
        popController.selectedCity = city
        self.navigationController?.popToViewController(popController, animated: true)
    }
    
    
}
