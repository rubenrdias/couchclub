//
//  ChatroomMessagesDataSource.swift
//  CouchClub
//
//  Created by Ruben Dias on 04/06/2020.
//  Copyright © 2020 Ruben Dias. All rights reserved.
//

import UIKit
import CoreData

protocol MessagesDataSourceDelegate: AnyObject {
    func dataWasUpdated()
}

class ChatroomMessagesDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

    weak var delegate: MessagesDataSourceDelegate?
    weak var chatroom: Chatroom!
    weak var tableView: UITableView!
    private var fetchedResultsController: NSFetchedResultsController<Message>!
    
    init(chatroom: Chatroom, tableView: UITableView, delegate: MessagesDataSourceDelegate? = nil) {
        super.init()
        self.chatroom = chatroom
        self.tableView = tableView
        self.delegate = delegate
        
        registerCells()
        setupFetchedResultsController()
    }
    
    deinit {
        print("-- DEINIT -- Chatroom Messages Data Source")
    }
    
    private func registerCells() {
        tableView.register(SmallHeaderTVCell.self, forHeaderFooterViewReuseIdentifier: SmallHeaderTVCell.reuseIdentifier)
    }
    
    func bottomIndexPath() -> IndexPath? {
        guard let sections = fetchedResultsController.sections, sections.count > 0 else { return nil }
        let lastSection = sections.count - 1
        let lastMessageIndex = sections[lastSection].numberOfObjects - 1
        return IndexPath(row: lastMessageIndex, section: lastSection)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sections = fetchedResultsController.sections else { return UIView() }
        guard let firstItem = sections[section].objects?.first as? Message else { return UIView() }
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: SmallHeaderTVCell.reuseIdentifier) as! SmallHeaderTVCell
        headerView.text = messageSectionFormatter.string(from: firstItem.date)
        headerView.useCenteredText = true
        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        return sections[section].numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageTVCell.reuseIdentifier, for: indexPath) as! MessageTVCell
        
        let message = fetchedResultsController.object(at: indexPath)
        var hideSender = false
        var reduceTopPadding = false
        var reduceBottomPadding = false
        
        
        if indexPath.row > 0 {
            let previousMessage = fetchedResultsController.object(at: .init(row: indexPath.row - 1, section: indexPath.section))
            hideSender = (previousMessage.sender == message.sender)
            reduceTopPadding = (previousMessage.sender == message.sender)
        }
        
        if indexPath.row < tableView.numberOfRows(inSection: indexPath.section) - 1 {
            let nextMessage = fetchedResultsController.object(at: .init(row: indexPath.row + 1, section: indexPath.section))
            reduceBottomPadding = (nextMessage.sender == message.sender)
        }

        // override hiding sender if message was sentBySelf
        if message.sentBySelf {
            hideSender = true
        }

        cell.configureDetails(message: message, hideSender: hideSender)
        cell.configurePadding(reduceTopPadding: reduceTopPadding, reduceBottomPadding: reduceBottomPadding)
        return cell
    }
    
}

extension ChatroomMessagesDataSource: NSFetchedResultsControllerDelegate {
    
    private func setupFetchedResultsController() {
        let request = Message.createFetchRequest()
        
        // sorting
        let dateSort = NSSortDescriptor(key: "date", ascending: true)
        request.sortDescriptors = [dateSort]
        
        // filtering
        request.predicate = NSPredicate(format: "chatroom == %@", chatroom)
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: LocalDatabase.shared.context, sectionNameKeyPath: "dateSection", cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView!.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            let sectionIndexSet = IndexSet(integer: sectionIndex)
            tableView!.insertSections(sectionIndexSet, with: .automatic)
        case .delete:
            let sectionIndexSet = IndexSet(integer: sectionIndex)
            tableView!.deleteSections(sectionIndexSet, with: .automatic)
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
            if newIndexPath!.row > 0 {
                let previousIndexPath = IndexPath(row: (newIndexPath!.row - 1), section: newIndexPath!.section)
                tableView.reloadRows(at: [previousIndexPath], with: .none)
            }
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
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
        delegate?.dataWasUpdated()
    }
}
