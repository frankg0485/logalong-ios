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
    var year: Int = 2018
    var incomes = [Double](repeating: 0, count: 12)
    var expenses = [Double](repeating: 0, count: 12)

    private var isVisible = false
    private var isRefreshPending = false

    override func viewDidLoad() {
        super.viewDidLoad()
        barChartView.superview!.backgroundColor = LTheme.Color.base_bgd_color
        createBarChart()
    }

    override func viewDidAppear(_ animated: Bool) {
        isVisible = true
        if isRefreshPending {
            createBarChart()
        }
        super.viewDidAppear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        isVisible = false
        super.viewDidDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    class MyXAxisValueFormatter: NSObject, IAxisValueFormatter {
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

    class MyYAxisValueFormatter: NSObject, IAxisValueFormatter {
        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            if axis != nil {
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = NumberFormatter.Style.decimal
                return numberFormatter.string(from: NSNumber(value: value)) ?? ""
            }
            return ""
        }
    }

    func createBarChart() {
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
        xAxis.valueFormatter = MyXAxisValueFormatter()

        barChartView.leftAxis.valueFormatter = MyYAxisValueFormatter()
        barChartView.rightAxis.valueFormatter = MyYAxisValueFormatter()

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
            yVals1.append(BarChartDataEntry(x: Double(ii), y: expenses[ii]))
            yVals2.append(BarChartDataEntry(x: Double(ii), y: incomes[ii]))
        }

        let dataSet1 = BarChartDataSet(values: yVals1, label: NSLocalizedString("Expense", comment: ""))
        let dataSet2 = BarChartDataSet(values: yVals2, label: NSLocalizedString("Income", comment: "") + " - " + String(year))

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

    func refresh(year: Int, incomes: [Double]?, expenses: [Double]?) {
        if incomes != nil && expenses != nil {
            self.incomes = incomes!
            self.expenses = expenses!
            self.year = year
        }

        if self.isVisible {
            isRefreshPending = false
            createBarChart()
        } else {
            isRefreshPending = true
        }
    }
}
