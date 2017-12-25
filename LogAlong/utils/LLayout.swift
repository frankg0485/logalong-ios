//
//  LLayout.swift
//  LogAlong
//
//  Created by Michael Gao on 12/24/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import UIKit

class HorizontalLayout : UIView {
    var xOffsets: [CGFloat] = []

    init(height: CGFloat) {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: height))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        var width : CGFloat = 0
        var fillerView: UIView?

        for ii in 0..<subviews.count {
            let view = subviews[ii] as UIView
            view.layoutSubviews()

            width += xOffsets[ii]
            if (view.frame.width > 0) {
                width += view.frame.width + view.layoutMargins.left + view.layoutMargins.right
            } else {
                fillerView = view
            }
        }

        if (width < superview!.frame.width && fillerView != nil) {
            fillerView!.frame.size.width = superview!.frame.width - width
                - fillerView!.layoutMargins.left - fillerView!.layoutMargins.right
        }

        width = 0
        for ii in 0..<subviews.count {
            let view = subviews[ii] as UIView
            view.layoutSubviews()

            width += xOffsets[ii] + view.layoutMargins.left
            view.frame.origin.x = width
            width += view.frame.width + view.layoutMargins.right
        }

        self.frame.size.width = width
    }

    override func addSubview(_ view: UIView) {
        xOffsets.append(view.frame.origin.x)
        super.addSubview(view)
    }
}
