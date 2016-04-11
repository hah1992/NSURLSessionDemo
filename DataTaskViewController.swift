//
//  DataTaskViewController.swift
//  NSURLSessionDemo
//
//  Created by hah on 16/4/8.
//  Copyright © 2016年 nuclear. All rights reserved.
//

import UIKit

class DataTaskViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    var data:NSData?
    var response:NSURLResponse?
    
    var callback:((data:NSData, response:NSURLResponse)->())?
    var models = [Model]()
    
    lazy var session:NSURLSession = {
        let config  = NSURLSessionConfiguration.defaultSessionConfiguration()
        let myQueue = NSOperationQueue()
        myQueue.maxConcurrentOperationCount = 1
        let session = NSURLSession(configuration: config, delegate: self, delegateQueue: myQueue)
        return session
    }()
    
    lazy var dataTask:NSURLSessionDataTask = {
        let URLString = "http://www.21cn.com/api/client/v2/getClientArticleList.do?userSerialNumber=85d3bbb95d03920e3c53d3801781c806&accessToken=&pageSize=1&hasImg=0&articleType=0&listIds=711r,846r,1235r"
        let URL = NSURL(string: URLString)
        let request = NSURLRequest(URL: URL!)
        let dataTask = self.session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                NSLog("fail with error:\(error)")
                return
            }
            let arr = self.parseResponse(data!, response: response!)
            
            for dic in arr {
                let model = Model(dic: dic)
                self.models.append(model)
            }
            
            dispatch_async(dispatch_get_main_queue(),{ Void in
                self.tableView.reloadData()
            })
            
        })
        return dataTask
    }()
    
    lazy var tableView:UITableView = {
        let t = UITableView(frame:self.view.bounds)
        t.delegate = self
        t.dataSource = self
        return t
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataTask.resume()
        self.view.addSubview(tableView)
    }
    
    func parseResponse(data:NSData, response:NSURLResponse) -> [[String:AnyObject]] {

        let d = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
        let info = d?.valueForKey("Rows") as! [[String:AnyObject]]
        
        return info
    }
    
    //MARK: - tableview datasource and delegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.models.count
    }
    
    let ID = "com.sessionDemo.dataTask"
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(ID)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: ID)
        }
        
        let info = self.models[indexPath.row]
        cell?.textLabel?.text = info.title
        
        return cell!
    }
}
