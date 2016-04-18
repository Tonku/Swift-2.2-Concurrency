//
//  HCFindMentions.swift
//  HipChat
//
//  Created by Tony Thomas on 28/03/16.
//  Copyright © 2016 Tony Thomas. All rights reserved.
//

import Foundation

/**
 This class extends the `HCStringOperation` class to bring pattern matching
 capability.This class can identify mentions in the chat text.
 eg :@bob It is a (success) => "bob"
 */
class HCFindMentions : HCStringOperation {
    // MARK: Properties
    
    //pattern for this class
    override var patten : String  {
        
        get{
            
            return "@(\\w+)"
        }
        
    }
    
    //chat element for this class
    override var chatElement : HCChatElement  {
        
        get{
            
            return HCChatElement.Mentions
        }
        
    }
    deinit{
        
         Log.print("FindMentions operation Died")
    }



}