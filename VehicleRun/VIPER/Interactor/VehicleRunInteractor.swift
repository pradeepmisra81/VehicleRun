//
//  VehicleRunInteractor.swift
//  VehicleRun
//
//  Created by pradeep kumar misra on 30/06/17.
//  Copyright © 2017 pradeep kumar misra. All rights reserved.
//

import Foundation
import CoreData

//Interactor class in VIPER archictecture
class VehicleRunInteractor {
    
    // MARK: properties
    var managedObjectContext: NSManagedObjectContext?
    var run: Run?
    var seconds = 0.0
    var distance = 0.0
    var instantPace = 0.0
    
    lazy var customLocations = [CustomLocation]()
    
    // MARK: member functions
    
    init(_ moc: NSManagedObjectContext) {
        managedObjectContext = moc
    }
    
    convenience init() {
        self.init()
    }
    
    /**
     * @description: Function is called to calculate the next time interval which is based on the current
     * speed , past speed of the vehicle
     * @Parameter: currentSpeed or type Double
     * @Parameter: pastSpeed of type Double
     * @Parameter: currentTimeInterval of type Double
     * @Return nextTimeInterval of type Double
     */
    func calculateNextTimeInterval(_ currentSpeed:Double, pastSpeed:Double, currentTimeInterval:Double) -> Double {
        
        let speedDiff = abs(currentSpeed - pastSpeed)
        
        var nextTimeInterval = currentTimeInterval
        
        // Implemented logic for location update based on the vehicle speed
        switch (currentSpeed,speedDiff, currentTimeInterval) {
        case let (currentSpeed,speedDiff, currentTimeInterval) where (currentSpeed >= 80 && speedDiff <= 20) || (currentSpeed > pastSpeed && speedDiff > 20 && currentTimeInterval == 30) || (currentSpeed > pastSpeed && speedDiff > 20 && currentTimeInterval == 60):
            nextTimeInterval = 30
        case let (currentSpeed,speedDiff, currentTimeInterval) where (currentSpeed >= 60 && currentSpeed < 80 && speedDiff <= 20) || (currentSpeed > pastSpeed && speedDiff > 20 && currentTimeInterval == 120) || (currentSpeed < pastSpeed && speedDiff > 20 && currentTimeInterval == 30):
            nextTimeInterval = 60
        case let (currentSpeed,speedDiff, currentTimeInterval) where (currentSpeed >= 30 && currentSpeed < 60 && speedDiff <= 20) || (currentSpeed > pastSpeed && speedDiff > 20 && currentTimeInterval == 300) || (currentSpeed < pastSpeed && speedDiff > 20 && currentTimeInterval == 60):
            nextTimeInterval = 120
        case let (currentSpeed,speedDiff, currentTimeInterval) where (currentSpeed < 30 && speedDiff <= 20) || (currentSpeed < pastSpeed && speedDiff > 20 && currentTimeInterval == 120):
            nextTimeInterval = 10
        default:
            nextTimeInterval = 10
        }
        
        return nextTimeInterval
    }
    
    /**
     * @description Function is called to save the Run and Location
     */
    func saveRun() -> Run {
        // Save Run
        //guard let managedObjectContext = managedObjectContext else { return }
        
        let savedRun = NSEntityDescription.insertNewObject(forEntityName: "Run",
                                                           into: managedObjectContext!) as! Run
        savedRun.distance = NSNumber(value: distance)
        savedRun.duration = (NSNumber(value: seconds))
        savedRun.timestamp = NSDate() as Date
        
        // Save Location
        var savedLocations = [Location]()
        
        for customLocation in customLocations {
            let savedLocation = NSEntityDescription.insertNewObject(forEntityName: "Location",
                                                                    into: managedObjectContext!) as! Location
            
            guard let timeStamp = customLocation.timestamp else { return savedRun }
            guard let latValue = customLocation.latitude else { return savedRun }
            guard let longValue = customLocation.longitude else { return savedRun }
            guard let currentTimeInterval = customLocation.currenttimeinterval else { return savedRun }
            guard let nextTimeInterval = customLocation.nexttimeinterval else { return savedRun }
            savedLocation.timestamp = timeStamp
            savedLocation.latitude = NSNumber(value: latValue)
            savedLocation.longitude = NSNumber(value: longValue)
            savedLocation.currenttimeinterval = NSNumber(value: currentTimeInterval)
            savedLocation.nexttimeinterval = NSNumber(value: nextTimeInterval)
            
            savedLocations.append(savedLocation)
        }
        
        savedRun.locations = NSOrderedSet(array: savedLocations)
        run = savedRun
        
        //Save Location and Run details in Core Data using managedObjectContext
        do{
            try managedObjectContext?.save()
        }catch{
            print("Could not save the run!")
        }
        
        return savedRun
    }
    
}

