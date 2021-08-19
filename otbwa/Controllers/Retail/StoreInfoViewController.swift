//
//  StoreInfoViewController.swift
//  otbwa
//
//  Created by 김학철 on 2021/08/17.
//

import UIKit
import SwiftyJSON

class StoreInfoViewController: BaseViewController {
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(UINib(nibName: "ProductColCell", bundle: nil), forCellWithReuseIdentifier: "ProductColCell")
            collectionView.register(UINib(nibName: "StoreInfoHearderView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "StoreInfoHearderView")
        }
    }
    var passData:JSON!
    var listData = [JSON]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CNavigationBar.drawBack(self, nil, #selector(actionNaviBack))
        CNavigationBar.drawTitle(self, "매장 정보", nil)
        
        let layout = CFlowLayout.init()
        layout.secInset = UIEdgeInsets(top: 10, left: 18, bottom: 10, right: 18)
        layout.lineSpacing = 10
        layout.numberOfColumns = 3
        layout.delegate = self
        
        collectionView.collectionViewLayout = layout
    }
    
    func requestStoreDetailInfo() {
        
    }
    
    @IBAction func onClickedBtnActions(_ sender: UIButton) {
        
    }
    
}

extension StoreInfoViewController: UICollectionViewDelegate, UICollectionViewDataSource, CFlowLayoutDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, heightForItemAtIndexPath indexpath: NSIndexPath) -> CGFloat {
        return 180
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listData.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductColCell", for: indexPath) as? ProductColCell else {
            return UICollectionViewCell()
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "StoreInfoHearderView", for: indexPath) as? StoreInfoHearderView else {
                return UICollectionReusableView()
            }
            return header
        }
        else {
            return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
