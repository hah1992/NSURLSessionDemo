//
//  BGSessionViewController.swift
//  NSURLSessionDemo
//
//  Created by hah on 16/4/5.
//  Copyright © 2016年 nuclear. All rights reserved.
//

import UIKit

let kMysessionID = "com.nuclear.bgsession"
typealias completionHandler = ()->()

class BGSessionViewController: BaseViewController{
    
    var resumeData = NSData()
    
    
    var completionHandlerDic = [String:completionHandler]()
    
    @IBOutlet weak var progressLable: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    lazy var bgSession:NSURLSession = {
        let bgConfig  = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(kMysessionID)
        let myQueue = NSOperationQueue()
        myQueue.maxConcurrentOperationCount = 1
        let bgSession = NSURLSession(configuration: bgConfig, delegate: self, delegateQueue: myQueue)
        return bgSession
    }()
    
    lazy var downloadTask:NSURLSessionDownloadTask = {
        let URLString = "http://dl.wenku.baidu.com/wenku23/%2Fe6a013c3c9a63209f1e201249d4eeb09?sign=MBOT:y1jXjmMD4FchJHFHIGN4z:HQtqOiPWWi7bT%2B8banMnAOUUNaA%3D&time=1460355526&response-content-disposition=attachment;%20filename=%22%BC%C6%CB%E3%BB%FA%CD%F8%C2%E7%BC%BC%CA%F5%BD%CC%B3%CC.pdf%22&response-content-type=application%2foctet-stream"
        let URL = NSURL(string: URLString)
        let request = NSURLRequest(URL: URL!)
        let downloadTask = self.bgSession.downloadTaskWithRequest(request)
        return downloadTask
    }()
    
    
    class func bgDownload() -> BGSessionViewController {
        return NSBundle.mainBundle().loadNibNamed("BGDownloadViewController", owner: nil, options: nil).last as! BGSessionViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressBar.progress = 0
    }
    
    deinit {
        bgSession.invalidateAndCancel()
    }
    
    //MARK: button click
    @IBAction func start(sender: AnyObject) {
        if downloadTask.state == .Running{return}
        
        NSLog("task start")
        downloadTask.resume()
    }
}



extension BGSessionViewController{
    //MARK: - session download delegate
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        if totalBytesExpectedToWrite == NSURLSessionTransferSizeUnknown {return}
        
        let p = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        NSLog("progress:\(p)")
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.progressBar.progress = p
            self.progressLable.text = String(format: "%.2f", p*100)
        }
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        NSLog("resume succeed")
    }
    
    override func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        let path = savePathForDownloadData(location, task: downloadTask)
        NSLog("download completed in path:\(path)")
        
        let alert = UIAlertController(title: "download succeed", message: "", preferredStyle: .Alert)
        let ok = UIAlertAction(title: "OK", style: .Default, handler:nil)
        alert.addAction(ok)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if let err = error {
            NSLog("download fail, reason:\(err.localizedDescription)")
        }
    }
    
    func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
        if let ID = session.configuration.identifier {
            self.callHandlerForSession(ID)
        }
    }
        
    func callHandlerForSession(identify:String) {
        if let hander = self.completionHandlerDic[identify] {
            NSLog("handler execute")
            hander()
        }
    }


    func addCompletionHandler(handler:completionHandler,session:String) {
        if let _ = completionHandlerDic[session] {
            NSLog("compleHandler has exited")
            return
        }
        completionHandlerDic[session] = handler
    }
    
    
    //MARK: save downloaded data then return save path
    func savePathForDownloadData(location:NSURL, task:NSURLSessionDownloadTask) -> NSURL {
        let manager = NSFileManager.defaultManager()
        let docDict = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first
        let originURL = task.originalRequest?.URL
        let distinationURL = docDict?.URLByAppendingPathComponent((originURL?.lastPathComponent)!)
        
        do{
            try manager.removeItemAtURL(distinationURL!)
        }catch{
            NSLog("remove failed")
        }
        
        do{
            try manager.copyItemAtURL(location, toURL: distinationURL!)
        }catch{
            NSLog("copy failed")
        }
        
        return distinationURL!
    }
}
