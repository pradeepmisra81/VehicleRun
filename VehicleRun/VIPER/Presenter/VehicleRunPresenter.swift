//
//  VehicleRunPresenter.swift
//  VehicleRun
//
//  Created by pradeep kumar misra on 30/06/17.
//  Copyright © 2017 pradeep kumar misra. All rights reserved.
//

import Foundation
import CoreData

// Presenter class in VIPER architecture
class VehicleRunPresenter {
    
    // MARK: properties
    var managedObjectContext: NSManagedObjectContext? = nil
    var interactor:VehicleRunInteractor
    lazy var customLocations = [CustomLocation]()
    //var run: Run
    
    // MARK: member functions
    init(_ moc: NSManagedObjectContext) {
        managedObjectContext = moc
        interactor = VehicleRunInteractor(managedObjectContext!)
        //run = interactor.saveRun()
    }
    
    convenience init() {
        let delegate = AppDelegate.getDelegate()
        let managedObjectContext = delegate.managedObjectContext
        self.init(managedObjectContext!)
        
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
        
        return interactor.calculateNextTimeInterval(currentSpeed, pastSpeed: pastSpeed, currentTimeInterval: currentTimeInterval)
    }
    
    /**
     * @description Function is called to save the Run and Location
     */
    func saveRun() -> Run {

        interactor.customLocations = customLocations
        return interactor.saveRun()
    }
}
