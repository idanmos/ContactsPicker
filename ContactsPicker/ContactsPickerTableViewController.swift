//
//  ContactsPickerTableViewController.swift
//  ContactsPicker
//
//  Created by Idan Moshe on 07/11/2020.
//

import UIKit
import Contacts

class ContactsPickerTableViewController: UITableViewController {
    
    private let contactsProvider = ContactsPickerProvider()
    
    private var dataSource: [String: [CNContact]] = [:]
    private var filteredDataSource: [String: [CNContact]] = [:]
    
    private lazy var searchController: UISearchController = {
        let controller = UISearchController()
        controller.searchResultsUpdater = self
        controller.hidesNavigationBarDuringPresentation = false
        controller.searchBar.sizeToFit()
        controller.searchBar.delegate = self
        
        if #available(iOS 12, *) {
            controller.obscuresBackgroundDuringPresentation = false
        } else {
            controller.dimsBackgroundDuringPresentation = false
        }
        
        return controller
    }()
    
    private var selectedContact: CNContact?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        self.tableView.tableHeaderView = self.searchController.searchBar
        self.tableView.tableFooterView = UIView(frame: .zero)
        
        self.tableView.register(UINib(nibName: ContactPickerTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: ContactPickerTableViewCell.identifier)
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        
        self.contactsProvider.delegate = self
        
        switch self.contactsProvider.authorizationStatus {
        case .notDetermined:
            self.contactsProvider.requestAccess()
        case .restricted:
            debugPrint("restricted")
        case .denied:
            debugPrint("restricted")
        case .authorized:
            self.requestContacts()
        @unknown default: break
        }
    }
    
    // MARK: - General methods
    
    private func requestContacts() {
        self.contactsProvider.findContacts()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.searchController.isActive {
            return self.filteredDataSource.keys.count
        } else {
            return self.dataSource.keys.count
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchController.isActive {
            let sectionKey: String = Array(self.filteredDataSource.keys)[section]
            let rows: Int = self.filteredDataSource[sectionKey]?.count ?? 0
            return rows
        } else {
            let sectionKey: String = Array(self.dataSource.keys)[section]
            let rows: Int = self.dataSource[sectionKey]?.count ?? 0
            return rows
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactPickerTableViewCell.identifier, for: indexPath) as! ContactPickerTableViewCell
        
        var sectionKey: String
        if self.searchController.isActive {
            sectionKey = Array(self.filteredDataSource.keys)[indexPath.section]
            
            if let contact: CNContact = self.filteredDataSource[sectionKey]?[indexPath.row] {
                cell.configure(contact: contact)
            }
        } else {
            sectionKey = Array(self.dataSource.keys)[indexPath.section]
            
            if let contact: CNContact = self.dataSource[sectionKey]?[indexPath.row] {
                cell.configure(contact: contact)
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.searchController.isActive {
            let sectionKey: String = Array(self.filteredDataSource.keys)[section]
            return sectionKey
        } else {
            let sectionKey: String = Array(self.dataSource.keys)[section]
            return sectionKey
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var sectionKey: String
        if self.searchController.isActive {
            sectionKey = Array(self.filteredDataSource.keys)[indexPath.section]
            self.selectedContact = self.filteredDataSource[sectionKey]?[indexPath.row]
        } else {
            sectionKey = Array(self.dataSource.keys)[indexPath.section]
            self.selectedContact = self.dataSource[sectionKey]?[indexPath.row]
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - ContactsPickerProviderDelegate

extension ContactsPickerTableViewController: ContactsPickerProviderDelegate {
        
    func contactsPicker(_ contactsPicker: ContactsPickerProvider, accessGranted: Bool, error: Error?) {
        if let error = error {
            debugPrint(#function, error)
            return
        }
        
        guard accessGranted == true else { return }
        
        contactsPicker.findContacts()
    }
    
    func contactsPicker(_ contactsPicker: ContactsPickerProvider, fetchContactsSuccess contacts: [CNContact]) {
        self.dataSource = self.contactsProvider.sortContacts(contacts: contacts)
        
        self.tableView.reloadData()
    }
    
    func contactsPicker(_ contactsPicker: ContactsPickerProvider, fetchContactsFail error: Error) {
        debugPrint(#function, error)
    }
    
}

// MARK: - UISearchResultsUpdating

extension ContactsPickerTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText: String = searchController.searchBar.text, searchController.isActive else { return }
        
        let predicate: NSPredicate
        if searchText.isEmpty {
            predicate = CNContact.predicateForContactsInContainer(withIdentifier: self.contactsProvider.contactStore.defaultContainerIdentifier())
        } else {
            predicate = CNContact.predicateForContacts(matchingName: searchText)
        }
        
        var filteredContacts: [CNContact] = []
        
        do {
            filteredContacts = try self.contactsProvider.contactStore.unifiedContacts(matching: predicate, keysToFetch: self.contactsProvider.keysToFetch)
            
            self.filteredDataSource = self.contactsProvider.sortContacts(contacts: filteredContacts)
            
            self.tableView.reloadData()
        } catch let error {
            debugPrint(#function, error)
        }
    }
    
}

// MARK: - UISearchBarDelegate

extension ContactsPickerTableViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.filteredDataSource.removeAll()
        
        self.view.endEditing(true)
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
}
