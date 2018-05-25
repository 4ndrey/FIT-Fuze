//
//  CurrentPlanViewController.swift
//  F.I.T.
//
//  Created by IVAN CHERNOV on 03.03.18.
//  Copyright © 2018 FIT-Team. All rights reserved.
//

import UIKit
import MagicalRecord

class CurrentPlanViewController: UIViewController {

    let managedContext = NSManagedObjectContext.mr_default()
    var currentPlan: TrainingProgram?
    var todaysWorkoutIndex = 0
    @IBOutlet var collection: UICollectionView!
    @IBOutlet var welcomeLabel: UILabel!
    @IBOutlet var welcomeButton: UIButton!
    @IBOutlet var startWorkoutButton: UIButton!
    @IBOutlet var startWorkoutEffectBackgroundView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showWelcomeMessage()

        if let uri = UserDefaults.standard.url(forKey: "currentTrainingplan"),
            let objectID = managedContext?.persistentStoreCoordinator!.managedObjectID(forURIRepresentation: uri) {
            currentPlan = managedContext?.object(with: objectID) as? TrainingProgram
            todaysWorkoutIndex = getTodaysWorkoutIndex()
        }

        let provider = ContentProvider()
        currentPlan = provider.getFreeTrainingPrograms()[1]
        
        if currentPlan != nil {
            hideWelcomeMessage()
        }
    }
    
    func getTodaysWorkoutIndex() -> Int {
        guard let plan = currentPlan,
            let workouts = plan.trainings,
            let maxRepetitionNumber = currentPlan?.workoutRepetition?.intValue else { return 0 }
        var currentMin = 1000
        var currentIndex = 0
        for i in (workouts.count-1)...0 {
            let workout = workouts[i] as! Training
            let currentRepValue = (workout.repetitionCounter?.intValue)!
            if currentRepValue < currentMin {
                currentIndex = i
                currentMin = currentRepValue
            }
        }
        
        // [[CurrentFitManager sharedManager] setCurrentWorkoutIndex:self.todayBannerIndex];
        return currentIndex
    }
    
    func showWelcomeMessage() {
        self.view.bringSubview(toFront: welcomeLabel)
        self.view.bringSubview(toFront: welcomeButton)
        collection.alpha = 0
        collection.isUserInteractionEnabled = false
        welcomeLabel.isHidden = false
        welcomeButton.isHidden = false
        startWorkoutEffectBackgroundView.isHidden = true
        welcomeButton.setTitle(NSLocalizedString("Select_First_Plan_Button_title", comment:""), for: .normal)
        welcomeButton.titleLabel?.textAlignment = .center
        let title = NSLocalizedString("Welcome_to_FITFuze_text", comment: "nil")
        let range = (title as NSString).range(of:"FIT Fuze")
        let boldFont = UIFont.systemFont(ofSize: 30.0, weight: UIFontWeightSemibold)
        let paramsDict = [NSFontAttributeName: boldFont]
        let attributedTitle = NSMutableAttributedString(string: title)
        attributedTitle.setAttributes(paramsDict, range: range)
        welcomeLabel.attributedText = attributedTitle
    }
    
    func hideWelcomeMessage() {
        self.view.sendSubview(toBack: welcomeLabel)
        self.view.sendSubview(toBack: welcomeButton)
        collection.alpha = 1
        collection.isUserInteractionEnabled = true
        welcomeLabel.isHidden = true
        welcomeButton.isHidden = true
        startWorkoutEffectBackgroundView.isHidden = false
    }
}

extension CurrentPlanViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentPlan?.trainings?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "workoutCellID", for: indexPath)
            as? DetailedWorkoutCollectionViewCell,
            let workouts = currentPlan?.trainings,
            let plan = currentPlan,
            let workout = workouts[indexPath.row] as? Training {
            cell.setup(with: workout, and: plan)
            cell.todayBanner.isHidden = todaysWorkoutIndex != indexPath.row
            return cell
        }
        
        return UICollectionViewCell()
    }
}
