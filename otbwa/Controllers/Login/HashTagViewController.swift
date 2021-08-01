//
//  HashTagViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/07/31.
//

import UIKit
import SwiftyJSON

class HashTagViewController: BaseViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var svContent: UIStackView!
    @IBOutlet weak var btnCose: UIButton!
    @IBOutlet weak var btnNext: CButton!
    @IBOutlet weak var safetyView: UIView!
    
    var completion:((_ items:[String]) ->Void)?
    let listData:[JSON] = [["sec_name": "여성의류",
                            "sec_list":[["group":"아우터", "group_list":["가다건", "점퍼", "코트", "자켓", "조끼"]],
                                        ["group":"상의", "group_list":["티셔츠", "맨투맨", "후드", "니트", "블라우스", "셔츠", "뷔스티에"]],
                                        ["group":"바지", "group_list":["긴바지", "7부바지", "반바지"]],
                                        ["group":"스커트", "group_list":["롱스커트", "미디스커트", "미니스커트"]],
                                        ["group":"원피스", "group_list":["드레스", "점프수트"]]]],
                           ["sec_name": "남성의류",
                            "sec_list":[["group":"아우터", "group_list":["가다건", "점퍼", "자켓", "조끼"]],
                                        ["group":"상의", "group_list":["티셔츠", "맨투맨", "후드", "니트", "셔츠"]]]],
                           ["sec_name": "여성 신발",
                            "sec_list":[["group":"구두", "group_list":["정장구두", "힐"]],
                                        ["group":"운동화", "group_list":["런닝화", "캐쥬얼"]],
                                        ["group":"슬리퍼", "group_list":["슬피퍼", "샌들"]]]],
                           ["sec_name": "남성 신발",
                            "sec_list":[["group":"구두", "group_list":["정장구두", "힐"]],
                                        ["group":"운동화", "group_list":["런닝화", "캐쥬얼"]],
                                        ["group":"슬리퍼", "group_list":["슬피퍼", "샌들"]]]]
    ]
    
    static func initWithCompletion(completion:((_ items:[String]) ->Void)?) ->HashTagViewController {
        let vc = HashTagViewController.instantiateFromStoryboard(.login)!
        vc.completion = completion
        return vc
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnNext.setBackgroundImage(UIImage.color(from: RGB(203, 203, 203)), for: .disabled)
        btnNext.setBackgroundImage(UIImage.color(from: UIColor(named: "AccentColor")!), for: .normal)
        
        btnNext.isEnabled = false
        self.decorationUi()
        safetyView.isHidden = !isEdgePhone
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    func decorationUi() {
        for item in  listData {
            let tagView = Bundle.main.loadNibNamed("HashTagSectionView", owner: nil, options: nil)?.first as! HashTagSectionView
            svContent.addArrangedSubview(tagView)
            tagView.configurationData(item) {
                if ShareData.ins.hashTags.count == 0 {
                    self.btnNext.isEnabled = false
                }
                else {
                    self.btnNext.isEnabled = true
                }
            }
            tagView.layer.cornerRadius = 6
            tagView.clipsToBounds = true
            tagView.layer.borderWidth = 1
            tagView.layer.borderColor = RGB(235, 235, 235).cgColor
        }
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        
    }
}
