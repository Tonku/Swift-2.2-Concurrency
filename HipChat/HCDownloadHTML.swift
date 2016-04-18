//
//  HCDownloadHTML.swift
//  HipChat
//
//  Created by Tony Thomas on 29/03/16.
//  Copyright © 2016 Tony Thomas. All rights reserved.
//


import UIKit

/**
    This operation class has the ability to downlod the HTML for a url.
    The url download task `HCDownloadHTML` contains can be cancelled even 
    after this operation starts execution.
 */
class HCDownloadHTML : HCOperation {
    // MARK: Properties
    
    weak var findPageTitle : HCParsePageTitle?
    
    var pageDownloadTask : NSURLSessionDataTask!
    
    /*
        Semaphore for waiting for async `NSURLSessionDataTask` and keep this
        object alive */
    private let semaphore = dispatch_semaphore_create(0);
    
    deinit{
        
        Log.print("DownloadHTML operation Died")
    }
     // MARK: Initialization
    
    init(pageURL : String , titleFinder:HCParsePageTitle) {
        
        findPageTitle = titleFinder
        
        super.init()
        
        setupURLDownload(pageURL)
      
    }
    
    //prepare the url download
    func setupURLDownload(pageURL:String){
        
        
        let url = NSURL(string: pageURL)
        
        guard url != nil else{
            
            //signal the semaphore to finish this operation
            dispatch_semaphore_signal(self.semaphore)
            return;
        }

        //Network activity indicator
       
        HCNetworkActivityIndicator.sharedIndicator.show()
        
        pageDownloadTask  = NSURLSession.sharedSession().dataTaskWithURL(url!)
                                                        { (var data , urlResponse, error) -> Void in
            
            
            
            HCNetworkActivityIndicator.sharedIndicator.hide()
                                                            
            Log.print("page download operation completed")
            
            if self.cancelled{
                
                Log.print("operation cancelled")
                data = nil;
            }
            
            if let error = error {
                
                Log.print("HTML Download Error \(error)")
                
            }
            guard data != nil else{
                
                dispatch_semaphore_signal(self.semaphore)
                return
            }
            
            if let  htmlPage =  String(data: data!, encoding: NSUTF8StringEncoding){
                                                                
                self.findPageTitle?.htmlPage = htmlPage
            }
                        
            /*
                signal the semaphore to finish this operation, so that the `HCFindURLTitle`
                operation can start execution
            */
            dispatch_semaphore_signal(self.semaphore)
            
        }

    }
    override func run() {
        
        Log.print("page download operation started")
        
        pageDownloadTask.resume()
        
        //Wait till till the async data task  finish
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        Log.print("Download operation complete")
    }
    
    override func cancel() {
        
        HCNetworkActivityIndicator.sharedIndicator.hide()
        //Cancel the current url download
        pageDownloadTask.cancel()
        //Singnal the semaphore and let the operation to finish
        dispatch_semaphore_signal(semaphore)
    }
}