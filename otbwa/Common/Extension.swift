//
//  Extension.swift
//  PetChart
//
//  Created by 김학철 on 2020/09/26.
//

import Foundation
import UIKit
import AlamofireImage
import CoreGraphics
import SwiftyJSON
import Toast_Swift

let TAG_LOADING_IMG = 1234321
let imgDownloader = ImageDownloader()

//FIXME:: UITableView
extension UITableView {
    func reloadData(completion:@escaping ()-> Void) {
        UIView.animate(withDuration: 0) {
            self.reloadData()
        } completion: { (finish) in
            completion()
        }
    }
}

extension UICollectionView {
    func reloadData(completion:@escaping ()-> Void) {
        UIView.animate(withDuration: 0) {
            self.reloadData()
        } completion: { (finish) in
            completion()
        }
    }
    func reloadData(_ delay: Double = 0.1, _ completion:@escaping() ->Void) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay) {
            completion()
        }
    }
}
//FIXME:: UIViewController
extension UIViewController {
    func setUserInterfaceStyle(_ interfaceStyle: UIUserInterfaceStyle) {
        if #available(iOS 13.0, *) {
            self.setValue(overrideUserInterfaceStyle, forKey:"overrideUserInterfaceStyle")
        }
    }
    class func instantiateFromStoryboard(_ name:Storyboard) -> Self? {
        let storyboard = UIStoryboard(name: name.rawValue, bundle: nil)
        let arrName = NSStringFromClass(self).components(separatedBy: ".")
        return storyboard.instantiateViewController(identifier: arrName.last!)
    }
    
    func showErrorToast(_ data: Any?) {
        if let data = data as? JSON {

            var msg:String = ""
            let message = data["msg"].stringValue;
            if message.isEmpty == false {
                msg.append("\(message)")
            }
            print("==== error: \(data)")
            if msg.isEmpty == true {
                return
            }
            
//            var findView:UIView = self.view
//            for subview in self.view.subviews {
//                if let subview = subview as? UIScrollView {
//                    findView = subview
//                    break
//                }
//            }
            if UIApplication.shared.isKeyboardPresented {
                self.view.makeToast(msg, position:.center)
            }
            else {
                self.view.makeToast(msg)
            }
        }
        else if let error = data as? Error, let msg = error.localizedDescription as String? {
//            var findView:UIView = self.view
//            for subview in self.view.subviews {
//                if let subview = subview as? UIScrollView {
//                    findView = subview
//                    break
//                }
//            }
//            findView.makeToast(msg)
            if UIApplication.shared.isKeyboardPresented {
                self.view.makeToast(msg, position:.center)
            }
            else {
                self.view.makeToast(msg)
            }
        }
    }
    
    func myAddChildViewController(superView:UIView, childViewController:UIViewController) {
        addChild(childViewController)
        childViewController.beginAppearanceTransition(true, animated: true)
        superView.addSubview(childViewController.view)
        childViewController.view.translatesAutoresizingMaskIntoConstraints = false
        childViewController.view.leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: 0).isActive = true
        childViewController.view.topAnchor.constraint(equalTo: superView.topAnchor, constant: 0).isActive = true
        childViewController.view.bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: 0).isActive = true
        childViewController.view.trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant: 0).isActive = true
        childViewController.endAppearanceTransition()
        childViewController.didMove(toParent: self)
    }
    
    func myRemoveChildViewController(childViewController:UIViewController) {
        childViewController.beginAppearanceTransition(false, animated: true)
        childViewController.view.removeFromSuperview()
        childViewController.endAppearanceTransition()
    }
    func transitionPresent(vc: UIViewController, duration: CFTimeInterval, type: CATransitionSubtype) {
        let customVcTransition = vc
        let transition = CATransition()
        transition.duration = duration
        transition.type = CATransitionType.moveIn
        transition.subtype = type
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        present(customVcTransition, animated: false, completion: nil)
    }
    func transitionDismiss(duration: CFTimeInterval, type:CATransitionSubtype, _ completion:(() -> Void)? = nil) {
        let transition = CATransition()
        transition.duration = duration
        transition.type = CATransitionType.reveal
        transition.subtype = type
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        dismiss(animated: false, completion: completion)
    }
    func transitionPush(vc: UIViewController, duration: CFTimeInterval, type: CATransitionSubtype) {
        guard let naviVc = self.navigationController else {
            return
        }
        let transition = CATransition()
        transition.duration = duration
        transition.type = CATransitionType.moveIn
        transition.subtype = type
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        naviVc.view.layer.add(transition, forKey: kCATransition)
        naviVc.pushViewController(vc, animated: false)
    }
    func transitionPop(duration: CFTimeInterval, type:CATransitionSubtype) {
        guard let naviVc = self.navigationController else {
            return
        }
        
        let transition = CATransition()
        transition.duration = duration
        transition.type = CATransitionType.moveIn
        transition.subtype = type
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        naviVc.view.layer.add(transition, forKey: kCATransition)
        naviVc.popViewController(animated: false)
    }
}
//FIXME:: UIView
extension UIView {
    func addConstraintsSuperView(_ inset:UIEdgeInsets = .zero) {
        guard let superview = self.superview else {
            return
        }
        self.translatesAutoresizingMaskIntoConstraints = false
        self.topAnchor.constraint(equalTo: superview.topAnchor, constant: inset.top).isActive = true
        self.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: inset.left).isActive = true
        self.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -inset.right).isActive = true
        self.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -inset.bottom).isActive = true
        
    }
    func addShadow(offset:CGSize, color:UIColor, raduius: Float, opacity:Float) {
        self.layer.masksToBounds = false
        self.layer.shadowOffset = offset
        self.layer.shadowColor = color.cgColor
        self.layer.shadowRadius = CGFloat(raduius)
        self.layer.shadowOpacity = opacity
        
        let bgColor = self.backgroundColor
        self.backgroundColor = nil
        self.layer.backgroundColor = bgColor?.cgColor
    }
    func addGradient(_ startColor: UIColor?, end endColor: UIColor?, sPoint: CGPoint, ePoint: CGPoint) {
        let subLayer = CAGradientLayer()
        subLayer.frame = bounds
        subLayer.colors = [startColor?.cgColor, endColor?.cgColor].compactMap { $0 }
        subLayer.locations = [NSNumber(value: Int32(0.0)), NSNumber(value: 1)]
        subLayer.startPoint = sPoint
        subLayer.endPoint = ePoint
        layer.insertSublayer(subLayer, at: 0)
    }
    func startAnimation(raduis: CGFloat) {
        let imageName = "ic_loading"

        let indicator = viewWithTag(TAG_LOADING_IMG) as? UIImageView
        if indicator != nil {
            indicator?.removeFromSuperview()
        }

        isHidden = false
        superview?.bringSubviewToFront(self)

        let ivIndicator = UIImageView(frame: CGRect(x: 0, y: 0, width: 2 * raduis, height: 2 * raduis))
        ivIndicator.tag = TAG_LOADING_IMG
        ivIndicator.contentMode = .scaleAspectFit
        ivIndicator.image = UIImage(named: imageName)
        addSubview(ivIndicator)
//        indicator?.layer.borderWidth = 1.0
//        indicator?.layer.borderColor = UIColor.red.cgColor
        ivIndicator.frame = CGRect(x: (frame.size.width - ivIndicator.frame.size.width) / 2, y: (frame.size.height - ivIndicator.frame.size.height) / 2, width: ivIndicator.frame.size.width, height: ivIndicator.frame.size.height)

        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.fromValue = NSNumber(value: 0.0)
        rotation.toValue = NSNumber(value: -2.0 * Double(CGFloat.pi))
        rotation.duration = 1
        rotation.repeatCount = .infinity

        ivIndicator.layer.add(rotation, forKey: "loading")
    }
    func stopAnimation() {
        isHidden = true
        let indicator = viewWithTag(TAG_LOADING_IMG) as? UIImageView
        if indicator != nil {
            indicator?.layer.removeAnimation(forKey: "loading")
            //        [indicator removeFromSuperview];
        }
    }
    
    var snapshot: UIImage {
       return UIGraphicsImageRenderer(size: bounds.size).image { _ in
            drawHierarchy(in: bounds, afterScreenUpdates: true)
        }
    }
    
    func removeConstraints() {
        let constraints = self.superview?.constraints.filter {
            $0.firstItem as? UIView == self || $0.secondItem as? UIView == self
        } ?? []
        
        self.superview?.removeConstraints(constraints)
        self.removeConstraints(self.constraints)
    }
}

