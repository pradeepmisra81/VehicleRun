# VehicleRun
This sample app is to capture the location on Vehicle Run

#Description: 

This app can start/stop location tracking on click "Start" or "Stop" buttons

#Reference:
https://www.raywenderlich.com/97944/make-app-like-runkeeper-swift-part-1

#Supported Version: iOS 10.x

#Logic in the file VehicleRunViewController.swift

File: VehicleRunViewController.swift

// MARK: Member Functions

/**
* @description: Function is called on each time interval which is based on the vehicle current speed
*
*/

func eachInterval(_ timer: Timer) {

seconds += currentTimeInterval

let (h,m,s) = secondsToHoursMinutesSeconds(seconds: Int(seconds))
let secondsQuantity = HKQuantity(unit: HKUnit.second(), doubleValue: Double(s))
let minutesQuantity = HKQuantity(unit: HKUnit.minute(), doubleValue: Double(m))
let hoursQuantity = HKQuantity(unit: HKUnit.hour(), doubleValue: Double(h))


timeLabel.text = "Time: "+hoursQuantity.description+" "+minutesQuantity.description+" "+secondsQuantity.description
let distanceQuantity = HKQuantity(unit: HKUnit.meter(), doubleValue: distance)

distanceLabel.text = "Distance: " + distanceQuantity.description

paceLabel.text = "Current speed: "+String((instantPace*3.6*10).rounded()/10)+" km/h"

vehicleCurrentSpeed = (instantPace*3.6*10).rounded()/10

vehiclePastSpeed = vehicleCurrentSpeed

// calculate the time interval for the location update
nextTimeInterval = calculateNextTimeInterval(vehicleCurrentSpeed, pastSpeed: vehiclePastSpeed, currentTimeInterval: currentTimeInterval)

var currentlocationMessage = "Current "
if let loc = self.currentLocation {
let lat = loc.coordinate.latitude
let long = loc.coordinate.longitude
currentlocationMessage = currentlocationMessage + "lat: \(String(describing: lat))   long:\(String(describing: long))"

let customLocation = CustomLocation(timestamp: (self.currentLocation?.timestamp)!, latitude:lat, longitude: long, currenttimeinterval: currentTimeInterval, nexttimeinterval: nextTimeInterval)

customLocations.append(customLocation)
}
locationLabel.text = currentlocationMessage



if currentTimeInterval != nextTimeInterval {
timer.invalidate()
Timer.scheduledTimer(timeInterval: nextTimeInterval,
target: self,
selector: #selector(eachInterval(_:)),
userInfo: nil,
repeats: true)
}

currentTimeInterval = nextTimeInterval

}

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
