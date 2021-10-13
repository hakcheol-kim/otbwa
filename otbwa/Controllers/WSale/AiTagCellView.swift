//
//  AiTagCellView.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/28.
//

import UIKit
import SwiftyJSON
import TagListView

class AiTagCellView: UIView {
    @IBOutlet weak var lbTitle:UILabel!
    @IBOutlet weak var tagBgView: UIView!
    @IBOutlet weak var tagListView: TagListView!
    
    var type:String = ""
    var list:[JSON]? {
        didSet {
            reloadTags()
        }
    }
    
    var display:JSON!
    
    var completion:((_ item: Any?, _ action:Int) ->Void)?
    override class func awakeFromNib() {
        super.awakeFromNib()
    }

    func reloadTags() {
        guard let list = list, list.isEmpty == false else {
            return
        }
        
        tagListView.removeAllTags()
        for item in list {
            tagListView.textFont = UIFont.systemFont(ofSize: 11, weight: .regular)
            tagListView.addTag(item["value"].stringValue).onTap = {[weak self] tagView in
                self?.tagListView.removeTagView(tagView)
            }
        }
    }
    func configurationData(_ display:JSON) {
        self.display = display
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapGestureHandler(_ :)))
        tagBgView.addGestureRecognizer(tap)
        
        lbTitle.text = display["tag_name"].stringValue
        tagListView.removeAllTags()
        
        tagListView.textFont = UIFont.systemFont(ofSize: 11, weight: .regular)
        tagListView.addTag(display["value"].stringValue).onTap = {[weak self] tagView in
            self?.tagListView.removeTagView(tagView)
        }
    }
    @objc func tapGestureHandler(_ gesture: UITapGestureRecognizer) {
        if gesture.view == tagBgView {
            self.completion?(display, 100)
        }
    }
}
