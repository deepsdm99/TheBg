/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

// test

import UIKit
import UserNotifications
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  
  
  var previous = NSDecimalNumber.one
  var current = NSDecimalNumber.one
  var position: UInt = 1
  var updateTimer: Timer?
  var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
  
  fileprivate var manager: APScheduledLocationManager!
  var locationManager: CLLocationManager = CLLocationManager()
  var startLocation: CLLocation!
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
    //UIApplication.shared.setMinimumBackgroundFetchInterval(
     // UIApplicationBackgroundFetchIntervalMinimum)
    
    // User Authorization for push notifications
    registerForPushNotifications()
    //configureLocation()
    // manager = APScheduledLocationManager(delegate: self)
    
     //manager.startUpdatingLocation(interval: 30, acceptableLocationAccuracy: 100)
    
    return true
  }
  
  func applicationDidEnterBackground(_ application: UIApplication) {
    print(#function)
   // locationManager.stopUpdatingLocation()
  }
  
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    print(#function)
   // locationManager.stopUpdatingLocation()
  }
  func applicationWillResignActive(_ application: UIApplication) {
    print(#function)
  }
  // Support for background fetch
  func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    if let tabBarController = window?.rootViewController as? UITabBarController,
           let viewControllers = tabBarController.viewControllers
    {
      for viewController in viewControllers {
        if let fetchViewController = viewController as? FetchViewController {
          fetchViewController.fetch {
            fetchViewController.updateUI()
            completionHandler(.newData)
          }
        }
      }
    }
  }
}


// MARK: Handle Silent Push Notifications
extension AppDelegate {
  
  
  func application(_ application: UIApplication,
                   didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let tokenParts = deviceToken.map { data -> String in
      return String(format: "%02.2hhx", data)
    }
    
    let token = tokenParts.joined()
    print("Device Token: \(token)")
  }
  
  func application(_ application: UIApplication,
                   didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("Failed to register: \(error)")
  }
  
  func registerForPushNotifications() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
      (granted, error) in
      print("Permission granted: \(granted)")
      
