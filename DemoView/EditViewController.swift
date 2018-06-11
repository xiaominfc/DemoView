//
//  EditViewController.swift
//  DemoView
//
//  Created by xiaominfc on 2018/6/8.
//  Copyright © 2018 xiaominfc. All rights reserved.
//

import UIKit


class EditViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "添加记录"
        self.tabBarController?.tabBar.isHidden = true
        
        if let path = ViewFatoryHelper.layout_path(name: "edit") {
            setContentView(layout: path)
        }
        
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(EditViewController.doSaveAction(sender:)))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    
    @objc func doCancelAction(sender:AnyClass) {
        self.dismiss(animated: true) {
            
        }
    }
    
    @objc func doSaveAction(sender:AnyClass) {
        self.dismiss(animated: true) {
            
        }
    }
}
