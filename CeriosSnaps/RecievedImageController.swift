//
//  RecievedImageController.swift
//  CeriosSnaps
//
//  Created by Rey Cerio on 2017-02-05.
//  Copyright © 2017 CeriOS. All rights reserved.
//

import UIKit
import Firebase

class RecievedImageController: UIViewController {
    
    var timer: Timer?
    var messageArr = [Message]()
    var messageIdArr = [String]()
    var message: Message? {   //figure out a way to pass the messageId too so you can just straight delete instead of another reference here
        didSet{
            guard let imageName = message?.imageName else {return}
            navigationItem.title = message?.fromName
            imageView.loadImageWithUrl(imageUrlString: imageName)
        }
    }
    
    //lazy var to access self
    lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.layer.masksToBounds = true
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissController)))
        return iv
    
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(imageView)
        
        view.addConstraintsWithVisualFormat(format: "H:|[v0]|", views: imageView)
        view.addConstraintsWithVisualFormat(format: "V:|[v0]|", views: imageView)
        
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(dismissController), userInfo: nil, repeats: false)

    }

    func dismissController() {
        assigningSnapshotToMessageIdVarThenDelete()
        DispatchQueue.main.async { 
            self.dismiss(animated: true, completion: nil)

        }
    }
    
    func assigningSnapshotToMessageIdVarThenDelete(){
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {return}
        guard let messageId = self.message?.messageId else {return}
        FIRDatabase.database().reference().child("user_messages")
            .child(uid).child(messageId).removeValue()
        
    }

}
//    func observeThenDeleteCurrentShowedImageFromFIR() {
//        guard let uid = FIRAuth.auth()?.currentUser?.uid else {return}
//        let userRef = FIRDatabase.database().reference().child("user_messages").child(uid)
//        userRef.observe(.childAdded, with: { (snapshot) in
//            var deleteTimer = Timer()
//            deleteTimer.invalidate()
//            deleteTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: { (timer) in
//                
//                guard let messageId = self.message?.messageId else {return}
//                FIRDatabase.database().reference().child("user_messages")
//                    .child(uid).child(messageId).removeValue()
//
//            })
//            
//        }, withCancel: nil)
//    }
//    
//    func timerForDeletion() {
//        timer?.invalidate()
//        timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(assigningSnapshotToMessageIdVarThenDelete), userInfo: nil, repeats: false)
//    }
//    
//    
//    func handleDeleteMessageReference(messageIdArrIndex: String, uid: String){
//        FIRDatabase.database().reference().child("user_messages")
//            .child(uid).child(messageIdArrIndex).removeValue();
//        DispatchQueue.main.async {
//            self.dismiss(animated: true, completion: nil)
//            
//        }
//
//    }

//            let messageRef = FIRDatabase.database().reference().child("message").child("\(messageId)")
//            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
//
//                let dictionary = snapshot.value as! [String: Any]
//                let messageSnap = Message()
//                messageSnap.fromEmail = dictionary["fromEmail"] as? String
//                messageSnap.toEmail = dictionary["toEmail"] as? String
//                messageSnap.imageName = dictionary["imageStringUrl"] as? String
//
//                self.messageArr.append(messageSnap)
//
//                var deleteTimer = Timer()
//                deleteTimer.invalidate()
//                deleteTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: { (timer) in
//                    messageRef.queryOrdered(byChild: messageId).queryEqual(toValue: self.messageArr[0]).observeSingleEvent(of: .value, with: { (snapshot) in
//                        snapshot.ref.removeValue(completionBlock: { (error, ref) in
//                            if error != nil {
//                                print("Could not remove value: ", error ?? "error unknows")
//                                return
//                            }
//                        })
//
//                    }, withCancel: nil)
//
//                })
//
//
//            }, withCancel: nil)

//            self.handleDeleteMessageReference(userRef: userRef, messageId: messageId, messageIdArr: self.messageIdArr[0])

//            var deleteTimer = Timer()
//            deleteTimer.invalidate()
//            deleteTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: { (timer) in
//
//
//
//            })


//userRef.queryOrdered(byChild: "\(messageId)").queryEqual(toValue: "\(self.messageIdArr[0])").ref.removeValue()


//            userRef.queryOrdered(byChild: "\(messageId)").queryEqual(toValue: "\(self.messageIdArr[0])").observe(.childAdded, with: { (snapshot) in
//                snapshot.ref.removeValue(completionBlock: { (error, reference) in
//                    if error != nil {
//                        print("Could not remove reference: ", error ?? "error unknown")
//                        return
//                    }
//                })
//            }, withCancel: nil)

