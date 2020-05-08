//
//  NewChatroomVC.swift
//  CouchClub
//
//  Created by Ruben Dias on 07/05/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

class NewChatroomVC: UIViewController {
    
    weak var delegate: ChatroomOperationDelegate?

    @IBOutlet weak var textView: UITextView!
    @IBOutlet var radioButtons: [UIButton]!
    @IBOutlet weak var createChatroomButton: UIButton!
        
    let placeholderText = "Chatroom title..."
    let titleRegex = NSRegularExpression(".*")
    
    var chatroomType: ChatroomType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(editingFinished))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        setupButtons()
        
        setupTitleToolbar()
        resetTextView(setPlaceholder: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.textView.becomeFirstResponder()
        }
    }
    
    deinit {
        print("-- DEINIT -- New Chatroom VC")
    }
    
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createButtonTapped(_ sender: UIButton) {
        // temporary
        guard let watchlists = LocalDatabase.shared.fetchWatchlists() else { return }
        guard let watchlist = watchlists.randomElement() else { return }
        
        let title = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        DataCoordinator.shared.createChatroom(title, .watchlist, watchlist.id) { [weak self] (id, _) in
            // TODO: handle errors
            if let id = id {
                self?.dismiss(animated: true, completion: {
                    self?.delegate?.didCreateChatroom(id)
                })
            } else {
                let ac = Alerts.simpleAlert(title: "Error", message: "Something went wrong when creating the chatroom.")
                self?.present(ac, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        radioButtons.forEach {
            if $0.tag == sender.tag {
                highlightButton($0)
            } else {
                restoreButton($0)
            }
        }
        
        // TODO: Allow the user to select a watchlist, movie or show
        
//        validateInputs()
    }
    
    private func setupButtons() {
        radioButtons.forEach {
            formatButtonCorners($0)
            restoreButton($0)
        }
        
        formatButtonCorners(createChatroomButton)
        createChatroomButton.alpha = 0
        createChatroomButton.isEnabled = false
    }
    
    private func highlightButton(_ button: UIButton) {
        button.backgroundColor = UIColor.systemOrange
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = .translatedFont(for: .subheadline, .semibold)
    }
    
    private func restoreButton(_ button: UIButton) {
        button.backgroundColor = .colorAsset(.dynamicBackgroundHighlight)
        button.setTitleColor(.colorAsset(.dynamicLabel), for: .normal)
        button.titleLabel?.font = .translatedFont(for: .subheadline, .regular)
    }
    
    private func setupTitleToolbar() {
        let toolbar = UIToolbar(frame: .init(x: 0, y: 0, width: view.bounds.width, height: 44))
        toolbar.tintColor = UIColor.systemOrange
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(editingFinished))
        
        toolbar.setItems([spacer, doneButton], animated: false)
        
        textView.inputAccessoryView = toolbar
    }
    
    @objc private func editingFinished() {
        textView.resignFirstResponder()
        validateInputs()
    }
    
    func resetTextView(setPlaceholder: Bool = true) {
        textView.text = setPlaceholder ? placeholderText : nil
        textView.font = .translatedFont(for: .body, .regular)
        textView.textColor = .colorAsset(.dynamicLabelSecondary)
    }
    
    func formatButtonCorners(_ button: UIButton) {
        button.clipsToBounds = true
        button.layer.cornerRadius = 4
    }
    
    func validateInputs() {
        let validText = !textView.text.isEmpty && textView.text != placeholderText
        
        if validText {
            UIView.animate(withDuration: 0.25, animations: { [weak self] in
                self?.createChatroomButton.alpha = 1
            }, completion: { [weak self] _ in
                self?.createChatroomButton.isEnabled = true
            })
        } else {
            createChatroomButton.isEnabled = false
            UIView.animate(withDuration: 0.25) { [weak self] in
                self?.createChatroomButton.alpha = 0
            }
        }
    }

}

extension NewChatroomVC: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text.isEmpty || textView.text == placeholderText  {
            textView.text = ""
            textView.font = .translatedFont(for: .title2, .semibold)
            textView.textColor = .colorAsset(.dynamicLabel)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            resetTextView()
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        validateInputs()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            editingFinished()
            return false
        } else if titleRegex.matches(text) {
            return textView.text.count + (text.count - range.length) <= 60
        } else {
            return false
        }
    }
    
}
