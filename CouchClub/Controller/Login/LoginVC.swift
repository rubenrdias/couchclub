//
//  LoginVC.swift
//  CouchClub
//
//  Created by Ruben Dias on 13/05/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginVC: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var forgottenPasswordButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var createAccountLabel: UILabel!
    @IBOutlet weak var createAccountButton: UIButton!
    
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
    
    @IBAction func forgottenPasswordTapped(_ sender: UIButton) {
    }
    
    @IBAction func signInTapped(_ sender: Any) {
        if let errorMessage = validateForm() {
            let alert = Alerts.simpleAlert(title: errorMessage.0, message: errorMessage.1)
            present(alert, animated: true, completion: nil)
        } else {
            // create user
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            Auth.auth().signIn(withEmail: email, password: password) { [unowned self] (result, error) in
                if let error = error {
                    // TODO: handle error
                    print("Firebase Auth | Error creating user: \(error.localizedDescription)")
                } else {
                    self.navigationController?.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func createAccountTapped(_ sender: Any) {
        performSegue(withIdentifier: "CreateAccountVC", sender: nil)
    }
    
    private func setupLabels() {
        titleLabel.text = "Sign In"
        titleLabel.font = .translatedFont(for: .largeTitle, .semibold)
        titleLabel.textColor = .colorAsset(.dynamicLabel)
        
        subtitleLabel.text = "Welcome back!\n" + "Sign in to see your movies and shows"
        subtitleLabel.font = .translatedFont(for: .body, .regular)
        subtitleLabel.textColor = .colorAsset(.dynamicLabelSecondary)
        
        createAccountLabel.text = "Don't have an account?"
        createAccountLabel.font = .translatedFont(for: .subheadline, .regular)
        createAccountLabel.textColor = .colorAsset(.dynamicLabelSecondary)
    }
    
    private func setupTextFields() {
        emailTextField.font = .translatedFont(for: .body, .regular)
        passwordTextField.font = .translatedFont(for: .body, .regular)
    }
    
    private func setupButtons() {
        signInButton.makeCTA()
        forgottenPasswordButton.titleLabel?.font = .translatedFont(for: .footnote, .semibold)
        createAccountButton.titleLabel?.font = .translatedFont(for: .subheadline, .bold)
    }
    
    private func validateForm() -> (String, String)? {
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
