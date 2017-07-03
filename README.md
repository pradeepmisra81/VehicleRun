# VehicleRun
This sample app is to capture the location on Vehicle Run

#Description: 

This app can start/stop location tracking on click "Start" or "Stop" buttons

#Reference:
https://www.raywenderlich.com/97944/make-app-like-runkeeper-swift-part-1

#Supported Version: iOS 10.x

#Logic in the Interactor module

File: VehicleRunInteractor.swift


/**
* @description: Function is called to calculate the next time interval which is based on the current
* speed , past speed of the vehicle
* @Parameter: currentSpeed or type Double
* @Parameter: pastSpeed of type Double
* @Parameter: currentTimeInterval of type Double
* @Return nextTimeInterval of type Double
*
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
nextTimeInterval = 300

default:
nextTimeInterval = 300
}

return nextTimeInterval

}

