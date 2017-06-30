//
//  Run.swift
//  VehicleRun
//
//  Created by pradeep kumar misra on 15/06/17.
//  Copyright © 2017 All rights reserved.
//

import Foundation
import CoreData

class Run: NSManagedObject {

    @NSManaged var duration: NSNumber?
    @NSManaged var distance: NSNumber?
    @NSManaged var timestamp: Date?
    @NSManaged var locations: NSOrderedSet?

}
