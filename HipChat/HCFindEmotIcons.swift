//
//  HCFindEmotIcons.swift
//  HipChat
//
//  Created by Tony Thomas on 28/03/16.
//  Copyright © 2016 Tony Thomas. All rights reserved.
//

import Foundation

/**
    This class extends the `HCStringOperation` class to bring pattern matching
    capability.This class can identify emoticons of length less than 15.
    eg : It is a (success) => "success"
 */
class HCFindEmotIcons : HCStringOperation {
    // MARK: Properties
    
    
    let emotIconLength = 15
    
    //Give pattern for finding emoticon
    override var patten : String  {
        
        get{
            
            return "(?<=\\().+?(?=\\))"
        }
        
    }
    //The chat element type to detect in the string, here it is `EmotIcons`
    override var chatElement : HCChatElement  {
        
        get{
            
            return HCChatElement.EmotIcons
        }
        
    }
    
    deinit{
        
         Log.print("FindEmotIcons operation Died")
    }
    
    //Overriding for custom transformation for the list
    override func transformResult(list : [String]?)->[String]?{
        
        return filterEmotIconsList(list, forLength: emotIconLength)
    }
    
    //Filter emotiocons of length more than `emotIconLength`
    func filterEmotIconsList(list :[String]?, forLength length:Int)->([String]?){
        
        
        let newList =  list?.filter({  $0.characters.count<length+1  })
        
        //we need nil list for proper JSON creation
        if newList?.count==0{
            
            return nil
        }
        return newList
    }
}