//
//  HCEnumerations.swift
//  HipChat
//
//  Created by Tony Thomas on 28/03/16.
//  Copyright © 2016 Tony Thomas. All rights reserved.
//

import Foundation

/**
 The enumeration defines the chat elements of interest
*/
enum HCChatElement : String{
    
    //URLs
    case Links   = "links"
    
    //@name
    case Mentions   = "mentions"
    
    //(String of size == 15)
    case EmotIcons = "emoticons"
    
    case None = "None"
}


