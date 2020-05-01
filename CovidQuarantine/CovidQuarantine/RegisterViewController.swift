import UIKit
import CoreLocation
import CloudKit

class RegisterViewController: UIViewController, CLLocationManagerDelegate {
    
    
    @IBOutlet weak var fullName: UITextField!
    @IBOutlet weak var personId: UITextField!
    @IBOutlet weak var latitude: UILabel!
    @IBOutlet weak var longtitude: UILabel!
    @IBOutlet weak var registerBtnOutlet: UIButton!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    var horizontalAccuracy = 100.0
    
    let locationManager = CLLocationManager()
    
    @IBAction func getLocation(_ sender: Any) {
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func registerBtn(_ sender: Any) {
        registerBtnOutlet.isEnabled = false
        loading.isHidden = false
        let name = (fullName.text)!.trimmingCharacters(in: .whitespaces)
        let id = (personId.text)!.trimmingCharacters(in: .whitespaces)
        let lat = (latitude.text)!.trimmingCharacters(in: .whitespaces)
        let long = (longtitude.text)!.trimmingCharacters(in: .whitespaces)
        if (!name.isEmpty && !id.isEmpty && !lat.isEmpty && !long.isEmpty) {
            let myTimeStamp = String(format:"%f", NSDate.timeIntervalSinceReferenceDate)
            let timeStampParts = myTimeStamp.components(separatedBy: ".")
            let recordID = CKRecord.ID(recordName: timeStampParts[0])
            let recordObject = CKRecord(recordType: "AppUsers", recordID: recordID)
            recordObject.setObject(name as CKRecordValue, forKey: "name")
            recordObject.setObject(id as CKRecordValue, forKey: "id")
            recordObject.setObject(lat as CKRecordValue, forKey: "latitude")
            recordObject.setObject(long as CKRecordValue, forKey: "longtitude")
            recordObject.setObject(NSDate(), forKey: "registerDate")
            
            let container = CKContainer.default()
            let privateDatabase = container.privateCloudDatabase
            privateDatabase.save(recordObject, completionHandler: { (myRecord, error) -> Void in
                if error != nil {
                    print(error!.localizedDescription)
                }
                OperationQueue.main.addOperation({ () -> Void in
                    self.loading.isHidden = true
                    self.navigationController?.popViewController(animated: true)
                })
            })
        } else {
            let alertController = UIAlertController(title: "Error", message: "Please check your input again", preferredStyle: .alert)
            let OKButton = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(OKButton)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loading.isHidden = true
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
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
        print("\(newLocation.horizontalAccuracy)")
        latitude.text = "\(newLocation.coordinate.latitude)"
        longtitude.text = "\(newLocation.coordinate.longitude)"
        horizontalAccuracy = newLocation.horizontalAccuracy
    }
}
