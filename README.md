# VehicleRun
This sample app is to capture the location on Vehicle Run
Description: - This app can start/stop location tracking on click "Start" or "Stop" buttons

#Reference:
https://www.raywenderlich.com/97944/make-app-like-runkeeper-swift-part-1

#Supported Version: iOS 10.x

#Logic

/**
* @description: Function is called on each time interval which is based on the vehicle current speed
* Implemented logic to capture the location on the specific time intervals, based on the vehicle speed

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

let speedDiff = abs(vehicleCurrentSpeed - vehiclePastSpeed)

vehiclePastSpeed = vehicleCurrentSpeed

let oldTimeInterval = timeInterval

// Implemented logic for location update based on the vehicle speed
if vehicleCurrentSpeed >= 80 {
timeInterval = 30
}
else if (vehicleCurrentSpeed >= 60) && (vehicleCurrentSpeed < 80) && speedDiff <= 20 {
timeInterval = 60
}
else if (vehicleCurrentSpeed >= 30) && (vehicleCurrentSpeed < 60) && speedDiff <= 20 {
timeInterval = 120
}
else if (vehicleCurrentSpeed < 30) && (vehicleCurrentSpeed > 0) {
timeInterval = 300
}
else if speedDiff > 20  && oldTimeInterval == 30{
timeInterval = 60
}
else if speedDiff > 20  && oldTimeInterval == 60{
timeInterval = 120
}
else if speedDiff > 20  && oldTimeInterval == 120{
timeInterval = 300
}


if oldTimeInterval != timeInterval {
timer.invalidate()
timer = Timer.scheduledTimer(timeInterval: timeInterval,
target: self,
selector: #selector(eachInterval(_:)),
userInfo: nil,
repeats: true)
}

}

