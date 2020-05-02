import UIKit
import CloudKit

class ViewController: UIViewController {
    
    @IBOutlet weak var inputId: UITextField!
    @IBOutlet weak var inputPassword: UITextField!
    @IBOutlet weak var loginObject: UIButton!
    
    var users : [CKRecord]? = []
    
    
    @IBAction func loginAction(_ sender: Any) {
        let container = CKContainer.default()
        let privateDatabase = container.privateCloudDatabase
        let myPredicate = NSPredicate(format: "self contains %@", inputId.text ?? "null")
        let myQuery = CKQuery(recordType: "AppUsers", predicate: myPredicate)
        privateDatabase.perform(myQuery, inZoneWith: nil) { (results, error) ->
            Void in
            if error != nil{
                print(error!)
            } else {
                OperationQueue.main.addOperation({ () -> Void in
                    self.users = results
                    self.checkLogin()
                })
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func checkLogin() {
        if(self.users!.count < 1) {
            self.loginFail()
        } else {
            let firstRecord = self.users?[0]
            if(firstRecord?.value(forKey: "password") as? String == self.inputPassword.text) {
                self.loginSuccess(ckUser: firstRecord!)
            } else {
                self.loginFail()
            }
        }
    }
    
    func loginSuccess(ckUser: CKRecord) {
        let successSegueWay =  self.storyboard?.instantiateViewController(withIdentifier: "HomeView") as! HomeViewController
        let name = ckUser.value(forKey: "name") ?? ""
        let id = ckUser.value(forKey: "id") ?? ""
        let latitude = ckUser.value(forKey: "latitude")  ?? ""
        let longtitude = ckUser.value(forKey: "longtitude")  ?? ""
        let currentUser: AppUser = AppUser(name: "\(name)", id: "\(id)", latitude: "\(latitude)", longtitude: "\(longtitude)")
        successSegueWay.currentUser = currentUser
        successSegueWay.modalPresentationStyle = .fullScreen
        self.present(successSegueWay, animated: true, completion: nil)
    }
    
    func loginFail() {
        print("Error to Login")
        let alertBox = UIAlertController(title: "Error", message: "Wrong username and password", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertBox.addAction(okButton)
        self.present(alertBox, animated: true, completion: nil)
    }
    
}

