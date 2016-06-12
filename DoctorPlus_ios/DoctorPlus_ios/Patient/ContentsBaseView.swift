//  ContentsBaseView.swift
//  
//
//  Created by Nan on 15/10/22.
//
//

import UIKit

@objc protocol ContentsBaseViewDelegate {
    
    //设置显示内容的cell
    func onSetContentsTableCell(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell?
    //设置显示时间的title
    func onSetTimeTableHeader(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    //设置cell的高度
    func onSetHeightForRowAtIndexPath(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    //设置timeHeader的高度
    func onSetHeightForHeaderInSection(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    //设置ITEM的点击事件
    func onItemClickListener(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)

}

class ContentsBaseView: UIView, ContentsBaseAdapterDelegate,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate {
    
    var adapter:ContentsBaseAdapter?
    weak var contentsBaseViewDelegate:ContentsBaseViewDelegate?
    
    @IBOutlet weak var contentTableView:UITableView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("ContentsBaseView", owner: self, options: nil)
        let view = nibs.lastObject as! UIView
        view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height)
        self.addSubview(view)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    //对外编辑
    func onEdit() {
    
    }
    
    //完成编辑
    func onFlishEdit() {
    
    }
    
    //刷新UI
    func onRefreshUI(){
        contentTableView.reloadData()
    }
    
    //开始获取数据
    func onStartFetchData(){
        self.adapter!.fetchData()
    }
    
    //设置内容来源
    func setContentsAdapter(adapter:ContentsBaseAdapter){
        self.adapter = adapter
        adapter.registerContentsObserver(self)
    }
    
    func onDataChanged() {
        onRefreshUI()
    }
    
    func onBaseAdapterError(code: Int, msg: String) {
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        return contentsBaseViewDelegate?.onSetContentsTableCell(tableView,cellForRowAtIndexPath:indexPath) ?? UITableViewCell()
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return contentsBaseViewDelegate?.onSetTimeTableHeader(tableView, viewForHeaderInSection: section)
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return adapter?.getSectionsNumber() ?? 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return adapter?.getRowsInSectionNumber(section) ?? 0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return contentsBaseViewDelegate?.onSetHeightForRowAtIndexPath(tableView, heightForRowAtIndexPath: indexPath) ?? 0
    }
    
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return contentsBaseViewDelegate?.onSetHeightForHeaderInSection(tableView, heightForHeaderInSection: section) ?? 0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        contentsBaseViewDelegate?.onItemClickListener(tableView, didSelectRowAtIndexPath: indexPath)
    }
    
}
