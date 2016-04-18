//
//  HCNetworkActivityIndicator.swift
//  HipChat
//
//  Created by Tony Thomas on 05/04/16.
//  Copyright © 2016 Tony Thomas. All rights reserved.
//

import UIKit

/**
   This class abstracts the network activity indicator and manages its show and hide
 */
class HCNetworkActivityIndicator{
    
   static let sharedIndicator = HCNetworkActivityIndicator()

    var referenceCount : Int = 0
   
    //Show activity
    func show(){
        
        /*
            Thread safety needed here for `referenceCount`, because multiple operations act on
            `referenceCount` dispatch queue for main thread provides thread safety using serialised
            access.Also network activity indicator must operate in UI thread
        */
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            self.referenceCount++
            
            if self.referenceCount>0{
                
                UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                
            }

        }
       
    }
    
    //Hide activity
    func hide(){
        

        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            self.referenceCount--
            
            if self.referenceCount<1{
                
                /*
                    Hiding network activity after a delay will give more smooth experience.
                    There are multiple operations turn on and off network activity indicator
                    in short time
                */
                let when = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
                
                dispatch_after(when, dispatch_get_main_queue()) {
                    
                     UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    
                }
                
            }
            
        }
        
    }
}