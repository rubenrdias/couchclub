//
//  Alerts.swift
//  CouchClub
//
//  Created by Ruben Dias on 30/04/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

class Alerts {
    
    static var shared = Alerts()
    
    private init() {}
    
    private var isPresenting = false
    
    private var activityIndicatorContentView: UIView?
    private var activityIndicatorBackgroundView: BlurredView?
    private var activityIndicatorStackView: UIStackView?
    private var activityIndicatorTitleLabel: UILabel?
    private var activityIndicatorSubtitleLabel: UILabel?
    private var activityIndicatorButton: UIButton?
    private var activityIndicatorButtonAction: (() -> Void)?
    private var activityIndicatorDismissAction: (() -> Void)?
    private var activityIndicatorSpinner: UIActivityIndicatorView?
    private var activityDismissGesture: UITapGestureRecognizer?
    
    private var keyWindow: UIWindow {
        UIApplication.shared.windows.filter{$0.isKeyWindow}.first!
    }
    
    static func simpleAlert(title: String?, message: String?, action: ((UIAlertAction) -> Void)? = nil) -> UIAlertController {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.view.tintColor = .colorAsset(.dynamicLabel)
        
        ac.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: action))
        
        return ac
    }
    
    static func deletionAlert(title: String?, message: String?, action: ((UIAlertAction) -> Void)?) -> UIAlertController {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.view.tintColor = .colorAsset(.dynamicLabel)
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        ac.addAction(UIAlertAction(title: "Confirm", style: .destructive, handler: action))
        
        return ac
    }
    
    func presentInviteCodeShareDialog(_ inviteCode: String, action: (() -> Void)?, dismissAction:(() -> Void)?) {
        presentActivityAlert(title: inviteCode, subtitle: "Share this invite code with your friends, they can join by tapping the '+' or the 'New Chatroom' buttons in the Chatrooms tab.", showSpinner: false, action: action, dismissAction: dismissAction)
    }
    
    func presentActivityAlert(title: String, subtitle: String?, showSpinner: Bool = true, action: (() -> Void)? = nil, dismissAction: (() -> Void)? = nil, completion: (() -> ())? = nil) {
        if isPresenting { return }
        
        DispatchQueue.main.async { [unowned self] in
            self.isPresenting = true
            
            // background view
            self.activityIndicatorBackgroundView = BlurredView()
            self.activityIndicatorBackgroundView?.translatesAutoresizingMaskIntoConstraints = false
            self.activityIndicatorBackgroundView?.alpha = 0
            self.activityIndicatorBackgroundView?.frame = self.keyWindow.frame
            
            // content view
            let width: CGFloat = 0.75 * UIScreen.main.bounds.width
            self.activityIndicatorContentView = UIView()
            self.activityIndicatorContentView?.translatesAutoresizingMaskIntoConstraints = false
            self.activityIndicatorContentView?.alpha = 0
            self.activityIndicatorContentView?.clipsToBounds = true
            self.activityIndicatorContentView?.layer.cornerRadius = 4
            self.activityIndicatorContentView?.backgroundColor = .colorAsset(.dynamicBackground)
            
            // constraints
            self.keyWindow.addSubview(self.activityIndicatorBackgroundView!)
            self.keyWindow.addSubview(self.activityIndicatorContentView!)
            NSLayoutConstraint.activate([
                self.activityIndicatorContentView!.widthAnchor.constraint(equalToConstant: width),
                self.activityIndicatorContentView!.centerXAnchor.constraint(equalTo: self.keyWindow.centerXAnchor),
                self.activityIndicatorContentView!.centerYAnchor.constraint(equalTo: self.keyWindow.centerYAnchor),
            ])
            
            // title
            self.activityIndicatorTitleLabel = UILabel.standardLabel(.body, .semibold, .colorAsset(.dynamicLabel))
            self.activityIndicatorTitleLabel?.text = title
            self.activityIndicatorTitleLabel?.numberOfLines = 0
            self.activityIndicatorTitleLabel?.textAlignment = .center
            
            // subtitle
            if subtitle != nil {
                self.activityIndicatorSubtitleLabel = UILabel.standardLabel(.footnote, .regular, .colorAsset(.dynamicLabelSecondary))
                self.activityIndicatorSubtitleLabel?.text = subtitle
                self.activityIndicatorSubtitleLabel?.numberOfLines = 0
                self.activityIndicatorSubtitleLabel?.textAlignment = .center
            }
            
            // button
            if action != nil {
                self.activityIndicatorButtonAction = action
                
                self.activityIndicatorButton = RoundedButton()
                self.activityIndicatorButton?.makeCTA(style: .primary)
                self.activityIndicatorButton?.contentEdgeInsets = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
                self.activityIndicatorButton?.setTitle("Copy to Clipboard", for: .normal)
                self.activityIndicatorButton?.addTarget(self, action: #selector(self.performButtonAction), for: .touchUpInside)
                
                if dismissAction != nil {
                    self.activityIndicatorDismissAction = dismissAction
                    
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissInstantly))
                    self.activityIndicatorBackgroundView?.addGestureRecognizer(tapGesture)
                    self.activityDismissGesture = tapGesture
                }
            }
            
            // spinner
            if showSpinner {
                self.activityIndicatorSpinner = UIActivityIndicatorView()
                self.activityIndicatorSpinner?.color = .colorAsset(.dynamicLabel)
                self.activityIndicatorSpinner?.startAnimating()
            }
            
            // stack view
            var subviews: [UIView] = [self.activityIndicatorTitleLabel!]
            if subtitle != nil { subviews.append(self.activityIndicatorSubtitleLabel!) }
            if action != nil { subviews.append(self.activityIndicatorButton!) }
            if showSpinner { subviews.append(self.activityIndicatorSpinner!) }
            
            self.activityIndicatorStackView = UIStackView(arrangedSubviews: subviews)
            self.activityIndicatorStackView?.translatesAutoresizingMaskIntoConstraints = false
            self.activityIndicatorStackView?.axis = .vertical
            self.activityIndicatorStackView?.spacing = 16
            
            // constraints
            self.activityIndicatorContentView?.addSubview(self.activityIndicatorStackView!)
            NSLayoutConstraint.activate([
                self.activityIndicatorStackView!.topAnchor.constraint(equalTo: self.activityIndicatorContentView!.topAnchor, constant: 24),
                self.activityIndicatorStackView!.bottomAnchor.constraint(equalTo: self.activityIndicatorContentView!.bottomAnchor, constant: -24),
                self.activityIndicatorStackView!.leftAnchor.constraint(equalTo: self.activityIndicatorContentView!.leftAnchor, constant: 16),
                self.activityIndicatorStackView!.rightAnchor.constraint(equalTo: self.activityIndicatorContentView!.rightAnchor, constant: -16),
                self.activityIndicatorStackView!.centerYAnchor.constraint(equalTo: self.activityIndicatorContentView!.centerYAnchor)
            ])
            
            UIView.animate(withDuration: 0.25, animations: {
                self.activityIndicatorBackgroundView?.alpha = 1
                self.activityIndicatorContentView?.alpha = 1
            }) { _ in
                completion?()
            }
        }
    }
    
    @objc private func performButtonAction() {
        guard let action = activityIndicatorButtonAction else { return }
        action()
    }
    
    func changeActivityAlertTitle(_ text: String) {
        DispatchQueue.main.async {
            self.activityIndicatorTitleLabel?.text = text
        }
    }
    
    func changeActivityAlertSubtitle(_ text: String) {
        DispatchQueue.main.async {
            self.activityIndicatorSubtitleLabel?.text = text
        }
    }

    func dismissActivityAlert(message: String, completion: (()->())? = nil) {
        if !self.isPresenting { completion?(); return }
        
        if let tapGesture = self.activityDismissGesture {
            self.activityIndicatorBackgroundView?.removeGestureRecognizer(tapGesture)
            self.activityDismissGesture = nil
        }
        
        self.activityIndicatorTitleLabel?.text = message
        self.activityIndicatorSubtitleLabel?.removeFromSuperview()
        self.activityIndicatorSubtitleLabel = nil
        self.activityIndicatorButton?.removeFromSuperview()
        self.activityIndicatorButtonAction = nil
        self.activityIndicatorDismissAction = nil
        self.activityIndicatorSpinner?.removeFromSuperview()
        self.activityIndicatorSpinner = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [unowned self] in
            UIView.animate(withDuration: 0.25, animations: {
                self.activityIndicatorBackgroundView?.alpha = 0
                self.activityIndicatorContentView?.alpha = 0
            }) { _ in
                self.activityIndicatorTitleLabel?.removeFromSuperview()
                self.activityIndicatorTitleLabel = nil
                self.activityIndicatorStackView?.removeFromSuperview()
                self.activityIndicatorStackView = nil
                self.activityIndicatorContentView?.removeFromSuperview()
                self.activityIndicatorContentView = nil
                self.activityIndicatorBackgroundView?.removeFromSuperview()
                self.activityIndicatorBackgroundView = nil
                
                self.isPresenting = false
                completion?()
            }
        }
    }
    
    @objc private func dismissInstantly() {
        if !self.isPresenting { return }
        
        if let tapGesture = self.activityDismissGesture {
            self.activityIndicatorBackgroundView?.removeGestureRecognizer(tapGesture)
            self.activityDismissGesture = nil
        }
        
        DispatchQueue.main.async { [unowned self] in
            UIView.animate(withDuration: 0.25, animations: {
                self.activityIndicatorBackgroundView?.alpha = 0
                self.activityIndicatorContentView?.alpha = 0
            }) { _ in
                self.activityIndicatorTitleLabel?.removeFromSuperview()
                self.activityIndicatorTitleLabel = nil
                self.activityIndicatorSubtitleLabel?.removeFromSuperview()
                self.activityIndicatorSubtitleLabel = nil
                self.activityIndicatorButton?.removeFromSuperview()
                self.activityIndicatorButtonAction = nil
                self.activityIndicatorSpinner?.removeFromSuperview()
                self.activityIndicatorSpinner = nil
                self.activityIndicatorStackView?.removeFromSuperview()
                self.activityIndicatorStackView = nil
                self.activityIndicatorContentView?.removeFromSuperview()
                self.activityIndicatorContentView = nil
                self.activityIndicatorBackgroundView?.removeFromSuperview()
                self.activityIndicatorBackgroundView = nil
                
                self.isPresenting = false

                if let dismissAction = self.activityIndicatorDismissAction {
                    dismissAction()
                }
                self.activityIndicatorDismissAction = nil
                
            }
        }
    }
    
}
