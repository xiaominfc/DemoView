//
//  ViewController.swift
//  DemoView
//
//  Created by xiaominfc on 2018/5/31.
//  Copyright © 2018 xiaominfc. All rights reserved.
//

import UIKit
import libxml2


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout=UIRectEdge.all
        let path = ViewFatoryHelper.layout_path(name: "main_table")
        setContentView(layout: path!)
        
        self.title = "记录"
        if let tableView = self.view.findViewById("tableview") as? UITableView {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.rowHeight = 100;
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(ViewController.doAddAction(sender:)))
    
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @objc func doAddAction(sender:AnyClass) {
    
        let editViewController = EditViewController()
        self.navigationController?.pushViewController(editViewController, animated: true)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let path = ViewFatoryHelper.layout_path(name: "item")
        let cell = tableView.instanceCell(identifier: path!)
        if let titleLabel = cell.findViewById("title_label", true) as? UILabel {
            titleLabel.text = "item \(indexPath.row)"
        }
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

