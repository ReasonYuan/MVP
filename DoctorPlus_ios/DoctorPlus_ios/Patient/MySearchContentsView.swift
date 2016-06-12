//
//  MySearchContentsView.swift
//  DoctorPlus_ios
//
//  Created by sunning on 15/12/9.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import UIKit



class MySearchContentsView: ContentsBaseView,ContentsBaseViewDelegate ,SearchPatientHeadViewDelegate,SearchRecordCellTableViewCellDelegate{
    
    var sectionSelectedIndex = -1
    var itemSelectedIndex = -1
    var itemSelectedSection = -1
    var isItemSelect = false
    var isFromChart = true
    var selectedRecord:ComFqHalcyonEntityPracticeRecordAbstract!
    var selectedPatient:ComFqHalcyonEntityPracticePatientAbstract!
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentsBaseViewDelegate = self
        let cellNib = UINib(nibName: "SearchRecordCellTableViewCell", bundle: NSBundle.mainBundle())
        contentTableView.registerNib(cellNib, forCellReuseIdentifier: "SearchRecordCellTableViewCell")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func onSetContentsTableCell(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell? {
        let cell = contentTableView.dequeueReusableCellWithIdentifier("SearchRecordCellTableViewCell") as! SearchRecordCellTableViewCell
        cell.delegate = self
        if isFromChart == true{
            cell.recordSelectBtn.hidden = false
        }else{
            cell.recordSelectBtn.hidden = true
        }
        if itemSelectedIndex == indexPath.row  &&  itemSelectedSection == indexPath.section && isItemSelect {
            cell.recordSelectBtn.setImage(UIImage(named: "friend_select.png"), forState: UIControlState.Normal)
            cell.recordSelectBtn.selected = true
            selectedRecord = ComFqHalcyonEntityPracticeRecordAbstract()
            selectedRecord = (adapter as! MySearchAdapter).getItem(indexPath.section, rowIndex: indexPath.row) as! ComFqHalcyonEntityPracticeRecordAbstract
        }else{
            cell.recordSelectBtn.setImage(UIImage(named: "friend_unselect.png"), forState: UIControlState.Normal)
            cell.recordSelectBtn.selected = false
        }
        cell.index = indexPath.row
        cell.section = indexPath.section
        let item = adapter?.getItem(indexPath.section, rowIndex: indexPath.row)
        let record = (item as! ComFqHalcyonEntityPracticeRecordAbstract)
        cell.recordTitleLabel.text = record.getRecordItemName()
        cell.recordAbstractTitleLabel.text = record.getTypeName()
        cell.recordAbstractTextView.text = record.getInfoAbstract()
        return cell
    }

    
    func SearchRecordCellSelected(isSelected: Bool, section: Int, index: Int) {
        sectionSelectedIndex = -1
        itemSelectedSection = section
        itemSelectedIndex = index
        isItemSelect = isSelected
        (adapter as! MySearchAdapter).protectedNotifyDataChanged()
    }
    
    func onSetHeightForHeaderInSection(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableView.frame.height / 3
    }
    
    func onSetHeightForRowAtIndexPath(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.frame.height / 4.5
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (adapter as! MySearchAdapter).tmpDatas[section].count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return (adapter as! MySearchAdapter).sectionsPatient.count
    }
    
    func onSetTimeTableHeader(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView = SearchPatientHeadView(frame: CGRectMake(0, 0, tableView.frame.width, tableView.frame.height / 3))
        headView.delegate = self
        headView.section = section
        headView.patientTitleLabel.text = adapter?.sectionsPatient[section].getShowName()
        headView.recordTitleLabel.text = adapter?.sectionsPatient[section].getShowSecond()
        headView.recordAbstractLabel.text = adapter?.sectionsPatient[section].getShowThrid()
        headView.HeaderOpen = (adapter as! MySearchAdapter).sectionIsOpen[section]
        if isFromChart == true {
            headView.patientSelectBtn.hidden = false
        }else{
            headView.patientSelectBtn.hidden = true
        }
        if sectionSelectedIndex == section {
            headView.patientSelectBtn.setImage(UIImage(named: "friend_select.png"), forState: UIControlState.Normal)
            headView.patientSelectBtn.selected = true
        }else{
            headView.patientSelectBtn.setImage(UIImage(named: "friend_unselect.png"), forState: UIControlState.Normal)
            headView.patientSelectBtn.selected = false
        }
        if (adapter?.sectionsPatient[section].getmUserImageId()) != 0 {
            headView.headIcon.downLoadImageWidthImageId(Int32((adapter?.sectionsPatient[section].getmUserImageId())!), callback: { (view, path) -> Void in
                headView.headIcon.image = UITools.getImageFromFile(path)
            })
        }
        return headView
    }
    
    func onItemClickListener(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if !isFromChart {
            (adapter as! MySearchAdapter).pushController(self,indexPath: indexPath)
        }
    }
    
    func opendSearchPatientHeadView(searchPatientHeadView: SearchPatientHeadView, sectionOpened: Int) {
        (adapter as! MySearchAdapter).tmpDatas[sectionOpened] = (adapter?.rowsInSections[sectionOpened])!
        (adapter as! MySearchAdapter).sectionIsOpen[sectionOpened] = true
        contentTableView.insertRowsAtIndexPaths(getIndexPaths(sectionOpened), withRowAnimation: UITableViewRowAnimation.Fade)
    }

    func closedSearchPatientHeadView(searchPatientHeadView: SearchPatientHeadView, sectionClosed: Int) {
        (adapter as! MySearchAdapter).tmpDatas[sectionClosed] = [Any]()
        (adapter as! MySearchAdapter).sectionIsOpen[sectionClosed] = false
        contentTableView.deleteRowsAtIndexPaths(getIndexPaths(sectionClosed), withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    func headViewClicked(searchPatientHeadView: SearchPatientHeadView, sectionClicked: Int) {
        if !isFromChart {
            let patientItem:ComFqHalcyonEntityPracticePatientAbstract = ComFqHalcyonEntityPracticePatientAbstract()
            patientItem.setPatientIdWithInt((adapter?.sectionsPatient[sectionClicked].getPatientId())!)
            let controller = MyRecordListViewController(patientItem: patientItem)
            Tools.getCurrentViewController().navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func headViewSelected(searchPatientHeadView: SearchPatientHeadView, sectionSelected: Int, isSelected: Bool) {
        if isSelected {
            sectionSelectedIndex = sectionSelected
            selectedPatient = ComFqHalcyonEntityPracticePatientAbstract()
            selectedPatient.setShowNameWithNSString(adapter?.sectionsPatient[sectionSelectedIndex].getShowName())
            selectedPatient.setUserImageIdWithInt((adapter?.sectionsPatient[sectionSelectedIndex].getmUserImageId())!)
            selectedPatient.setPatientIdWithInt((adapter?.sectionsPatient[sectionSelectedIndex].getPatientId())!)
            selectedPatient.setPatientNameWithNSString(adapter?.sectionsPatient[sectionSelectedIndex].getPatientName())
            selectedPatient.setShowSecondWithNSString(adapter?.sectionsPatient[sectionSelectedIndex].getShowSecond())
            selectedPatient.setShowThridWithNSString(adapter?.sectionsPatient[sectionSelectedIndex].getShowThrid())
        }else{
            sectionSelectedIndex = -1
        }
        itemSelectedIndex = -1
        itemSelectedSection = -1
        (adapter as! MySearchAdapter).protectedNotifyDataChanged()
    }
    
    func getIndexPaths(section:Int) -> Array<NSIndexPath>{
        var resultArray = [NSIndexPath]()
        for i in 0 ..< (adapter?.rowsInSections[section].count)! {
            resultArray.append(NSIndexPath(forRow: i, inSection: section))
        }
        return resultArray
    }
    
    
}
