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
    //FIXME: 소매 API
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
    /// - Parameters: "kind": "retail", "product_no": 23, "user_no": 2
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
    
    ///거래처 공지사항 목록 조회
    /// - Parameters: "comp_no": 34, "p_current": 3
    func requestNoticeList(_ param:[String:Any], success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/v1/comp/notices", param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    ///공지사항 상세
    ///- Parameters: notice_no
    func requestCompNoticeDetail(_ noticeNo:Int, success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.get, "/api/v1/comp/notice/\(noticeNo)") { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    ///공지사항 등록
    ///- Parameters:   "cntnt": "공지사항입니다/", "comp_no": 2, "title": "title", "user_no": 2
    func requestRegiestCompNotice(_ param:[String:Any], success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/v1/comp/notice", param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    
    ///공지사항 수정
    ///- Parameters:   "cntnt": "공지사항입니다/", "comp_no": 2, "notice_no": 41, "title": "title", "user_no": 2
    func requestModifyCompNotice(_ param:[String:Any], success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.put, "/api/v1/comp/notice", param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    ///공지사항 삭제
    ///- Parameters:   "comp_no": 2, "notice_no": 2
    func requestDeleteCompNotice(_ param:[String:Any], success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.delete, "/api/v1/comp/notice", param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    
    ///거래처 신청
    ///- Parameters:  "client_comp_no": 2, "comp_no": 2
    func requestClientApply(_ param:[String:Any], success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/v1/comp/client_apply", param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    ///거래처 관리
    ///- Parameters:  "client_no": 3, "comp_no": 4, "fn_value": "approved", "kind": "retail", "search": "허브", "type": "client"
    func requestManagerClient(_ param:[String:Any], success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.put, "/api/v1/comp/client_Management", param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    ///거래처 검색
    ///- Parameters:    "comp_no": 3, "kind": "retail", "p_current": 3, "search": "허브", "type": "client"
    func requestSearchClients(_ param:[String:Any], success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/v1/comp/clients", param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    /// 도매장 대표 이미지 등록
    ///- Parameters:    "comp_img": file, "comp_no": 21, "user_no": 3
    func rquestRegistCompImg(_ param:[String:Any], success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.requestFileUpload(.post, "/api/v1/comp/comp_img", param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    
    ///도매매장 정보페이지
    func requestCompanyInfo(_ param:[String:Any], success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/v1/comp/comp_info", param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    ///인기 검색어
    func requestPopularSearchWord(success: ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.get, "/api/v1/etc/top_searched") { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    ///상품 검색
    ///- Parameters:   "p_current": 1, "search": "인기", "user_no": 44
    func requestProductSearch(_ param:[String:Any], success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/v1/product/search", param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    ///내 최근 검색어 조회
    func requestMySearchHistoryList(userNo: Int, success: ResSuccess?, fail: ResFailure?) {
        NetworkManager.ins.request(.get, "/api/v1/user/recent_searched/\(userNo)") { res in
            success?(res)
        }  failure: { error in
            fail?(error)
        }
    }
    /// 최근 검색어 삭제
    ///- Parameters: "search": "셔츠", "user_no": 2
    func requestDeleteMyRecentSeached(_ param:[String:Any], success: ResSuccess?, fail: ResFailure?) {
        NetworkManager.ins.request(.delete, "/api/v1/user/recent_searched", param) { res in
            success?(res)
        }  failure: { error in
            fail?(error)
        }
    }
    ///AI 이미지 속성 태그
    func requestSearchAiImageTag(_ param:[String:Any], success:ResSuccess?, fail: ResFailure?) {
        NetworkManager.ins.requestFileUpload(.post, "/api/v1/product/product_img", param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    ///주문한 상폼 목록 조회
    ///- Parameters: building: 건물번호, month: 3d:3일, 1w:1주일, 1m:1개월, 3m:3개월, 6m:6개월, name: 검색 매장명, p_current: 1, user_no: 1
    func requestOrderProductList(_ param:[String:Any], success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/v1/user/order", param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    ///주문 상세 내역 조회
    ///- Parameters: order_no: 건물번호, user_no:2
    func requestOrderDetailInfo(_ param:[String:Any], success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/v1/user/order_detail", param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    ///거래처 검색
    ///- Parameters: "comp_no": 3, "kind": "retail", "p_current": 3, "search": "허브", "type": "client"
    func requestSearchCompClients(_ param:[String:Any], success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/v1/comp/clients", param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    ///거래처관리 요청 취소, 삭제
    ///- Parameters: "client_no": 3, "comp_no": 4, "fn_value": "approved", "kind": "retail", "search": "허브", "type": "client"
    ///- fn_value : 'approved’ : 승인, 'reject’ : 거절, 'cancel’ : 요청취소, 'stop’ : 거래중지/거래처삭제
    func requestClientMangement(_ param:[String:Any], success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.put, "/api/v1/comp/client_Management", param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    ///직원 리스트 조회
    ///- Parameters: "comp_no": 34, "p_current": 3
    func requestEmployeeList(_ param:[String:Any], success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/v1/comp/employee", param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    ///직원 승인여부 처리
    ///- Parameters: "comp_no": 4, "fn_value": "approved", "user_no": 2
    ///- "fn_value": "approved" 승인, "reject" 취소
    func requestEmployeeManagement(_ param:[String:Any], success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.put, "/api/v1/comp/employee/management", param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
        
    /// 이용약관 조회
    func requestTermText(success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.get, "/api/v1/etc/term_use_txt") { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    ///관리자 공지 리스트
    ///- Parameters: "kind": "wsale", "p_current": 1
    func requestAdminNoticeList(_ param:[String:Any], success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/v1/etc/manager_notice", param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    ///관리자 공지 리스트
    ///- Parameters: "kind": "wsale", "p_current": 1
    func requestAdminNoticeDetail(noticeNo:Int, success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.get, "/api/v1/etc/manager_notice_info/\(noticeNo)") { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    /// 기본정보 수정
    ///- Parameters: "id": "user0022", "new_pw": "qlalf11!!", "phone": "010-4613-4455", "pw": "votmdnjsme11", "user_no": 2
    func requestModifyMyInfo(_ param:[String:Any], success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.put, "/api/v1/user/user_info", param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    /// 사업자정보 수정
    func requestModifyStoreInfo(_ param:[String:Any], success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.requestFileUpload(.put, "/api/v1/user/comp_info", param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    
    //FIXME: 도매 API
    ///도매매장 상품 검색 리스트
    func requestCompProductSearch(_ param:[String:Any], success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/v1/comp/products", param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    /// 주문 상세정보 조회
    /// - Parameters: "comp_no": 3, "order_no": 200928162513760
    func requestCompOrderDetailInfo(_ param:[String:Any], success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/v1/comp/order_detail", param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    /// 주문관리 목록 조회
    /// - Parameters: "comp_no": 34, "p_current": 3, "search": "허브"
    func requestCompOrderList(_ param:[String:Any], success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/v1/comp/order", param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    ///도매 상품 상태관리
    ///- Parameters: "comp_no": 34, "disp": "client", "order_type": "latest", "product_no": 23, "search": "린넨",
    ///- "status": "soldout", restock
    func requestChangeProductStatus(_ param: [String:Any], success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.put, "/api/v1/product/product_status", param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    ///도매 상품 품절처리 (상품상세보기에서 처리. 리턴리스트 없음)
    ///- Prameters:  "comp_no": 29, "product_no": 1258
    func requestProductSoldout(_ param:[String:Any], success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.put, "/api/v1/product/soldout", param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    /// 상품 수정페이지 조회
    func requestProductInfo(productNo:String, success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.get, "/api/v1/product/product_info/\(productNo)") { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    ///상품 수정
    func requestModifyProductInfo(_ param:[String:Any], succes:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.requestFileUpload(.put, "/api/v1/product", param) { res in
            succes?(res)
        } failure: { error in
            fail?(error)
        }
    }
    ///상품 등록
    func requestRegistProductInfo(_ param:[String:Any], succes:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.requestFileUpload(.post, "/api/v1/product", param) { res in
            succes?(res)
        } failure: { error in
            fail?(error)
        }
    }
    ///상품 삭제
    func requestDeleteProductInfo(_ param:[String:Any], succes:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.delete, "/api/v1/product", param) { res in
            succes?(res)
        } failure: { error in
            fail?(error)
        }
    }
    /// 회원 알림/방해금지모드 설정값 세팅
    /// - Parameters : "disturb_end": "10:00", "disturb_start": "23:00", "disturb_yn": "N", "notification_yn": "Y", "user_no": 2
    func requestNotificationStting(_ param:[String:Any], success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/v1/user/notification_disturb", param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    ///계좌정보 수정
    /// - Parameters: "account": "121345-01-45613", "bank": "국민은행", "comp_no": 4, "holder": "김밀리", "user_no": 2
    func requestModifyBankAccount(_ param:[String:Any], success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.put, "/api/v1/user/account", param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    ///주문하기
    func requestProductsOrder(_ param:[String:Any], success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.post, "/api/v1/product/order", param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
    /// 토큰 갱신
    func requestUpdateFcmToken(_ param:[String:Any], success:ResSuccess?, fail:ResFailure?) {
        NetworkManager.ins.request(.put, "/api/v1/notification/token", param) { res in
            success?(res)
        } failure: { error in
            fail?(error)
        }
    }
}

