//
//  HomeViewController.swift
//  VehicleRun
//
//  Created by pradeep kumar misra on 15/06/17.
//  Copyright © 2017 All rights reserved.
//

import UIKit
import CoreData

class HomeViewController: UIViewController {
  var managedObjectContext: NSManagedObjectContext?

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.destination.isKind(of: VehicleRunViewController.self) {
      if let vehicleRunViewController = segue.destination as? VehicleRunViewController {
        vehicleRunViewController.managedObjectContext = managedObjectContext
      }
    }
  }
}
