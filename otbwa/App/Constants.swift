//
//  Constants.swift
//  otbwa
//
//  Created by 김학철 on 2021/07/30.
//

import Foundation
import UIKit

let baseUrl = "http://211.233.15.31:8080"
let rootPath = "api"

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

struct DfsKey {
    
}
enum Storyboard: String {
    case login = "Login"
    case main = "Main"
}
enum JoinType: String {
    case wholesale = "wholesale"
    case retail = "retail"
}
enum UserType: String {
    case ceo = "ceo"
    case staff = "staffer"
}

