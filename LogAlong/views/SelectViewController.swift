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

    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var tableView: UITableView!

    var initValue: Int64!
    var color: UIColor!
    var selectType: SelectType!

    var myIndexPath: Int = 0
    var type: TypePassed = TypePassed(double: 0, int: 0, int64: 0)

    weak var delegate: FViewControllerDelegate?

    var selections: [NameWithId] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredContentSize.width = LTheme.Dimension.popover_width
        self.preferredContentSize.height = LTheme.Dimension.popover_height

        tableView.dataSource = self
        tableView.delegate = self

        checkIdentifierAndPopulateArray()

        //tableView.reloadData()
        if selections.count > 0 {
            DispatchQueue.main.async(execute: {
                let indexPath = IndexPath(row: self.myIndexPath, section: 0)
                self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
            })
        }

        okButton.isEnabled = false
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.view.superview?.layer.borderColor = color.cgColor
        navigationController?.view.superview?.layer.borderWidth = 1
        super.viewWillAppear(animated)
    }

    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func okButtonPressed(_ sender: UIButton) {
        type.int64 = selections[myIndexPath].id

        delegate?.passNumberBack(self, type: type)
        dismiss(animated: true, completion: nil)
        /*       let myVC = storyboard?.instantiateViewController(withIdentifier: "testID") as! AddTableViewController
         myVC.intPassed = myIndexPath

         print("jsnfsjnfjfnkdjf: \(myVC.intPassed)")

         navigationController?.pushViewController(myVC, animated: true)
         dismiss(animated: true, completion: nil)
         popoverPresentationController?.delegate?.popoverPresentationControllerDidDismissPopover?(popoverPresentationController!)*/
    }
/*
    func passCreationBack(creation: NameWithId) {
        var account = LAccount(name: creation.name)
        DBAccount.instance.add(&account)
        LJournal.instance.addAccount(account.id)

        _ = navigationController?.popViewController(animated: true)

        reloadTableView()
    }
*/
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
        okButton.isEnabled = true
        myIndexPath = indexPath.row
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "ChooseCell"

        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            as? SelectTableViewCell else {
            fatalError("The dequeued cell is not an instance of SelectTableViewCell.")
        }

        let selection = selections[indexPath.row]
        cell.nameLabel.text = selection.name

        return cell
    }

    func checkIdentifierAndPopulateArray() {
        var ii = 0
        switch (selectType) {
        case .ACCOUNT: fallthrough
        case .ACCOUNT2:
            for account in DBAccount.instance.getAll() {
                selections.append(NameWithId(name: account.name, id: account.id))
                if (account.id == initValue) {
                    myIndexPath = ii
                }
                ii += 1
            }
        case .CATEGORY:
            for category in DBCategory.instance.getAll() {
                selections.append(NameWithId(name: category.name, id: category.id))
                if (category.id == initValue) {
                    myIndexPath = ii
                }
                ii += 1
            }
        case .TAG:
            for tag in DBTag.instance.getAll() {
                selections.append(NameWithId(name: tag.name, id: tag.id))
                if (tag.id == initValue) {
                    myIndexPath = ii
                }
                ii += 1
            }
        //TODO: separate payer/payee support
        case .PAYER: fallthrough
        case .PAYEE:
            for vendor in DBVendor.instance.getAll() {
                selections.append(NameWithId(name: vendor.name, id: vendor.id))
                if (vendor.id == initValue) {
                    myIndexPath = ii
                }
                ii += 1
            }
            break
        default:
            LLog.e("\(self)", "unknown request type")
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CreateNew" {
            let popoverViewController = segue.destination

            popoverViewController.modalPresentationStyle = UIModalPresentationStyle.popover
            popoverViewController.popoverPresentationController?.sourceRect =
                CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: LTheme.Dimension.popover_anchor_width, height: 0)
            popoverViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue:0)
            popoverViewController.popoverPresentationController!.delegate = self

            popoverViewController.popoverPresentationController?.sourceView = view
        }

        if let secondViewController = segue.destination as? CreateViewController {
            secondViewController.delegate = self
            secondViewController.createType = selectType
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
