//
//  ChatURLInfo.swift
//  HipChat
//
//  Created by Tony Thomas on 29/03/16.
//  Copyright © 2016 Tony Thomas. All rights reserved.
//

import Foundation

/** 
    Protocol for notification when the url tile is found for the give url
*/
protocol HCURLTitleOperationDelegate : class{
    
    //`titleOfUrl` is the title for the `url` of interest
    func urlOperationResultAvailableForUrl(url : String , titleOfUrl title:String?)->()
}

class HCChatURLInfo : NSObject,HCURLTitleOperationDelegate{
    // MARK: Properties
    
    var url : String
    
    var title : String?
    
    var referanceCount : Int = 1;
    
    private var urlOperation : HCFindURLTitle?
    
    private let accessLock = NSLock()
    
    private let titleAvailableForUrl : ( )->()!
     
     // MARK: Initialization
    
    init(url:String, titleAvailablityNotifier:()->()){
        
        self.url = url
        titleAvailableForUrl = titleAvailablityNotifier
        super.init()
        
    }
    
    //Cancel the operation
    func cancelOperation()->(){
    
        urlOperation?.cancel()
    }
    
    //Add the operation to queue
    func addOperationToQueue(queue : NSOperationQueue){
        
        if (urlOperation == nil){
            
            urlOperation = HCFindURLTitle(pageURLString: url, delegate: self)
            queue.addOperation(urlOperation!)
        }
        
    }
    //Get the JSON for this item
    func getJSON()->[String:AnyObject]{
        
        //Thread safety is needed
        accessLock.lock()
        
        var urlInfo : [String:AnyObject]
        
        if let pageTitle =  self.title{
            
            urlInfo = ["url":url,"title":pageTitle];
        }
        else{
            
             urlInfo = ["url":url,"title":"Loading..."];
        }
       
        accessLock.unlock()
        
        return urlInfo
    }
    
    // MARK: HCURLOperationDelegate
    
    func urlOperationResultAvailableForUrl(url : String , titleOfUrl title:String?)->(){
        
        accessLock.lock()
        
        self.title = title
        
        urlOperation = nil
        
        accessLock.unlock()
        
        titleAvailableForUrl()
    }
}