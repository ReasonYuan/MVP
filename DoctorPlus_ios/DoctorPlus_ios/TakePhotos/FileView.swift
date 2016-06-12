//
//  FileView.swift
//  DoctorPlus_ios
//
//  Created by Monkey on 15/12/23.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import UIKit

class FileView: UIView,UISearchBarDelegate {

    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    var searchResultsView:SavedSearchResultsView!
    var fileViewFrame:CGRect!
    
    //判断view是否关闭ß
    var isClose = true
    //判断view是显示了一部分还全屏显示
    var isOpenFullScreen = false
    //判断动画是否完成
    var isAnimationFinish = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        fileViewFrame = frame
        addXib()
        initWidgets(frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addXib() {
        let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("FileView", owner: self, options: nil)
        let view = nibs.lastObject as! UIView
        view.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight)
        self.addSubview(view)
    }
    
    func initWidgets(frame: CGRect) {
        searchBar.delegate = self
        searchBar.backgroundImage = UITools.imageWithColor(UIColor.whiteColor())
        let frame = CGRect(x: 0, y: 180, width: ScreenWidth, height: frame.size.height - 180)
        searchResultsView = SavedSearchResultsView(frame: frame)
        self.addSubview(searchResultsView)
    }
    
    //关闭view
    func closeView() {
    
        if !isAnimationFinish {
            return
        }
        self.isAnimationFinish = false
        var transformY:CGFloat = 0
        
        if isOpenFullScreen {
            transformY = self.fileViewFrame.size.height
        }else{
            transformY = 130
        }
        
        UIView.animateWithDuration(1.2, animations: { () -> Void in
                self.transform = CGAffineTransformMakeTranslation(0, transformY)
            }) { (isFinish) -> Void in
                self.hidden = true
                self.isClose = true
                self.isOpenFullScreen = false
                self.searchBar.endEditing(true)
                self.isAnimationFinish = true
        }
    }
    
    //打开view
    func openView() {
        
        if isOpenFullScreen || !isAnimationFinish {
            return
        }
        
        self.isAnimationFinish = false
        if isClose && !isOpenFullScreen {
            self.hidden = false
            UIView.animateWithDuration(1.2, animations: { () -> Void in
                self.transform = CGAffineTransformMakeTranslation(0, -130)
                }) { (isFinish) -> Void in
                    self.isClose = false
                    self.isAnimationFinish = true
            }
        }else if !isClose && !isOpenFullScreen {
            UIView.animateWithDuration(1.2, animations: { () -> Void in
                self.transform = CGAffineTransformMakeTranslation(0, -ScreenHeight)
                }) { (isFinish) -> Void in
                    self.isOpenFullScreen = true
                    self.isAnimationFinish = true
            }
        }
    }
    
    @IBAction func onCloseBtnClickListener(sender: UIButton) {
        closeView()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count > 0 {
            closeBtn.hidden = true
        }else{
            closeBtn.hidden = false
        }
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        openView()
    }
    
    @IBAction func onCreatePatientClickListener(sender: AnyObject) {
        Tools.getCurrentViewController().navigationController?.pushViewController(CreateNewPatientViewController(from: FromType.FromCamera), animated: true)
    }
    
    //搜索跳转
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        let key = searchBar.text ?? ""
        if key.characters.count == 0 {
            return
        }
        let controller = SearchPatientController()
        controller.keys = key
        Tools.getCurrentViewController().navigationController?.pushViewController(controller, animated: true)
        
    }
}
