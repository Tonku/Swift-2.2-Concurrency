//
//  HipChatTests.swift
//  HipChatTests
//
//  Created by Tony Thomas on 22/03/16.
//  Copyright © 2016 Tony Thomas. All rights reserved.
//

import XCTest
@testable import HipChat

class HipChatTests: XCTestCase, HCURLTitleOperationDelegate {
    
    
    var findURLTitle : HCFindURLTitle!
    var operationQueue = NSOperationQueue()
    var findURLTitleExpectation : XCTestExpectation!
  
    override func setUp() {
        
        super.setUp()
        
        findURLTitleExpectation = expectationWithDescription("Tile fetching should happen within 3 seconds")
        findURLTitle = HCFindURLTitle(pageURLString: "https://twitter.com/jdorfman/status/430511497475670016", delegate: self)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
      

    
    func testfindValueOfHTMLTag(){
        
        let parsePageTitle = HCParsePageTitle()
        
        let html = "<html><body>You scored 192 points</body></html>"
        let tag = "<body>"
        
        let result = parsePageTitle.findValueOfHTMLTag(tag, inHTML: html)
        
        XCTAssertNotNil(result)
    }
    
    //Test to ensure that nothing is find for the value of a tag which is absent in a HTML
    func testfindValueOfHTMLTagNotPresent(){
        
        let parsePageTitle = HCParsePageTitle()
        
        let html = "<html><body>You scored 192 points.</body></html>"
        let tag = "<title>"
        
        let result = parsePageTitle.findValueOfHTMLTag(tag, inHTML: html)
        
        XCTAssertNil(result)
    }
    
    //Test to find the exact match of the mentions
    func testFindMentions(){
        
        let stringOperation = HCStringOperation(chatMessage: "")
        
        let chatMessage = "Mr @bob is good. @simon is fine too"
        
        let pattern = "@(\\w+)"
        
        let result = stringOperation.findInText(chatMessage, pattenOfInterest: pattern)
        
        XCTAssertTrue(result?.count == 2)
    
    }
    
    //Test to make sure that the similar patterns are not matched
    func testAbsenseOfMentions(){
        
        let stringOperation = HCStringOperation(chatMessage: "")
        
        let chatMessage = "Mr @ bob is good #simon@ is fine too"
        
        let pattern = "@(\\w+)"
        
        let result = stringOperation.findInText(chatMessage, pattenOfInterest: pattern)
        
        XCTAssertNil(result)
        
    }
    
    //Test to find emoticons in a chat which are of length max up to 15 chars
    func testFindEmoticons(){
        
        let findEmotIcons = HCFindEmotIcons(chatMessage: "")
        
        let chatMessage = "@bob @john (success) such a (cool) feature, (that is a lot of text), (yes); "
        let pattern = "\\((.*?)\\)"
        let emotIconLength = 15
        
        
        let result = findEmotIcons.findInText(chatMessage, pattenOfInterest: pattern)
        
        if let result =  result{
            
            XCTAssertTrue(result.count == 4)
            
            let filteredList = findEmotIcons.filterEmotIconsList(result, forLength: emotIconLength)
            
            if let filteredList = filteredList{
                
                 XCTAssertTrue(filteredList.count == 3)
            }
            
        }
    }
    
    //Find urls in the given text
    func testFindURLs(){
        
        let stringOperation = HCStringOperation(chatMessage: "")
        
        let chatMessage = "Olympics are starting soon http://www.nbcolympics.com/  cool feature https://twitter.com/jdorfman/status/430511497475670016"
        
        let pattern = "https?:\\/\\/(?:www\\.|(?!www))[^\\s\\.]+\\.[^\\s]{2,}|www\\.[^\\s]+\\.[^\\s]{2,}"
        
        let result = stringOperation.findInText(chatMessage, pattenOfInterest: pattern)
        
        XCTAssertTrue(result?.count == 2)
        
    }
    
    //Some urls will be missing the prefix http:// or https:// ,  NSURL need them badly
    func testURLPrefixIfMissingAddressed(){
        
        let chatMessage = "Olympics are starting soon www.nbcolympics.com/  cool feature https://twitter.com/jdorfman/status/430511497475670016"
        
        let findURLs = HCFindURLs(chatMessage: chatMessage)
        
        let pattern = "https?:\\/\\/(?:www\\.|(?!www))[^\\s\\.]+\\.[^\\s]{2,}|www\\.[^\\s]+\\.[^\\s]{2,}"
        
        var result = findURLs.findInText(chatMessage, pattenOfInterest: pattern)

        result = findURLs.transformResult(result)
        
        if let result = result{
            
            for url in result{
                
                XCTAssertTrue(url.hasPrefix("http://")||url.hasPrefix("https://"))
            }
            
        }

    }
    //check the performance of URL detection
    func testPerformanceOfDetectURL() {
        
        self.measureBlock {
            
            let stringOperation = HCStringOperation(chatMessage: "")
            
            let chatMessage = "Olympics are starting soon http://www.nbcolympics.com/ ddd cool feature https://twitter.com/jdorfman/status/430511497475670016 dd www.yahoo.com www.google.com Olympics are starting soon http://www.nbcolympics.com/  cool feature https://twitter.com/jdorfman/status/430511497475670016 www.yahoo.com www.google.com ls lld "
            
            let pattern = "https?:\\/\\/(?:www\\.|(?!www))[^\\s\\.]+\\.[^\\s]{2,}|www\\.[^\\s]+\\.[^\\s]{2,}"
            
            let _ = stringOperation.findInText(chatMessage, pattenOfInterest: pattern)

        }
    }
    func urlOperationResultAvailableForUrl(url : String , titleOfUrl title:String?)->(){
        
        print("url : \(url) title : \(title)")
        findURLTitleExpectation.fulfill()
    }
    //testing async url title feching
    func testAsyncGetURLTitle(){
        
        
     
        let timeout = 2.0
        
        operationQueue.addOperation(findURLTitle)
     
        
        
        waitForExpectationsWithTimeout(timeout) { error in
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
          
        }
    }
}
