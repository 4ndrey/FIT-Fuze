//
//  JSONParser.swift
//  FIT Fuze
//
//  Created by Andrei Toropchin on 09.06.18.
//  Copyright © 2018 FIT. All rights reserved.
//

import Foundation

class JSONConverter {
    class func convert() {
        // Convert training programs
        if let path = Bundle.main.path(forResource: "program", ofType: "json") {
            if let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                if let jsonResult: NSDictionary = (try? JSONSerialization.jsonObject(with: jsonData, options: [])) as? NSDictionary {
                    if let plans = jsonResult["trainingPrograms"] as? [[String: Any]] {
                        for planDict in plans {
                            var workouts = [Workout]()
                            if let workoutsDicts = planDict["trainings"] as? [[String: Any]] {
                                for workoutDict in workoutsDicts {
                                    var items = [WorkoutItem]()
                                    if let itemsDicts = workoutDict["exerciseMetaMappings"] as? [[String: Any]] {
                                        for itemDict in itemsDicts {
                                            let item = WorkoutItem(id: itemDict["exerciseName"] as! String,
                                                                   exerciseId: itemDict["exerciseName"] as! String,
                                                                   executions: [],
                                                                   nextItem: nil)
                                            items.append(item)
                                        }
                                    }

                                    let workout = Workout(id: workoutDict["name"] as! String,
                                                          name: workoutDict["name"] as! String,
                                                          items: items)
                                    workouts.append(workout)
                                }
                            }
                            let plan = TrainingPlan(id: planDict["programId"] as! String,
                                                    name: planDict["name"] as! String,
                                                    description: planDict["description"] as! String,
                                                    type: planDict["type"] as! String,
                                                    level: planDict["level"] as! String,
                                                    defaultWeeks: planDict["repetitions"] as? Int,
                                                    isFree: planDict["free"] as! Bool,
                                                    workouts: workouts)
                            TrainingPlanStore.shared.save(plan, id: plan.id)
                        }
                    }
                }
            }
        }
        // Convert exercises
        if let path = Bundle.main.path(forResource: "exercises", ofType: "json") {
            if let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                if let jsonResult: NSDictionary = (try? JSONSerialization.jsonObject(with: jsonData, options: [])) as? NSDictionary {
                    if let exercises = jsonResult["exercises"] as? [[String: Any]] {
                        for exerciseDict in exercises {
                            let exercise = Exercise(id: (exerciseDict["name"] as! String).replacingOccurrences(of: " ", with: "_"),
                                                    name: exerciseDict["name"] as! String,
                                                    primaryMuscles: (exerciseDict["primary"] as! [[String: String]]).compactMap { $0["type"] },
                                                    secondaryMuscles: (exerciseDict["secondary"] as! [[String: String]]).compactMap { $0["type"] })
                            ExerciseStore.shared.save(exercise, id: exercise.id)
                        }
                    }
                }
            }
        }
    }
}
