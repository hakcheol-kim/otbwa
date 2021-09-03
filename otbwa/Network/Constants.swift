//
//  Constants.swift
//  otbwa
//
//  Created by 김학철 on 2021/07/30.
//

import Foundation
import UIKit

let baseUrl = "https://www.otbwa.com:5021"
let urlAddrSearch = "https://www.otbwa.com/address.html"

public func RGB(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> UIColor {
    UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: 1.0)
}
public func RGBA(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat) -> UIColor {
    UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a / 1.0)
}


let TagCallingView = 1000001
let IsShowTutorial = "IsShowTutorial"
let kPushSetting = "PushSetting"
let PUSH_DATA = "PUSH_DATA"
let AUTH_TIMEOUT_MIN: Double = 3

struct Dfskey {
    static let userId = "userId"
    static let userPw = "userPw"
    static let uniqueId = "uniqueId"
    static let uuid = "uuid"
    static let autoLogin = "autoLogin"
    static let filterCacheData = "filterCacheData"
    static let notification_yn = "notification_yn"
    static let disturb_yn = "disturb_yn"
    static let disturb_st = "disturb_st"
    static let disturb_end = "disturb_end"
}
struct FitlerKey {
    static let ftAddr = "ft_addr"
    static let ftCategory = "ft_category"
    static let ftColor = "ft_color"
    static let ftCountry = "ft_country"
    static let ftStyle = "ft_style"
    static let maxPrice = "max_price"
    static let minPrice = "min_price"
}
enum FitlerViewType: String {
    case hastagOne = "hastagOne"
    case hastagThree = "hastagThree"
    case hastagAll = "hastagAll"
}

enum Storyboard: String {
    case login = "Login"
    case main = "Main"
    case common = "Common"
    case wsale = "WSale"
}
enum ListType: Int {
    case normal, editing
}
enum EcomerceKind: String {
    case wsale = "wsale"
    case retail = "retail"
}
enum UserType: String {
    case ceo = "ceo"
    case employee = "employee"
}
enum TableViewType: Int {
    case normal, edit
}
