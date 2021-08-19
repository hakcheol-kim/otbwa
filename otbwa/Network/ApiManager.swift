//
//  ApiManager.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/02.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class ApiManager: NSObject {
    static let ins = ApiManager()
    
     ///상가 호수 카테고리 조회
     ///- Parameters : "category_no": 3, "p_current": 3
    func requestBuildingUnit(_ param:[String:Any] , success:ResSuccess?, fail: ResFailure?) {
        NetworkManager.ins.request(.post, "/api/v1/sign/category/building/unit", param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    ///아이디 증복체크
    func requestDuplicateCheckId(_ id: String, success: ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.get, "/api/v1/sign/dupCheck/id/\(id)") { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    /// chkProduct State
    func requestCheckProductState(success:ResSuccess?, fail: ResFailure?) {
        NetworkManager.ins.request(.get, "/api/v1/sign/chkproduct") { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    
    ///필터 리스트 조회
    func requestFilterList(hasCache:Bool = true, success:ResSuccess?, fail: ResFailure?) {
        if hasCache == true, let cachData = UserDefaults.standard.object(forKey: Dfskey.filterCacheData) {
            success?(JSON(cachData))
            return
        }
        NetworkManager.ins.request(.get, "/api/v1/sign/filter") { res in
            UserDefaults.standard.setValue(res.dictionaryObject, forKey: Dfskey.filterCacheData)
            UserDefaults.standard.synchronize()
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    ///핸드폰 인증번호 발송
    /// - Parameters: phone, type: signup:회원가입, find_id:아이디찾기
    func requestSendSmsAuthCode(_ param: [String:Any], success: ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/v1/sign/common/auth_num_send", param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    ///회원가입 - 인증번호 확인
    ///- Parameters : auth_num: 4642135, phone:01011112222
    func requestCheckAuthCode(_ param: [String:Any], success: ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/v1/sign/signup/auth_num_check", param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    ///아이디 찾기 - 인증번호 확인
    ///- Parameters : auth_num: 4642135, phone:01011112222
    func requestCheckAuthCodeFindId(_ param: [String:Any], success: ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/v1/sign/findId/auth_num_check", param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    ///패스워드 찾기 - 인증번호 발송
    /// - Parameters: id, phone
    func requestSendSmsAuthCodeFindPw(_ param: [String:Any], success: ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/v1/sign/findPw/auth_num_send", param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    ///아이디 찾기 - 인증번호 확인
    ///- Parameters : id, auth_num: 4642135, phone:01011112222
    func requestCheckAuthCodeFindPw(_ param: [String:Any], success: ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/v1/sign/findPw/auth_num_check", param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    
    ///도매회원 가입, 소매회원 가입
    func requestSignup(_ param: [String:Any], success: ResSuccess?, fail: ResFailure?) {
        let kind = param["kind"] as!String
        var url = "/api/v1/sign/signup/wsale"
        if kind == "retail" {
           url = "/api/v1/sign/signup/retail"
        }
        NetworkManager.ins.requestFileUpload(.post, url, param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    /// 로그인
    func requestSingin(_ param: [String:Any], success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/v1/sign/login", param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
        
    ///판매 스타일과 맞는 이미지 선택을 위한 이미지 조회
    func requestStyleImages(success: ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.get, "/api/v1/sign/prefer_img") { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    ///예비 상호명 중복체크
    func requestCheckStoreName(_ storeName: String, success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.get, "/api/v1/sign/dupCheck/comp_nm_scd/\(storeName)") { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    /// 매장검색(직원가입)
    func requestFindCompany(_ param: [String:Any], success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/v1/sign/find/comp_nm", param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    ///배너 리스트
    func requestEventBannerList(success: ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.get, "/api/v1/etc/banner") { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    /// 전체신상 상품목록 조회
    func requestAllProductList(param: [String:Any], success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/v1/product/all_products", param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    /// 거래처 신상품목록 조회
    func requestPartnerProductList(param:[String:Any], success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/v1/product/client_products", param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    
    
    ///User
    ///회원 마이페이지 정보 조회
    ///- Parameters: user_no
    func requestMyPageInfo(param:[String:Any], success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/v1/user/info/mypage", param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    ///내 정보 수정 페이지 조회
    func requestMyPageAndStoreInfo(userNo:Int, success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.get, "/api/v1/user/my_page/\(userNo)") { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    ///알림 정보 조회
    /// - Parameters:  "kind": "retail", "p_current": 3, "user_no": 34
    func requestNotificationInfo(param:[String:Any], success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/v1/user/inform", param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    ///찜 목록 조회
    ///- Parameters:   "user_no": 34
    func requestMyLikes(param:[String:Any], success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/v1/user/likes", param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    ///찜 목록 삭제
    ///- Parameters:   "user_no": 34, list:[11, 24]
    func requestDeleteMyLikes(param:[String:Any], success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.delete, "/api/v1/user/likes", param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    
    ///최근 본 상품
    ///- Parameters:   "user_no": 34
    func requestRecentProducts(param:[String:Any], success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/v1/user/recent_product", param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    ///최근 본 상품 삭제
    ///- Parameters:   "user_no": 34, list : [11, 24]
    func requestDeleteRecentProducts(param:[String:Any], success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.delete, "/api/v1/user/recent_product", param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    ///최근 검색어 조회
    func requestRecentSearchedList(userNo:Int, success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.get, "/api/v1/user/recent_searched/\(userNo)") { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    ///최근 검색어 조회
    ///- Parameters: "search": "셔츠", "user_no": 2
    func requestDeleteSearched(param:[String:Any], success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.delete, "/api/v1/user/recent_searched", param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    
    
    ///상품상세 보기
    func requestProductDetail(param: [String:Any], success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/v1/product/product_detail", param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    ///상품상세보기 - 어울리는상품, 비슷한상품 리스트
    func requestRecommendProducts(productNo:String,  success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.get, "/api/v1/product/product_detail/etc_list/\(productNo)") { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    
    //장바구니 담기
    func requestProductPutBasket(param:[String:Any],  success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/v1/product/put_basket", param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    //여러상품 장바구니 담기
    func requestProductPutBasketMany(param:[String:Any],  success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/v1/product/put_baskets", param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    ///상품 찜 목록에 추가
    ///- Parameters: "product_no": 23, "user_no": 2
    func requestProductLike(param:[String:Any], success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/v1/product/like", param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    ///장바구니 목록 조회
    ///- Parameters : "p_current": 3, "user_no": 34
    func requestBasketList(param:[String:Any], success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/v1/product/basket_list", param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    ///장바구니 목록 삭제
    ///- Parameters : "product_no": [3..], "user_no": 34
    func requestDeleteBasketList(param:[String:Any], success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.delete, "/api/v1/product/basket", param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    ///장바구니 목록 수정
    func requestModifyBasket(param:[String:Any], success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.put, "/api/v1/product/basket", param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    
}
