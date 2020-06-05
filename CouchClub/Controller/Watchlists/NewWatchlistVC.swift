//
//  NewWatchlistVC.swift
//  CouchClub
//
//  Created by Ruben Dias on 30/04/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit

class NewWatchlistVC: UIViewController, Storyboarded {
    
    weak var coordinator: NewWatchlistCoordinator?

    @IBOutlet weak var textView: TitleTextView!
    @IBOutlet var radioButtons: [UIButton]!
    @IBOutlet weak var createWatchlistButton: RoundedButton!
    
    var itemType: ItemType! = .movie
    
    private let titlePlaceholderText = "Watchlist title..."
    private var shouldFocusOnTitle = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "New Watchlist"

        setupView()
        setupButtons()
        setupTextView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if shouldFocusOnTitle {
            textView.becomeFirstResponder()
            shouldFocusOnTitle = false
        }
    }
    
    deinit {
        print("-- DEINIT -- New Watchlist VC")
    }
    
    private func setupView() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(editingFinished))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func cancelTapped(_ sender: UIBarButtonItem) {
        coordinator?.didFinishCreating(nil)
    }
    
    @IBAction func createButtonTapped(_ sender: UIButton) {
        let title = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        DataCoordinator.shared.createWatchlist(title, itemType) { [unowned self] (id, error) in
            if let error = error {
                let alert = Alerts.simpleAlert(title: "Failed", message: error.localizedDescription)
                self.present(alert, animated: true)
                return
            }
            
            self.coordinator?.didFinishCreating(id)
        }
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        highlightButton(sender)
        radioButtons.filter{ $0.tag != sender.tag }.forEach({ restoreButton($0) })
        
        if sender.tag == 0 {
            itemType = .movie
        } else {
            itemType = .series
        }
        
        validateInputs()
    }
    
    private func setupButtons() {
        highlightButton(radioButtons[0])
        restoreButton(radioButtons[1])
        
        createWatchlistButton.alpha = 0
        createWatchlistButton.isEnabled = false
        createWatchlistButton.makeCTA()
    }
    
    private func highlightButton(_ button: UIButton) {
        button.backgroundColor = UIColor.systemOrange
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = .translatedFont(for: .headline, .semibold)
    }
    
    private func restoreButton(_ button: UIButton) {
        button.backgroundColor = .colorAsset(.dynamicBackgroundHighlight)
        button.setTitleColor(.colorAsset(.dynamicLabel), for: .normal)
        button.titleLabel?.font = .translatedFont(for: .headline, .regular)
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
    
    func setupTextView() {
        textView.placeholderText = titlePlaceholderText
        textView.titleDelegate = self
    }
    
    func validateInputs() {
        let validText = !textView.text.isEmpty && textView.text != titlePlaceholderText
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

extension NewWatchlistVC: TitleDelegate {
    
    func titleDidChange() {
        validateInputs()
    }
    
}
