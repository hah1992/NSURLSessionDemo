//
//  Model.swift
//  NSURLSessionDemo
//
//  Created by hah on 16/4/8.
//  Copyright © 2016年 nuclear. All rights reserved.
//

import UIKit

class Model: NSObject {
    
    var articleId = 0
    var articleType = 0
    var articleUrl = ""
    var columnId = 0
    var displayType = 0
    var firstPicUrl = ""
    var isHot = 0
    var isRecommend = 0
    var isSpecial = 0
    var originalHeight = 0
    var originalWidth = 0
    var publishTime = ""
    var regionId = 0
    var reviewNum = 0
    var showBigPic = 0
    var sourceId = 0
    
    var sourceName = ""
    var summary = ""
    var tags = ""
    var thumbImgUrl = ""
    var thumbImgUrlList = []
    var title = ""
    var topTime = ""
    
    var weight = 0
    
    convenience init(dic: [String : AnyObject]) {
        self.init()
        self.setValuesForKeysWithDictionary(dic)
    }
    

}
