//
//  ExerciseDetailsCollectionCell.swift
//  FIT Fuze
//
//  Created by Andrei Toropchin on 24.02.19.
//  Copyright © 2019 FIT. All rights reserved.
//

import UIKit

enum ExerciseStatus {
    case empty
    case successful
    case failed
}

class ExerciseDetailsCollectionCell: UICollectionViewCell {

    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var repetitionsLabel: UILabel!

    @IBOutlet weak var rightVerticalSeperator: UIView!
    @IBOutlet weak var leftVerticalSeperator: UIView!

    @IBOutlet weak var exerciseSuccessImageView: UIImageView!
    @IBOutlet weak var labelContainer: UIView!
    @IBOutlet weak var activeSetBackground: UIView!
    @IBOutlet weak var background: UIView!

    var status: ExerciseStatus? {
        didSet {
            guard let status = status else { return }
            switch status {
            case .empty:
                exerciseSuccessImageView.isHidden = true
            case .successful:
                exerciseSuccessImageView.isHidden = false
                exerciseSuccessImageView.image = UIImage(named: "set-succeed")
                break;
            case .failed:
                exerciseSuccessImageView.isHidden = false
                exerciseSuccessImageView.image = UIImage(named: "set-failed")
            }
        }
    }

    var isActive: Bool = false {
        didSet {
            activeSetBackground.isHidden = !isActive;
            background.backgroundColor = isActive ? UIColor(red: 239/225.0, green: 251/255.0, blue: 1, alpha: 1) : UIColor.clear;
            setFontForLabel(weightLabel, isActive: isActive)
            setFontForLabel(repetitionsLabel, isActive: isActive)
        }
    }

    static let labelFontNameActive = "HelveticaNeue"
    static let labelFontNameUnactive = "HelveticaNeue-Thin"


    override func awakeFromNib() {
        super.awakeFromNib()
        labelContainer.layer.borderColor = UIColor.main.cgColor
        activeSetBackground.isHidden = false
        background.backgroundColor = UIColor.white
    }

    // MARK: Helpers

    func setFontForLabel(_ label: UILabel, isActive: Bool) {
        let currentFont = label.font
        let newFont = isActive ? UIFont(name: ExerciseDetailsCollectionCell.labelFontNameActive, size: currentFont!.pointSize) : UIFont(name: ExerciseDetailsCollectionCell.labelFontNameUnactive, size: currentFont!.pointSize)
        label.font = newFont
    }

    // MARK: - Setters
/*
    func setupWithExecutionDetails(_ executionDetailsArray: [ExecutionDetails], indexPath: IndexPath, isActive: Bool) {
        for view in subviews where view.tag == 1 {
            view.removeFromSuperview()
        }

        let kgOrLbls = UserDefaults(suiteName: "group.fitfuze")?.bool(forKey: "kilogrammChoosenKey") ? NSLocalizedString("kg", comment: "") : NSLocalizedString("lbs", comment: "")


        if executionDetailsArray.count == 1 {

        }
    ExerciseMetaMapping *exerciseMetaMapping = exerciseMetaMappings[0];
    ExerciseMeta *exerciseMeta = exerciseMetaMapping.exerciseMeta;

    NSInteger index = indexPath.row;
    WorkoutSet *exerciseSet = [exerciseMeta.sets array][index];

    self.weightLabel.hidden = NO;
    self.repetitionsLabel.hidden = NO;

    self.numberLabel.text = [NSString stringWithFormat:@"%ld/%ld", index+1, (long)([exerciseMeta.sets array].count)];
    self.weightLabel.text = [NSString stringWithFormat:@"%@%@", exerciseSet.convertedWeight,kgOrLbls];
    self.repetitionsLabel.text = [NSString stringWithFormat:@"×%@",exerciseSet.repetitions];
    } else {
    ExerciseMetaMapping *mainExerciseMetaMapping = exerciseMetaMappings[0];
    ExerciseMeta *mainExerciseMeta = mainExerciseMetaMapping.exerciseMeta;
    NSInteger index = indexPath.row;
    self.numberLabel.text = [NSString stringWithFormat:@"%ld/%ld", index+1, (long)([mainExerciseMeta.sets array].count)];
    self.weightLabel.hidden = YES;
    self.repetitionsLabel.hidden = YES;

    for(int i = 0; i < exerciseMetaMappings.count; i++) {
    ExerciseMetaMapping *exerciseMetaMapping = exerciseMetaMappings[i];
    ExerciseMeta *exerciseMeta = exerciseMetaMapping.exerciseMeta;
    WorkoutSet *exerciseSet = [exerciseMeta.sets array][index];
    NSString *weightText = [NSString stringWithFormat:@"%@%@", exerciseSet.convertedWeight, kgOrLbls];
    NSString *repsText = [NSString stringWithFormat:@"×%@", exerciseSet.repetitions];

    UILabel *weightLabel = [[UILabel alloc] init];
    weightLabel.textAlignment = NSTextAlignmentCenter;
    weightLabel.text = weightText;

    UILabel *repsLabelLabel = [[UILabel alloc] init];
    repsLabelLabel.textAlignment = NSTextAlignmentCenter;
    repsLabelLabel.text = repsText;

    int fontSize = 24;
    int allowedHeight = (self.frame.size.height - 20)/2;
    int allowedWidth = (self.frame.size.width - 10)/exerciseMetaMappings.count;

    weightLabel.font = [UIFont systemFontOfSize:fontSize weight: isActive ? UIFontWeightRegular : UIFontWeightLight];
    weightLabel.tag = 1;
    weightLabel.numberOfLines = 1;
    weightLabel.adjustsFontSizeToFitWidth = YES;
    weightLabel.minimumScaleFactor = 0.5;
    weightLabel.frame = CGRectMake(5+allowedWidth*i+5, 10, allowedWidth-10, allowedHeight);
    weightLabel.textColor = (i%2==1) ? [UIColor grayColor] : [UIColor blackColor];
    [self addSubview:weightLabel];

    repsLabelLabel.font = [UIFont systemFontOfSize:fontSize weight:isActive ? UIFontWeightLight : UIFontWeightThin];
    repsLabelLabel.textColor = [UIColor mainColor];
    repsLabelLabel.tag = 1;
    repsLabelLabel.numberOfLines = 1;
    repsLabelLabel.adjustsFontSizeToFitWidth = YES;
    repsLabelLabel.minimumScaleFactor = 0.5;
    repsLabelLabel.textColor = (i%2==1) ? [UIColor editColor] : [UIColor mainColor];
    repsLabelLabel.frame = CGRectMake(5+allowedWidth*i+5, 10 + allowedHeight, allowedWidth-10, allowedHeight);
    [self addSubview:repsLabelLabel];

    UIView *colorMarkView = [[UIView alloc] initWithFrame:CGRectMake(5+i*allowedWidth, self.frame.size.height-2, allowedWidth-2, 2)];
    colorMarkView.backgroundColor = colorsArray[i];
    colorMarkView.tag = 1;
    [self addSubview:colorMarkView];

    if(i != exerciseMetaMappings.count-1) {
    UIView *whiteSeparator = [[UIView alloc] initWithFrame:CGRectMake(5+i*allowedWidth+allowedWidth-2, 5, 2, self.frame.size.height-10)];
    whiteSeparator.backgroundColor = [UIColor whiteColor];
    whiteSeparator.tag = 1;
    [self addSubview:whiteSeparator];
    }
    }
    }

    [self bringSubviewToFront:self.activeSetBackground];
    self.leftVerticalSeperator.hidden = indexPath.row != 0;
    }

*/
}
