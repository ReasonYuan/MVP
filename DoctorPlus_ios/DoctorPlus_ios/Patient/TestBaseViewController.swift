//
//  TestBaseViewController.swift
//  
//
//  Created by Nan on 15/10/22.
//
//

import UIKit

class TestBaseViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let view = RecycleContentsView(frame:CGRectMake(0 , 70 , ScreenWidth , ScreenHeight - 70))
        let adapter = RecycleContentsAdapter()
        view.setContentsAdapter(adapter)
        view.onStartFetchData()
        self.view.addSubview(view)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func getXibName() -> String {
        return "TestBaseViewController"
    }


}
