//
//  ExerciseDescriptionViewController.swift
//  FIT Fuze
//
//  Created by Andrei Toropchin on 03.10.18.
//  Copyright © 2018 FIT. All rights reserved.
//

import UIKit

class ExerciseDescriptionViewController: UIViewController {

    static let height: CGFloat = 200

    var exercise: Exercise? // get somewhere
    weak var delegate: NSObject?

    @IBOutlet weak var exerciseImageView: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var detailsButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageSideConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        // stub
        exercise = ExerciseStore.shared.get("Ab_Crunch_Machine")

        setupViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupImage()
        imageSideConstraint.constant = height()
    }

    func setupViews() {
        exerciseImageView.layer.cornerRadius = 3
        exerciseImageView.clipsToBounds = true

        nameLabel.text = NSLocalizedString(exercise?.name ?? "", comment: "")
    }

    func setupImage() {
        // get from exercise
        let images = [1,2,3,4,5,6,7,8].map { UIImage(named: "\($0)")! }

        var array = images
        if array.count <= 7 {
            array.append(contentsOf: images.reversed())
        }

        exerciseImageView.animationImages = array
        exerciseImageView.animationRepeatCount = 1
        exerciseImageView.animationDuration = 0.3 * Double(array.count)
        exerciseImageView.image = array.first
        view.bringSubview(toFront: playButton)

        let locAttrTitle = NSMutableAttributedString(attributedString: detailsButton.currentAttributedTitle!)
        locAttrTitle.mutableString.setString(NSLocalizedString("DetailButton_Title", comment: ""))
        detailsButton.setAttributedTitle(locAttrTitle, for: .normal)
    }


    // MARK: IBActions

    @IBAction func playPressed(sender: UIButton) {
        sender.isUserInteractionEnabled = false
        sender.isHidden = true
        exerciseImageView.startAnimating()
        perform(#selector(didFinishAnimatingImageView(_:)), with: sender, afterDelay: exerciseImageView.animationDuration)
    }

    @IBAction func showDetails(sender: UIButton) {
//    [self.delegate showDetailsForExerciseMetaMapping:self.exerciseMapping];
    }

    // MARK: Private

    @objc private func didFinishAnimatingImageView(_ sender: UIButton) {
        sender.isUserInteractionEnabled = true
        sender.isHidden = false
    }

    private func height() -> CGFloat {
        let height = UIScreen.main.bounds.size.height
        switch height {
        case 480:
            return 138
        case 736:
            return 230
        case 667:
            return 180
        default:
            return 140
        }
    }

}
