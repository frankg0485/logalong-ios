//
//  LLayout.swift
//  LogAlong
//
//  Created by Michael Gao on 12/24/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import UIKit

class LLayout: UIView {
    var weights: [CGFloat] = []

    init(width: CGFloat, height: CGFloat) {
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public func refresh() {
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
}

class HorizontalLayout : LLayout {

    init(height: CGFloat) {
        super.init(width: 0, height: height)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        if nil == superview {
            LLog.w("\(self)", "unexpected layout request before superview presence.")
            return
        }

        var weightSum: CGFloat = 0
        var width : CGFloat = 0

        //print("layout subviews ............")
        for ii in 0..<subviews.count {
            let view = subviews[ii] as UIView
            if view.isHidden {
                continue
            }
            view.layoutSubviews()
            if (weights[ii] == 0) {
                width += view.frame.width + view.layoutMargins.left + view.layoutMargins.right
            } else {
                width += view.layoutMargins.left + view.layoutMargins.right
                weightSum += weights[ii]
            }
        }

        if (width < superview!.frame.width) {
            let space = superview!.frame.width - width
            for ii in 0..<subviews.count {
                let view = subviews[ii] as UIView
                if view.isHidden {
                    continue
                }
                if weights[ii] != 0 {
                    view.frame.size.width = (space * weights[ii]) / weightSum
                }
            }
        }

        width = 0
        for ii in 0..<subviews.count {
            let view = subviews[ii] as UIView
            if view.isHidden {
                continue
            }
            view.center.y = self.center.y - self.frame.origin.y
            view.layoutSubviews()

            width += view.layoutMargins.left
            view.frame.origin.x = width
            width += view.frame.width + view.layoutMargins.right
        }
        self.frame.size.width = width.rounded()
    }

    override func addSubview(_ view: UIView) {
        weights.append(view.frame.origin.x)
        view.frame.origin.x = 0

        super.addSubview(view)
    }
}

class VerticalLayout : LLayout {

    init(width: CGFloat) {
        super.init(width: width, height: 0)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        if nil == superview {
            LLog.w("\(self)", "unexpected layout request before superview presence.")
            return
        }

        var weightSum: CGFloat = 0
        var height : CGFloat = 0

        //print("layout subviews ............")
        for ii in 0..<subviews.count {
            let view = subviews[ii] as UIView
            if view.isHidden {
                continue
            }
            view.layoutSubviews()
            if (weights[ii] == 0) {
                height += view.frame.height + view.layoutMargins.top + view.layoutMargins.bottom
            } else {
                height += view.layoutMargins.top + view.layoutMargins.bottom
                weightSum += weights[ii]
            }
        }

        if (height < superview!.frame.height) {
            let space = superview!.frame.height - height
            for ii in 0..<subviews.count {
                let view = subviews[ii] as UIView
                if view.isHidden {
                    continue
                }
                if weights[ii] != 0 {
                    view.frame.size.height = (space * weights[ii]) / weightSum
                }
            }
        }

        height = 0
        for ii in 0..<subviews.count {
            let view = subviews[ii] as UIView
            if view.isHidden {
                continue
            }
            view.center.x = self.center.x - self.frame.origin.x
            view.layoutSubviews()

            height += view.layoutMargins.top
            view.frame.origin.y = height
            height += view.frame.height + view.layoutMargins.bottom
        }

        self.frame.size.height = height
    }

    override func addSubview(_ view: UIView) {
        weights.append(view.frame.origin.y)
        view.frame.origin.y = 0

        super.addSubview(view)
    }
}
