//
//  NetworkManager.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/02.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

typealias ResSuccess = (JSON) -> Void
typealias ResFailure = (Any) -> Void

enum AppError: String, Error {
    case invalidResponseType = "response data type not dictionary"
    case reqeustStatusCodeOverRage = "response status code over range 200 ~ 300"
}

enum ContentType: String {
    case json = "application/json; charset=utf-8"
    case formdata = "multipart/form-data"
    case urlencoded = "application/x-www-form-urlencoded"
    case text = "text/plain"
}

class NetworkManager: NSObject {
    static let ins = NetworkManager()
    
    func getFullUrl(_ url:String) -> String {
        return "\(baseUrl)\(url)"
    }
    
    func request(_ method: HTTPMethod, _ url: String, _ param:[String:Any]? = nil, _ encoding:ParameterEncoding = JSONEncoding.default, _ isStartIndicator:Bool = true,  success:ResSuccess?, failure:ResFailure?) {
        
        var fullUrl = ""
        if (url.hasPrefix("http") || url.hasPrefix("https")) {
            fullUrl = url
        }
        else {
            fullUrl = self.getFullUrl(url)
        }
        guard let encodedUrl = fullUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        
        if isStartIndicator {
            appDelegate.startIndicator()
        }
        
        let header:HTTPHeaders = [.contentType(ContentType.json.rawValue)]
        
        let request = AF.request(encodedUrl, method: method, parameters: param, encoding: encoding, headers: header)
        request.responseJSON { (response:AFDataResponse<Any>) in
            if let url = response.request?.url?.absoluteString {
                print("\n=======request: url: \(String(describing: url))")
                if let param = param {
                    print(String(describing: param))
                }
            }
            print("\n======= response ======= \n\(response)")
            if isStartIndicator {
                appDelegate.stopIndicator()
            }
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                success?(json)
                break
            case .failure(let error):
                failure?(error)
                break
            }
        }
    }
    
    func requestFileUpload(_ method: HTTPMethod, _ url: String, _ param:[String:Any]?, success:ResSuccess?, failure:ResFailure?) {
        let fullUrl = self.getFullUrl(url)
        guard let encodedUrl = fullUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let param = param else {
            return
        }
        
        appDelegate.startIndicator()
        
        let header: HTTPHeaders = [.contentType(ContentType.formdata.rawValue)]
        
        AF.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in param {
                if let value = value as? Array<UIImage> {
                    for img in value {
                        if let imgData = img.jpegData(compressionQuality: 0.9) {
                            let strDate = Utility.getCurrentDate(format: "yyyyMMddHHmmssS")
                            multipartFormData.append(imgData, withName: "\(key)[]", fileName: "JPEG_\(strDate).jpg", mimeType: "image/jpg")
                            print(" == imgData byte: \(ByteCountFormatter().string(fromByteCount: Int64(imgData.count)))")
                        }
                    }
                }
                else {
                    if let value = value as? UIImage {
                        if let imgData = value.jpegData(compressionQuality: 0.9) {
                            let strDate = Utility.getCurrentDate(format: "yyyyMMddHHmmssS")
                            multipartFormData.append(imgData, withName: "\(key)", fileName: "JPEG_\(strDate).jpg", mimeType: "image/jpg")
                            print(" == imgData byte: \(ByteCountFormatter().string(fromByteCount: Int64(imgData.count)))")
                        }
                    }
                    else {
                        let data:Data? = "\(value)".data(using: .utf8)
                        if let data = data {
                            multipartFormData.append(data, withName: key)
                        }
                    }
                }
            }
        }, to: encodedUrl, method: method, headers: header).responseJSON { (response) in
            if let url = response.request?.url?.absoluteString {
                print("\n=======request: url: \(String(describing: url))")
                print(String(describing: param))
            }
//            print("\n======= response ======= \n\(response)")
            appDelegate.stopIndicator()
            
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                success?(json)
                break
            case .failure(let error):
                failure?(error)
                break
            }
        }
    }
}