//
//  HCOperation.swift
//  HipChat
//
//  Created by Tony Thomas on 28/03/16.
//  Copyright © 2016 Tony Thomas. All rights reserved.
//

import Foundation

/**
    The base class of all operations.
    We can use this class for more generalised implementations for future 
    requrements like opration state, notification of progress etc.
 */
class HCOperation : NSOperation {
    
   
    override func main() {
        

        if !cancelled{
            
             run()
        }
       
    }
    
    /*
        Sub classes can override the run method.This method will run only
        if the operation is not cancelled just before the the call from the
        main()
    */
    func run() {
        
    }

}