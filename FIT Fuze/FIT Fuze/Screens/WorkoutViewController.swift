//
//  WorkoutViewController.swift
//  FIT Fuze
//
//  Created by Andrei Toropchin on 15.09.18.
//  Copyright © 2018 FIT. All rights reserved.
//

import UIKit
import StackViewController

class WorkoutViewController: StackViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        backgroundColor = UIColor.white

        addItem(ExerciseDescriptionViewController())
        addItem(ExecutionDetailsViewController())
        addItem(ExecutionControlsViewController())
    }

}
