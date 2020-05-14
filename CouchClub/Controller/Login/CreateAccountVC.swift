//
//  CreateAccountVC.swift
//  CouchClub
//
//  Created by Ruben Dias on 13/05/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class CreateAccountVC: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordHintlabel: UILabel!
    @IBOutlet weak var createAccountButton: RoundedButton!
    @IBOutlet weak var signInLabel: UILabel!
    @IBOutlet weak var signInButton: UIButton!
    
    let emailRegex = NSRegularExpression("[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]")
    let passwordRegex = NSRegularExpression(".{6,50}")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) { isModalInPresentation = true }
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        setupLabels()
        setupTextFields()
        setupButtons()
    }
    
    @IBAction func createAccountTapped(_ sender: Any) {
        if let errorMessage = validateForm() {
            let alert = Alerts.simpleAlert(title: errorMessage.0, message: errorMessage.1)
            present(alert, animated: true, completion: nil)
        } else {
            // create user
            let username = usernameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            print("Should create user: \(username) | \(email) | \(password)")
            
            Auth.auth().createUser(withEmail: email, password: password) { [unowned self] (result, error) in
                if let error = error {
                    // TODO: handle error
                    print("Firebase Auth | Error creating user: \(error.localizedDescription)")
                } else {
                    Firestore.firestore().collection("users").addDocument(data: [
                        "uid": result!.user.uid,
                        "username": username
                    ]) { (error) in
                        if let error = error {
                            // TODO: handle error
                            print("Firebase Firestore | Error creating user data: \(error.localizedDescription)")
                        } else {
                            self.navigationController?.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func signInTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    private func setupLabels() {
        titleLabel.text = "Create Account"
        titleLabel.font = .translatedFont(for: .largeTitle, .semibold)
        titleLabel.textColor = .colorAsset(.dynamicLabel)
        
        subtitleLabel.text = "Sign up to track movies and shows, and chat with friends about them!"
        subtitleLabel.font = .translatedFont(for: .body, .regular)
        subtitleLabel.textColor = .colorAsset(.dynamicLabelSecondary)
        
        passwordHintlabel.text = "Passwords must contain between 6-50 characters"
        passwordHintlabel.font = .translatedFont(for: .footnote, .regular)
        passwordHintlabel.textColor = .colorAsset(.dynamicTertiary)
        
        signInLabel.text = "Already have an account?"
        signInLabel.font = .translatedFont(for: .subheadline, .regular)
        signInLabel.textColor = .colorAsset(.dynamicLabelSecondary)
    }
    
    private func setupTextFields() {
        usernameTextField.font = .translatedFont(for: .body, .regular)
        emailTextField.font = .translatedFont(for: .body, .regular)
        passwordTextField.font = .translatedFont(for: .body, .regular)
    }
    
    private func setupButtons() {
        createAccountButton.makeCTA()
        signInButton.titleLabel?.font = .translatedFont(for: .subheadline, .bold)
    }
    
    private func validateForm() -> (String, String)? {
        guard let username = usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !username.isEmpty else { return ("Missing username", "Please make sure to enter a username.") }
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !email.isEmpty else { return ("Missing email", "Please make sure to enter an email.") }
        guard let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !password.isEmpty else { return ("Missing password", "Please make sure to enter a password.") }
        
        if !emailRegex.matches(email) {
            return ("Invalid email", "Please check this field and try again.")
        }
        
        if !passwordRegex.matches(password) {
            return ("Invalid password", "Passwords must have between 6-50 characters.")
        }
        
        return nil
    }
    
}
