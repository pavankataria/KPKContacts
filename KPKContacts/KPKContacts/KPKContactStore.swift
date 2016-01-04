//
//  KPKContactsNumberFinder.swift
//  CNContacts
//
//  Created by Pavan Kataria on 03/01/2016.
//  Copyright © 2016 Pavan Kataria. All rights reserved.
//

import Foundation
import Contacts

protocol KPKContactStoreProtocol {
    func findContactsWithValidNumbersOnly() -> [KPKContact]?
}
protocol KPKContactStoreDelegate{
    func kpkContactStore(contactStore: KPKContactStore, contactsAccessAuthorizationStatus status: KPKContactAuthorizationStatus)
}
/*!
* @abstract The authorization the user has given the application to access an entity type.
*/
enum KPKContactAuthorizationStatus: Int{
    /*! The user has not yet made a choice regarding whether the application may access contact data. */
    case NotDetermined = 0
    /*! The application is not authorized to access contact data.
    *  The user cannot change this application’s status, possibly due to active restrictions such as parental controls being in place. */
    case Restricted
    /*! The user explicitly denied access to contact data for the application. */
    case Denied
    /*! The application is authorized to access contact data. */
    case Authorized
    
    init?(withCNAuthStatus status: CNAuthorizationStatus){
        self.init(rawValue: status.rawValue)
    }
}

public class KPKContactStore: KPKContactStoreProtocol {
    private let store = CNContactStore()
    var delegate: KPKContactStoreDelegate?

    internal func authorizationStatusForAccessingContacts() -> CNAuthorizationStatus {
        return CNContactStore.authorizationStatusForEntityType(CNEntityType.Contacts)
    }
    
    // You can set your own regex phone number validator block if you prefer to change the default
    public func setRegexPhoneNumberValidatorBlock(block: String -> Bool){
        regexPhoneNumberValidatorBlock = block
    }
    
    private var regexPhoneNumberValidatorBlock: String -> Bool = { value in
        let PHONE_REGEX = "^\\s*(?:\\+?(\\d{1,3}))?[-. (]*(\\d{3})[-. )]*(\\d{3})[-. ]*(\\d{4})(?: *x(\\d+))?\\s*$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluateWithObject(value)
        return result
    }
    
    public func findContactsWithValidNumbersOnly() -> [KPKContact]? {
        let authStatus = authorizationStatusForAccessingContacts()
        let authorization: KPKContactAuthorizationStatus = KPKContactAuthorizationStatus(withCNAuthStatus: authStatus)!
        
        dispatch_async(dispatch_get_main_queue()) {
            self.delegate?.kpkContactStore(self, contactsAccessAuthorizationStatus: authorization)
        }
        
        switch authorization {
            case .Denied, .Restricted:
                print("The iOS contacts are not accessible. Register to KPKContact's contactsAccessAuthorizationStatus: delegate method to be notified of the contacts access authorization status and to take appropriate action.")
                return nil
            default: break
        }
        
        let keysToFetch = [CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName), CNContactPhoneNumbersKey]
        let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
        
        var contacts = [KPKContact]()
        do {
            try store.enumerateContactsWithFetchRequest(fetchRequest, usingBlock: {
                ( contact, pointer) -> Void in
                
                if let numbers = self.findValidPhoneNumbers(contact.phoneNumbers) {
                    
                    let kpkContact = KPKContact(originalCNContact: contact, firstName: contact.givenName, lastName: contact.familyName , numbers: numbers)
                    contacts.append(kpkContact)
                }
            })
        }
        catch let error as NSError {
            print(error.localizedDescription)
            return nil
        }
        if contacts.isEmpty {
            return nil
        }
        return contacts
    }
    
    private func findValidPhoneNumbers(numbers: [CNLabeledValue]) -> [KPKContactNumberInformation]? {
        // TODO: Use map and reduce function
        if let numbers = getKPKNumbers(numbers) {
            var validNumbers = [KPKContactNumberInformation]()
            validNumbers = numbers
                .filter{ regexPhoneNumberValidatorBlock($0.number) }
            if validNumbers.isEmpty {
                return nil
            }
            return validNumbers
        }
        return nil
    }
    
    private func getKPKNumbers(rawPhoneNumbers: [CNLabeledValue]) -> [KPKContactNumberInformation]?{
        // TODO: Use map and reduce function
        var numbers = [KPKContactNumberInformation]()
        for rawNumber in rawPhoneNumbers {
            if let phoneNumber = rawNumber.value as? CNPhoneNumber {
                let digits = phoneNumber.stringValue
                let identifier = rawNumber.identifier
                let displayLabel = CNLabeledValue.localizedStringForLabel(rawNumber.label)
                let numberInformation = KPKContactNumberInformation(identifier: identifier, displayType: displayLabel, number: digits)
                numbers.append(numberInformation)
            }
        }
        if numbers.isEmpty {
            return nil
        }
        return numbers
    }
    
    
}
/*

protocol KPKContactProtocol {
func originalCNContacts() -> [CNContact]?
}
//extension KPKContact:
TODO: Add an extension on arrays where it checks for the KPKContactProtocol and then add this method to it:
func originalCNContacts() -> [CNContact]? {
return contacts.map { return $0.originalCNContact }
}

*/