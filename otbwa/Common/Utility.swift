//
//  Utility.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/02.
//

import UIKit
import Photos

class Utility: NSObject {
    class func isEdgePhone() -> Bool {
        return ((appDelegate.window?.safeAreaInsets.bottom)! > 0.0)
    }
    class func thumbnailUrl(_ userId: String?, _ fileName: String?) ->String? {
        guard let userId = userId, let fileName = fileName, userId.isEmpty == false, fileName.isEmpty == false  else {
            return nil
        }
        var url = "\(baseUrl)/upload/talk/\(userId)/thum/thum_\(fileName)"
        url = url.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if url.isEmpty == false {
//            print("url: \(url)")
        }
        return url
    }
    class func originImgUrl(_ userId: String?, _ fileName: String?) ->String? {
        guard let userId = userId, let fileName = fileName, userId.isEmpty == false, fileName.isEmpty == false  else {
            return nil
        }
        var url = "\(baseUrl)/upload/talk/\(userId)/\(fileName)"
        url = url.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        return url
    }
    class func getCurrentDate(format:String) -> String {
        let df = CDateFormatter.init()
        df.dateFormat = format
        let dateStr = df.string(from: Date())
        return dateStr
    }
    
    class func getThumnailImage(with asset:PHAsset, _ completion:@escaping(_ image:UIImage?) -> Void) {
        var imageRequestOptions: PHImageRequestOptions {
               let options = PHImageRequestOptions()
               options.version = .current
               options.resizeMode = .exact
               options.deliveryMode = .highQualityFormat
               options.isNetworkAccessAllowed = true
               options.isSynchronous = true
               return options
           }
        
        PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 400, height: 400), contentMode:.aspectFit, options: imageRequestOptions) { (image, _)  in
            guard let image = image else {
                completion(nil)
                return
            }
            return completion(image)
        }
    }
    class func downloadImage(_ url:String, _ userInfo:[String:Any]? = nil, _ completion:@escaping(_ image:UIImage?, _ userInfo:[String:Any]?)->Void) {
        guard let uurl =  URL(string: url) else {
            completion(nil, userInfo)
            return
        }
        
        let request = URLRequest(url:uurl)
        imgDownloader.download(request, completion:  { response in
            if case .success(let image) = response.result {
                completion(image, userInfo)
            }
            else {
                completion(nil, userInfo)
            }
        })
    }
    class func randomSms5digit() -> String {
        let number = Int.random(in: 10000..<100000)
        return String(format: "%0ld", number)
    }
    class func roomKeyCam() -> String {
        let date = Utility.getCurrentDate(format: "yyyyMMddHHmmss")
        let random = Int.random(in: 0..<50)
        return "CAM_\(date)_\(random)"
    }
    class func roomKeyPhone() -> String {
        let date = Utility.getCurrentDate(format: "yyyyMMddHHmmss")
        let random = Int.random(in: 0..<50)
        return "PHONE_\(date)_\(random)"
    }
    class func hexStringToUIColor(_ hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
