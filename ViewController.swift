//
//  ViewController.swift
//  NSURLSessionDemo
//
//  Created by hah on 16/4/1.
//  Copyright © 2016年 nuclear. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Session"
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    //MARK: - tableivew datasource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("id")
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "id")
        }
        var title = ""
        switch (indexPath.row){
        case 0:
            title = "background download"
        case 1:
            title = "foreground download"
        case 2:
            title = "upload file"
        case 3:
            title = "data task"
        default:
            break
        }
        cell!.textLabel!.text = title
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var baseVC:BaseViewController?
        
        switch (indexPath.row){
        case 0:
            let bg = BGSessionViewController.bgDownload()
            baseVC = bg
        case 1:
            let download = DownloadFIleViewController.downloadFileViewController()
            baseVC = download
        case 3:
            let data = DataTaskViewController()
            baseVC = data
        default:
            break
        }
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if let v = baseVC {
            v.title = cell?.textLabel?.text
            self.navigationController?.pushViewController(v, animated: true)
        }
    }
}

