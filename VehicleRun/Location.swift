//
//  Location.swift
//  VehicleRun
//
//  Created by pradeep kumar misra on 15/06/17.
//  Copyright © 2017 All rights reserved.
//

import Foundation
import CoreData

class Location: NSManagedObject {

    @NSManaged var timestamp: Date
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var run: NSManagedObject

}
