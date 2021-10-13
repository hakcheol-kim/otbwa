//
//  SearchImageReusableHeaderView.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/22.
//

import UIKit
import SwiftyJSON
import WSTagsField

class SearchImageReusableHeaderView: UICollectionReusableView {
    @IBOutlet weak var bgImageView: UIView!
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var btnImgUpDwon: UIButton!
    @IBOutlet weak var btnAiTagUpDown: UIButton!
    @IBOutlet weak var tagBgView: UIView!
    
    var tags: [JSON]?
    var fitImgView: FitImageView?
    var completion:((_ action: Int, _ isSelected: Bool) ->Void)?
    var didfinishCropImgClosure:((_ crop: Any?) -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configuratinData(_ image: UIImage?, _ tags: [JSON]?, _ hideImageView:Bool = false, _ hideTagView:Bool = false) {
        
        self.tags = tags
        if let image = image {
            if let _ = self.fitImgView {
                
            }
            else {
                self.fitImgView = Bundle.main.loadNibNamed("FitImageView", owner: nil, options: nil)?.first as? FitImageView
                self.fitImgView!.delegate = self
                bgImageView.addSubview(fitImgView!)
                self.fitImgView!.image = image
                self.fitImgView!.createOverlay()
            }
        }
        
        if let tags = tags, tags.isEmpty == false {
            for subView in tagBgView.subviews {
                subView.removeFromSuperview()
            }
            
            let  tagsField = WSTagsField()
            self.tagBgView.addSubview(tagsField)
            
            tagsField.translatesAutoresizingMaskIntoConstraints = false
            tagsField.topAnchor.constraint(equalTo: tagBgView.topAnchor).isActive = true
            tagsField.leadingAnchor.constraint(equalTo: tagBgView.leadingAnchor, constant: 0).isActive = true
            tagsField.trailingAnchor.constraint(equalTo: tagBgView.trailingAnchor, constant: 0).isActive = true
            tagsField.bottomAnchor.constraint(equalTo: tagBgView.bottomAnchor).isActive = true
            
            tagsField.layoutMargins = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
            tagsField.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0) //old padding
            tagsField.cornerRadius = 16.0
            tagsField.spaceBetweenLines = 12
            tagsField.spaceBetweenTags = 8
            tagsField.tintColor = .clear
            tagsField.textColor = UIColor.label
            tagsField.borderWidth = 1
            tagsField.borderColor = UIColor(named: "BorderColor")
            tagsField.textField.textColor =  UIColor.label
            tagsField.font = UIFont.systemFont(ofSize: 13)
            tagsField.readOnly = true
            
            for item in tags {
                let title = item["value"].stringValue
                if title.isEmpty == false {
                    tagsField.addTag(title)
                }
            }
        }
        bgImageView.isHidden = hideImageView
        tagBgView.isHidden = hideTagView
        btnAiTagUpDown.isSelected = hideTagView
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnImgUpDwon {
            sender.isSelected = !sender.isSelected
            self.completion?(100, sender.isSelected)
        }
        else if sender == btnAiTagUpDown {
            sender.isSelected = !sender.isSelected
            self.completion?(200, sender.isSelected)
        }
        else if sender == btnSearch {
            self.completion?(300, true)
        }
        
    }
}
extension SearchImageReusableHeaderView: FitImageViewDelegate {
    func didFinishCropImage(_ image: UIImage?) {
        self.didfinishCropImgClosure?(image)
    }
}
