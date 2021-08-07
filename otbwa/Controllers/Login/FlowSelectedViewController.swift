//
//  FlowSelectedViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/07/30.
//

import UIKit
import SwiftyJSON

class FlowSelectedViewController: UIViewController {
    @IBOutlet var btnClose: UIButton!
    @IBOutlet weak var tblView: UITableView!
    
    var completion:((_ item:JSON) ->Void)?
    var listData: [JSON]!
    
    static func initWithData(_ data:[JSON], completion:((_ item:Any) ->Void)?) ->FlowSelectedViewController {
        let vc = FlowSelectedViewController.instantiateFromStoryboard(.login)!
        vc.completion = completion
        vc.listData = data
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tblView.bounds.width, height: 8))
        tblView.tableHeaderView?.backgroundColor = UIColor.clear
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        if sender == btnClose {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension FlowSelectedViewController: UITableViewDelegate, UITableViewDataSource {
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
