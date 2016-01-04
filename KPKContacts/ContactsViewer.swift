//
//  ContactsViewer.swift
//  CNContacts
//
//  Created by Pavan Kataria on 03/01/2016.
//  Copyright © 2016 Pavan Kataria. All rights reserved.
//

import UIKit

class ContactsViewer: UITableViewController {

    var kpkContactStore = KPKContactStore()
    var contacts = [KPKContact]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        kpkContactStore.delegate = self
        findContacts()
    }
    
    func findContacts(){
        self.kpkContactStore.findContactsWithValidNumbersOnly(){
            kpkContacts in
            if let contacts = kpkContacts {
                self.contacts = contacts
                self.tableView.reloadData()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let CellIdentifier: String = "ContactsCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as UITableViewCell!
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: CellIdentifier)
        }
        
        let contact: KPKContact = contacts[indexPath.row]
        cell.textLabel?.text = contact.firstName.uppercaseString
        cell?.detailTextLabel?.text = contact.firstNumberAvailable()
        return cell
    }
    
    func displayContactsNotAccessibleAlert(){
        let alertController = UIAlertController (title: "Contacts Not Enabled", message: "This application needs access to your contacts in order for it to function properly.", preferredStyle: .Alert)
 
        
        let settingsAction = UIAlertAction(title: "Go to settings and enable?", style: .Default) { (_) in
            if let settingsUrl = NSURL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.sharedApplication().openURL(settingsUrl)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Not now.", style: .Default, handler: nil)
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil);
    }
}
extension ContactsViewer: KPKContactStoreDelegate {
    func kpkContactStore(contactStore: KPKContactStore, contactsAccessAuthorizationStatus status: KPKContactAuthorizationStatus) {
        
        switch status {
        case .Denied, .NotDetermined:
            displayContactsNotAccessibleAlert()
        default:
            return
        }
        
    }
}

