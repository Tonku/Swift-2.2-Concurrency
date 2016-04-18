//
//  HCChatToJSON.swift
//  HipChat
//
//  Created by Tony Thomas on 28/03/16.
//  Copyright © 2016 Tony Thomas. All rights reserved.
//

import Foundation


/**
 The class facilitate theconversion of chat strings into separate json entities.They are urls,
 mentions and emoticons.
 This class uses NSOperation and contains two NSOperationQueues, one for plain string operation and
 other for fetching title of URLs.
 The results are asynchronlously updated into a result dictionary,in real time.
 Operation cancel is supported and to cancel any url title fetching operations out there which are no
 longer valid
 Class also handles a special case of any repeated urls, which are handled by reference counting 
 menchanism, rather than fetching the same url again
 */
class HCChatToJSON : NSObject,HCStringOperationDelegate{
     // MARK: Properties

    private  var stringOperationQueue : NSOperationQueue!
    
    private  var urlOperationQueue : NSOperationQueue!
    
    //Unique urls are mapped to `HCChatURLInfo` object
    private lazy var urlList = [String:HCChatURLInfo]()
    
    private var resultDictionary = [String:AnyObject]()
    
    private let updateJSONProgress : (json:String)->()
    
    
       
     // MARK: Initialization
    
    init(withPrograssiveJSONUpdator callback:(String)->()) {
        
        stringOperationQueue = NSOperationQueue()
        
        urlOperationQueue = NSOperationQueue()
        
        /*
         Limit the maximum url operation , otherwise pasting a large
         number of urls leads to a network congestion
        */
        
        urlOperationQueue.maxConcurrentOperationCount = 5

        updateJSONProgress = callback
               
        super.init()
    }
    
    func convertChatMessageToJSON(message : String){
        
        //Cancel all string parsing to keep the things simple
        stringOperationQueue.cancelAllOperations()
        
        //Empty the result dictionary ,all operations on this is done through
        //main thread to have thread safety
        resultDictionary = [String:AnyObject]()

        //find urls in the chat
        let findUrlsOperation = HCFindURLs(chatMessage:message)
        findUrlsOperation.delegate = self
        
        //find emoticons in the chat
        let findEmotIconsOperation = HCFindEmotIcons(chatMessage:message)
        findEmotIconsOperation.delegate = self
        
        //find mentions in the chat
        let findMentionsOperation = HCFindMentions(chatMessage:message)
        findMentionsOperation.delegate = self
        
        //add operations to queue
        stringOperationQueue .addOperations([findUrlsOperation,findEmotIconsOperation,findMentionsOperation
            ], waitUntilFinished: false)
    }
     // MARK: HCStringOperationDelegate
    
    /*
        The JSON is composed in real time with the result from various string operations,
        `HCFindEmotIcons`, `HCFindMentions` and `HCHCChatURLInfo` are them.
    */
    func stringOperationResultAvailable( result:AnyObject?, forKey key:HCChatElement)->(){
        
        
        switch key{
            
        case .Links:
            
             findTitleOfURLs(result)
            
        default:
            
            //Serialise the result dictionary manipuation to ensure thread safety
            dispatch_async(dispatch_get_main_queue(), {
                
                //set the JSON object for mentions and emotions
                self.resultDictionary[key.rawValue] = result
               
                //update the JSON composition progress to the UI
                self.updateJSONCompositionProgressToUI()

                
            });
            
        }
         
    }
    
    // MARK: HCURLOperationDelegate
    
    func urlOperationResultAvailableForUrl()->(){
        
        updateJSONDictionaryForURLList()
    }
    
    //MARK:  helper functions
    
    
    private func findTitleOfURLs(urlList :AnyObject?)->(){
        
        let apparentURLList = urlList as? [String]
        
        guard nil != apparentURLList
            
            else{
                
                cancelAllURLs()
                
                return
        }
        //Find the urls which need to be worked on.
        let urlsNeedToWorkOn = computeNewURLs(apparentURLList!)
        
        //Add new urls in current url list
        addNewURLsInCurrentList(urlsNeedToWorkOn)
        
        //The repeating urls if any, is handled
        manageURLreferenceCountForRepeatedURLs(apparentURLList!)
        
        //Update the dictionary, so that there is a realtime feedback
        updateJSONDictionaryForURLList()
    }
    
    /*
        If there is no url in current chat message, cancel all existing url info
        operation
    */
    private func cancelAllURLs(){
        
        for (_,urlInfo) in urlList{
            
            urlInfo.cancelOperation()
        }
        urlList.removeAll()
    }

    /*
        Find unique urls in the array of urls in current chat message
    */
    private func computeNewURLs(urls : [String])->Set<String>{
        
        var newUniqueURLs: Set<String> = Set(urls)
        
        
        if  urlList.count>0{
            
            let existingURLs = Set(urlList.keys)
            
            //cancel operations out there which are no longer needed
            let urlsToCancel = existingURLs.subtract(Set(urls))
            
            for url in urlsToCancel {
                
                urlList[url]?.cancelOperation()
                urlList[url] = nil
                //remove the entry from the map
                Log.print("cancelled operation for url \(url)")
            }
            //find new URLs in result add them as new operations
            newUniqueURLs =  Set(urls).subtract(Set(existingURLs))
        }
        return newUniqueURLs
    }
    
    /*
        New urls are translated into `HCChatURLInfo` object and add to the list
    */
    private func addNewURLsInCurrentList(urls : Set<String>){
        
        for url in urls{
            
            let urlAction = HCChatURLInfo(url: url ,  titleAvailablityNotifier: urlOperationResultAvailableForUrl)
            urlAction.addOperationToQueue(urlOperationQueue)
            
            Log.print("Added new operation for url \(url)")
            urlList[url] = urlAction
        }
        
    }
    
    /*
        There can be repeated urls in the chat which actually need just one copy
        best way to manage it is using referance count to track the instance count
    */
    private func manageURLreferenceCountForRepeatedURLs(urls : [String])->(){
    
        for (urlExisting, urlAction) in urlList{
            
            urlAction.referanceCount = 0;
            //increase the usage count for repeating urls, we have already the result
            for url in urls{
                
                if url == urlExisting{
                    
                    urlAction.referanceCount++
                }
            }
            if urlAction.referanceCount == 0{
                
                //we need positive reference count for each entry in dictonary, when we compose
                //JSON for the urls
                urlAction.referanceCount = 1
            }
           
        }
    
    }
    
    /*
        The JSON is composed in real time from the result from various operations
    */
    private func updateJSONCompositionProgressToUI(){
        
        do{
            
            let theJSONData = try NSJSONSerialization.dataWithJSONObject(self.resultDictionary, options: NSJSONWritingOptions.PrettyPrinted)
            
            let jsonString = String(data: theJSONData, encoding: NSUTF8StringEncoding)
            
            if let jsonString = jsonString{
                
                updateJSONProgress(json: jsonString)
            }
         }
        catch{
            
             Log.print("Error converting JSON dictionary")
        }
        
    }
    /*
       Update the JSON when there is a change in the url details
    */
    private func updateJSONDictionaryForURLList(){
        
        //Serialise the manipuation to ensure thread safety
        
        dispatch_async(dispatch_get_main_queue(), {
            
            //update the title value in json dictionary
            
            var links = Array<AnyObject>()
            
            for (_, urlAction) in self.urlList{
                
                for _ in 1...urlAction.referanceCount{
                    
                    links.append(urlAction.getJSON())
                }
                
            }
            self.resultDictionary[HCChatElement.Links.rawValue] = links
            self.updateJSONCompositionProgressToUI()
            
            
        });
    }

    
}