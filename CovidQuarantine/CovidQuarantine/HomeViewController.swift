//
//  HomeViewController.swift
//  CovidQuarantine
//
//  Created by Student07 on 2/5/2563 BE.
//  Copyright © 2563 MO IO. All rights reserved.
//

import UIKit
import LocalAuthentication
import CloudKit
import CoreLocation

class HomeViewController: UIViewController, CLLocationManagerDelegate {
    
    var currentUser: AppUser = AppUser(name: "", id: "", latitude: "", longtitude: "")
    let today: Date = Date()
    let locationManager = CLLocationManager()
    var latitude: String = ""
    var longtitude: String = ""
    var horizontalAccuracy: Double = 50.0
    @IBOutlet weak var welcomeMessage: UILabel!
    @IBOutlet weak var todayDate: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        welcomeMessage.text = "Hi, \(currentUser.name)"
        todayDate.text = "\(self.today.asString(style: .full))"
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestLocation()
    }
    
    @IBAction func acionCheckIn(_ sender: Any) {
        self.biometricAuth()
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        self.signOutMethod()
    }
    
    @objc func signOutMethod(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func biometricAuth() -> Void {
        let context = LAContext()
        var error : NSError?
        if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Please Check Permission Again", reply: {(success, authenticateError) in
                if authenticateError != nil {
                    self.authenticateFail(message: "Not Match, Please Try Again")
                } else {
                    OperationQueue.main.addOperation {
                        self.authenticateSuccess()
                    }
                }
            })
        } else {
            self.authenticateFail(message: "Permission Error")
        }
    }
    
    func authenticateSuccess() {
        let id = currentUser.id.trimmingCharacters(in: .whitespaces)
        let lat = (latitude).trimmingCharacters(in: .whitespaces)
        let long = (longtitude).trimmingCharacters(in: .whitespaces)
        if(!id.isEmpty && !lat.isEmpty && !long.isEmpty) {
            let myTimeStamp = String(format:"%f", NSDate.timeIntervalSinceReferenceDate)
            let timeStampParts = myTimeStamp.components(separatedBy: ".")
            let recordID = CKRecord.ID(recordName: timeStampParts[0])
            let recordObject = CKRecord(recordType: "CheckIns", recordID: recordID)
            recordObject.setObject(id as CKRecordValue, forKey: "id")
            recordObject.setObject(lat as CKRecordValue, forKey: "latitude")
            recordObject.setObject(long as CKRecordValue, forKey: "longtitude")
            let container = CKContainer.default()
            let privateDatabase = container.privateCloudDatabase
            privateDatabase.save(recordObject, completionHandler: { (myRecord, error) -> Void in
                if error != nil {
                    print(error!.localizedDescription)
                }
                OperationQueue.main.addOperation({ () -> Void in
                    self.navigationController?.popViewController(animated: true)
                })
            })
        }
        
    }
    
    func authenticateFail(message: String) {
        let alertController = UIAlertController(title: "Error", message: "No permission allowed for Face ID", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okButton)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let myError = error as! CLError
        let errorType = myError.code == CLError.denied ? "Access Denied" : "Error : \(myError.localizedDescription)"
        let alertController = UIAlertController(title: "Location Manager Error", message: errorType, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations[locations.count - 1]
        latitude = "\(newLocation.coordinate.latitude)"
        longtitude = "\(newLocation.coordinate.longitude)"
        horizontalAccuracy = newLocation.horizontalAccuracy
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print(status.rawValue)
    }
    
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        print("locationManagerDidResumeLocationUpdates")
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        print("locationManagerDidPauseLocationUpdates")
    }
    
    // TODO: Future Feature
    func checkToday() {
        let container = CKContainer.default()
        let privateDatabase = container.privateCloudDatabase
        let myPredicate = NSPredicate(format: "self contains %@", self.currentUser.id)
        let myQuery = CKQuery(recordType: "AppUsers", predicate: myPredicate)
        privateDatabase.perform(myQuery, inZoneWith: nil) { (results, error) ->
            Void in
            if error != nil{
                print(error!)
            } else {
                OperationQueue.main.addOperation({ () -> Void in
                    print(">>>>>>> Hay come here")
                    print(results!)
                })
            }
        }
    }
}

extension Date {
    func asString(style: DateFormatter.Style) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = style
        return dateFormatter.string(from: self)
    }
}
