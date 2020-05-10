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
    
    var chatroom: Chatroom!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(editingFinished))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        title = chatroom.title
        
        tableView.backgroundColor = .colorAsset(.dynamicBackground)
        
        tableView.register(SmallHeaderTVCell.self, forHeaderFooterViewReuseIdentifier: SmallHeaderTVCell.reuseIdentifier)
        tableView.register(MessageTVCell.self, forCellReuseIdentifier: MessageTVCell.reuseIdentifier)
        
        setupFetchedResultsController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.scrollToBottom()
        }
    }
    
    deinit {
        print("-- DEINIT -- Chatroom VC")
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
        // TODO: present chatroom options
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
    
    func didSendMessage(_ text: String) {
        DataCoordinator.shared.createMessage(text: text, sender: "Me", chatroom: chatroom) { (id, error) in
            // TODO: handle errors
        }
        
        let delay: Double = Double.random(in: 3...5)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak chatroom] in
            guard let chatroom = chatroom else { return
                
            }
            let names = ["Paul", "John", "Mary", "Claire"]
            let messages = [
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. ",
                "Donec pretium vulputate sapien nec sagittis aliquam malesuada bibendum arcu.",
                "Commodo quis imperdiet massa tincidunt.",
                "Adipiscing elit duis tristique sollicitudin nibh. Tincidunt arcu non sodales neque. Integer vitae justo eget magna.",
                "Dolor sit amet consectetur adipiscing elit pellentesque habitant morbi.",
                "Amet cursus sit amet dictum sit amet.",
                "Quam elementum pulvinar etiam non quam lacus suspendisse faucibus. Ac tortor dignissim convallis aenean et tortor at. Quis vel eros donec ac odio. Rhoncus mattis rhoncus urna neque viverra."
            ]
            
            guard let message = messages.randomElement() else { return }
            guard let person = names.randomElement() else { return }
            
            DataCoordinator.shared.createMessage(text: message, sender: person, chatroom: chatroom) { (_, _) in }
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
