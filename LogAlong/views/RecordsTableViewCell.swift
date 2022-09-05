//
//  RecordsTableViewCell.swift
//  LogAlong
//
//  Created by Frank Gao on 3/6/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import UIKit

class RecordsTableViewCell: UITableViewCell {

    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var tagLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        categoryLabel.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        dateLabel.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func showRecord(_ record: LTransaction) {
        guard let acnt = DBAccount.instance.get(id: record.accountId) else { return }
        if (record.type == TransactionType.TRANSFER) {
            if let acnt2 = DBAccount.instance.get(id: record.accountId2) {
                categoryLabel.text = acnt.name + " --> " + acnt2.name
            } else {
                categoryLabel.text = acnt.name + " -->"
            }
        } else if (record.type == TransactionType.TRANSFER_COPY) {
            if let acnt2 = DBAccount.instance.get(id: record.accountId2) {
                categoryLabel.text = acnt.name + " <-- " + acnt2.name
            } else {
                categoryLabel.text = "--> " + acnt.name
            }
        } else {
            if  let cat = DBCategory.instance.get(id: record.categoryId) {
                if let tag = DBTag.instance.get(id: record.tagId) {
                    categoryLabel.text = cat.name + ":" + tag.name
                } else {
                    categoryLabel.text = cat.name
                }
            } else if let tag = DBTag.instance.get(id: record.tagId) {
                categoryLabel.text = tag.name
            } else {
                categoryLabel.text = ""
            }
        }

        if let vendor = DBVendor.instance.get(id: record.vendorId) {
            tagLabel.text = vendor.name
        } else if !record.note.isEmpty {
            tagLabel.text = record.note
        } else {
            tagLabel.text = ""
        }

        switch (record.type) {
        case .INCOME:
            amountLabel.textColor = LTheme.Color.base_green
        case .EXPENSE:
            amountLabel.textColor = LTheme.Color.base_red
        default:
            amountLabel.textColor = LTheme.Color.base_blue
        }
        amountLabel.text = String(format: "%.2f", record.amount)

        let date = Date(milliseconds: record.timestamp)
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateStyle = .medium
        let dateString = dayTimePeriodFormatter.string(from: date)
        dateLabel.text = dateString
    }
}
