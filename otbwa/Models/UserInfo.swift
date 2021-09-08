//
//  UserInfo.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/01.
//

import UIKit
import Foundation

class UserInfo: NSObject  {
    var comp_addr: String?  //소매 매장 주소
    var comp_nm: String?     //업체 상호명
    var comp_nm_scd: String?    //예비상호명
    var comp_num: String?   //업체 사업자번호 (* '-'를 포함한 값이어야 합니다.)
    var comp_reg_img: UIImage?   //사업자등록증 img
    var id: String?     //가입 아이디
    var img: UIImage?    //소매업체 매장이미지 (오프라인인 경우 필수)
    var infoUse: String?    //개인정보수집동의
    var kind: String?   //가입회원 도매/소매 구분 ('retail’:소매, 'wsale’:도매)
    var link: String?   //판매 링크 (온라인일 경우 필수)
    var name: String?   //가입회원 이름
    var onlineYN: String?   //소매업체 온라인/오프라인 구분 ('Y’:온라인, 'N’:오프라인)
    var phone: String?  //가입회원 핸드폰번호
    var pw: String?     //가입 패스워드
    var selected_img: String?   //(판매 스타일과 매치) 회원이 선택한 img_no List String
    var smsUse: String?     //sms수신동의
    var tel: String?    //매장 전화번호 (* '-'를 포함한 값이어야 합니다.)
    var termUse: String?    //이용약관동의
    var type: String?   //가입회원 대표/직원 구분 ('ceo’:대표, 'employee’:직원)
    var unique: String?     //디바이스 고유번호(토큰값)
    var uuid: String?   //UUID
    var building: String?  //도매업체 매장 건물 카테고리 id
    var hashtag: String? //해시태그
    
    override var description: String {
        return "comp_addr : \(String(describing: comp_addr))"+" comp_nm : \(String(describing: comp_nm))"+" comp_nm_scd : \(String(describing: comp_nm_scd))"+" comp_num : \(String(describing: comp_num))"+" comp_reg_img : \(String(describing: comp_reg_img))"+" id : \(String(describing: id))"+" img : \(String(describing: img))"+" infoUse : \(String(describing: infoUse))"+" kind : \(String(describing: kind))"+" link : \(String(describing: link))"+" name : \(String(describing: name))"+" onlineYN : \(String(describing: onlineYN))"+" phone : \(String(describing: phone))"+" pw : \(String(describing: pw))"+" selected_img : \(String(describing: selected_img))"+" smsUse : \(String(describing: smsUse))"+" tel : \(String(describing: tel))"+" termUse : \(String(describing: termUse))"+" type : \(String(describing: type))"+" unique : \(String(describing: unique))"+" uuid : \(String(describing: uuid))"+" building : \(String(describing: building))"+" hashtag : \(String(describing: hashtag))"
    }
    
    func map() -> [String : Any] {
        var dic:[String:Any] = [String:Any]()
        dic["comp_addr"] = self.comp_addr
        dic["comp_nm"] = self.comp_nm
        dic["comp_nm_scd"] = self.comp_nm_scd
        dic["comp_num"] = self.comp_num
        dic["comp_reg_img"] = self.comp_reg_img
        dic["id"] = self.id
        dic["img"] = self.img
        dic["infoUse"] = self.infoUse
        dic["kind"] = self.kind
        dic["link"] = self.link
        dic["name"] = self.name
        dic["onlineYN"] = self.onlineYN
        dic["phone"] = self.phone
        dic["pw"] = self.pw
        dic["selected_img"] = self.selected_img
        dic["smsUse"] = self.smsUse
        dic["tel"] = self.tel
        dic["termUse"] = self.termUse
        dic["type"] = self.type
        dic["unique"] = self.unique
        dic["uuid"] = self.uuid
        dic["building"] = self.building
        dic["hashtag"] = self.hashtag
        return dic
    }
}
