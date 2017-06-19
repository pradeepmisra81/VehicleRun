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
*/

func eachInterval(_ timer1: Timer) {

seconds += timeInterval
let (h,m,s) = secondsToHoursMinutesSeconds(seconds: Int(seconds))
let secondsQuantity = HKQuantity(unit: HKUnit.second(), doubleValue: Double(s))
let minutesQuantity = HKQuantity(unit: HKUnit.minute(), doubleValue: Double(m))
let hoursQuantity = HKQuantity(unit: HKUnit.hour(), doubleValue: Double(h))


timeLabel.text = "Time: "+hoursQuantity.description+" "+minutesQuantity.description+" "+secondsQuantity.description
let distanceQuantity = HKQuantity(unit: HKUnit.meter(), doubleValue: distance)

distanceLabel.text = "Distance: " + distanceQuantity.description

paceLabel.text = "Current speed: "+String((instantPace*3.6*10).rounded()/10)+" km/h"

vehicleCurrentSpeed = (instantPace*3.6*10).rounded()/10

var currentlocationMessage = "Current "
if let loc = self.currentLocation {
let lat = loc.coordinate.latitude
let long = loc.coordinate.longitude
currentlocationMessage = currentlocationMessage + "lat: \(String(describing: lat))   long:\(String(describing: long))"
}

locationLabel.text = currentlocationMessage



vehiclePastSpeed = vehicleCurrentSpeed

let oldTimeInterval = timeInterval

// calculate the time interval for the location update
timeInterval = calulateTimeInterval(vehicleCurrentSpeed, pastSpeed: vehiclePastSpeed, pastTimeInterval: oldTimeInterval)


if oldTimeInterval != timeInterval {
timer.invalidate()
timer = Timer.scheduledTimer(timeInterval: timeInterval,
target: self,
selector: #selector(eachInterval(_:)),
userInfo: nil,
repeats: true)
}


}


/**
* @description: Function is called to calculate the time interval which is based on the current speed 
* and past speed of the vehicle
*/


func calulateTimeInterval(_ currentSpeed:Double, pastSpeed:Double, pastTimeInterval:Double) -> Double {


let speedDiff = abs(currentSpeed - pastSpeed)

// Implemented logic for location update based on the vehicle speed

if (currentSpeed >= 80) && (speedDiff <= 20){
timeInterval = 30
}
else if (currentSpeed >= 60) && (currentSpeed < 80) && (speedDiff <= 20) {
timeInterval = 60
}
else if (currentSpeed >= 30) && (currentSpeed < 60) && (speedDiff <= 20) {
timeInterval = 120
}
else if (currentSpeed < 30) && (speedDiff <= 20){
timeInterval = 300
}
else if speedDiff > 20  && (pastTimeInterval == 30) && (currentSpeed > pastSpeed) {
timeInterval = 30
}
else if speedDiff > 20  && pastTimeInterval == 60 && (currentSpeed > pastSpeed) {
timeInterval = 30
}
else if speedDiff > 20  && pastTimeInterval == 120 && (currentSpeed > pastSpeed) {
timeInterval = 60
}
else if speedDiff > 20  && pastTimeInterval == 300 && (currentSpeed > pastSpeed) {
timeInterval = 120
}
else if speedDiff > 20  && (pastTimeInterval == 30) && (currentSpeed < pastSpeed) {
timeInterval = 60
}
else if speedDiff > 20  && pastTimeInterval == 60 && (currentSpeed < pastSpeed){
timeInterval = 120
}
else if speedDiff > 20  && pastTimeInterval == 120 && (currentSpeed < pastSpeed){
timeInterval = 300
}

return timeInterval

}


