# KPKContacts (1.1)

This package was originally created to solve a friend's problem. He found it difficult to access the iOS' contacts telephone numbers.

Here's what you can do with this package:

  - You can retrieve all contacts from an iOS device which contain valid telephone numbers - a default regex function is used if one is not provided
  - you can specify your own phone number validator block.
  - A custom `KPKContact` object is returned for every contact found which contain both the original `CNContact` information should you require other details, as well as properties that are exposed for convenience.

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
Here's how you make a call for contacts retrieval

```Swift
// This will use a default regex phone number vaidator block
contacts = self.kpkContactStore.findContactsWithValidNumbersOnly()
```
You can then dispatch the contact search into the background like so where we update a `tableView` once the contacts have been retrieved
```Swift
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
  if let contacts = self.kpkContactStore.findContactsWithValidNumbersOnly() {
    self.contacts = contacts
    dispatch_async(dispatch_get_main_queue()) {
      self.tableView.reloadData()
    }
  }
}
```
Here's how you can set a custom regex phone number validator block, you do so by using the helper function:
```swift
private var regexPhoneNumberValidatorBlock: String -> Bool = { 
  value in
  let PHONE_REGEX = "^\\s*(?:\\+?(\\d{1,3}))?[-. (]*(\\d{3})[-. )]*(\\d{3})[-. ]*(\\d{4})(?: *x(\\d+))?\\s*$"
  let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
  let result =  phoneTest.evaluateWithObject(value)
  return result
}
// And then you'd make the call to the findContactsWithValidNumbersOnly method
contacts = self.kpkContactStore.findContactsWithValidNumbersOnly()
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
