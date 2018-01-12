//
//  UsersTableViewCell.swift
//  LogAlong
//
//  Created by Frank Gao on 12/30/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import UIKit

class UsersTableViewCell: UITableViewCell {

    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var shareStatusButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