//FIXME:: UIImageView
extension UIImageView {
    func setImageCache(_ url:String, _ placeholderImgName:String? = nil) {
        var placeholderImg: UIImage? = nil
        if let placeholderImgName = placeholderImgName {
            placeholderImg = UIImage(named: placeholderImgName)
        }
        
        guard let requestUrl = URL.init(string: url)  else {
            return
        }
        self.af.setImage(withURL: requestUrl, placeholderImage: placeholderImg)
    }
    
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
            contentMode = mode
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard
                    let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
//                    let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                    let data = data, error == nil,
                    let image = UIImage(data: data)
                    else { return }
                DispatchQueue.main.async() { [weak self] in
                    self?.image = image
                }
            }.resume()
        }
        func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
            guard let url = URL(string: link) else { return }
            downloaded(from: url, contentMode: mode)
        }
}
extension UIButton {
    func setImageCache(_ url:String, _ placeholderImgName:String? = nil) {
        guard let reqUrl = URL(string: url) else {
            return
        }
        self.accessibilityIdentifier = reqUrl.absoluteString
        let request = URLRequest(url: reqUrl)
        
        imgDownloader.download(request, completion:  { response in
            if case .success(let image) = response.result {
                self.setImage(image, for: .normal)
            }
            else {
                guard let defaultImgName = placeholderImgName, let img = UIImage(named: defaultImgName) else {
                    return
                }
                self.setImage(img, for: .normal)
            }
        })
        
    }
    
}
//FIXME:: CACornerMask
extension CACornerMask {
    init(TL: Bool = false, TR: Bool = false, BL: Bool = false, BR: Bool = false) {
        var value: UInt = 0
        if TL { value += 1 }
        if TR { value += 2 }
        if BL { value += 4 }
        if BR { value += 8 }

        self.init(rawValue: value)
    }
}
extension UIColor {
    convenience init(hex: UInt) {
        self.init(red: CGFloat((hex & 0xFF0000) >> 16) / 255.0, green: CGFloat((hex & 0x00FF00) >> 8) / 255.0, blue: CGFloat(hex & 0x0000FF) / 255.0, alpha: CGFloat(1.0))
    }
}
//FIXME:: UIImage
extension UIImage {
    class func color(from color: UIColor?) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        if let cg = color?.cgColor {
            context?.setFillColor(cg)
        }
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    func resized(withPercentage percentage: CGFloat, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: size.width * percentage, height: size.height * percentage)
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
    
