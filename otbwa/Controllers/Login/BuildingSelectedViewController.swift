//
//  BuildingSelectedViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/07/30.
//

import UIKit
import SwiftyJSON
class BuildingSelectedViewController: UIViewController {
    @IBOutlet var arrBtn: [CButton]!
    @IBOutlet var btnClose: UIButton!
    @IBOutlet weak var tblView: UITableView!
    
    var completion:((_ item:JSON) ->Void)?
    var data:[JSON]!
    var listData:[JSON] = [JSON]()
    
    var selIdx:Int = 0
    
    static func initWithData(_ data:[JSON], _ index:Int = 0, completion:((_ item: Any?) ->Void)?) ->BuildingSelectedViewController {
        let vc = BuildingSelectedViewController.instantiateFromStoryboard(.login)!
        vc.completion = completion
        vc.data = data
        vc.selIdx = index
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tblView.bounds.width, height: 4))
        tblView.tableHeaderView?.backgroundColor = UIColor.clear
        
        var findBtn: UIButton? = nil
        
        let category = data.filter { item in
            return item["level"].intValue == 1
        }
        
        let categorys1 = category.filter { item in
            return item["name"].stringValue == "동대문"
        }
        
        let categorys2 = category.filter { item in
            return item["name"].stringValue == "남대문"
        }
        
        for i in 0..<arrBtn.count {
            let btn = arrBtn[i]
            
            btn.addTarget(self, action: #selector(onClickedBtnActions(_:)), for: .touchUpInside)
            let img = UIImage(named: "oval")
            let ivMark = UIImageView.init(image: img)
            btn.addSubview(ivMark)
            ivMark.tag = 101;
            ivMark.frame = CGRect(x: (btn.frame.size.width - img!.size.width)/2, y: btn.bounds.height-10, width: img!.size.width, height: img!.size.height)
            ivMark.isHidden = true
            if btn.tag == selIdx {
                findBtn = btn
            }
            
            if i == 0 && categorys1.isEmpty == false {
                let category = categorys1.first!
                let ctgr_id = category["ctgr_id"].intValue
                btn.data = self.getGategoryList(ctgr_id)
            }
            else if i == 1 && categorys2.isEmpty == false {
                let category = categorys2.first!
                let ctgr_id = category["ctgr_id"].intValue
                btn.data = self.getGategoryList(ctgr_id)
            }
        }
        
        if let findBtn = findBtn {
            findBtn.sendActions(for: .touchUpInside)
        }
    }
    
    func getGategoryList(_ categoryId: Int) -> [JSON] {
        let list = data.filter { item in
            return categoryId == item["up_ctgr_id"].intValue
        }
        
        return list
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnClose {
            self.dismiss(animated: true, completion: nil)
        }
        else if let sender = sender as? CButton, arrBtn.contains(sender) == true {
            arrBtn.forEach { btn in
                btn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
                btn.setTitleColor(UIColor.label, for: .normal)
                if let ivMark = btn.viewWithTag(101) {
                    ivMark.isHidden = true
                }
            }
            sender.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
            sender.setTitleColor(UIColor(named: "AccentColor"), for: .normal)
            if let data = sender.data as? [JSON] {
                listData = data
                self.tblView.reloadData()
            }
            if let ivMark = sender.viewWithTag(101) {
                ivMark.isHidden = false
            }
        }
    }
}

extension BuildingSelectedViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "PopupCell") as? PopupCell
        if cell == nil {
            cell = Bundle.main.loadNibNamed("PopupCell", owner: nil, options: nil)?.first as? PopupCell
        }
        let item = listData[indexPath.row]
        let text = item["name"].stringValue
        cell?.lbTitle.text = text
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true, completion: nil)
        let item = listData[indexPath.row]
        completion?(item)
    }
}
