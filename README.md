# FoundIt — Storyboard / Interface Builder version

FoundIt is a UIKit lost-and-found app for a college practical. All visible screens and controls are laid out in `FoundIt/Main.storyboard` using Xcode Interface Builder (drag and drop). Swift files handle behavior and database operations; they do not create screen controls programmatically.

## Screens
- Home dashboard: Lost and Found counts, View All Reports, Report an Item.
- Lost & Found list: storyboard prototype table cell, tap to edit, swipe to delete.
- Report form: item name, description, location, Lost/Found selector, Open/Returned selector, Save/Update button.

## Technology
- Swift + UIKit
- Main.storyboard / Auto Layout / IBOutlet / IBAction
- SQLite3 local database
- CRUD: Create, Read, Update, Delete

## Open and run
1. Extract the ZIP.
2. Open `FoundIt/FoundIt.xcodeproj` in Xcode.
3. Select an iPhone simulator and press Cmd+R.
4. Open `Main.storyboard` to visually edit the screens by dragging controls from the Object Library.

## Important
This project is configured to load its initial Navigation Controller from `Main.storyboard`. The UI is storyboard-based; the Swift controllers contain only behavior, event handlers, and database interaction. The project archive and storyboard XML were checked, but this environment does not have Xcode available to compile or run the iOS app, so a successful simulator build has not been independently verified.
