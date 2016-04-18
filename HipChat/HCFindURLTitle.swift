//
//  HCFindURLTitle.swift
//  HipChat
//
//  Created by Tony Thomas on 29/03/16.
//  Copyright © 2016 Tony Thomas. All rights reserved.
//

import Foundation

/**
    Finds the title of the given url.It has two internal operations which are
    scheduled in an internal operation queue.The operations are,
    1,`HCDownloadHTML` which download the HTML page for the url
    2, `HCParsePageTitle` which parses the HTML and finds its title
*/
class HCFindURLTitle : HCOperation {
    // MARK: Properties
    
    
    var pageURL : String
    
    //internal opration queue for downloading HTML and finding its title
    var internalOperationQueue = NSOperationQueue()
    
    //The operation which finds the page title
    let findPageTitleOperaton = HCParsePageTitle()
    
    //The `HCURLTitleOperationDelegate` concrete instance, which will be notified when page title is found
    weak var delegate : HCURLTitleOperationDelegate?
    
    
    deinit{
        
        Log.print("HCPageTitleOperation operation Died")
    }
    
     // MARK: Initialization
    
    init(pageURLString : String, delegate:AnyObject) {
        
     
        pageURL = pageURLString
        self.delegate = delegate as? HCURLTitleOperationDelegate
        super.init()
        
        Log.print("Find page title operation inited for \(pageURL)")
        let downloadHtmlOperation = HCDownloadHTML(pageURL: pageURL, titleFinder: findPageTitleOperaton)
        
        /*
        
            make `HCFindURLTitle` depend on `HCParsePageTitle` operation so that , this instance
            will wait till `HCParsePageTitle` operation finishes
        
        */
        self.addDependency(findPageTitleOperaton)
        
        
        findPageTitleOperaton .addDependency(downloadHtmlOperation)
        
        internalOperationQueue .addOperations([downloadHtmlOperation,findPageTitleOperaton], waitUntilFinished: false)
        
    }
    override func run() {
        
        
        if self.cancelled{
            Log.print("Find page title operation cancelled")
            return;
        }
        
        Log.print("Results available")
        /*
            This operation (`HCFindURLTitle`) will run only after `FindPageTitle` is finished, so
            we can anticipate value for the title of the url
        */
        var urlTitle : String? = nil
        if let title = findPageTitleOperaton.pageTitle{
            
            urlTitle = title
           
        }
        else{
            
             urlTitle = "Not available"
        }
        //We are ready to to update the page title
        delegate?.urlOperationResultAvailableForUrl(pageURL, titleOfUrl: urlTitle)
    }
    
    override func cancel() {
        
        //Cancel all pending operations which are no longer needed due the change in url list
        super.cancel()
        internalOperationQueue.cancelAllOperations()
    }
    
}