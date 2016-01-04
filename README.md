# KPKContacts (v1.2.0)

This package was originally created to solve a friend's problem. He found it difficult to access the iOS' contacts telephone numbers.

Here's what you can do with this package:

  - You can retrieve all contacts from an iOS device which contain valid telephone numbers - a default regex function is used if one is not provided
  - you can specify your own phone number validator block.
  - A custom `KPKContact` object is returned for every contact found which contain both the original `CNContact` information should you require other details, as well as properties that are exposed for convenience.

### Demo 
A demo is available which shows a table view contacts viewer displaying all your iOS device's contacts with their phone numbers with writing a few lines of code.

### Installation

There isn't a cocoapod for this package as of today, didn't have the time to do so just yet. 
For now, simply dragging the two source files into your project is all that's required.

### How to use
This is the store where you call your methods on
```Swift
    var kpkContactStore = KPKContactStore()
```
Define and instantiate an empty array to store found contacts in
```Swift
    var contacts = [KPKContact]()
```

If you want to detect if the user has disabled your app access to their Contacts you will have to make your class the delegate
```Swift
    kpkContactStore.delegate = self
```
You can then adopt the protocol method that will get called when you initiate a contact search
```Swift
extension ContactsViewer: KPKContactStoreDelegate {
    func kpkContactStore(contactStore: KPKContactStore, contactsAccessAuthorizationStatus status: KPKContactAuthorizationStatus) {
        switch status {
        case .Denied, .NotDetermined:
            // You can display an alert to the user which can deep link on your app in the device's settings app.
        //case other options are available:
        default:
            return
        }
    }
}```

Here's how you make a call for contacts retrieval. This will use a default regex phone number vaidator block

```Swift
    self.kpkContactStore.findContactsWithValidNumbersOnly(){
        kpkContacts in
        // set local array to kpkContacts
}
```
You can then process a the contact search. This is done in the background with the completion handler invoked on the main queue. Here's an example of a `tableView` being updated with the contacts retrieved
```Swift
    self.kpkContactStore.findContactsWithValidNumbersOnly(){
        kpkContacts in
        if let contacts = kpkContacts {
            self.contacts = contacts
            self.tableView.reloadData()
        }
    }
```
Here's how you can set a custom regex phone number validator block, you do so by using the helper function:
```swift
private var regexPhoneNumberValidatorBlock: String -> Bool = { value in
    let PHONE_REGEX = "^\\s*(?:\\+?(\\d{1,3}))?[-. (]*(\\d{3})[-. )]*(\\d{3})[-. ]*(\\d{4})(?: *x(\\d+))?\\s*$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluateWithObject(value)
        return result
    }
    // And then you'd make the call to the findContactsWithValidNumbersOnly method
    contacts = self.kpkContactStore.findContactsWithValidNumbersOnly()
```

Here's how you access the 4 properties (so far, more to come when there's a demand for them) for the contact objects retrieved:
```Swift
    // You can access your contacts array to grab a contact object - KPKContact - by specifying some sort of index.
    let contact: KPKContact = contacts[indexPath.row]
```
    
The KPKContact object contains 4 properties:
```Swift
    // The original contact information should you need something extra
    let originalContact: CNContact = contact.originalCNContact
    
    // First name
    let firstName: String = contact.firstName
    
    // Last name
    let lastName: String = contact.lastName
    
    // And a numbers array which stores all the valid numbers associated to the contact
    let numbers: [KPKContactNumberInformation] = contact.numbers
```
Within the numbers array you'll have `KPKContactNumberInformation` objects.
They contain 3 properties
```Swift
    // An identifier which uniquely identifies the number even after install
    let identifier: String
    
    // The display name used for the number: Mobile, Home, etc
    let displayType: String
    
    // The telephone number in string format
    let number: String
```

There is a helper method which allows you to access the first number for a contact:
```Swift
    contact.firstNumberAvailable()
    // Rather than doing 
    // contact.numbers.first?.number 
```
### To-dos
+ Simplify internal methods by using `.map`, and `.filter` methods
+ Add more helper functions to the KPKContacts class
+ Make the search look at the keys available.
+ Write Tests

### Development

Want to contribute? Great!

KPKContacts uses git for fast developing.
+ Fork this repo
+ Make a change
+ And then make a pull request.


License
----

MIT


**Free Software, Hell Yeah!**
