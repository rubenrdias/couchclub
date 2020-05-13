//
//  CreateAccountVC.swift
//  CouchClub
//
//  Created by Ruben Dias on 13/05/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) { isModalInPresentation = true }
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        setupLabels()
        setupTextFields()
        setupButtons()
    }
    
    @IBAction func createAccountTapped(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
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
    
}
