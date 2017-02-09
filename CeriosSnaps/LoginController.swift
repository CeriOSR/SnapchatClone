//
//  LoginController.swift
//  CeriosSnaps
//
//  Created by Rey Cerio on 2017-02-02.
//  Copyright © 2017 CeriOS. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase

class LoginController: UIViewController, FBSDKLoginButtonDelegate {
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        navigationController?.isNavigationBarHidden = true
        view.backgroundColor = .white
        
    }
    
    let nameField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "enter name"
        return tf
    }()
    
    let emailField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "enter email"
        return tf
    }()
    
    lazy var dummyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("dummy Register", for: .normal)
        button.addTarget(self, action: #selector(handleDummyRegister), for: .touchUpInside)
        return button
    }()
    
    lazy var dummyLogin: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("dummy login", for: .normal)
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()


    
    func setupViews() {
        
        let loginButton = FBSDKLoginButton()
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.delegate = self
        loginButton.readPermissions = ["email", "public_profile", "user_friends"]
        view.addSubview(loginButton)
        view.addSubview(nameField)
        view.addSubview(emailField)
        view.addSubview(dummyButton)
        view.addSubview(dummyLogin)
        
        //loginButton.frame = CGRect(x: -100, y: view.frame.midY, width: view.frame.width - 100, height: 50)
        
        //ios 9 constraints x, y, w, h
        loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loginButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -100.0).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        //constraints with visuals
        view.addConstraintsWithVisualFormat(format: "H:|-50-[v0]-50-|", views: nameField)
        view.addConstraintsWithVisualFormat(format: "H:|-50-[v0]-50-|", views: emailField)
        view.addConstraintsWithVisualFormat(format: "H:|-50-[v0]-50-|", views: dummyButton)
        view.addConstraintsWithVisualFormat(format: "H:|-50-[v0]-50-|", views: dummyLogin)

        view.addConstraintsWithVisualFormat(format: "V:|-50-[v0(50)]-6-[v1(50)]-6-[v2(50)]-6-[v3(50)]", views: nameField, emailField, dummyButton, dummyLogin)


    }
    
    func handleDummyRegister() {
        
        FIRAuth.auth()?.createUser(withEmail: emailField.text!, password: "qqqqqq", completion: { (user, error) in
            if error != nil {
                print(error!)
            }
            let uid = FIRAuth.auth()?.currentUser?.uid
            let values = ["email": self.emailField.text, "name": self.nameField.text, "id": uid]
            self.handlePutUserInDatabaseWithUid(values: values as! [String : String])
            self.dismiss(animated: true, completion: nil)

        })
        
        
    }
    
    func handlePutUserInDatabaseWithUid(values: [String: String]) {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {return}
        let ref = FIRDatabase.database().reference().child("users").child(uid)
        ref.updateChildValues(values)
        
    }
    
    func handleLogin() {
        FIRAuth.auth()?.signIn(withEmail: emailField.text!, password: "qqqqqq", completion: { (user, error) in
            if error != nil {
                print("Could not log in: ", error ?? "unknown error")
                return
            }
            self.dismiss(animated: true, completion: nil)
        })
    }

    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if error != nil {
            print(error)
            return
        }
        
        guard let accessToken = FBSDKAccessToken.current() else {return}
        
        let fbCredentials = FIRFacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
        
        FIRAuth.auth()?.signIn(with: fbCredentials, completion: { (user, error) in
            if error != nil {
                return
            }
            
        })
        
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "email, id, name"]).start { (connection, result, error) in
            if error != nil {
                print(error ?? "")
                return
            }
            
            if let userDetails = result as! [String: String]?{
                guard let fbEmail = userDetails["email"] else {return}
                guard let fbName = userDetails["name"] else {return}
                guard let fbId = userDetails["id"] else {return}
                let values = ["email": fbEmail, "name": fbName, "id": fbId]
                
                self.handlePutUserInDatabaseWithUid(values: values)

            }
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }


    
}
