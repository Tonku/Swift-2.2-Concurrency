//
//  ViewController.swift
//  HipChat
//
//  Created by Tony Thomas on 22/03/16.
//  Copyright © 2016 Tony Thomas. All rights reserved.
//

import UIKit

class ViewController: UIViewController , UITextViewDelegate {
    
  
    @IBOutlet weak var chatWindow: UITextView!
    @IBOutlet weak var jsonView: UITextView!
    @IBOutlet weak var keyBoardPalcementConstraint: NSLayoutConstraint!
    
    var chatToJSON : HCChatToJSON!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        

        NSNotificationCenter.defaultCenter().addObserver(self, selector:Selector("keyboardWillAppear:") , name: UIKeyboardWillShowNotification, object: nil)
        
         NSNotificationCenter.defaultCenter().addObserver(self, selector:Selector("keyboardWillDisappear:") , name: UIKeyboardWillHideNotification, object: nil)
        
        chatToJSON = HCChatToJSON(withPrograssiveJSONUpdator: onJSONProgressiveUpdate)
        
        chatWindow.text = "Type your message..."
        chatWindow.textColor = UIColor.lightGrayColor()
    }

    //MARK: Overrides
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }

    //MARK: JSON Callback
    
    func onJSONProgressiveUpdate(json : String){
        
        jsonView.text  = json
    }
    
    //MARK: TextViewDelegate
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        
        if textView == jsonView{
            
             view.endEditing(true)
            
             return false
        }
        return true
    }
    func textViewDidBeginEditing(textView: UITextView) {
        
        if textView.text == "Type your message..."{
            
            textView.text = ""
            textView.textColor = UIColor.blackColor()
        }
        textView.becomeFirstResponder()
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        
        if textView.text == ""{
            
            textView.text = "Type your message..."
            textView.textColor = UIColor.lightGrayColor()
        }
        textView.resignFirstResponder()
    }
    
    
    func textViewDidChange(textView: UITextView){
        
         chatToJSON.convertChatMessageToJSON(chatWindow.text)
    }

    //MARK: Actions
    
    @IBAction func onClear(sender: AnyObject) {
        
        chatWindow.text = nil
        chatToJSON.convertChatMessageToJSON(chatWindow.text)
        
    }
    
    //MARK: Keyboard notifications
    
    func keyboardWillAppear(notification: NSNotification){
        
        if let userInfo = notification.userInfo{
            
            if let keyboardRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue(){
                
                keyBoardPalcementConstraint.constant = keyboardRect.height
                view.setNeedsLayout()
            }
        }
    }
    
    func keyboardWillDisappear(notification: NSNotification){
        
        keyBoardPalcementConstraint.constant = 0;
        view.setNeedsLayout()
    }

}

