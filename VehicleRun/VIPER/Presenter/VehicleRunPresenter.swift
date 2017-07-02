//
//  VehicleRunPresenter.swift
//  VehicleRun
//
//  Created by pradeep kumar misra on 30/06/17.
//  Copyright © 2017 pradeep kumar misra. All rights reserved.
//

import Foundation

// Presenter class in VIPER architecture
class VehicleRunPresenter {
    
    /**
     * @description: Function is called to calculate the next time interval which is based on the current
     * speed , past speed of the vehicle
     * @Parameter: currentSpeed or type Double
     * @Parameter: pastSpeed of type Double
     * @Parameter: currentTimeInterval of type Double
     * @Return nextTimeInterval of type Double
     */
    func calculateNextTimeInterval(_ currentSpeed:Double, pastSpeed:Double, currentTimeInterval:Double) -> Double {
        
        let interactor = VehicleRunInteractor()
        
        return interactor.calculateNextTimeInterval(currentSpeed, pastSpeed: pastSpeed, currentTimeInterval: currentTimeInterval)
    }
    
    /**
     * @description Function is called to save the Run and Location
     */
    func saveRun() {
        
        let interactor = VehicleRunInteractor()
        interactor.saveRun()
    }
}
