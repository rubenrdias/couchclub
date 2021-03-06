//
//  CreateAccountVC.swift
//  CouchClub
//
//  Created by Ruben Dias on 13/05/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

class CreateAccountVC: UIViewController, Storyboarded {
    
    weak var coordinator: LoginCoordinator?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordHintlabel: UILabel!
    @IBOutlet weak var createAccountButton: RoundedButton!
    @IBOutlet weak var signInLabel: UILabel!
    @IBOutlet weak var signInButton: UIButton!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
    let emailRegex = NSRegularExpression("[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]")
    let passwordRegex = NSRegularExpression(".{6,50}")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) { isModalInPresentation = true }
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(editingFinished))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        setupLabels()
        setupTextFields()
        setupButtons()
    }
    
    deinit {
        print("-- DEINIT -- Create Account VC")
    }

    
    @IBAction func createAccountTapped(_ sender: Any) {
        if let errorMessage = validateForm() {
            let alert = Alerts.simpleAlert(title: errorMessage.0, message: errorMessage.1)
            present(alert, animated: true)
        } else {
			self.setLoadingState(true)
			
            let username = usernameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            DataCoordinator.shared.createUser(username, email, password) { [unowned self] (error) in
                if let error = error {
                    let alert = Alerts.simpleAlert(title: "Account creation failed", message: error.localizedDescription)
                    self.present(alert, animated: true)
                } else {
                    self.coordinator?.accountCreated()
                }
				
				self.setLoadingState(false)
            }
        }
    }
    
    @IBAction func signInTapped(_ sender: Any) {
        coordinator?.showLoginScreen()
    }
    
    @objc private func editingFinished() {
        view.endEditing(true)
    }
	
	private func setLoadingState(_ loading: Bool) {
		if loading {
			activityIndicator.startAnimating()
			createAccountButton.setTitle(nil, for: .normal)
			createAccountButton.isEnabled = false
		} else {
			activityIndicator.stopAnimating()
			createAccountButton.setTitle("Create Account", for: .normal)
			createAccountButton.isEnabled = true
		}
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
