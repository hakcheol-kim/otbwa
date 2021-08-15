//
//  FilterReusableView.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/08.
//

import UIKit
import SwiftyJSON

class FilterReusableView: UICollectionReusableView {
    static let identifier = "FilterReusableView"
    @IBOutlet weak var bannerView: FSPagerView!
    @IBOutlet weak var btnFilter: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var svFilter: UIStackView!
    
    var banners:[JSON]?
    var completion:((_ item:JSON?, _ action: Int) ->Void)?
    var filters:JSON?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUi()
    }
    
    func setupUi() {
        self.bannerView.register(UINib(nibName: "BannerColCell", bundle: nil), forCellWithReuseIdentifier: "BannerColCell")
        self.bannerView.automaticSlidingInterval = 3.0
        self.bannerView.isInfinite = false
        self.bannerView.decelerationDistance = FSPagerView.automaticDistance

        let newScale = CGFloat(0.9)
        self.bannerView.itemSize = self.bannerView.frame.size.applying(CGAffineTransform(scaleX: newScale, y: newScale))
        self.bannerView.interitemSpacing = 10
        self.bannerView.delegate = self
        self.bannerView.dataSource = self
    }
    
    func reloadData() {
        if let _ = banners {
            bannerView.isHidden = false
            bannerView.reloadData()
        }
        
        for subView in svFilter.subviews {
            subView.removeFromSuperview()
        }
        
        let ft_category = self.filters?["ft_category"]
        let ft_style = self.filters?["ft_style"]
        let ft_color = self.filters?["ft_color"].arrayValue
        let ft_amount = self.filters?["ft_amount"]
        let ft_addr = self.filters?["ft_addr"]
        let ft_country = self.filters?["ft_country"]
        
        var index = 100
        for i in 0..<6 {
            let btn = UIButton.init(type: .custom)
            svFilter.addArrangedSubview(btn)
            
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            btn.heightAnchor.constraint(equalToConstant: 30).isActive = true
            btn.layer.cornerRadius = 15.0
            btn.clipsToBounds = true
            btn.tag = index
            index += 1
            btn.addTarget(self, action: #selector(onClickedBtnActions(_ :)), for: .touchUpInside)
            
            if i == 0 {
                if let ft_category = ft_category, ft_category.isEmpty == false {
                    let title = ft_category["name"].stringValue
                    self.decorationBtn(btn, title, true)
                }
                else {
                    self.decorationBtn(btn, "카테고리", false)
                }
            }
            else if i == 1 {
                if let ft_style = ft_style, ft_style.isEmpty == false {
                    let title = ft_style["value"].stringValue
                    self.decorationBtn(btn, title, true)
                }
                else {
                    self.decorationBtn(btn, "스타일", false)
                }
            }
            else if i == 2 {
                if let ft_color = ft_color, ft_color.isEmpty == false {
                    let item = ft_color.first!
                    var title = item["value"].stringValue
                    if ft_color.count > 1 {
                        title = item["value"].stringValue + "외 \(ft_color.count-1)건"
                    }
                    self.decorationBtn(btn, title, true)
                }
                else {
                    self.decorationBtn(btn, "색상", false)
                }
            }
            else if i == 3 {
                if let ft_amount = ft_amount, ft_amount.isEmpty == false {
                    self.decorationBtn(btn, ft_amount["title"].stringValue, true)
                }
                else {
                    self.decorationBtn(btn, "금액", false)
                }
            }
            else if i == 4 {
                if let ft_addr = ft_addr, ft_addr.isEmpty == false {
                    self.decorationBtn(btn, ft_addr["name"].stringValue, true)
                }
                else {
                    self.decorationBtn(btn, "상가", false)
                }
            }
            else if i == 5 {
                if let ft_country = ft_country, ft_country.isEmpty == false {
                    self.decorationBtn(btn, ft_country["value"].stringValue, true)
                }
                else {
                    self.decorationBtn(btn, "제조국", false)
                }
            }
        }
    }
    
    func decorationBtn(_ btn:UIButton, _ title:String, _ selected:Bool) {
        if selected {
            btn.setTitle(title, for: .normal)
            btn.backgroundColor = UIColor(named: "AccentColor")
            btn.setTitleColor(UIColor.white, for: .normal)
            btn.layer.borderWidth = 0
            btn.layer.borderColor = UIColor.clear.cgColor
        }
        else {
            btn.setTitle(title, for: .normal)
            btn.backgroundColor = UIColor.systemBackground
            btn.setTitleColor(UIColor.label, for: .normal)
            btn.layer.borderWidth = 1
            btn.layer.borderColor = UIColor(named: "BorderColor")?.cgColor
        }
    }
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender.tag >= 100  && sender.tag < 200 {
            self.completion?(nil, sender.tag)
        }
        else if sender.tag == 200 {
            self.completion?(nil, sender.tag)
        }
    }
}

extension FilterReusableView: FSPagerViewDelegate, FSPagerViewDataSource {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        guard let banners = banners else {
            return 0
        }
        return banners.count
    }
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> UICollectionViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "BannerColCell", at: index) as! BannerColCell
        if let banners = banners {
            let item = banners[index]
            cell.configurationData(item)
        }
        return cell
    }
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        let item = banners?[index]
        self.completion?(item, 300)
    }
    
}
