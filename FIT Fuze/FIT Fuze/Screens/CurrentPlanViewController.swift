//
//  CurrentPlanViewController.swift
//  FIT
//
//  Created by IVAN CHERNOV on 03.03.18.
//  Copyright © 2018 FIT-Team. All rights reserved.
//

import UIKit

class CurrentPlanViewController: UIViewController {

    //let managedContext = NSManagedObjectContext.mr_default()
    var currentPlan: TrainingPlan?
    var todaysWorkoutIndex = 0
    @IBOutlet var collection: UICollectionView!
    @IBOutlet var welcomeLabel: UILabel!
    @IBOutlet var welcomeButton: UIButton!
    @IBOutlet var startWorkoutButton: UIButton!
    @IBOutlet var startWorkoutEffectBackgroundView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentPlan = DataProvider.shared.currentProgram()
        todaysWorkoutIndex = DataProvider.shared.todayWorkoutIndex()
        
        if currentPlan == nil {
            showWelcomeMessage()
        }
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
        let attributedTitle = NSMutableAttributedString(string: title)
        let textAttributes: [NSAttributedStringKey: Any] = [
            .font : UIFont.systemFont(ofSize: 30.0, weight: .semibold)
        ]
        attributedTitle.addAttributes(textAttributes, range: range)
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
        return currentPlan?.workouts.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "workoutCellID", for: indexPath)
            as? DetailedWorkoutCollectionViewCell,
            let plan = currentPlan,
            let workout = plan.workouts[indexPath.row] as? Workout {
            cell.setup(for: workout, and: plan)
            cell.todayBanner.isHidden = todaysWorkoutIndex != indexPath.row
            return cell
        }
        
        return UICollectionViewCell()
    }
}
