import UIKit

final class AddEditItemViewController: UIViewController {
    var itemToEdit: LostFoundItem?

    @IBOutlet private weak var nameField: UITextField!
    @IBOutlet private weak var descriptionView: UITextView!
    @IBOutlet private weak var locationField: UITextField!
    @IBOutlet private weak var typeControl: UISegmentedControl!
    @IBOutlet private weak var statusControl: UISegmentedControl!
    @IBOutlet private weak var saveButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = itemToEdit == nil ? "Report an Item" : "Edit Report"
        saveButton.setTitle(itemToEdit == nil ? "Save Report" : "Update Report", for: .normal)
        if let item = itemToEdit { populateForm(with: item) }
    }

    private func populateForm(with item: LostFoundItem) {
        nameField.text = item.name
        descriptionView.text = item.itemDescription
        locationField.text = item.location
        typeControl.selectedSegmentIndex = item.type == "Found" ? 1 : 0
        statusControl.selectedSegmentIndex = item.status == "Returned" ? 1 : 0
    }

    @IBAction private func saveTapped(_ sender: UIButton) {
        let name = (nameField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let location = (locationField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let description = (descriptionView.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty, !location.isEmpty else {
            showAlert(title: "Missing information", message: "Please enter the item name and location.")
            return
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        let item = LostFoundItem(id: itemToEdit?.id ?? 0, name: name, itemDescription: description, location: location,
            type: typeControl.selectedSegmentIndex == 1 ? "Found" : "Lost",
            status: statusControl.selectedSegmentIndex == 1 ? "Returned" : "Open",
            date: itemToEdit?.date ?? formatter.string(from: Date()))
        let saved = itemToEdit == nil ? DatabaseManager.shared.insert(item) : DatabaseManager.shared.update(item)
        if saved { navigationController?.popViewController(animated: true) }
        else { showAlert(title: "Save failed", message: "The report could not be saved. Please try again.") }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
