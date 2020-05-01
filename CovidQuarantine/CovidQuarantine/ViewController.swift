//
//  ViewController.swift
//  CovidQuarantine
//
//  Created by Student07 on 1/5/2563 BE.
//  Copyright © 2563 MO IO. All rights reserved.
//

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
        let myPredicate = NSPredicate(format: "self contains \(inputId.text ?? "")")
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
        }
        let firstRecord = self.users?[0]
        if(firstRecord?.value(forKey: "password") as? String == self.inputPassword.text) {
            self.loginSuccess()
        } else {
            self.loginFail()
        }
    }
    
    func loginSuccess() {
        // Success
    }
    
    func loginFail() {
        // No Success
    }
    
}

