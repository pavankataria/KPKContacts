//
//  KPKContact.swift
//  CNContacts
//
//  Created by Pavan Kataria on 03/01/2016.
//  Copyright © 2016 Pavan Kataria. All rights reserved.
//

import Foundation
import Contacts


public struct KPKContact {
    let originalCNContact: CNContact
    let firstName: String
    let lastName: String
    let numbers: [KPKContactNumberInformation]
    
    init(originalCNContact: CNContact, firstName: String, lastName: String = "", numbers: [KPKContactNumberInformation]){
        self.originalCNContact = originalCNContact
        if firstName.isEmpty {
            self.firstName = "No Name"
        }
        else {
            self.firstName = firstName
        }
        self.lastName = lastName
        self.numbers = numbers
    }
    
    func firstNumberAvailable() -> String{
        //There will always be a number available
        return self.numbers.first!.number
    }
}
extension KPKContact: CustomStringConvertible{
    public var description: String {
        return "Name: \(firstName) \(lastName)"
    }
}

public struct KPKContactNumberInformation{
    let identifier: String
    let displayType: String
    let number: String
}
extension KPKContactNumberInformation: CustomStringConvertible {
    public var description: String {
        return "Display Type: \(displayType) number: \(number)"
    }
}