//
//  SelectViewController.swift
//  LogAlong
//
//  Created by Frank Gao on 5/13/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import UIKit

enum SelectType {
    case ACCOUNT
    case ACCOUNT2
    case CATEGORY
    case PAYER
    case PAYEE
    case VENDOR
    case TAG
}

class SelectViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,
UIPopoverPresentationControllerDelegate, FPassCreationBackDelegate {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var allSwitch: UISwitch?

    let headerHeight: CGFloat = 45 //constraint set in storyboard

    var initValues: [Int64]!
    var color: UIColor!
    var selectType: SelectType!
    var multiSelection: Bool = false

    // carries the first selection if any, upon entering this menu.
    // if single selection, this also carries the active selection
    var myIndexPath: Int = -1

    weak var delegate: FViewControllerDelegate?

    var selections: [NameWithId] = []
    var checked: [Bool] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        headerView.backgroundColor = LTheme.Color.dialog_border_color
        createHeader()

        self.preferredContentSize.width = LTheme.Dimension.popover_width

        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()

        checkIdentifierAndPopulateArray()

        //tableView.reloadData()
        if selections.count > 0 && myIndexPath >= 0 {
            DispatchQueue.main.async(execute: {
                let indexPath = IndexPath(row: self.myIndexPath, section: 0)
                self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
            })
        }

        if (selections.count > 4) {
            self.preferredContentSize.height = 105 + CGFloat(selections.count * 51)
        } else {
            self.preferredContentSize.height = LTheme.Dimension.popover_height
        }

        if multiSelection {
            allSwitch?.isOn = isAllChecked()
        }
        okButton.isEnabled = true
    }

    override func viewWillAppear(_ animated: Bool) {
        view.superview?.layer.borderColor = color.cgColor
        view.superview?.layer.borderWidth = 1
        super.viewWillAppear(animated)
    }

    private func getHeaderTitle() -> String {
        switch (selectType) {
        case .ACCOUNT: fallthrough
        case .ACCOUNT2:
            //return multiSelection ? NSLocalizedString("Select Accounts", comment: "") : NSLocalizedString("Select Account", comment: "")
            return NSLocalizedString("Account", comment: "")
        case .CATEGORY:
            //return multiSelection ? NSLocalizedString("Select Categories", comment: "") : NSLocalizedString("Select Category", comment: "")
            return NSLocalizedString("Category", comment: "")
        case .TAG:
            //return multiSelection ? NSLocalizedString("Select Tags", comment: "") : NSLocalizedString("Select Tag", comment: "")
            return NSLocalizedString("Tag", comment: "")
        case .PAYER:
            return NSLocalizedString("Payer", comment: "")
        case .PAYEE:
            return NSLocalizedString("Payee", comment: "")
        case .VENDOR:
            //return multiSelection ? NSLocalizedString("Select Payee/Payers", comment: "") : NSLocalizedString("Select Payee/Payer", comment: "")
            return NSLocalizedString("Payee/Payer", comment: "")
        default:
            return ""
        }
    }

    private func createHeader() {
        let layout = HorizontalLayout(height: headerHeight)

        let spacer = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 30))
        layout.addSubview(spacer)

        let label = UILabel(frame: CGRect(x: 1, y: 0, width: 60, height: 30))
        label.text = NSLocalizedString(getHeaderTitle(), comment: "")
        layout.addSubview(label)

        if multiSelection {
            allSwitch = UISwitch(frame: CGRect(x: 0, y: 0, width: 40, height: 25))
            allSwitch!.addTarget(self, action: #selector(onSelectAllClick), for: .valueChanged)
            layout.addSubview(allSwitch!)

            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            label.text = NSLocalizedString("all", comment: "")
            layout.addSubview(label)
        } else {
            let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 25 + 10, height: 25))
            btn.addTarget(self, action: #selector(onAddClick), for: .touchUpInside)
            btn.setImage(#imageLiteral(resourceName: "ic_action_new").withRenderingMode(.alwaysOriginal), for: .normal)
            btn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10)
            layout.addSubview(btn)
        }
        headerView.addSubview(layout)
    }

    @objc func onSelectAllClick() {
        if multiSelection {
            let on = allSwitch!.isOn
            for ii in 0..<checked.count {
                checked[ii] = on
            }
            tableView.reloadData()
            //okButton.isEnabled = true
        }
    }

    @objc func onAddClick() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateViewController") as! CreateViewController

        vc.modalPresentationStyle = UIModalPresentationStyle.popover
        vc.popoverPresentationController?.sourceView = self.view
        vc.popoverPresentationController?.sourceRect =
            CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        vc.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue:0)
        vc.popoverPresentationController!.delegate = self

        vc.delegate = self
        vc.createType = selectType

        self.present(vc, animated: true, completion: nil)
    }

    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func okButtonPressed(_ sender: UIButton) {
        let ids = getCheckedIds()
        var type: TypePassed = TypePassed(double: 0, int: 0, int64: 0, array64: nil, allSelected: false)

        if multiSelection {
            type.array64 = ids
            type.allSelected = isAllChecked()
        } else {
            if ids.count == 1 {
                type.int64 = ids[0]
            } else {
                type.int64 = 0
            }
        }

        delegate?.passNumberBack(self, type: type, okPressed: true)
        dismiss(animated: true, completion: nil)
    }

    func creationCallback(created: Bool) {
        if (created) {
            reloadTableView()
        }
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selections.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath as IndexPath) {
            cell.accessoryType = .checkmark
        }
        checked[indexPath.row] = true

        if multiSelection {
            //okButton.isEnabled = isAnyChecked()
            allSwitch?.isOn = isAllChecked()
        } else {
            if (myIndexPath != indexPath.row && myIndexPath != -1) {
                checked[myIndexPath] = false
                if let cell = tableView.cellForRow(at: IndexPath(row: myIndexPath, section: 0)) {
                    cell.accessoryType = .none
                }
            }
            myIndexPath = indexPath.row
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath as IndexPath) {
            cell.accessoryType = .none
        }
        checked[indexPath.row] = false

        if multiSelection {
            //okButton.isEnabled = isAnyChecked()
            allSwitch?.isOn = isAllChecked()
        } else {
            myIndexPath = -1;
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "ChooseCell"

        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            as? SelectTableViewCell else {
            fatalError("The dequeued cell is not an instance of SelectTableViewCell.")
        }

        let selection = selections[indexPath.row]
        cell.nameLabel.text = selection.name

        cell.accessoryType = checked[indexPath.row] ? .checkmark : .none
        return cell
    }

    private func getCheckedIds() -> [Int64] {
        var chked: [Int64] = []

        var index = 0
        if !checked.isEmpty {
            for chk in checked {
                if chk {
                    chked.append(selections[index].id)
                }
                index += 1
            }
        }

        return chked
    }

    private func isAnyChecked() -> Bool {
        if !checked.isEmpty {
            for chk in checked {
                if chk {
                    return true
                }
            }
        }
        return false
    }

    private func isAllChecked() -> Bool {
        if !checked.isEmpty {
            for chk in checked {
                if !chk {
                    return false
                }
            }
        }
        return true
    }

    private func wasChecked(id: Int64) -> Bool {
        for val in initValues {
            if val == id {
                return true
            }
        }
        return false
    }

    private func initChecked(id: Int64, index: Int) {
        let chk = wasChecked(id: id)
        checked.append(chk)
        if (myIndexPath == -1 && chk) {
            myIndexPath = index
        }
    }

    func checkIdentifierAndPopulateArray() {
        selections.removeAll()

        var ii = 0
        switch (selectType) {
        case .ACCOUNT: fallthrough
        case .ACCOUNT2:
            for account in DBAccount.instance.getAll() {
                selections.append(NameWithId(name: account.name, id: account.id))
                initChecked(id: account.id, index: ii)
                ii += 1
            }
        case .CATEGORY:
            for category in DBCategory.instance.getAll() {
                selections.append(NameWithId(name: category.name, id: category.id))
                initChecked(id: category.id, index: ii)
                ii += 1
            }
        case .TAG:
            for tag in DBTag.instance.getAll() {
                selections.append(NameWithId(name: tag.name, id: tag.id))
                initChecked(id: tag.id, index: ii)
                ii += 1
            }
        //TODO: separate payer/payee support
        case .PAYER: fallthrough
        case .PAYEE: fallthrough
        case .VENDOR:
            for vendor in DBVendor.instance.getAll() {
                selections.append(NameWithId(name: vendor.name, id: vendor.id))
                initChecked(id: vendor.id, index: ii)
                ii += 1
            }
            break
        default:
            LLog.e("\(self)", "unknown request type")
        }
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }

    func reloadTableView() {
        checkIdentifierAndPopulateArray()
        tableView.reloadData()
    }
}
