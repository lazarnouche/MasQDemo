//
//  ViewController+UI.swift


import UIKit
import FBSDKLoginKit
import ProgressHUD
import Firebase
import GoogleSignIn

extension ViewController: GIDSignInDelegate, GIDSignInUIDelegate {
    
    func setupHeaderTitle() {
        let title = "Create a new account"
        let subTitle = "\n\nLorem ipsum dolor sit amet conse ctetur adipisicing elit sed do."
        
        let attributedText = NSMutableAttributedString(string: title, attributes: [NSAttributedString.Key.font : UIFont.init(name: "Didot", size: 28)!,
                                                                                   NSAttributedString.Key.foregroundColor : UIColor.black                                                                      ])
        let attributedSubTitle = NSMutableAttributedString(string: subTitle, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16),
                                                                                          NSAttributedString.Key.foregroundColor : UIColor(white: 0, alpha: 0.45)                                                                      ])
        attributedText.append(attributedSubTitle)
        
        
        let paragrapStyle = NSMutableParagraphStyle()
        paragrapStyle.lineSpacing = 5
        
        attributedText.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragrapStyle, range: NSMakeRange(0, attributedText.length))
        titleLabel.numberOfLines = 0
        
        titleLabel.attributedText = attributedText
    }
    
    func setupOrLabel() {
        
        orLabel.text = "Or"
        orLabel.font = UIFont.boldSystemFont(ofSize: 16)
        orLabel.textColor = UIColor(white: 0, alpha: 0.45)
        orLabel.textAlignment = .center
    }
    
    func setupFacebookButton() {
        
        signInFacebookButton.setTitle("Sign in with Facebook", for: UIControl.State.normal)
        signInFacebookButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        signInFacebookButton.backgroundColor = UIColor(red: 58/255, green: 85/255, blue: 159/255, alpha: 1)
        signInFacebookButton.layer.cornerRadius = 5
        signInFacebookButton.clipsToBounds = true
        
        signInFacebookButton.setImage(UIImage(named: "icon-facebook") , for: UIControl.State.normal)
        signInFacebookButton.imageView?.contentMode = .scaleAspectFit
        signInFacebookButton.tintColor = .white
        signInFacebookButton.imageEdgeInsets = UIEdgeInsets(top: 12, left: -15, bottom: 12, right: 0)
        
        signInFacebookButton.addTarget(self, action: #selector(fbButtonDidTap), for: UIControl.Event.touchUpInside)
        
        
    }
    
    @objc func fbButtonDidTap() {
        let fbLoginManager = LoginManager()
        fbLoginManager
//        fbLoginManager.logIn(permissions: ["public_profile", "email"], from: self) { (result, error) in
//            
//        }
        
        
        fbLoginManager.logIn(permissions: ["public_profile", "email"], from: self) { (result, error) in
            if let error = error {
                ProgressHUD.showError(error.localizedDescription)
                return
            }
            
            guard let accessToken = AccessToken.current else {
                ProgressHUD.showError("Failed to get access token")
                return
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            Auth.auth().signInAndRetrieveData(with: credential, completion: { (result, error) in
                if let error = error {
                    ProgressHUD.showError(error.localizedDescription)
                    return
                }
                
                if let authData = result {
                self.handleFbGoogleLogic(authData: authData)
                }
            })
        }
    }
    
    func setupGoogleButton() {
        
        signInGoogleButton.setTitle("Sign in with Google", for: UIControl.State.normal)
        signInGoogleButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        signInGoogleButton.backgroundColor = UIColor(red: 223/255, green: 74/255, blue: 50/255, alpha: 1)
        signInGoogleButton.layer.cornerRadius = 5
        signInGoogleButton.clipsToBounds = true
        
        signInGoogleButton.setImage(UIImage(named: "icon-google") , for: UIControl.State.normal)
        signInGoogleButton.imageView?.contentMode = .scaleAspectFit
        signInGoogleButton.tintColor = .white
        signInGoogleButton.imageEdgeInsets = UIEdgeInsets(top: 12, left: -35, bottom: 12, right: 0)
        
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.uiDelegate = self
        
         signInGoogleButton.addTarget(self, action: #selector(googleButtonDidTap), for: UIControl.Event.touchUpInside)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil {
            return
        }
        guard let authentication = user.authentication else {
            return
        }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        Auth.auth().signInAndRetrieveData(with: credential) { (result, error) in
            if let error = error {
                ProgressHUD.showError(error.localizedDescription)
                return
            }
            
            if let authData = result {
            self.handleFbGoogleLogic(authData: authData)
            }
        }
    }
    
    func handleFbGoogleLogic(authData: AuthDataResult) {
        let dict: Dictionary<String, Any> =  [
            UID: authData.user.uid,
            EMAIL: authData.user.email,
            USERNAME: authData.user.displayName,
            PROFILE_IMAGE_URL: (authData.user.photoURL == nil) ? "" : authData.user.photoURL!.absoluteString,
            STATUS: "Welcome to MasQ"
        ]
        Ref().databaseSpecificUser(uid: authData.user.uid).updateChildValues(dict, withCompletionBlock: { (error, ref) in
            if error == nil {
                Api.User.isOnline(bool: true)
                (UIApplication.shared.delegate as! AppDelegate).configureInitialViewController()
                
            } else {
                ProgressHUD.showError(error!.localizedDescription)
            }
        })
        
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        ProgressHUD.showError(error!.localizedDescription)
    }
    
    @objc func googleButtonDidTap() {
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    func setupTermsLabel() {
        
        let attributedTermsText = NSMutableAttributedString(string: "By clicking “Create a new account” you agree to our ", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14),
                                                                                                                                             NSAttributedString.Key.foregroundColor : UIColor(white: 0, alpha: 0.65)                                                                      ])
        let attributedSubTermsText = NSMutableAttributedString(string: "Terms of Service.", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14),
                                                                                                         NSAttributedString.Key.foregroundColor : UIColor(white: 0, alpha: 0.65)                                                                      ])
        attributedTermsText.append(attributedSubTermsText)
        
        termsOfServiceLabel.attributedText = attributedTermsText
        termsOfServiceLabel.numberOfLines = 0
    
    }

    
    func setupCreateAccountButton() {
        
        createAccountButton.setTitle("Create a new account", for: UIControl.State.normal)
        createAccountButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        createAccountButton.backgroundColor = UIColor.black
        createAccountButton.layer.cornerRadius = 5
        createAccountButton.clipsToBounds = true
        
    }
    
    
    
}
