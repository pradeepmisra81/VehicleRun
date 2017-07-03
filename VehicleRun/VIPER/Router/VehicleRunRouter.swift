//
//  VehicleRunRouter.swift
//  VehicleRun
//
//  Created by pradeep kumar misra on 30/06/17.
//  Copyright © 2017 pradeep kumar misra. All rights reserved.
//
import UIKit
import Foundation
import CoreData

// Router class in VIPER architecture
class VehicleRunRouter {
    
    var navController: UINavigationController?
    var view: HomeViewController?
    var managedobjectcontest: NSManagedObjectContext?
    
    init(navigationController: UINavigationController, homeViewController: HomeViewController, managedobjectcontest: NSManagedObjectContext ) {
        navController = navigationController
        view = homeViewController
        
        if let view = view {
            
            view.managedObjectContext = managedobjectcontest
        }
        else {
            
            // Error 
            print("Error: managedObjectContext in HomeView is not initialised")
        }
        
    }
}
