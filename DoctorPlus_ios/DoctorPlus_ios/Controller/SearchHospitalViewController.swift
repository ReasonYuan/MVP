//
//  SearchHospitalViewController.swift
//  DoctorPlus_ios
//
//  Created by monkey on 15-5-4.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit


class SearchHospitalViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,ComFqHalcyonLogic2SearchHospitalLogic_SearchHospitalCallBack,ComFqHalcyonLogic2RequestCSDLogic_RequetHospitalInf{
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var hospitalTableView: UITableView!
    @IBOutlet weak var statelabel: UILabel!
    
    var hospitalList:JavaUtilArrayList = JavaUtilArrayList()
    
    var city:ComFqHalcyonEntityCity!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTittle("医院选择")
        hiddenRightImage(true)
        setHiddenCreateView(true)
        //        getHotHospitalList(city.getName())
        getSearchResult("", cityName: city.getName())
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func getXibName() -> String {
        return "SearchHospitalViewController"
    }
    
    
    /**
    获取热门医院列表
    */
    func getHotHospitalList(cityName:String){
        let logic = ComFqHalcyonLogic2RequestCSDLogic()
        logic.requestHospitalWithNSString(cityName, withBoolean: false, withComFqHalcyonLogic2RequestCSDLogic_RequetHospitalInf:self)
    }
    
    /**
    获取热门医院列表出错的回调
    */
    func onErrorWithInt(code: Int32, withJavaLangThrowable error: JavaLangThrowable!) {
        
    }
    
    /**
    获取热门医院列表成功的回调
    */
    func feedHospitalWithJavaUtilArrayList(hos: JavaUtilArrayList!) {
        hospitalList.clear()
        hospitalList.addAllWithJavaUtilCollection(hos)
        if hospitalList.size() > 0 {
            hospitalTableView.reloadData()
            setHiddenCreateView(true)
        } else {
            hospitalTableView.reloadData()
            setHiddenCreateView(false)
        }
        
        hospitalTableView.reloadData()
    }
    
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.rowHeight = 40.0
        return Int(hospitalList.size())
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("HotHospitalTableViewCell") as? HotHospitalTableViewCell
        if cell == nil {
            let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("HotHospitalTableViewCell", owner: self, options: nil)
            cell = nibs.lastObject as? HotHospitalTableViewCell
        }
        
        
        
        cell?.mHospitalName.text = hospitalList.getWithInt(Int32(indexPath.row)).getName()
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.view.endEditing(true)
        let hos:ComFqHalcyonEntityHospital = hospitalList.getWithInt(Int32(indexPath.row)) as! ComFqHalcyonEntityHospital
        let logic = ComFqHalcyonLogic2ResetDoctorInfoLogic()
        
        logic.reqModyHospWithInt(city?.getCityId() ?? 0, withInt: hos.getHospitalId(), withNSString: hos.getName())
        ComFqLibToolsConstants.getUser().setHospitalWithNSString(hos.getName())
        
        
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        //        if searchText.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
        getSearchResult(searchBar.text!, cityName: city.getName())
        //        }else{
        //            getHotHospitalList(city.getName())
        //        }
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
//    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
//        self.view.endEditing(true)
//    }
    
    /**
    调用搜索logic获取搜索结果
    **/
    func getSearchResult(hospitalName:String, cityName:String){
        
        let logic = ComFqHalcyonLogic2SearchHospitalLogic(comFqHalcyonLogic2SearchHospitalLogic_SearchHospitalCallBack:self)
        logic.searchHospitalWithNSString(hospitalName, withNSString: cityName)
        searchBar.resignFirstResponder()
    }
    
    /**
    获取出错的回调
    **/
    func onSearchHospitalErrorWithInt(code: Int32, withNSString msg: String!) {
        
    }
    
    /**
    获取搜索结果的回调
    **/
    func onSearchHospitalResultWithJavaUtilArrayList(mList: JavaUtilArrayList!) {
        hospitalList.clear()
        hospitalList.addAllWithJavaUtilCollection(mList)
        
        if hospitalList.size() > 0 {
            hospitalTableView.reloadData()
            setHiddenCreateView(true)
        } else {
            hospitalTableView.reloadData()
            setHiddenCreateView(false)
        }
        
    }
    
    
    /**
    设置是否隐藏创建医院的view
    true:隐藏view，显示tableview
    false:显示view,隐藏tableview
    **/
    func setHiddenCreateView(hidden:Bool){
        if hidden {
            statelabel.hidden = true
            hospitalTableView.hidden = false
        } else {
            statelabel.hidden = false
            hospitalTableView.hidden = true
        }
    }
    
}
