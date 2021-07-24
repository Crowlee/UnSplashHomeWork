//
//

import Foundation
import UIKit
import SystemConfiguration



let requestTimeout:TimeInterval = 10.0
let authToken:TimeInterval = 200.0
//let RETRY_MAX:Int = 10
let RETRY_MAX:Int = 5


protocol ConnectionMgrDelegate {
    func displayResult(data:Array<Any>) -> Void
    func displayResultWithSearch(data:Dictionary<String, Any>) -> Void
}

private let ConnectionMgrSharedInstance = ConnectionMgr()



class ConnectionMgr:NSObject, URLSessionDelegate, URLSessionDownloadDelegate{

    var nRtCnt:Int = 0
    var delegate:ConnectionMgrDelegate?
    
    
    class func sharedInstance() -> ConnectionMgr {
        return ConnectionMgrSharedInstance
    }
    public func setCommand(strUrl:String, strCmd:String){
//        let url = URL(string: "https://api.unsplash.com/photos/")
//        var request = URLRequest(url: url!)

        self.makeURLRequest(strURL: strUrl,  strCmd: strCmd)
    
    }
    private func makeURLRequest(strURL:String,  strCmd:String) -> Void {
        let escapedString = strURL.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)
        print(escapedString)
        guard let urlString:URL = URL(string:strURL) else {
            print ("Error : URL create Error")
            
            return
        }
        let urlRequest = NSMutableURLRequest(url: urlString)
        urlRequest.httpMethod = strCmd
        urlRequest.setValue("Client-ID \(cID)", forHTTPHeaderField: "Authorization")
        let netStatus = Network.reachability?.status
        
        if(netStatus == .unreachable){
            return
        }
        
        
        
        let task = URLSession.shared.dataTask(with: urlRequest as URLRequest) { (data, response, err) in
            guard let data = data else {
                return
            }
            do {
                let parsedValue = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
                
                if(isKeywordSearch == false)
                {
                    self.delegate?.displayResult(data: parsedValue as! Array<Any>)
                }
                else {
                    self.delegate?.displayResultWithSearch(data: parsedValue as! Dictionary<String, Any>)
                }

                print(parsedValue)
            } catch {
                print(err as Any)
            }
        }
        task.resume()
        
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {

    }
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {

        
    }
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        print(downloadTask)
        print(fileOffset)
    }
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {

    }
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {

    }
    func parseToResponseParam(data:Dictionary<String,Any>, command:String) -> Void {
        NSLog("data = %@, commnad = %@", data, command)
    }
    
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if((challenge.protectionSpace.host == "https://unsplash.com/")){
                let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
                completionHandler(URLSession.AuthChallengeDisposition.useCredential, credential)
            
            
        }
        else {
            completionHandler(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
        }
    }
    
}

extension NSMutableURLRequest {
    
    /// Percent escape
    ///
    /// Percent escape in conformance with W3C HTML spec:
    ///
    /// See http://www.w3.org/TR/html5/forms.html#application/x-www-form-urlencoded-encoding-algorithm
    ///
    /// - parameter string:   The string to be percent escaped.
    /// - returns:            Returns percent-escaped string.
    
    private func percentEscapeString(string: String) -> String {
        let characterSet = NSCharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._* ")
        
        return string
            .addingPercentEncoding(withAllowedCharacters: characterSet as CharacterSet)!
            .replacingOccurrences(of: " ", with: "+", options: [], range: nil)

    }
    
    /// Encode the parameters for `application/x-www-form-urlencoded` request
    ///
    /// - parameter parameters:   A dictionary of string values to be encoded in POST request
    

    func encodeParameters(parameters: [String : String], cmdType:String) {
        
        httpMethod = cmdType
        httpBody = parameters
            .map { "\(percentEscapeString(string: $0))=\(percentEscapeString(string: $1))" }
            .joined(separator: "&")
            .data(using: String.Encoding.utf8)
//        print(httpBody)
//        print(String.init(bytes: httpBody as Data!, encoding: String.Encoding.utf8))
    }
}

extension Dictionary {
    
    func paramsString() -> String {
        var paramsString = [String]()
        for (key, value) in self {
            guard let stringValue = value as? String, let stringKey = key as? String else {
                return ""
            }
            paramsString += [stringKey + "=" + "\(stringValue)"]
            
        }
        return (paramsString.isEmpty ? "" : paramsString.joined(separator: "&"))
    }
}
