//
//  HCStringOperation.swift
//  HipChat
//
//  Created by Tony Thomas on 28/03/16.
//  Copyright © 2016 Tony Thomas. All rights reserved.
//

import Foundation

/**
    The string operations, ie finding urls, emoticons and mentions in the chat
    are done asynchronlously. The results are notified if implemented this protocol
 */
protocol HCStringOperationDelegate{
    
    /*
        `result` is a list and is generalised as `AnyObject`. The `key` specifies
         chat elements of interest, here they can be links, emoticons or mentions
    */
    func stringOperationResultAvailable(result:AnyObject?, forKey key:HCChatElement)->()
    
    
}

/**
    The base class of all string operations.Give pattern matching capability to
    all sub classes.
 */
class HCStringOperation : HCOperation {
    // MARK: Properties
   
    var delegate: HCStringOperationDelegate?
    
    var chatText : String
    
    //Subclasses can override `patten` to give custom pattern for regular expression
    var patten : String  {
        
        get{
            
            return ""
        }
        
    }
    
    //Subclass can override `chatElement` to give there on element type to detect in the string
    var chatElement : HCChatElement  {
        
        get{
            
            return HCChatElement.None
        }
        
    }
    
    // MARK: Initialization
    
    init(chatMessage:String ) {
 
        chatText = chatMessage
        
        super.init()
     }

    override func run() {
        
       var result = findInText(chatText, pattenOfInterest: patten)
       
        result = transformResult(result);
        
        delegate?.stringOperationResultAvailable(result, forKey: chatElement)
    }
    
    //Subclasses can override this method to do custom transformations on the items
    func transformResult(list : [String]?)->[String]?{
        
        //if no transformation needed
        return list;
    }
    
   /*
        This method finds a patten in the give string `text`.The pattern of interest is
        `pattern`
    */
    func findInText(text :String, pattenOfInterest pattern:String) ->([String]?){
        
        
        if let regex = try? NSRegularExpression(pattern: pattern, options: [.CaseInsensitive]){
            
            let matches = regex.matchesInString(text, options: [], range:  NSMakeRange(0, text.characters.count))
            
            guard matches.count > 0 else{
                
                return nil
            }
            
            let nsString = text as NSString
            let itemList = matches.map { nsString.substringWithRange($0.range)}
            
            return itemList
            
        }
        return nil
    }
}