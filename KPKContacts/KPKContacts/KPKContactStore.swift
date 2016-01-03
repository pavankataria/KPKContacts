//
//  KPKContactsNumberFinder.swift
//  CNContacts
//
//  Created by Pavan Kataria on 03/01/2016.
//  Copyright © 2016 Pavan Kataria. All rights reserved.
//

import Foundation
import Contacts


public class KPKContactStore {
    
    private let store = CNContactStore()

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