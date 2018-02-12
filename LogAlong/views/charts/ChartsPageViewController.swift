//
//  ChartsPageViewController.swift
//  LogAlong
//
//  Created by Michael Gao on 2/7/18.
//  Copyright © 2018 Swoag Technology. All rights reserved.
//

import UIKit

class ChartsPageViewController: UIPageViewController/*, UIPageViewControllerDataSource, UIPageViewControllerDelegate*/,
UIPopoverPresentationControllerDelegate {

    var pieVC: PieChartViewController!
    var barVC: BarChartViewController!
    //var barVC: PieChartViewController!
    var chartBtn: UIButton!
    var bottomBar: HorizontalLayout!
    var showingPieChart = true

    override func viewDidLoad() {
        super.viewDidLoad()
        if let d = UIApplication.shared.delegate as? AppDelegate {
            d.shouldRotate = true
        }

        setupViewControllers()
        setViewControllers([pieVC!], direction: .forward, animated: true, completion: nil)
        showingPieChart = true

        setupButtons()
    }

    override func viewWillDisappear(_ animated: Bool) {
        if let d = UIApplication.shared.delegate as? AppDelegate {
            d.shouldRotate = false
            UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
        }
    }

    @objc func onChartClick() {
        let nextVC = showingPieChart ? barVC : pieVC
        let direction: UIPageViewControllerNavigationDirection = showingPieChart ? .forward : .reverse
        setViewControllers([nextVC], direction: direction, animated: true, completion: { (complete) -> Void in
            if (complete) {
                self.showingPieChart = !self.showingPieChart
                if self.showingPieChart {
                    self.chartBtn.setImage(#imageLiteral(resourceName: "chart_light").withRenderingMode(.alwaysOriginal), for: .normal)
                } else {
                    self.chartBtn.setImage(#imageLiteral(resourceName: "pie_chart_light").withRenderingMode(.alwaysOriginal), for: .normal)
                }
                self.bottomBar.refresh()
            }
        })
    }

    @objc func onSearchClick() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchViewController")

        vc.modalPresentationStyle = UIModalPresentationStyle.popover
        vc.popoverPresentationController?.sourceView = self.view
        vc.popoverPresentationController?.sourceRect =
            CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY - 22, width: 0, height: 0)
        vc.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue:0)
        vc.popoverPresentationController!.delegate = self

        self.present(vc, animated: true, completion: nil)
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }

    @objc func onCancelClick() {
        dismiss(animated: true, completion: nil)
    }

    private func setupButtons() {
        let BTN_W: CGFloat = LTheme.Dimension.bar_button_width
        let BTN_H: CGFloat = LTheme.Dimension.bar_button_height
        let BTN_S: CGFloat = 15 //LTheme.Dimension.bar_button_space
        let BAR_H: CGFloat = 30

        bottomBar = HorizontalLayout(height: BAR_H)

        chartBtn = UIButton(type: .system)
        chartBtn.addTarget(self, action: #selector(self.onChartClick), for: .touchUpInside)
        chartBtn.setImage(#imageLiteral(resourceName: "chart_light").withRenderingMode(.alwaysOriginal), for: .normal)
        chartBtn.frame = CGRect(x: 0, y: 0, width: BTN_W + BTN_S, height: BTN_H)
        chartBtn.imageEdgeInsets = UIEdgeInsetsMake(0, BTN_S, 0, 0)

        let searchBtn = UIButton(type: .system)
        searchBtn.addTarget(self, action: #selector(self.onSearchClick), for: .touchUpInside)
        searchBtn.setImage(#imageLiteral(resourceName: "ic_action_search").withRenderingMode(.alwaysOriginal), for: .normal)
        searchBtn.frame = CGRect(x: 0, y: 0, width: BTN_W + BTN_S, height: BTN_H)
        searchBtn.imageEdgeInsets = UIEdgeInsetsMake(0, BTN_S, 0, 0)

        let leftBtn = UIButton(type: .system)
        leftBtn.setImage(#imageLiteral(resourceName: "ic_action_left").withRenderingMode(.alwaysOriginal), for: .normal)
        leftBtn.frame = CGRect(x: 0, y: 0, width: BTN_W + BTN_S, height: BTN_H)
        leftBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, BTN_S)

        let rightBtn = UIButton(type: .system)
        rightBtn.setImage(#imageLiteral(resourceName: "ic_action_right").withRenderingMode(.alwaysOriginal), for: .normal)
        rightBtn.frame = CGRect(x: 0, y: 0, width: BTN_W + BTN_S, height: BTN_H)
        rightBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, BTN_S)

        let spacer = UIView(frame: CGRect(x: 1, y: 0, width: 0, height: BTN_H))

        bottomBar.addSubview(chartBtn)
        bottomBar.addSubview(searchBtn)
        bottomBar.addSubview(spacer)
        bottomBar.addSubview(leftBtn)
        bottomBar.addSubview(rightBtn)
        view.addSubview(bottomBar)

        let cancelBtn = UIButton(type: .system)
        cancelBtn.addTarget(self, action: #selector(self.onCancelClick), for: .touchUpInside)
        cancelBtn.setImage(#imageLiteral(resourceName: "ic_action_cancel").withRenderingMode(.alwaysOriginal), for: .normal)
        cancelBtn.frame = CGRect(x: 0, y: 0, width: BTN_W + BTN_S, height: BTN_H)
        cancelBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, BTN_S)
        view.addSubview(cancelBtn)

        // apply layout constraints after veiw has been added to hierarchy
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: bottomBar, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal,
                           toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: bottomBar, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal,
                           toItem: view, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: bottomBar, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal,
                           toItem: view, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: bottomBar, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal,
                           toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: BAR_H).isActive = true

        cancelBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: cancelBtn, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal,
                           toItem: view, attribute: NSLayoutAttribute.topMargin, multiplier: 1.0, constant: 5).isActive = true
        NSLayoutConstraint(item: cancelBtn, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal,
                           toItem: view, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: cancelBtn, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal,
                           toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: BTN_W + BTN_S).isActive = true
        NSLayoutConstraint(item: cancelBtn, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal,
                           toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: BTN_H).isActive = true

    }

    private func setupViewControllers() {
        pieVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PieChartViewController") as? PieChartViewController
        //barVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PieChartViewController") as? PieChartViewController
        barVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BarChartViewController") as? BarChartViewController
    }

    //@objc func canRotate() -> Void {}
}
