//
//  SignInViewController.swift
//  MySampleApp
//
//
// Copyright 2017 Amazon.com, Inc. or its affiliates (Amazon). All Rights Reserved.
//
// Code generated by AWS Mobile Hub. Amazon gives unlimited permission to 
// copy, distribute and modify it.
//
// Source code generated from template: aws-my-sample-app-ios-swift v0.15
//
//

import UIKit
import AWSMobileHubHelper
import Flurry_iOS_SDK

let backgroundImageColor =  UIColor(red: 40/255, green: 40/255, blue: 40/255, alpha: 1)

class SignInViewController : UIViewController {
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var logoView: UIImageView!
    @IBOutlet weak var tableFormView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var googleButton: UIButton!
    
    @IBOutlet weak var logoViewHeight: NSLayoutConstraint!
    @IBOutlet weak var orSignInWithLabel: UILabel!
    
    var canCancel : Bool = true
    var didCompleteSignIn: ((_ success: Bool) -> Void)? = nil
    var passwordRow : FormTableCell?
    var userNameRow : FormTableCell?
    var tableDelegate : FormTableDelegate?
    var passwordAuthenticationCompletion: AWSTaskCompletionSource<AnyObject>?
    let bigLogoName = "logo_transparentbg"
    let smallLogoName = "logo-wots-big"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set up the navigation controller
        self.setUpNavigationController()
        // set up the logo in image view
        self.setUpLogo()
        // set up username and password UI if user pools enabled
        self.setUpUserPoolsUI()
        // set up background
        self.setUpBackground()
        // set up facebook button if enabled
        self.setUpFacebookButton()
        // set up google button if enabled
        self.setUpGoogleButton()
        self.hideKeyboardWhenTappedAround()

    }
    
    func setUpUserPoolsUI() {
        passwordRow = FormTableCell(placeHolder: "Password", type: InputType.password)
        userNameRow = FormTableCell(placeHolder: "User Name", type: InputType.text)
        tableDelegate = FormTableDelegate()
        tableDelegate?.add(cell: userNameRow!)
        tableDelegate?.add(cell: passwordRow!)
        tableView?.delegate = tableDelegate
        tableView?.dataSource = tableDelegate
        tableView.reloadData()
        UserPoolsUIHelper.setUpFormShadow(view: tableFormView)
        self.setUpResponders()
        orSignInWithLabel.removeFromSuperview()
    }
    
    func setUpLogo() {
        logoView.contentMode = UIViewContentMode.center
        logoView.image = UIImage(imageLiteralResourceName: bigLogoName)
        logoViewHeight.constant = 200
        logoView.setNeedsLayout()
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
    func setUpBackground() {
        self.view.backgroundColor = UIColor.white
        let backgroundImageView = UIImageView(frame: CGRect(x: 0, y:0, width: self.view.frame.width, height: self.tableFormView.center.y))
            backgroundImageView.backgroundColor = backgroundImageColor
        backgroundImageView.autoresizingMask = UIViewAutoresizing.flexibleWidth
        self.view.insertSubview(backgroundImageView, at: 0)
    }
    
    func setUpFacebookButton() {
        // Hide facebook button
        facebookButton.removeFromSuperview()
    }
    
    func setUpGoogleButton() {
        // Hide google button
        googleButton.removeFromSuperview()
    }
    
    func setUpNavigationController() {
        // set up title bar
        self.navigationController?.navigationBar.topItem?.title = "Sign In"
        // allow user to cancel sign in flow if sign in not mandatory
        if (self.canCancel) {
            let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(barButtonClosePressed))
            cancelButton.tintColor = UIColor.white
            self.navigationController?.navigationBar.topItem?.leftBarButtonItem = cancelButton;
        }
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.white,
        ]
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.darkGray
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    func barButtonClosePressed() {
        self.dismiss(animated: true, completion: nil)
        if let didCompleteSignIn = self.didCompleteSignIn {
            didCompleteSignIn(false)
        }
    }
    
    func handleLoginWithSignInProvider(_ signInProvider: AWSSignInProvider) {
        self.activityIndicatorView.startAnimating()
        AWSSignInManager.sharedInstance().login(signInProviderKey: signInProvider.identityProviderName, completionHandler: {(result: Any?, authState: AWSIdentityManagerAuthState, error: Error?) in
            print("result = \(result), error = \(error)")
            // If no error reported by SignInProvider, discard the sign-in view controller.
            if error == nil {
                DispatchQueue.main.async(execute: {
                    self.transition()
                    
                    // Instrumentation: time user session
                    Flurry.logEvent("User_Session", timed: true)
                    
                    self.activityIndicatorView.stopAnimating()
                    if let didCompleteSignIn = self.didCompleteSignIn {
                        didCompleteSignIn(true)
                    }
                })   
                return
            }
            self.showErrorDialog(signInProvider.identityProviderName, withError: error as! NSError)
        })
    }
    
    func transition(){
        let session = SessionManager.sharedInstance
        session.getUserData { (info) in
            if(info == nil){
                session.saveUserInfo()
            }
        }
        
        performSegue(withIdentifier: "toMainTabView", sender: self)
        
    }
    
    func showErrorDialog(_ loginProviderName: String, withError error: NSError) {
        print("\(loginProviderName) failed to sign in w/ error: \(error)")
        let alertController = UIAlertController(title: NSLocalizedString("Sign-in Provider Sign-In Error", comment: "Sign-in error for sign-in failure."), message: NSLocalizedString("\(loginProviderName) failed to sign in w/ error: \(error)", comment: "Sign-in message structure for sign-in failure."), preferredStyle: .alert)
        let doneAction = UIAlertAction(title: NSLocalizedString("Ok", comment: "Label to cancel sign-in failure."), style: .cancel, handler: nil)
        alertController.addAction(doneAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func setUpResponders() {
        signUpButton.addTarget(self, action: #selector(handleUserPoolSignUp), for: .touchUpInside)
        signInButton.addTarget(self, action: #selector(handleUserPoolSignIn), for: .touchUpInside)
        forgotPasswordButton.addTarget(self, action: #selector(handleUserPoolForgotPassword), for: .touchUpInside)
    }
}
