import UIKit

final class HomeViewController: UIViewController {
    @IBOutlet private weak var lostCountLabel: UILabel!
    @IBOutlet private weak var foundCountLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "FoundIt"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshCounts()
    }

    private func refreshCounts() {
        let items = DatabaseManager.shared.fetchAll()
        lostCountLabel.text = "\(items.filter { $0.type == "Lost" }.count)"
        foundCountLabel.text = "\(items.filter { $0.type == "Found" }.count)"
    }

    @IBAction private func viewReportsTapped(_ sender: UIButton) {
        let controller = storyboard!.instantiateViewController(withIdentifier: "ItemsViewController")
        navigationController?.pushViewController(controller, animated: true)
    }

    @IBAction private func reportItemTapped(_ sender: UIButton) {
        let controller = storyboard!.instantiateViewController(withIdentifier: "AddEditItemViewController") as! AddEditItemViewController
        navigationController?.pushViewController(controller, animated: true)
    }
}
