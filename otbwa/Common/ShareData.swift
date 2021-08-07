//
//  ShareData.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/01.
//

import Foundation

class ShareData: NSObject {
    static let ins = ShareData()
    private var data:[String:Any] = [String:Any]()
    
    func setObject(_ value: Any?, forKey key: String?) {
        guard let value = value, let key = key else {
            return
        }
        data[key] = value
    }
    func objectForKey(_ key: String?) -> Any? {
        guard let key = key else {
            return nil
        }
        return data[key]
    }
    func removeObject(forKey key: String?) {
        guard let key = key else {
            return
        }
        data.removeValue(forKey: key)
    }
    
}
