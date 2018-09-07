//
//  WorkoutCollectionViewCell.swift
//  FIT Fuze
//
//  Created by IVAN CHERNOV on 04.09.18.
//  Copyright © 2018 FIT. All rights reserved.
//

import UIKit

class WorkoutCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var workoutTitleLabel: UILabel!
    
    @IBOutlet weak var exercisesCollection: UICollectionView!
    
    @IBOutlet weak var currentExerciseTitle: UILabel!
    @IBOutlet weak var currentExerciseDetailsLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
}

extension WorkoutCollectionViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "exerciseSimpleCell", for: indexPath)
        return cell
    }
}

extension WorkoutCollectionViewCell: UICollectionViewDelegate {
    
}

extension WorkoutCollectionViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = self.bounds.height - 150
        let width = height
        return CGSize(width: width, height: height)
    }
}

class SimpleExerciseCell: UICollectionViewCell {
    @IBOutlet weak var exerciseImage: UIImageView!
}
