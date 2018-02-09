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

    let accounts = DBAccount.instance.getAll()
    var amounts: [Double] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        for _ in accounts {
            amounts.append((Double(arc4random()) / 0xFFFFFFFF) * (90) + 10)
        }

        createBarChart(accounts: accounts, values: amounts)
        // Do any additional setup after loading the view.

        barChartView.superview!.backgroundColor = LTheme.Color.base_bgd_color
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    class MyAxisValueFormatter: NSObject, IAxisValueFormatter {
        private let months: [String] = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            if let axis = axis {
                let percent = value / (axis.axisRange)
                if (percent >= 0 && value >= 0) {
                    let mp = Double(months.count) * percent
                    if mp >= 0 && mp <= 11 {
                        return months[Int(mp)]
                    }
                }
            }
            return ""
        }
    }

    func createBarChart(accounts: [LAccount], values: [Double]) {
        barChartView.chartDescription?.text =  ""

        // scaling can now only be done on x- and y-axis separately
        barChartView.pinchZoomEnabled = false
        //barChart.setTouchEnabled(false);
        barChartView.scaleXEnabled = false
        barChartView.doubleTapToZoomEnabled = false
        barChartView.highlightPerTapEnabled = false
        barChartView.highlightPerDragEnabled = false

        let xAxis = barChartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.drawGridLinesEnabled = false
        xAxis.granularity = 1
        xAxis.centerAxisLabelsEnabled = true
        //xAxis.setLabelRotationAngle(15f);
        xAxis.labelCount = 13
        //xAxis.setLabelCount(13, true);
        xAxis.valueFormatter = MyAxisValueFormatter()

        barChartView.leftAxis.drawGridLinesEnabled = false
        barChartView.drawBarShadowEnabled = false
        barChartView.drawGridBackgroundEnabled = false

        let legend = barChartView.legend
        legend.verticalAlignment = .top
        legend.horizontalAlignment = .left
        legend.orientation = .horizontal
        legend.drawInside = true

        var yVals1 = [BarChartDataEntry]()
        var yVals2 = [BarChartDataEntry]();
        for ii in 0..<12 {
            yVals1.append(BarChartDataEntry(x: Double(ii), y: Double(arc4random_uniform(10000))))
            yVals2.append(BarChartDataEntry(x: Double(ii), y: Double(arc4random_uniform(10000))))
        }

        let dataSet1 = BarChartDataSet(values: yVals1, label: "Expense");
        let dataSet2 = BarChartDataSet(values: yVals2, label: "Income - 2018")

        dataSet1.colors = [UIColor.red]
        dataSet1.drawValuesEnabled = false

        dataSet2.colors = [UIColor.green]
        dataSet2.drawValuesEnabled = false

        var dataSets = [BarChartDataSet]();
        dataSets.append(dataSet1);
        dataSets.append(dataSet2);

        let data = BarChartData(dataSets: dataSets)

        barChartView.data = data

        let groupSpace = 0.25
        let barSpace = 0.0 // x2 DataSet
        let barWidth = 0.375 // x2 DataSet
        // (barSpace + barWidth) * 2 + groupSpace = 1.00 -> interval per "group"
        barChartView.barData?.barWidth = barWidth
        barChartView.xAxis.axisMinimum = 0
        barChartView.xAxis.axisMaximum = 12
        barChartView.groupBars(fromX: 0, groupSpace: groupSpace, barSpace: barSpace)
    }
}
