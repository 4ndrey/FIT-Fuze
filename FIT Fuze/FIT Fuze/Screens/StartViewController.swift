//
//  StartViewController.swift
//  FIT Fuze
//
//  Created by IVAN CHERNOV on 03.09.18.
//  Copyright © 2018 FIT. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {

    @IBOutlet weak var cardsCollectionView: UICollectionView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var settingsCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.navigationController?.pushViewController(WorkoutViewController(), animated: true)
        }
    }

}

extension StartViewController: UICollectionViewDelegate {
}

extension StartViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == cardsCollectionView {
            let height = (cardsCollectionView.frame.height - 20)
            let width = CGFloat(250.0)
            return CGSize(width: width, height: height)
        } else if collectionView == settingsCollectionView {
            let sideSize = (cardsCollectionView.frame.width - 42) / 3
            return CGSize(width: sideSize, height: sideSize)
        }
        return CGSize.zero
    }
}

extension StartViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == cardsCollectionView {
            let cardCell = collectionView.dequeueReusableCell(withReuseIdentifier: "startCardCell", for: indexPath)
            return cardCell
        } else if collectionView == settingsCollectionView,
            let settingsCell = collectionView.dequeueReusableCell(withReuseIdentifier: "startSettingsCell", for: indexPath)
                as? SettingsCollectionViewCell {
            switch indexPath.row {
            case 0:
                settingsCell.icon.image = UIImage(named: "gear")
                settingsCell.title.text = "Settings"
            case 1:
                settingsCell.icon.image = UIImage(named: "stats")
                settingsCell.title.text = "Statistics"
            case 2:
                settingsCell.icon.image = UIImage(named: "exercise")
                settingsCell.title.text = "Exercises"
            case 3:
                settingsCell.icon.image = UIImage(named: "aid")
                settingsCell.title.text = "Help"
            default:
                break
            }
            return settingsCell
        }
        return UICollectionViewCell()
    }
}


