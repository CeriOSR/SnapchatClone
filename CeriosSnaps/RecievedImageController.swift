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
    
    override func viewDidAppear(_ animated: Bool) {
        
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

