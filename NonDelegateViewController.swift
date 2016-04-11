//
//  NonDelegateViewController.swift
//  NSURLSessionDemo
//
//  Created by hah on 16/4/5.
//  Copyright © 2016年 nuclear. All rights reserved.
//

import UIKit

class NonDelegateViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    func createSession() {
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: nil, delegateQueue: NSOperationQueue.mainQueue())
        
        let request = NSURLRequest(URL: NSURL(string:"https://www.baidu.com")!)
        
        session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            NSLog("Got response \(response) with error \(error)\n");
            NSLog("DATA:\n%@\nEND DATA\n",NSString(data: data!, encoding: NSUTF8StringEncoding)!)
            }.resume()
    }
    
    
    

}
