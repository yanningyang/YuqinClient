//
//  SelectCarTypeTableViewCell.swift
//  YuQinClient
//
//  Created by ksn_cn on 16/3/18.
//  Copyright © 2016年 YuQin. All rights reserved.
//

import UIKit

class SelectCarTypeTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.registerClass(CarTypeCollectionViewCell.self, forCellWithReuseIdentifier: "CollectionCellForCar")
        let cellNib = UINib(nibName: "CarTypeCollectionViewCell", bundle: nil)
        collectionView.registerNib(cellNib, forCellWithReuseIdentifier: "CollectionCellForCar")
        collectionView.backgroundColor = UIColor.whiteColor()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
//    func setCollectionViewDelegate(delegate: UICollectionViewDelegate, UICollectionViewDataSource) {
//        collectionView.dataSource = delegate
//        collectionView.delegate = delegate
//        collectionView.reloadData()
//    }

}
