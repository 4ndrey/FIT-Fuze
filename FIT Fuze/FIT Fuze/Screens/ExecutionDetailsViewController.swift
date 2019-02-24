//
//  ExecutionDetailsController.swift
//  FIT Fuze
//
//  Created by Andrei Toropchin on 03.10.18.
//  Copyright © 2018 FIT. All rights reserved.
//

import UIKit

class ExecutionDetailsViewController: UIViewController, UICollectionViewDataSource {

    static let height: CGFloat = 100

    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(UINib(nibName: "ExerciseDetailsCollectionCell", bundle: nil), forCellWithReuseIdentifier: "ExerciseDetailsCollectionCell")
        collectionView.register(UINib(nibName: "AddSetCollectionCell", bundle: nil), forCellWithReuseIdentifier: "AddSetCollectionCell")
    }

    func centerAHorizontallyCell(indexPath: IndexPath) {
        let activeCell = collectionView.cellForItem(at: indexPath)

        let collectionViewWidth = collectionView.bounds.width
        collectionView.contentInset = UIEdgeInsets(top: 0, left: collectionViewWidth / 2, bottom: 0, right: collectionViewWidth / 2)

        let offset = CGPoint(x: activeCell?.center.x ?? 0, y: collectionViewWidth / 2)
        collectionView.setContentOffset(offset, animated: true)
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? 3 : 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 1 {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "AddSetCollectionCell", for: indexPath)
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExerciseDetailsCollectionCell", for: indexPath)

            // stub
            (cell as? ExerciseDetailsCollectionCell)?.weightLabel.text = "5kg"
            (cell as? ExerciseDetailsCollectionCell)?.repetitionsLabel.text = "x10"
            (cell as? ExerciseDetailsCollectionCell)?.numberLabel.text = "\(indexPath.row + 1)/\(collectionView.numberOfItems(inSection: 0))"

            return cell
        }
    }

}
