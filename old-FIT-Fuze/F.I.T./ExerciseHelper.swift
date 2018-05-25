//
//  ExerciseHelper.swift
//  F.I.T.
//
//  Created by Tobias Feldmann on 27.02.15.
//  Copyright (c) 2015 FIT-Team. All rights reserved.
//

import Foundation
import Parse

class ExerciseHelper
{
    
    class func handleImages(pfObject : PFObject!, exerciseObject : ParseExercise,  createFromLocal : Bool, delegate : ParseInterface?)
    {
        if createFromLocal == true
        {
            exerciseObject.localImagesData = pfObject["localImagesData"] as? Array<PFFile>
            
            if exerciseObject.localImagesData != nil
            {
                exerciseObject.exerciseImages = Array<UIImage>()
                for image in exerciseObject.localImagesData!
                {
                    image.getDataInBackgroundWithBlock(){
                        (imageData: NSData!, error: NSError!) -> Void in
                        if (error == nil) {
                            let uiImage = UIImage(data:imageData)
                            exerciseObject.exerciseImages!.append(uiImage!)
                        }
                        else
                        {
                            //NSLog("%@", error)
                        }
                    }
                }
                
            }
            
        }
        else
        {
            let images = pfObject[TableConstants.FIELD_EXERCISES_IMAGES] as? Array<String>
            if images != nil
            {
                
                var imageCounter = 0
                exerciseObject.localImagesData = Array<PFFile>()
                for image in images!
                {
                    var query = PFQuery(className:TableConstants.TABLE_EXERCISES_IMAGES)
                    query.getObjectInBackgroundWithId(image) {
                        (parseImage: PFObject!, error: NSError!) -> Void in
                        if error == nil {
                            let picture = parseImage["image"] as PFFile
                            picture.getDataInBackgroundWithBlock(){
                                (imageData: NSData!, error: NSError!) -> Void in
                                if (error == nil) {
                                    exerciseObject.localImagesData!.append(picture)
                                    imageCounter++
                                    if imageCounter == images?.count
                                    {
                                        self.saveObject(pfObject, exerciseObject: exerciseObject, delegate: delegate)
                                    }
                                }
                                else
                                {
                                   //NSLog("%@", error)
                                }
                            }
                            
                            
                        } else {
                            //NSLog("%@", error)
                        }
                        
                    }
                }
                
            }
            
            
        }
    }
    
    private class func saveObject(pfObject : PFObject!, exerciseObject : ParseExercise, delegate : ParseInterface?)
    {
        pfObject["localImagesData"] = exerciseObject.localImagesData!
        pfObject.pinWithName(pfObject.objectId)
        exerciseObject.localStorage.addExercise(exerciseObject)
        
        if delegate != nil
        {
            delegate!.onExerciseDownloadFinished(exerciseObject)
        }
        
        
    }

}