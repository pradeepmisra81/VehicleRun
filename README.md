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


guard let loc = self.currentLocation else { return }

var currentlocationMessage = "Location: "

let lat = loc.coordinate.latitude

let long = loc.coordinate.longitude

currentlocationMessage = currentlocationMessage + "lat: \(String(describing: lat))   long:\(String(describing: long))"

guard let timeStamp = self.currentLocation?.timestamp else { return }

let customLocation = CustomLocation(timestamp: timeStamp, latitude:lat, longitude: long, currenttimeinterval: currentTimeInterval, nexttimeinterval: nextTimeInterval)

customLocations.append(customLocation)

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


/**
* @description Function is called to save the Run and Location data in sqlite local db
*
*/


func saveRun() {

// Save Run
let savedRun = NSEntityDescription.insertNewObject(forEntityName: "Run",
into: managedObjectContext!) as! Run

savedRun.distance = NSNumber(value: distance)

savedRun.duration = (NSNumber(value: seconds))

savedRun.timestamp = NSDate() as Date

// Save Location

var savedLocations = [Location]()

for customLocation in customLocations {

let savedLocation = NSEntityDescription.insertNewObject(forEntityName: "Location",
into: managedObjectContext!) as! Location

guard let timeStamp = customLocation.timestamp else { return }

guard let latValue = customLocation.latitude else { return }

guard let longValue = customLocation.longitude else { return }

guard let currentTimeInterval = customLocation.currenttimeinterval else { return }

guard let nextTimeInterval = customLocation.nexttimeinterval else { return }

savedLocation.timestamp = timeStamp

savedLocation.latitude = NSNumber(value: latValue)

savedLocation.longitude = NSNumber(value: longValue)

savedLocation.currenttimeinterval = NSNumber(value: currentTimeInterval)

savedLocation.nexttimeinterval = NSNumber(value: nextTimeInterval)

savedLocations.append(savedLocation)

}

savedRun.locations = NSOrderedSet(array: savedLocations)

run = savedRun

//Save Location and Run details in Core Data using managedObjectContext

do {

try managedObjectContext!.save()

} catch {

print("Could not save the run!")

}

}