    func resized(toWidth width: CGFloat, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
    func getCropRatio() -> CGFloat {
        return CGFloat(self.size.height/self.size.width)
    }
}
//FIXME:: Error
public extension Error {
    var localizedDescription: String {
        return NSError(domain: _domain, code: _code, userInfo: nil).localizedDescription
    }
}

//FIXME:: String
extension String {
    func isEqualToString(find: String) -> Bool {
        return String(format: self) == find
    }
    func deletingPrefix(_ prefix: String) -> String {
           guard self.hasPrefix(prefix) else { return self }
           return String(self.dropFirst(prefix.count))
    }
    // String Trim
    public var stringTrim: String{
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    // Return String chracters count
    public var length: Int {
        return self.count
    }
    
    // String localized
    public var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    // String localized with comment
    public func localizedWithComment(comment: String) -> String {
        return NSLocalizedString(self, comment:comment)
    }
    
    // E-mail address validation
    public func validateEmail() -> Bool {
        let emailRegEx = "^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$"
        let predicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return predicate.evaluate(with: self)
    }
//    public func validateKorPhoneNumber() -> Bool {
//        let reg = "^[0-9]{3}[-]+[0-9]{4}[-]+[0-9]{4}$"
////        let reg = "^[0-9]{3}+[0-9]{4}+[0-9]{4}$"
//        let predicate = NSPredicate(format:"SELF MATCHES %@", reg)
//        return predicate.evaluate(with: self)
//    }
    public func validateKorPhoneNumber() -> Bool {
        let regx = "^[0-9]{3}+[0-9]{4}+[0-9]{4}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regx)
        return predicate.evaluate(with: self)
    }
    // Password validation
    public func validatePassword() -> Bool {
//        let passwordRegEx = "(?=.*[a-zA-Z])(?=.*[!@#$%^_*-])(?=.*[0-9]).{8,40}"
            //"^(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{8,16}$"
        let passwordRegEx = "(?=.*[a-zA-Z0-9~!@#$%^&*()_+|<>?:{}]).{8,40}"
        let predicate = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        return predicate.evaluate(with: self)
    }
    public func checkEnglish() ->Bool {
        let reg = "^[a-zA-Z]"
        return NSPredicate(format: "SELF MATCHES %@", reg).evaluate(with: self)
    }
    public func checkNum() ->Bool {
        let reg = "^[0-9]"
        return NSPredicate(format: "SELF MATCHES %@", reg).evaluate(with: self)
    }
    public func checkSpecialPw() ->Bool {
        let reg = "^[~!@#$%^&*()_+ |.<>?:{}]"
        return NSPredicate(format: "SELF MATCHES %@", reg).evaluate(with: self)
    }
    
    // String split return array
    public func arrayBySplit(splitter: String? = nil) -> [String] {
        if let s = splitter {
            return self.components(separatedBy: s)
        } else {
            return self.components(separatedBy: NSCharacterSet.whitespacesAndNewlines)
        }
    }
    
    func getNumberString() ->String? {
        let strArr = self.components(separatedBy: CharacterSet.decimalDigits.inverted)
        var result = ""
        for item in strArr {
            result.append(item)
        }
        return result
    }
    func addComma() ->String {
        let nf = NumberFormatter.init()
        nf.minimumFractionDigits = 0
        nf.maximumFractionDigits = 1
        nf.roundingMode = .halfEven
        nf.numberStyle = .decimal
        
        nf.locale = Locale(identifier: "en_US")
        let number = NSNumber.init(value: Double(self)!)
        let result = nf.string(from: number)
        return result ?? ""
    }
    func delComma() ->String {
        var result = self
        result = self.replacingOccurrences(of: " ", with: "")
        result = self.replacingOccurrences(of: ",", with: "")
        result = self.replacingOccurrences(of: ".", with: "")
        return result
    }
    func split(by length: Int) -> [String] {
        var startIndex = self.startIndex
        var results = [Substring]()
        while startIndex < self.endIndex {
            let endIndex = self.index(startIndex, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
            results.append(self[startIndex..<endIndex])
            startIndex = endIndex
        }
        return results.map { String($0) }
    }
    
    func reverseOf(splitLength length: Int = 0) -> String {
        if length == 0 {
            return String(self.reversed())
        }
        else {
            var result = ""
            let array = self.split(by: length)
            for str in array {
                let reStr = String(str.reversed())
                result.append(reStr)
            }
            return result
        }
    }
    func maskOfSuffixLenght(_ length:Int) -> String? {
        return String(repeating: "✱", count: Swift.max(0, count-length)) + suffix(length)
    }
    func parsingJsonObject() -> [String:Any]? {
        guard let data = self.data(using: .utf8) else {
            return nil
        }
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            return json as? [String:Any]
        } catch  {
            return nil
        }
    }
    func toClipboard() {
        let pasteboard = UIPasteboard.general
        pasteboard.string = self
    }
}

extension NSAttributedString {
    convenience init(htmlString html: String) throws {
        try self.init(data: Data(html.utf8), options: [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ], documentAttributes: nil)
    }
}

extension Data {
    var hexString: String {
        let hexString = map { String(format: "%02.2hhx", $0) }.joined()
        return hexString
    }
}

extension Bundle {
    /// 앱 이름
    var appName: String {
        if let value = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String {
            return value
        }
        return ""
    }
    /// 앱 버전 class
    var appVersion: String {
        if let value = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String { return value
        }
        return ""
    }
    ////// 앱 빌드 버전
    var appBuildVersion: String {
        if let value = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            return value
        }
        return ""
    }
    /// 앱 번들 ID
    var bundleIdentifier: String {
        if let value = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String {
            return value
        }
        return ""
    }
    
//    static func swizzleLocalization() {
//        let orginalSelector = #selector(localizedString(forKey:value:table:))
//        guard let orginalMethod = class_getInstanceMethod(self, orginalSelector) else { return }
//
//        let mySelector = #selector(myLocaLizedString(forKey:value:table:))
//        guard let myMethod = class_getInstanceMethod(self, mySelector) else { return }
//
//        if class_addMethod(self, orginalSelector, method_getImplementation(myMethod), method_getTypeEncoding(myMethod)) {
//            class_replaceMethod(self, mySelector, method_getImplementation(orginalMethod), method_getTypeEncoding(orginalMethod))
//        } else {
//            method_exchangeImplementations(orginalMethod, myMethod)
//        }
//    }
//
//    @objc private func myLocaLizedString(forKey key: String,value: String?, table: String?) -> String {
//        let curLanCode = appDelegate.currentLanguage
//        var tblCode = curLanCode
//        switch curLanCode {
//            case "ko":
//                tblCode = curLanCode
//                break
//            case "en":
//                tblCode = curLanCode
//                break
//            default:
//                tblCode = "Base"
//                break
//        }
//
//        guard let bundlePath = Bundle.main.path(forResource: tblCode, ofType: "lproj"),
//              let bundle = Bundle(path: bundlePath) else {
//            return Bundle.main.myLocaLizedString(forKey: key, value: value, table: table)
//        }
//        return bundle.myLocaLizedString(forKey: key, value: value, table: table)
//    }
//    static func localizeStirng(_ key: String) -> String {
//        return Bundle.main.localizedString(forKey: key, value: nil, table: "InfoPlist")
//    }
}

extension Locale {
    var languageCode: String {
        let localId = NSLocale.preferredLanguages[0] as String
        let info = NSLocale.components(fromLocaleIdentifier: localId)
        guard let language = info["kCFLocaleLanguageCodeKey"] else {
            return ""
        }
        return language
    }
    var countryCode: String {
        let localId = NSLocale.preferredLanguages[0] as String
        let info = NSLocale.components(fromLocaleIdentifier: localId)
        guard let language = info["kCFLocaleCountryCodeKey"] else {
            return ""
        }
        return language
    }
}
extension NSNumber {
    func toString(_ minDigit:Int = 0, _ maxDigit:Int = 2) -> String {
        let nf = NumberFormatter.init()
        nf.minimumFractionDigits = minDigit
        nf.maximumFractionDigits = maxDigit
        nf.roundingMode = .halfEven
        nf.numberStyle = .decimal
        nf.locale = Locale(identifier: "en_US")
        
        guard let result = nf.string(from: self) else {
            return ""
        }
        return result
    }
   
}
extension UIApplication {
    var isKeyboardPresented: Bool {
          if let keyboardWindowClass = NSClassFromString("UIRemoteKeyboardWindow"),
              self.windows.contains(where: { $0.isKind(of: keyboardWindowClass) }) {
              return true
          } else {
              return false
          }
      }
}

