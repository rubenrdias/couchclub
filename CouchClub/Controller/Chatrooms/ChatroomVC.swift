//
//  ChatroomVC.swift
//  CouchClub
//
//  Created by Ruben Dias on 07/05/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit
import CoreData

class ChatroomVC: UITableViewController {
    
    var fetchedResultsController: NSFetchedResultsController<Message>!
    
    var chatroom: Chatroom! {
        didSet { chatroomID = chatroom.id }
    }
    private var chatroomID: UUID!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(chatroomsWereUpdated), name: .chatroomsDidChange, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(editingFinished))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        title = chatroom.title
        
        tableView.backgroundColor = .colorAsset(.dynamicBackground)
        tableView.contentInset = .init(top: 8, left: 0, bottom: 8, right: 0)
        
        tableView.register(SmallHeaderTVCell.self, forHeaderFooterViewReuseIdentifier: SmallHeaderTVCell.reuseIdentifier)
        tableView.register(MessageTVCell.self, forCellReuseIdentifier: MessageTVCell.reuseIdentifier)
        
        setupFetchedResultsController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        scrollToBottom()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("-- DEINIT -- Chatroom VC")
    }
    
    @objc private func chatroomsWereUpdated() {
        DispatchQueue.main.async { [weak self] in
            let chatrooms = LocalDatabase.shared.fetchChatrooms()
            if chatrooms?.firstIndex(where: { $0.id == self?.chatroomID }) == nil {
                let alert = Alerts.simpleAlert(title: "Chatroom was deleted", message: "The chatroom owner has deleted this chatroom. It will now be deleted from the device.") { _ in
                    self?.navigationController?.popViewController(animated: true)
                }
                self?.present(alert, animated: true)
            }
        }
    }
    
    @objc private func editingFinished() {
        inputAccessoryViewContainer.dismissKeyboard()
    }
    
    lazy var inputAccessoryViewContainer: MessageInputAccessoryView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let messageInputAccessoryView = MessageInputAccessoryView(frame: frame)        
        messageInputAccessoryView.delegate = self
        return messageInputAccessoryView
    }()
    
    override var inputAccessoryView: UIView? {
        get { return inputAccessoryViewContainer }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    @IBAction func moreButtonTapped(_ sender: UIBarButtonItem) {
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        ac.view.tintColor = .colorAsset(.dynamicLabel)
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if chatroom.owner === LocalDatabase.shared.fetchCurrentuser() {
            ac.addAction(UIAlertAction(title: "Delete Chatroom", style: .destructive) { [unowned self] _ in
                let deletionAlert = Alerts.deletionAlert(title: "Are you sure?", message: "This action is irreversible.") { _ in
                    DataCoordinator.shared.deleteChatroom(self.chatroom) { error in
                        if let error = error {
                            let alert = Alerts.simpleAlert(title: "Failed", message: error.localizedDescription)
                            self.present(alert, animated: true)
                        } else {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
                
                self.present(deletionAlert, animated: true, completion: nil)
            })
        }
        
        ac.addAction(UIAlertAction(title: "Leave Chatroom", style: .destructive) { [unowned self] _ in
            let deletionAlert = Alerts.deletionAlert(title: "Are you sure?", message: "You can only rejoin later by with an invite code.") { _ in
                DataCoordinator.shared.leaveChatroom(self.chatroom) { error in
                    if let error = error {
                        let alert = Alerts.simpleAlert(title: "Failed", message: error.localizedDescription)
                        self.present(alert, animated: true)
                    } else {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
            
            self.present(deletionAlert, animated: true, completion: nil)
        })
                
        ac.popoverPresentationController?.barButtonItem = sender
        present(ac, animated: true, completion: nil)
    }
    
    private func setupFetchedResultsController() {
        let request = Message.createFetchRequest()
        
        // sorting
        let dateSort = NSSortDescriptor(key: "date", ascending: true)
        request.sortDescriptors = [dateSort]
        
        // filtering
        request.predicate = NSPredicate(format: "chatroom == %@", chatroom)
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: "dateSection", cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    func scrollToBottom(animated: Bool = true) {
        guard let sections = fetchedResultsController.sections, sections.count > 0 else { return }
        let validSectionCount = sections.count - 1
        let lastMessageIndex = sections[validSectionCount].numberOfObjects - 1
        tableView.scrollToRow(at: .init(row: lastMessageIndex, section: validSectionCount), at: .bottom, animated: animated)
    }
    
}

extension ChatroomVC: MessageDelegate {
    
    func shouldSendMessage(_ text: String) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        DataCoordinator.shared.createMessage(trimmedText, in: chatroom) { [unowned self] (error) in
            if let error = error {
                let alert = Alerts.simpleAlert(title: "Failed", message: error.localizedDescription)
                self.present(alert, animated: true)
            }
        }
    }
    
}

extension ChatroomVC {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sections = fetchedResultsController.sections else { return UIView() }
        guard let firstItem = sections[section].objects?.first as? Message else { return UIView() }
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: SmallHeaderTVCell.reuseIdentifier) as! SmallHeaderTVCell
        headerView.text = messageSectionFormatter.string(from: firstItem.date)
        headerView.useCenteredText = true
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 16
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        return sections[section].numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageTVCell.reuseIdentifier, for: indexPath) as! MessageTVCell
        let message = fetchedResultsController.object(at: indexPath)
        
        var shouldReduceTopMargin = false
        var shouldReduceBottomMargin = false
        
        if indexPath.row > 0 {
            let previousMessage = fetchedResultsController.object(at: .init(row: indexPath.row - 1, section: indexPath.section))
            if previousMessage.sender == message.sender {
                shouldReduceTopMargin = true
            }
        }
        
        if indexPath.row < tableView.numberOfRows(inSection: indexPath.section) - 1 {
            let nextMessage = fetchedResultsController.object(at: .init(row: indexPath.row + 1, section: indexPath.section))
            if nextMessage.sender == message.sender {
                shouldReduceBottomMargin = true
            }
        }
        
        cell.shouldReduceTopMargin = shouldReduceTopMargin
        cell.shouldReduceBottomMargin = shouldReduceBottomMargin
        cell.message = message
        return cell
    }
    
}

extension ChatroomVC: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView!.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            let sectionIndexSet = IndexSet(integer: sectionIndex)
            tableView!.insertSections(sectionIndexSet, with: .fade)
        case .delete:
            let sectionIndexSet = IndexSet(integer: sectionIndex)
            tableView!.deleteSections(sectionIndexSet, with: .fade)
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .none)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        @unknown default:
            fatalError()
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView!.endUpdates()
        scrollToBottom()
    }
}
