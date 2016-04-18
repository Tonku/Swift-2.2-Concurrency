//
//  HCParsePageTitle.swift
//  HipChat
//
//  Created by Tony Thomas on 29/03/16.
//  Copyright © 2016 Tony Thomas. All rights reserved.
//

import Foundation

/**
    `HCParsePageTitle` operation can parse a HTML and find its title.
     This operation has a dependancy on `HCDownloadHTML` operation, so
     this instance will wait for the HTML download to comple.
 */
class HCParsePageTitle : HCOperation {
    // MARK: Properties
    
    var htmlPage : String?
    
    var pageTitle : String?
    
    deinit{
        
        Log.print("FindPageTitle operation Died")
    }
    
    override func run() {
        
        
        if let htmlPage = self.htmlPage{
            
            pageTitle = findValueOfHTMLTag("<title>", inHTML: htmlPage)
        }
        
    }
    /* 
        finds value of a tag in the given html
    */
    func findValueOfHTMLTag(tag : String, inHTML html: String)->String?{
        
        guard !html.isEmpty && !tag.isEmpty
        
            else{
                
                return nil;
        }
        
        let endTag = tag.stringByReplacingOccurrencesOfString("<", withString: "</")
        
        let pageScanner = NSScanner(string: html)
        var titleString : NSString? = nil

        /*
            The method `scanUpToString` scan into full length try to find the match and
            the cursor will be on last char, if the match is not found
        */
        if pageScanner.scanUpToString(tag, intoString: nil) {
            
            if pageScanner.scanLocation == html.characters.count{
                
                Log.print("No title for this url")
                return nil
            }
            pageScanner.scanLocation += tag.characters.count
            pageScanner.scanUpToString(endTag, intoString: &titleString)
            
        }
        guard titleString != nil
            
            else{
                
                return nil
        }
        Log.print("found title \(titleString!)")
        //uses third party library to decode HTML entities
       return String(titleString!).stringByDecodingHTMLEntities
    }
}