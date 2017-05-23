//
//  ProfileHeaderView.swift
//  WOTS
//
//  Created by Michael-Anthony Doshi on 5/12/17.
//  Copyright © 2017 Learning Curve. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import AWSCognitoUserPoolsSignIn
import AWSS3

class ProfileHeaderView: UIView {
    
    // MARK: - Properties
    
    private lazy var profileImageView: UIImageView = {
        let profileImageView = UIImageView()
        profileImageView.image = UIImage(named: "defaultProfileImage")
        profileImageView.layer.cornerRadius = self.imageSize / 2
        profileImageView.layer.masksToBounds = true
        return profileImageView
    }()
    
    private lazy var userNameLabel: UILabel = {
        let userNameLabel = UILabel()
        userNameLabel.text = AWSCognitoUserPoolsSignInProvider.sharedInstance().getUserPool().currentUser()?.username
        userNameLabel.textColor = .white
        userNameLabel.textAlignment = .center
        return userNameLabel
    }()
    
    private lazy var addImageButton: UIButton = {
        let addImageButton = UIButton()
        addImageButton.setBackgroundImage(UIImage(named: "profile_plus"), for: .normal)
        addImageButton.addTarget(self, action: #selector(changeProfileImage), for: .touchUpInside)
        return addImageButton
    }()
    
    private let imageSize: CGFloat = 80.0
    private let margin: CGFloat = 20.0
    
    weak var delegate: ProfileHeaderDelegate?
    
    // MARK: - ProfileHeaderView
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.charcoal
        
        addSubview(profileImageView.usingAutolayout())
        addSubview(userNameLabel.usingAutolayout())
        addSubview(addImageButton.usingAutolayout())
        setupConstraints()
        downloadContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helper Methods
    
    private func setupConstraints() {
        
        // Profile Image View
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: margin),
            profileImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: imageSize),
            profileImageView.heightAnchor.constraint(equalTo: profileImageView.widthAnchor)
            ])
        
        // User Name Label
        NSLayoutConstraint.activate([
            userNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: margin),
            userNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -margin),
            userNameLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            userNameLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -margin)
            ])
        
        // Add Image Button
        NSLayoutConstraint.activate([
            addImageButton.centerXAnchor.constraint(equalTo: profileImageView.trailingAnchor),
            addImageButton.centerYAnchor.constraint(equalTo: profileImageView.topAnchor),
            addImageButton.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: -7.5),
            addImageButton.widthAnchor.constraint(equalToConstant: 16.0),
            addImageButton.heightAnchor.constraint(equalTo: addImageButton.widthAnchor)
            ])
    }
    
    func setProfileImage(_ newImage: UIImage) {
        profileImageView.image = newImage
    }
    
    // MARK: - Button Actions
    
    func changeProfileImage() {
        if let delegate = delegate {
            delegate.changeProfileImage()
        }
    }
    
    func completionHandler() -> AWSS3TransferUtilityDownloadCompletionHandlerBlock? {
        DispatchQueue.main.async {
            print("done")
        }
        return nil
        
    }
    
    fileprivate func downloadContent() {
        let transferManager = AWSS3TransferManager.default()

        let downloadingFileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("profile_pic.jpg")
        
        let downloadRequest = AWSS3TransferManagerDownloadRequest()
        
        downloadRequest?.bucket = "wordonthestreet-userdata-mobile-hub-915338963"
        downloadRequest?.key =  "\( (SessionManager.sharedInstance.userInfo?._userId!)! ).jpg"
        downloadRequest?.downloadingFileURL = downloadingFileURL
        
        transferManager.download(downloadRequest!).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask<AnyObject>) -> Any? in
            
            if let error = task.error as NSError? {
                if error.domain == AWSS3TransferManagerErrorDomain, let code = AWSS3TransferManagerErrorType(rawValue: error.code) {
                    switch code {
                    case .cancelled, .paused:
                        break
                    default:
                        print("Error downloading: \(String(describing: downloadRequest?.key)) Error: \(error)")
                    }
                } else {
                    print("Error downloading: \(String(describing: downloadRequest?.key)) Error: \(error)")
                }
                return nil
            }
            print("Download complete for: \(String(describing: downloadRequest?.key))")
            let _ = task.result
            
            if let data = NSData(contentsOf: downloadingFileURL) {
                let img = UIImage(data: data as Data)
                self.setProfileImage(img!)
            }
            return nil
        })
    }
}

protocol ProfileHeaderDelegate: class {
    func changeProfileImage()
}
