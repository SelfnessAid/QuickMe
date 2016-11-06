//
//  WebserviceUtils.swift
//  Quick Me
//
//  Created by Abdul Wahib on 5/3/16.
//  Copyright © 2016 Quick Me. All rights reserved.
//

import Foundation
import AFNetworking

class WebserviceUtils {
    
    class func callGetRequest(url: String, var params: [String: String]?, success: ((AnyObject?)) -> Void ,failure: ((NSError)->Void)) {
        let manager = AFHTTPSessionManager()
        
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer()
        manager.responseSerializer.acceptableContentTypes?.insert("text/plain")
        manager.responseSerializer.acceptableContentTypes?.insert("text/html")
        manager.responseSerializer.acceptableContentTypes?.insert("image/png")
        manager.responseSerializer.acceptableContentTypes?.insert("image/jpeg")
        
        
        
        if params != nil {
            params!["sc"] = "AAKMVNNDKEEOWOQQJCNGJRELWLSFEWF12WFW"
        }else {
            params = [:]
            params!["sc"] = "AAKMVNNDKEEOWOQQJCNGJRELWLSFEWF12WFW"
        }
        
        manager.securityPolicy.allowInvalidCertificates = true
        manager.securityPolicy.validatesDomainName = false
        
        manager.GET(
            url,
            parameters: params,
            progress: nil,
            success: { (session, response) -> Void in
                success(response)
        }) { (session, error) -> Void in
            failure(error)
        }
    }

    
    class func callGetRequest(url: String, header: [String: String],params: [String: String]?, success: ((AnyObject?)) -> Void ,failure: ((NSError)->Void)) {
        let manager = AFHTTPSessionManager()
        
        manager.requestSerializer = AFHTTPRequestSerializer()
        for (k,v) in header {
            manager.requestSerializer.setValue(v, forHTTPHeaderField: k)
        }
        
        manager.responseSerializer.acceptableContentTypes?.insert("text/plain")
        
        manager.GET(
            url,
            parameters: params,
            progress: nil,
            success: { (session, response) -> Void in
                success(response)
        }) { (session, error) -> Void in
            failure(error)
        }
    }
    
    class func callPostRequest(url: String, var params: [String: String], success: ((AnyObject?)) -> Void ,failure: ((NSError)->Void)) {
        let manager = AFHTTPSessionManager()
        
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer.acceptableContentTypes?.insert("text/plain")
        
        manager.securityPolicy.allowInvalidCertificates = true
        manager.securityPolicy.validatesDomainName = false
        
        params["sc"] = "AAKMVNNDKEEOWOQQJCNGJRELWLSFEWF12WFW"
        
        manager.POST(
            url,
            parameters: params,
            progress: nil,
            success: { (session, response) -> Void in
                success(response)
        }) { (session, error) -> Void in
            failure(error)
        }
    }
    
    class func callPostRequest(url: String, header: [String: String] ,params: [String: String]?, success: ((AnyObject?)) -> Void ,failure: ((NSError)->Void)) {
        let manager = AFHTTPSessionManager()
        
        manager.requestSerializer = AFHTTPRequestSerializer()
        for (k,v) in header {
            manager.requestSerializer.setValue(v, forHTTPHeaderField: k)
        }
        
        manager.responseSerializer = AFJSONResponseSerializer()
        manager.responseSerializer.acceptableContentTypes?.insert("text/plain")
        
        manager.POST(
            url,
            parameters: params,
            progress: nil,
            success: { (session, response) -> Void in
                success(response)
        }) { (session, error) -> Void in
            failure(error)
        }
    }
    
    class func callPostJSONRequest(url: String, header: [String: String],params: [String: String] , success: ((AnyObject?)) -> Void ,failure: ((NSError)->Void)) {
        let manager = AFHTTPSessionManager()
        
        manager.requestSerializer = AFJSONRequestSerializer()
        for (k,v) in header {
            manager.requestSerializer.setValue(v, forHTTPHeaderField: k)
        }
        manager.responseSerializer = AFJSONResponseSerializer()
        manager.responseSerializer.acceptableContentTypes?.insert("text/plain")
        
        manager.POST(
            url,
            parameters: params,
            progress: nil,
            success: { (session, response) -> Void in
                success(response)
        }) { (session, error) -> Void in
            failure(error)
        }
    }
    
    class func callPostJSONRequest(url: String, header: [String: String] ,params: AnyObject?, success: ((AnyObject?)) -> Void ,failure: ((NSError)->Void)) {
        let manager = AFHTTPSessionManager()
        
        manager.requestSerializer = AFJSONRequestSerializer()
        for (k,v) in header {
            manager.requestSerializer.setValue(v, forHTTPHeaderField: k)
        }
        
        manager.responseSerializer = AFJSONResponseSerializer()
        manager.responseSerializer.acceptableContentTypes?.insert("text/plain")
        
        manager.POST(
            url,
            parameters: params,
            progress: nil,
            success: { (session, response) -> Void in
                success(response)
        }) { (session, error) -> Void in
            failure(error)
        }
    }
    
    class func callPostRequestMultipartData(url: String,var params: [String: String],image: UIImage?, success: ((AnyObject?)) -> Void , failure: ((NSError)->Void)) {
        let manager = AFHTTPSessionManager()
        
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer()
        manager.responseSerializer.acceptableContentTypes?.insert("text/plain")
        
        manager.securityPolicy.allowInvalidCertificates = true
        manager.securityPolicy.validatesDomainName = false
        
        
        params["sc"] = "AAKMVNNDKEEOWOQQJCNGJRELWLSFEWF12WFW"
        
        manager.POST(
            url,
            parameters: params,
            constructingBodyWithBlock: { (formData) -> Void in
                if let img = image {
                    if let data = UIImageJPEGRepresentation(img, 0.0) {
                        formData.appendPartWithFileData(data, name: "doc", fileName: "photo.jpg", mimeType: "image/jpeg")
                    }
                }else {
                    if let data = UIImageJPEGRepresentation(UIImage(), 0.0) {
                        formData.appendPartWithFileData(data, name: "doc", fileName: "photo.jpg", mimeType: "image/jpeg")
                    }
                }
            },
            progress: nil,
            success: { (session, response) -> Void in
                success(response)
            })
        { (session, error) -> Void in
            failure(error)
        }
    }
    
}