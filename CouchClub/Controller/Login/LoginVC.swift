//
//  LoginVC.swift
//  CouchClub
//
//  Created by Ruben Dias on 13/05/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var forgottenPasswordButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var createAccountLabel: UILabel!
    @IBOutlet weak var createAccountButton: UIButton!
    
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
        navigationController?.dismiss(animated: true, completion: nil)
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
    
}