      guard granted else { return }
      self.getNotificationSettings()
    }
  }
  
  func getNotificationSettings() {
    UNUserNotificationCenter.current().getNotificationSettings { (settings) in
      //print("Notification settings: \(settings)")
      guard settings.authorizationStatus == .authorized else { return }
      DispatchQueue.main.async {
        UIApplication.shared.registerForRemoteNotifications()
      }
      
    }
  }
  
  func configureLocation() {
    
    locationManager.startUpdatingLocation()
    locationManager.delegate = self
    
    //locationManager.allowsBackgroundLocationUpdates = true
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.distanceFilter = kCLDistanceFilterNone
   // locationManager.pausesLocationUpdatesAutomatically = false
    
  }
  
  func application(
    _ application: UIApplication,
    didReceiveRemoteNotification userInfo: [AnyHashable : Any],
    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    print(#function)
    let aps = userInfo["aps"] as! [String: AnyObject]
    
    // 1
            if aps["content-available"] as? Int == 1 {
              
              if UIApplication.shared.applicationState == .inactive {
                print("App is in inactive")
                 configureLocation()
                //mapView.showAnnotations(self.locations, animated: true)
              } else if UIApplication.shared.applicationState == .background {
                 configureLocation()
                 print("App is backgrounded")
              } else {
                print("App in foreground")
              }
              
             // configureLocation()
              //manager.startLocationManager()
              // manager.startUpdatingLocation(interval: 30, acceptableLocationAccuracy: 100)
//
//                // if sender.isSelected {
//                      resetCalculation()
//                      updateTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self,
//                        selector: #selector(calculateNextNumber), userInfo: nil, repeats: true)
//                      registerBackgroundTask()
//                   // }
////                 else {
////                      updateTimer?.invalidate()
////                      updateTimer = nil
////                      if backgroundTask != UIBackgroundTaskInvalid {
////                        endBackgroundTask()
////                      }
////                    }
               // let podcastStore = PodcastStore.sharedStore
                // Refresh Podcast
                // 2
               // podcastStore.refreshItems { didLoadNewItems in
                    // 3
                   completionHandler( .newData)
               // }
            } else  {
//              updateTimer?.invalidate()
//              updateTimer = nil
//              if backgroundTask != UIBackgroundTaskInvalid {
//                endBackgroundTask()
//              }
                // News
                // 4
               // _ = NewsItem.makeNewsItem(aps)
                completionHandler(.newData)
            }
  }
  
  
  func resetCalculation() {
    previous = NSDecimalNumber.one
    current = NSDecimalNumber.one
    position = 1
  }
  
  func registerBackgroundTask() {
    backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
      self?.endBackgroundTask()
    }
    assert(backgroundTask != UIBackgroundTaskInvalid)
  }
  
  func endBackgroundTask() {
    print("Background task ended.")
    UIApplication.shared.endBackgroundTask(backgroundTask)
    backgroundTask = UIBackgroundTaskInvalid
  }
  
  func calculateNextNumber() {
    let result = current.adding(previous)
    
    let bigNumber = NSDecimalNumber(mantissa: 1, exponent: 40, isNegative: false)
    if result.compare(bigNumber) == .orderedAscending {
      previous = current
      current = result
      position += 1
    } else {
      // This is just too much.... Start over.
      resetCalculation()
    }
    
    let resultsMessage = "Position \(position) = \(current)"
    
    switch UIApplication.shared.applicationState {
    case .active:
     // resultsLabel.text = resultsMessage
       print("App is in foreground")
    case .background:
      print("App is backgrounded. Next number = \(resultsMessage)")
      print("Background time remaining = \(UIApplication.shared.backgroundTimeRemaining) seconds")
      //if UIApplication.shared.backgroundTimeRemaining <= 160 {
       // print(<#T##items: Any...##Any#>)
        endBackgroundTask()
    //  }
    case .inactive:
      break
    }
  }
}


