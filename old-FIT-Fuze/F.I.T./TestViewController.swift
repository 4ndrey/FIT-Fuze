//
//  TestViewController.swift
//  F.I.T.
//
//  Created by Tobias Feldmann on 27.02.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//


import UIKit

class TestViewController: UIViewController, UITableViewDataSource {
    

    @IBOutlet weak var tableView: UITableView!
    
    var trainingPrograms: [TrainingProgram] = [TrainingProgram]()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        //createData()
        var trainingPrograms = TrainingProgram.MR_findAll() as [TrainingProgram]
        
        /*
        for program in trainingPrograms
        {
            NSLog("%@", program.name!)
            for training in program.trainings
            {
                let train = training as Training
                NSLog("%@", train.name)
                if(train.name == "T1")
                {
                    for metaMapping in train.exerciseMetaMappings
                    {
                        let mapping = metaMapping as ExerciseMetaMapping
                        let exercise = mapping.exercise as Exercise
                        let meta = mapping.exerciseMeta as ExerciseMeta
                        NSLog("%@", exercise.name)
                        NSLog("%@", meta.defaultSets.stringValue)
                    }
                    
                }
            }
        }*/
        

    }
    
    
    func createData()
    {
        
        let exercise1 = Exercise.MR_createEntity() as Exercise
        exercise1.name = "exercise1"
        exercise1.exerciseDescription = "exercisedescr"
        
        let exerciseMeta = ExerciseMeta.MR_createEntity() as ExerciseMeta
        exerciseMeta.defaultSets = 4
        
        var trainings = [Training]()
        var metaMappings = [ExerciseMetaMapping]()
        
        let trainingProgram = TrainingProgram.MR_createEntity() as TrainingProgram
        trainingProgram.name = "TrainingProgram-1"
        trainingProgram.programDescription = "Eine Beschreibung"
        trainingProgram.type = "der Type"
        trainingPrograms.append(trainingProgram)
        
        let training1 = Training.MR_createEntity() as Training
        training1.name = "T1"
        training1.trainingDescription = "training description1"
        training1.trainingProgram = trainingProgram

        
        let metaMapping1 = ExerciseMetaMapping.MR_createEntity() as ExerciseMetaMapping
        metaMapping1.training = training1
        metaMapping1.exercise = exercise1
        metaMapping1.exerciseMeta = exerciseMeta
        metaMappings.append(metaMapping1)
        training1.exerciseMetaMappings = NSOrderedSet(array: metaMappings)
        trainings.append(training1)
        
        let training2 = Training.MR_createEntity() as Training
        training2.name = "T2"
        training2.trainingDescription = "training description2"
        training2.trainingProgram = trainingProgram
        trainings.append(training2)
        
        trainingProgram.trainings = NSOrderedSet(array: trainings)
        
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
  
        
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trainingPrograms.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell
        
        /*
        let trainingProgram = trainingPrograms[indexPath.row]
        var trainings = trainingProgram.trainings.allObjects as Array<Training>
        var trainingsString = ""
        for training in trainings
        {
            trainingsString += training.name + ", "
        }
        
        cell.textLabel!.text = trainingProgram.name + " --- " + trainingsString
*/
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    

}