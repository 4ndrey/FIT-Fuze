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
    
    func setup(with workout: Training, and plan: TrainingProgram) {
        guard let mappings = workout.exerciseMetaMappings?.array as? [ExerciseMetaMapping] else {
            return
        }
        
        exerciseImages = mappings.map {
            let imgWrapper = $0.exercise?.images?.firstObject as! Images
            let imgData = imgWrapper.image!
            return UIImage(data: imgData)!
        }
        
        titleLabel.text = NSLocalizedString(workout.name!, comment: "")
        if let doneValue = workout.repetitionCounter?.intValue,
            let todoValue = plan.workoutRepetition?.intValue {
            doneLabel.text = "DONE: \(doneValue) OF \(todoValue)"
        }
        
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