extension AppDelegate {
//  func scheduledLocationManager(_ manager: APScheduledLocationManager, didUpdateLocations locations: [CLLocation]) {
//
//    print(#function)
//
//    let latestLocation: CLLocation = locations[locations.count - 1]
////
////    latitude.text = String(format: "%.4f",
////                           latestLocation.coordinate.latitude)
////    longitude.text = String(format: "%.4f",
////                            latestLocation.coordinate.longitude)
////    hAccuracy.text = String(format: "%.4f",
////                            latestLocation.horizontalAccuracy)
////    altitude.text = String(format: "%.4f",
////                           latestLocation.altitude)
////    vAccuracy.text = String(format: "%.4f",
////                            latestLocation.verticalAccuracy)
////
//    if startLocation == nil {
//      startLocation = latestLocation
//    }
//
//    let distanceBetween: CLLocationDistance =
//      latestLocation.distance(from: startLocation)
//
// //   distance.text = String(format: "%.2f", distanceBetween)
//
//    let dateFormatter = DateFormatter()
//    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssSSSSSS"
//    dateFormatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
//
//    dateFormatter.timeZone = NSTimeZone.local
//    let timeStamp = dateFormatter.string(from: latestLocation.timestamp)
//   // print("latestLocation.timestamp", latestLocation.timestamp)
//   // print("Local time",timeStamp)
//    print(latestLocation)
//
//    let dataToWrite = "timestamp:\(timeStamp)" +
//      ",latitude:\(latestLocation.coordinate.latitude)" +
//      ",longitude:\(latestLocation.coordinate.longitude)" +
//      ",altitude:\(latestLocation.altitude)" +
//      ",horizontalAccuracy:\(latestLocation.horizontalAccuracy)" +
//      ",verticalAccuracy:\(latestLocation.verticalAccuracy)" +
//      ",course:\(latestLocation.course)" +
//      ",speed:\(latestLocation.speed)" + "\n"
//
//    let data = dataToWrite.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
//    writeToFile(data!, Int32(dataToWrite.lengthOfBytes(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))))
//
//    //        let formatter = DateFormatter()
//    //        formatter.dateStyle = .short
//    //        formatter.timeStyle = .medium
//    //
//    //        let l = locations.first!
//    //
//    //        textView.text = "\(textView.text!)\r \(formatter.string(from: Date())) loc: \(l.coordinate.latitude), \(l.coordinate.longitude)"
//    //
//    //
//    //
//    //        let latestLocation = locations[locations.count - 1]
//    //
//    //        let dateFormatter = DateFormatter()
//    //        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//    //        dateFormatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
//    //
//    //        // let ss = dateFormatter.string(from: latestLocation.timestamp)
//    //
//    //        // let date = dateFormatter.date(from: "2015-04-01 12:00:00")
//    //        // print("UTC time",date!)
//    //
//    //        dateFormatter.timeZone = NSTimeZone.local
//    //        let timeStamp = dateFormatter.string(from: latestLocation.timestamp)
//    //
//    //        print("Local time",timeStamp)
//    //
//    //
//    //        let dataToWrite = "timestamp:\(timeStamp)" +
//    //            ",latitude:\(latestLocation.coordinate.latitude)" +
//    //            ",longitude:\(latestLocation.coordinate.longitude)" +
//    //            ",altitude:\(latestLocation.altitude)" +
//    //            ",horizontalAccuracy:\(latestLocation.horizontalAccuracy)" +
//    //            ",verticalAccuracy:\(latestLocation.verticalAccuracy)" +
//    //            ",course:\(latestLocation.course)" +
//    //            ",speed:\(latestLocation.speed)" + "\n"
//    //
//    //        let data = dataToWrite.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
//    //        writeToFile(data!, Int32(dataToWrite.lengthOfBytes(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))))
//    //
//
//
//  }
//
//
//  func scheduledLocationManager(_ manager: APScheduledLocationManager, didFailWithError error: Error) {
//
//  }
//
//  func scheduledLocationManager(_ manager: APScheduledLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//
// }


  
  
  func writeToFile(_ dataToWrite: Data, _ len: Int32) {
    
    let dir: URL = URL(string: FileManager.documentDir())!
    
    let url = dir.appendingPathComponent("CLLocations.txt")
    
    do {
      if FileManager.default.fileExists(atPath: url.absoluteString) {
        //Append..
        let fileHandle:FileHandle = try FileHandle.init(forUpdating: url)
        fileHandle.seekToEndOfFile()
        fileHandle.write(dataToWrite as Data)
        fileHandle.closeFile()
      } else {
        //No seek, just write..
        let status = FileManager.default.createFile(atPath: url.absoluteString, contents: dataToWrite as Data, attributes: nil)
      }
    } catch {
      
    }
    
    
    
  }
}


extension FileManager {
  class func documentDir() -> String {
    return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
  }
  
}



// MARK: - CLLocationManagerDelegate
extension AppDelegate: CLLocationManagerDelegate {
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let mostRecentLocation = locations.last else {
      return
    }
    
//    // Add another annotation to the map.
//    let annotation = MKPointAnnotation()
//    annotation.coordinate = mostRecentLocation.coordinate
//
//    // Also add to our map so we can remove old values later
//    self.locations.append(annotation)
//
//    // Remove values if the array is too big
//    while locations.count > 100 {
//      let annotationToRemove = self.locations.first!
//      self.locations.remove(at: 0)
//
//      // Also remove from the map
//      mapView.removeAnnotation(annotationToRemove)
//    }
//
    if UIApplication.shared.applicationState == .active {
      print("App is in foreground. New location is %@", mostRecentLocation)
      //mapView.showAnnotations(self.locations, animated: true)
    } else {
      print("App is backgrounded. New location is %@", mostRecentLocation)
   }
  }
  
}

