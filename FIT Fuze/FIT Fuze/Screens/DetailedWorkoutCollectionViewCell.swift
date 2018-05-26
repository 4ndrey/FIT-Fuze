//
//  DetailedWorkoutCollectionViewCell.swift
//  F.I.T.
//
//  Created by IVAN CHERNOV on 03.03.18.
//  Copyright © 2018 FIT-Team. All rights reserved.
//

import UIKit

class DetailedWorkoutCollectionViewCell: UICollectionViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var timingLabel: UILabel!
    @IBOutlet var imagesCollectionView: UICollectionView!
    @IBOutlet var doneLabel: UILabel!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var todayBanner: UIImageView!
    
    var exerciseImages: [UIImage] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
        
        self.contentView.layer.cornerRadius = 5.0
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.clear.cgColor
        self.contentView.layer.masksToBounds = true
        
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        self.layer.shadowRadius = 5.0
        self.layer.shadowOpacity = 1.0
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
    }
    
    func setup(for workout: Workout, and plan: TrainingPlan) {
        exerciseImages = [UIImage(named: "1")!,
                          UIImage(named: "2")!,
                          UIImage(named: "3")!,
                          UIImage(named: "4")!,
                          UIImage(named: "5")!,
                          UIImage(named: "6")!,
                          UIImage(named: "7")!,
                          UIImage(named: "8")!]
        
        titleLabel.text = NSLocalizedString(workout.name, comment: "")
        doneLabel.text = "DONE: \(workout.timesDone) OF \(plan.weeksCount)"
        
        imagesCollectionView.reloadData()
    }
}

extension DetailedWorkoutCollectionViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return exerciseImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "exerciseCellID", for: indexPath) as? SimpleImageCollectionViewCell {
            cell.imageView.image = exerciseImages[indexPath.row]
            return cell
        }
        
        return UICollectionViewCell()
    }
}

