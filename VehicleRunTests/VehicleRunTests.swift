//
//  VehicleRunTests.swift
//  VehicleRun
//
//  Created by pradeep kumar misra on 15/06/17.
//  Copyright © 2017 All rights reserved.
//

import UIKit
import XCTest
import CoreData
@testable import VehicleRun

class VehicleRunTests: XCTestCase {

    var managedObjectContext: NSManagedObjectContext?
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // This is a functional test case for calculating the time interval for location update, based on the
    // current and past speed of the Vehicle
    func testcalulatedTimeInterval() {
        
        let currentSpeedArray:[Double]              =   [60.0,  90.0, 9.0,  19.0,  29.0,  39.0,   49.0,  59.0, 69.0, 79.0, 89.0, 99.0]
        let pastSpeedArray:[Double]                 =   [40.0,  80.0, 90.0, 9.0,   19.0,  29.0,   39.0,  9.0,  89.0, 39.0, 69.0, 59.0]
        let currentTimeIntervalArray:[Double]       =   [120.0, 30.0, 30.0, 300.0, 300.0, 300.0, 120.0, 300.0, 30.0, 120.0, 60.0, 120.0]
        let expectedNextTimeIntervalArray:[Double]  =   [60.0,  30.0, 60.0, 300.0, 300.0, 120.0, 120.0, 120.0, 60.0, 60.0, 30.0, 60.0]
                
        let presenter = VehicleRunPresenter()
        
        for i in 0..<currentSpeedArray.count {
            
            let calulatedNextTimeInterval = presenter.calculateNextTimeInterval(Double(currentSpeedArray[i]), pastSpeed: pastSpeedArray[i], currentTimeInterval: currentTimeIntervalArray[i])
            
            XCTAssertTrue((calulatedNextTimeInterval == expectedNextTimeIntervalArray[i]), "Time interval calculation Test Case for current speed:\(currentSpeedArray[i]): Pass")
        }
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
