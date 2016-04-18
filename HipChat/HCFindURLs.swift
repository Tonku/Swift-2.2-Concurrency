//
//  HCFindURLs.swift
//  HipChat
//
//  Created by Tony Thomas on 28/03/16.
//  Copyright © 2016 Tony Thomas. All rights reserved.
//

import Foundation

/**
    This class extends the `HCStringOperation` class to bring pattern matching
    capability.This class can identify urls in the chat text.
    eg :@bob It is a (success), see this www.cnn.com => "http://www.cnn.com"
 */
class HCFindURLs : HCStringOperation {
    // MARK: Properties
    
    //Pattern for the class
     override var patten : String  {
        
        get{
            
            return "https?:\\/\\/(?:www\\.|(?!www))[^\\s\\.]+\\.[^\\s]{2,}|www\\.[^\\s]+\\.[^\\s]{2,}"
        }
        
    }
    
    //Chat element type
    override var chatElement : HCChatElement  {
        
        get{
            
            return HCChatElement.Links
        }
        
    }

    
    deinit{
        
         Log.print("FindURLs operation Died")
    }
    
    //Custom transformation for adding prefix for urls
    override func transformResult(list : [String]?)->[String]?{
        
        
        return  list?.map{
            
            if $0.lowercaseString.hasPrefix("http://") || $0.lowercaseString.hasPrefix("https://"){
                
                return $0
            }
            else{
                
                return "http://"+$0
            }
            
            
        }
        
    }
 
    
}