//
//  TestSearchViewController.swift
//  LogAlong
//
//  Created by Frank Gao on 2/5/23.
//  Copyright © 2023 Swoag Technology. All rights reserved.
//

import UIKit

class TestSearchViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    override func viewDidLoad() {
        displayButton()
    }
    
    private func displayButton() {
        let button = UIButton()
        button.backgroundColor = .green
        button.setTitle("Test Button", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(onButtonClick), for: .touchUpInside)
        button.layer.cornerRadius = 20
        
        self.view.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.5).isActive = true
        button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }
    
    @objc func onButtonClick() {
        presentPopup()
    }
    
    private func presentPopup() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TestSearchPopupController")

        vc.modalPresentationStyle = UIModalPresentationStyle.popover
        vc.popoverPresentationController?.sourceView = self.view
        vc.preferredContentSize = CGSize(width: self.view.frame.width * 0.75, height: self.view.frame.height * 0.75)
        vc.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        vc.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue:0)
        vc.popoverPresentationController!.delegate = self

        self.present(vc, animated: true, completion: nil)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
