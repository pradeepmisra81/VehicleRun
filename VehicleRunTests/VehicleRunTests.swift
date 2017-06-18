//
//  VehicleRunTests.swift
//  VehicleRun
//
//  Created by pradeep kumar misra on 15/06/17.
//  Copyright © 2017 All rights reserved.
//

import UIKit
import XCTest
@testable import VehicleRun

class VehicleRunTests: XCTestCase {
    
    var viewController: VehicleRunViewController!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let storyboard = UIStoryboard(name: "Main",
                                      bundle: Bundle.main)
        
        viewController = storyboard.instantiateViewController(withIdentifier: "VehicleRunViewController") as! VehicleRunViewController
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // This is a functional test case for calculating the time interval for location update, based on the
    // current and past speed of the Vehicle
    func testcalulateTimeInterval() {
        
        let currentSpeed = 60.0
        let pastSpeed = 40.0
        let pastTimeInterval = 120.0
        
        let calulateTimeInterval = viewController.calulateTimeInterval(Double(currentSpeed), pastSpeed: pastSpeed, pastTimeInterval: pastTimeInterval)
        
        let expectedTimeInterval = 60.0
        
        XCTAssertTrue((calulateTimeInterval == expectedTimeInterval), "Time interval calculation Test Case: Pass")
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
