//
//  NewWatchlistVC.swift
//  CouchClub
//
//  Created by Ruben Dias on 30/04/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

protocol WatchlistOperationDelegate: AnyObject {
    func didCreateWatchlist(_ id: UUID)
}

class NewWatchlistVC: UIViewController {
    
    weak var delegate: WatchlistOperationDelegate?

    @IBOutlet weak var textView: UITextView!
    @IBOutlet var radioButtons: [UIButton]!
    @IBOutlet weak var createWatchlistButton: UIButton!
        
    let placeholderText = "Watchlist title..."
    let titleRegex = NSRegularExpression(".*")
    
    var itemType: ItemType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(editingFinished))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        formatButton(createWatchlistButton)
        radioButtons.forEach { formatButton($0) }
        
        createWatchlistButton.alpha = 0
        createWatchlistButton.isEnabled = false
        
        buttonTapped(radioButtons[0])
        
        setupTitleToolbar()
        resetTextView()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.textView.becomeFirstResponder()
        }
    }
    
    deinit {
        print("-- DEINIT -- New Watchlist VC")
    }
    
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createButtonTapped(_ sender: UIButton) {
        let title = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        DataCoordinator.shared.createWatchlist(title, itemType) { [weak self] (id, _) in
            print("TODO: handle possible errors")
            if let id = id {
                self?.dismiss(animated: true, completion: {
                    self?.delegate?.didCreateWatchlist(id)
                })
            } else {
                let ac = Alerts.simpleAlert(title: "Error", message: "Something went wrong when creating the watchlist.")
                self?.present(ac, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        radioButtons.forEach {
            if $0.tag == sender.tag {
                $0.backgroundColor = UIColor.systemOrange
                $0.setTitleColor(UIColor.white, for: .normal)
                $0.titleLabel?.font = UIFont.translatedFont(for: .body, .bold)
            } else {
                $0.backgroundColor = UIColor.colorAsset(.dynamicBackgroundHighlight)
                $0.setTitleColor(UIColor.colorAsset(.dynamicLabel), for: .normal)
                $0.titleLabel?.font = UIFont.translatedFont(for: .body, .regular)
            }
        }
        
        if sender.tag == 0 {
            itemType = .movie
        } else {
            itemType = .series
        }
        
        validateInputs()
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
    
    func resetTextView() {
        textView.text = placeholderText
        textView.font = UIFont.translatedFont(for: .body, .regular)
        textView.textColor = UIColor.colorAsset(.dynamicLabelSecondary)
    }
    
    func formatButton(_ button: UIButton) {
        button.clipsToBounds = true
        button.layer.cornerRadius = 4
    }
    
    func validateInputs() {
        let validText = !textView.text.isEmpty && textView.text != placeholderText
        let validType = itemType != nil
        
        if validText && validType {
            UIView.animate(withDuration: 0.25, animations: { [weak self] in
                self?.createWatchlistButton.alpha = 1
            }, completion: { [weak self] _ in
                self?.createWatchlistButton.isEnabled = true
            })
        } else {
            createWatchlistButton.isEnabled = false
            UIView.animate(withDuration: 0.25) { [weak self] in
                self?.createWatchlistButton.alpha = 0
            }
        }
    }

}

extension NewWatchlistVC: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholderText {
            textView.text = ""
            textView.font = UIFont.translatedFont(for: .title2, .semibold)
            textView.textColor = UIColor.colorAsset(.dynamicLabel)
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
