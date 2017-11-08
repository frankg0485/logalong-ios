//
//  BarChartViewController.swift
//  LogAlong
//
//  Created by Frank Gao on 10/30/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import UIKit
import Charts

class BarChartViewController: UIViewController {

    @IBOutlet weak var barChartView: BarChartView!

    let accounts = RecordDB.instance.getAccounts()
    var amounts: [Double] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        for _ in accounts {
            amounts.append((Double(arc4random()) / 0xFFFFFFFF) * (90) + 10)
        }

        createBarChart(accounts: accounts, values: amounts)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func createBarChart(accounts: [Account], values: [Double]) {
        var entries = [BarChartDataEntry]()

        for i in 0..<accounts.count {
            let dataPoint = BarChartDataEntry(x: Double(i), y: values[i])
            entries.append(dataPoint)
        }

        let set = BarChartDataSet(values: entries, label: "")

        var colors: [UIColor] = []

        for _ in 0..<values.count {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        set.colors = colors

        let data = BarChartData(dataSet: set)

        barChartView.data = data
        barChartView.chartDescription?.text = ""
        //barChartView.legend.formSize = 15
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
