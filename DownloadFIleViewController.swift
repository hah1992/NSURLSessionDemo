//
//  DownloadFIleViewController.swift
//  NSURLSessionDemo
//
//  Created by hah on 16/4/5.
//  Copyright © 2016年 nuclear. All rights reserved.
//

import UIKit

class DownloadFIleViewController: BaseViewController {
    
    var resumeData = NSData()
    
    @IBOutlet weak var progress: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var imageView: UIImageView!
    
    /*
    init sesion and download task
    */
    lazy var session:NSURLSession = {
        let config  = NSURLSessionConfiguration.defaultSessionConfiguration()
        let myQueue = NSOperationQueue()
        myQueue.maxConcurrentOperationCount = 1
        let session = NSURLSession(configuration: config, delegate: self, delegateQueue: myQueue)
        return session
    }()
    
    lazy var downloadTask:NSURLSessionDownloadTask = {
        let URLString = "http://img.pconline.com.cn/images/upload/upc/tx/wallpaper/1308/15/c4/24495135_1376532082021.jpg"
        let URL = NSURL(string: URLString)
        let request = NSURLRequest(URL: URL!)
        let downloadTask = self.session.downloadTaskWithRequest(request)
        return downloadTask
    }()
    
    var imgPath = NSURL()
    
    class func downloadFileViewController() -> DownloadFIleViewController {
        return NSBundle.mainBundle().loadNibNamed("DownloadFileView", owner: nil, options: nil).last as! DownloadFIleViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressBar.progress = 0
  
    }
    
    
    
    //MARK: -
    /*
    start,pause,resuem download task
    */
    @IBAction func startDownload(sender: AnyObject) {
        if downloadTask.state == .Running{return}
        NSLog("task start")
        downloadTask.resume()
    }
    
    @IBAction func pauseDownload(sender: AnyObject) {
        NSLog("task pause")
        downloadTask.cancelByProducingResumeData({ (data) -> Void in
            if let d = data{
                self.resumeData = d
            }
        })
    }
    
    @IBAction func resumeDownload(sender: AnyObject)
    {
        if downloadTask.state == .Running { return }
        
        if let _ = NSData(contentsOfURL: self.imgPath) { return }
        
        downloadTask = session.downloadTaskWithResumeData(resumeData)
        NSLog("task resume")
        downloadTask.resume()
    }
    
    //MARK:
    /*
    download task delegate
    */
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let p = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.progress.text = "\(p)"
            self.progressBar.progress = p
        }
        NSLog("progress:\(p)")
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        NSLog("resume succeed")
    }
    
    override func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        
        self.imgPath = self.savePathForDownloadData(location, task: downloadTask)
        
        assert(self.imgPath.absoluteString.characters.count>0, "imgPath is not exit")
        
        NSLog("download completed in path:\(imgPath)")
        let data = NSData(contentsOfURL: self.imgPath)
        let img = UIImage(data: data!)
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.imageView.image = img
        }
    }
    
    override func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if error != nil {
            NSLog("download failed, reasion:\(error)")
            
            NSLog("try to restart task")
            let resumeData = error?.userInfo[NSURLSessionDownloadTaskResumeData]
            if let rd = resumeData {
                self.downloadTask = self.session.downloadTaskWithResumeData(rd as! NSData)
                self.downloadTask.resume()
                NSLog("restart task succeed")
            }else {
                NSLog("restart task failed")
            }
            
            return
        }
        
        NSLog("download succeed")
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