//
//  ExecutionControlsViewController.swift
//  FIT Fuze
//
//  Created by Andrei Toropchin on 03.10.18.
//  Copyright © 2018 FIT. All rights reserved.
//

import UIKit

class ExecutionControlsViewController: UIViewController {

    @IBOutlet weak var heightConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        heightConstraint.constant = UIScreen.main.bounds.height - 20 /* status bar */ - ExerciseDescriptionViewController.height - ExecutionDetailsViewController.height
    }

}
