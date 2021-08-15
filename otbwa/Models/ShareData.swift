//
//  ShareData.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/01.
//

import Foundation
import SwiftyJSON

class ShareData: NSObject {
    static let ins = ShareData()

    private var data:[String:Any] = [String:Any]()
    var userNo: Int = -1
    var userId: String = ""
    var userPw: String = ""
    var token: String = ""
    var kind: EcomerceKind = .retail
    var type: UserType = .employee
    var compNo: String = ""
    var compNm: String = ""
    
    var selectedFilterList:[JSON] = [JSON]()

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
    
    func setUserInfo(_ data:JSON) {
        ShareData.ins.userNo = data["user_no"].intValue
        let kind = data["kind"].stringValue
        if kind == "wsale" {
            ShareData.ins.kind = .wsale
        } else {
            ShareData.ins.kind = .retail
        }
        
        let type = data["type"].stringValue
        if type == "ceo" {
            ShareData.ins.type = .ceo
        } else {
            ShareData.ins.type = .employee
        }
        self.token = data["token"].stringValue
        self.compNo = data["comp_no"].stringValue
        self.compNm = data["comp_nm"].stringValue
        
    }
}
