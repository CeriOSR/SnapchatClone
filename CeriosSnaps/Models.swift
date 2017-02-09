//
//  Models.swift
//  CeriosSnaps
//
//  Created by Rey Cerio on 2017-02-05.
//  Copyright © 2017 CeriOS. All rights reserved.
//

import UIKit

class User: NSObject {
    var email: String?
    var name: String?
    var id: String?
}

class Message: NSObject {
    var messageId: String?
    var imageName: String?
    var fromName: String?
    var fromEmail: String?
    var toEmail: String?
}

class BaseCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        
    }
}

class UsersCell: BaseCell {
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let emailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func setupView(){
        super.setupView()
        
        addSubview(nameLabel)
        addSubview(emailLabel)
        
        addConstraintsWithVisualFormat(format: "H:|-8-[v0]-8-|", views: nameLabel)
        addConstraintsWithVisualFormat(format: "H:|-8-[v0]-8-|", views: emailLabel)
        
        addConstraintsWithVisualFormat(format: "V:|-10-[v0(30)][v1(25)]-10-|", views: nameLabel, emailLabel)
        
    }
}

