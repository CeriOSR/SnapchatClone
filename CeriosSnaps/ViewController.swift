//
//  ViewController.swift
//  CeriosSnaps
//
//  Created by Rey Cerio on 2017-02-02.
//  Copyright © 2017 CeriOS. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class MessageCollectionController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var timer: Timer?
    var messageArr = [Message]()
    var recievedImageController = RecievedImageController()
    private let cellId = "cellId"
    var user = [User]()   //array has to be constructed and not an optional else will return nil
    var currentUser = User()
    var recepient = User()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        self.collectionView?.register(UsersCell.self, forCellWithReuseIdentifier: cellId)
        fetchUsers()
        user = []
        checkIfUserExists()
        checkForMessages()
        
//        timer?.invalidate()
//        timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(checkForMessages), userInfo: nil, repeats: true)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(checkForMessages), userInfo: nil, repeats: true)

    }
        
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
            return user.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UsersCell
        let users = user[indexPath.item]
        
        cell.nameLabel.text = users.name
        cell.emailLabel.text = users.email
        
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        recepient = user[indexPath.item]
        print(recepient)
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self          //needs UINavigationControllerDelegate as class type also
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 100)
    }
    
    func fetchUsers() {
        
        user = []
        let ref = FIRDatabase.database().reference().child("users")
        ref.observe(.childAdded, with: { (snapshot) in
            
            let dictionary = snapshot.value as! [String: AnyObject]
            let users = User()
            users.email = dictionary["email"] as? String
            users.name = dictionary["name"] as? String
            users.id = dictionary["id"] as? String
            
            if users.id != FIRAuth.auth()?.currentUser?.uid {
                self.user.append(users)
            }
            
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
            
            
        }, withCancel: nil)
        
    }
    func checkIfUserExists() {
        if FIRAuth.auth()?.currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else {
            guard let uid = FIRAuth.auth()?.currentUser?.uid else {return}
            let ref = FIRDatabase.database().reference().child("users").child(uid)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: Any] {
                    
                    self.currentUser.id = FIRAuth.auth()?.currentUser?.uid
                    self.currentUser.email = dictionary["email"] as? String
                    self.currentUser.name = dictionary["name"] as? String
                    self.navigationItem.title = dictionary["name"] as? String
                }
                
            }, withCancel: nil)
        }

    }
    
    func checkForMessages() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {return}
        let userRef = FIRDatabase.database().reference().child("user_messages").child("\(uid)")
        userRef.observe(.childAdded, with: { (snapshot) in
            self.messageArr = []
            if snapshot.key != "" {
            
                let messageId = snapshot.key
                let messageRef = FIRDatabase.database().reference().child("message").child("\(messageId)")
                    messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        let dictionary = snapshot.value as! [String: Any]
                        let messageSnapshot = Message()
                        messageSnapshot.messageId = messageId
                        messageSnapshot.fromName = dictionary["senderName"] as? String
                        messageSnapshot.toEmail = dictionary["toEmail"] as? String
                        messageSnapshot.fromEmail = dictionary["fromEmail"] as? String
                        messageSnapshot.imageName = dictionary["imageStringUrl"] as? String
                        
                        self.messageArr.append(messageSnapshot)
                        
                    }, withCancel: nil)
                
                    self.assigningAndPresentingAtTheEnd()
            }
            
        }, withCancel: nil)
        
    }
    
    func assigningAndPresentingAtTheEnd() {
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(handlePresentController), userInfo: nil, repeats: false)
        
    }
    
    func handlePresentController() {
        self.recievedImageController.message = self.messageArr[0]
        let alertController = UIAlertController(title: "New Message", message: "You have a new message from: \(self.messageArr[0].fromName)", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
            let navController = UINavigationController(rootViewController: self.recievedImageController)
            self.present(navController, animated: true, completion: nil)
        }))
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func handleLogout() {
        
        do {
            try FIRAuth.auth()?.signOut()
        }catch let err {
            print(err)
        }
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        
        let loginController = LoginController()
        present(loginController, animated: true, completion: nil)
        
    }
    
    func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    
    //ImagePicker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var image = UIImage()
        if let imageEdited = info[UIImagePickerControllerOriginalImage] as? UIImage {
            image = imageEdited
        } else {
            print("something went wrong!")
        }
        let imagePost = image as UIImage
        
        if let uploadedImage = UIImageJPEGRepresentation(imagePost, 0.5) {
            
            let imageName = NSUUID().uuidString
            let ref = FIRStorage.storage().reference().child("sent_image").child("\(imageName)")
            ref.put(uploadedImage, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print("Could not save image: ", error ?? "")
                    return
                }
                
                guard let imageUrl = metadata?.downloadURL()?.absoluteString else {return}
                guard let senderName = self.currentUser.name else {return}
                guard let toId = self.recepient.id else {return}
                guard let fromId = self.currentUser.id else {return}
                
                let values = ["imageStringUrl": imageUrl, "toEmail": toId, "fromEmail": fromId, "senderName": senderName]
                let refDatabase = FIRDatabase.database().reference().child("message").childByAutoId()
                refDatabase.updateChildValues(values) { (error, reference) in
                    if error != nil {
                        print("Could not save message: ", error ?? "")
                        return
                    }
                    
                    let messageId = refDatabase.key
                    FIRDatabase.database().reference().child("user_messages").child("\(toId)").updateChildValues([messageId:1])
                    
                }
            
            })
            self.dismiss(animated: true, completion: nil)
            self.createAlert(title: "Message sent!", message: "Your message has been sent!")

        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
   
}




