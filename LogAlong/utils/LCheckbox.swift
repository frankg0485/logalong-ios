//
//  LCheckbox.swift
//  LogAlong
//
//  Created by Michael Gao on 3/1/18.
//  Copyright © 2018 Swoag Technology. All rights reserved.
//

import UIKit

class LCheckbox: UIButton
{
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setImage(#imageLiteral(resourceName: "btn_check_off_holo_light").withRenderingMode(.alwaysOriginal), for: .normal)
        self.setImage(#imageLiteral(resourceName: "btn_check_off_disable_holo_light").withRenderingMode(.alwaysOriginal), for: .disabled)
        self.setImage(#imageLiteral(resourceName: "btn_check_on_holo_light").withRenderingMode(.alwaysOriginal), for: .selected)
        self.setImage(#imageLiteral(resourceName: "btn_check_on_disabled_holo_light").withRenderingMode(.alwaysOriginal), for: [.disabled, .selected])
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setImage(#imageLiteral(resourceName: "btn_check_off_holo_light").withRenderingMode(.alwaysOriginal), for: .normal)
        self.setImage(#imageLiteral(resourceName: "btn_check_off_disable_holo_light").withRenderingMode(.alwaysOriginal), for: .disabled)
        self.setImage(#imageLiteral(resourceName: "btn_check_on_holo_light").withRenderingMode(.alwaysOriginal), for: .selected)
        self.setImage(#imageLiteral(resourceName: "btn_check_on_disabled_holo_light").withRenderingMode(.alwaysOriginal), for: [.disabled, .selected])
    }
}
