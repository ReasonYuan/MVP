//
//  FilterFriendViewController.swift
//  DoctorPlus_ios
//
//  Created by monkey on 15-7-1.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class FilterFriendViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource {


    @IBOutlet weak var hospitalTableView: UITableView!
    @IBOutlet weak var departmentTableView: UITableView!
    
    var hospitalArray:[String] = ["同仁医院","军海医院","天坛医院","二炮医院","华博医院","海华医院"]
    var departmentArray:[String] = ["新生儿科","中医科","营养科","肿瘤科","变态反应科","神经内科","感染科","血液内科","心内科"]
    
    var hospitalSelectedStatus = Array<Bool>()
    var departmentSelectedStatus = Array<Bool>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setRightBtnTittle("确定")
        setTittle("筛选")
        initSelectedStatus()
        hospitalTableView.registerNib(UINib(nibName: "FilterFriendTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "FilterFriendTableViewCell")
        departmentTableView.registerNib(UINib(nibName: "FilterDepartmentTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "FilterDepartmentTableViewCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func getXibName() -> String {
        return "FilterFriendViewController"
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if hospitalTableView == tableView {
            return hospitalArray.count
        }else if departmentTableView == tableView {
            return departmentArray.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if hospitalTableView == tableView {
            let cell = tableView.dequeueReusableCellWithIdentifier("FilterFriendTableViewCell") as! FilterFriendTableViewCell
            cell.nameLabel.text = hospitalArray[indexPath.row]
            if hospitalSelectedStatus[indexPath.row] {
                cell.selectedImg.image = UIImage(named:"friend_select.png")
            }else{
                cell.selectedImg.image = UIImage(named:"friend_unselect.png")
            }
            return cell
        }else if departmentTableView == tableView {
            let cell = tableView.dequeueReusableCellWithIdentifier("FilterDepartmentTableViewCell") as! FilterDepartmentTableViewCell
            cell.nameLabel.text = departmentArray[indexPath.row]
            if departmentSelectedStatus[indexPath.row] {
                cell.selectedImg.image = UIImage(named:"friend_select.png")
            }else{
                cell.selectedImg.image = UIImage(named:"friend_unselect.png")
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if hospitalTableView == tableView {
            var cell = tableView.dequeueReusableCellWithIdentifier("FilterFriendTableViewCell") as! FilterFriendTableViewCell
            if hospitalSelectedStatus[indexPath.row] {
                hospitalSelectedStatus[indexPath.row] = false
            }else{
                hospitalSelectedStatus[indexPath.row] = true
            }
            hospitalTableView.reloadData()
            
        }else if departmentTableView == tableView {
            var cell = tableView.dequeueReusableCellWithIdentifier("FilterDepartmentTableViewCell") as! FilterDepartmentTableViewCell
            if departmentSelectedStatus[indexPath.row] {
                departmentSelectedStatus[indexPath.row] = false
            }else{
                departmentSelectedStatus[indexPath.row] = true
            }
            departmentTableView.reloadData()
        }
    }
    
    func initSelectedStatus(){
        for item in hospitalArray {
            hospitalSelectedStatus.append(false)
        }
        for item in departmentArray {
            departmentSelectedStatus.append(false)
        }
    }
    
    override func onRightBtnOnClick(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
