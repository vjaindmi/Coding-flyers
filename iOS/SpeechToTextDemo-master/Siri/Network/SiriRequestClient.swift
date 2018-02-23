//
//  CFTVRequestClient.swift
//  FitnessFirst
//
//  Created by Ishita Agarwal on 22/12/17.
//  Copyright © 2017 Fitness First. All rights reserved.
//

import UIKit
import Alamofire

class SiriRequestClient: URLRequestConvertible
{
    var path : String = ""
    var method : String? = ""
    var params : NSDictionary? = nil
    
    init(path : String , method : String , params : NSDictionary?)
    {
        self.path = path
        self.method = method
        self.params = params
    }
    
     var baseURL : String = {
        let urlString = "http://learnictify.azurewebsites.net/api/"
        return urlString
    }()
    
    func asURLRequest() throws -> URLRequest
    {
        let url = URL(string: path, relativeTo: URL(string:self.baseURL))
        var request = URLRequest(url: url!)
        request.httpMethod = method
        request.timeoutInterval = TimeInterval(60 * 1000)
        return try URLEncoding.default.encode(request, with: self.params as? Parameters)
    }
    

}

protocol ResponseDelegate  {
    func responseReceived(data : NSDictionary)
}

class SiriRequestMethods : NSObject {
    
    static let sharedInstance = SiriRequestMethods()
    var delegate : ResponseDelegate?
    
     func fetchImagesFor(_text : String, completion : @escaping (_ _responseData : NSDictionary) -> Void) {
        var urlString = "v1/user/imagedata?requestText=" + _text
        let request : URLRequestConvertible = SiriRequestClient.init(path: urlString, method: "GET", params: nil)
        Alamofire.request(request).responseJSON { response in
            if response.result.isSuccess {
                let arr_response = response.result.value as! NSArray
                let response = arr_response.firstObject as! NSDictionary
                self.delegate?.responseReceived(data: response)
                
                completion(response)
            }
            else
            {
                let response = NSDictionary(object: "No Response", forKey: "query" as NSCopying)
                self.delegate?.responseReceived(data: response)

                completion(response)
            }
        

    }
    
}

}
