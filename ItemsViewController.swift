import UIKit

final class ItemsViewController: UITableViewController {
    private var items: [LostFoundItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Lost & Found"
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 84
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItem))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadItems()
    }

    private func reloadItems() {
        items = DatabaseManager.shared.fetchAll()
        tableView.reloadData()
    }

    @objc private func addItem() {
        let controller = storyboard!.instantiateViewController(withIdentifier: "AddEditItemViewController") as! AddEditItemViewController
        navigationController?.pushViewController(controller, animated: true)
    }

    override func numberOfSections(in tableView: UITableView) -> Int { 1 }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { items.count }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemTableViewCell", for: indexPath) as! ItemTableViewCell
        cell.configure(with: items[indexPath.row])
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let controller = storyboard!.instantiateViewController(withIdentifier: "AddEditItemViewController") as! AddEditItemViewController
        controller.itemToEdit = items[indexPath.row]
        navigationController?.pushViewController(controller, animated: true)
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let item = items[indexPath.row]
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            guard let self else { completion(false); return }
            let alert = UIAlertController(title: "Delete report?", message: "This report will be permanently removed from this device.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in completion(false) })
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
                let success = DatabaseManager.shared.delete(id: item.id)
                if success { self.reloadItems() }
                completion(success)
            })
            self.present(alert, animated: true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

final class ItemTableViewCell: UITableViewCell {
    @IBOutlet private weak var itemTitleLabel: UILabel!
    @IBOutlet private weak var detailLabel: UILabel!
    @IBOutlet private weak var statusLabel: UILabel!

    func configure(with item: LostFoundItem) {
        itemTitleLabel.text = item.name
        detailLabel.text = "\(item.type) • \(item.location)\n\(item.date)"
        statusLabel.text = item.status
        statusLabel.textColor = item.status == "Returned" ? .systemGreen : .systemOrange
    }
}
