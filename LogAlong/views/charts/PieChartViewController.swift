//
//  PieChartViewController.swift
//  LogAlong
//
//  Created by Frank Gao on 10/22/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import UIKit
import Charts

class PieChartViewController: UIViewController, ChartViewDelegate {

    @IBOutlet weak var pieChartView: PieChartView!

    var accounts = DBAccount.instance.getAll()
    var amounts: [Double] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        pieChartView.backgroundColor = LTheme.Color.base_bgd_color
        pieChartView.delegate = self
    }

    func chartValueNothingSelected(_ chartView: ChartViewBase) {
    }
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
    }

    override func viewDidAppear(_ animated: Bool) {

        let value = UIInterfaceOrientation.landscapeRight.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")

        tabBarController?.tabBar.isHidden = true

        accounts = DBAccount.instance.getAll()

        amounts.removeAll()
        for _ in accounts {
            amounts.append((Double(arc4random()) / 0xFFFFFFFF) * (90) + 10)
        }

        createPieChart(accounts: accounts, values: amounts)
    }

    func createPieChart(accounts: [LAccount], values: [Double]) {
        pieChartView.centerText = "Expense - 2018"
        pieChartView.drawSlicesUnderHoleEnabled = true
        pieChartView.usePercentValuesEnabled = true

        /*
        currentExpenseCats.clear();
        currentCharData = chartData;
        // group all sub-categories
        double sum = 0;
        for (String key : chartData.expenseCategories.keySet()) {
            sum += chartData.expenseCategories.get(key);
            String mainCat = key.split(":", -1)[0];
            Double v = currentExpenseCats.get(mainCat);
            if (v == null) {
                currentExpenseCats.put(mainCat, chartData.expenseCategories.get(key));
            } else {
                v += chartData.expenseCategories.get(key);
                currentExpenseCats.put(mainCat, v);
            }
        }
        piechartExpenseSumTV.setText(String.format("$%.2f", sum));

        // group tiny entries
        pieEntries = new ArrayList<>();
        extraPieEntries = new ArrayList<>();
        lastPieEntry = currentExpenseCats.size() - 1;

        int count = 0;
        String lastGroup = null;
        double lastGroupValue = 0;

        List list = new ArrayList<String>();
        double threshold = sum * 0.005;
        String lastKey = "";
        Double lastValue = 0.0;

        for (Map.Entry<String, Double> entry : entriesSortedByValues(currentExpenseCats)) {
            if (count < MAX_PIE_CHART_ITEMS && entry.getValue() > threshold) {
                list.add(entry.getKey());
            } else {
                if (null == lastGroup) {
                    list.remove(lastKey);
                    extraPieEntries.add(new PieEntry(lastValue.floatValue(), lastKey));

                    lastGroup = lastKey + " ...";
                    lastGroupValue = lastValue;
                    lastPieEntry = count - 1;
                }

                extraPieEntries.add(new PieEntry(entry.getValue().floatValue(), entry.getKey()));
                lastGroupValue += entry.getValue();
            }

            lastKey = entry.getKey();
            lastValue = entry.getValue();
            count++;
        }

        if (currentExpenseCats.size() <= list.size()) {
            for (String key : currentExpenseCats.keySet()) {
                pieEntries.add(new PieEntry(currentExpenseCats.get(key).floatValue(), key));
            }
        } else {
            count = 0;
            for (String key : currentExpenseCats.keySet()) {
                if (list.contains(key)) {
                    pieEntries.add(new PieEntry(currentExpenseCats.get(key).floatValue(), key));
                    count++;
                    if (count >= list.size()) break;
                }
            }
            pieEntries.add(new PieEntry((float) lastGroupValue, lastGroup));
        }
        */
        var pieEntries = [PieChartDataEntry]()

        for i in 0..<values.count {
            let entry = PieChartDataEntry()
            entry.y = values[i]
            entry.label = accounts[i].name
            pieEntries.append(entry)
        }
        var colors: [UIColor] = []

        for _ in 0..<values.count {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }

        let set = PieChartDataSet(values: pieEntries, label: "")
        set.sliceSpace = 1.0
        set.selectionShift = 5.0
        set.colors = colors

        /*
         set.setValueLinePart1OffsetPercentage(80.f);
         set.setValueLinePart1Length(0.2f);
         set.setValueLinePart2Length(0.4f);
         //dataSet.setXValuePosition(PieDataSet.ValuePosition.OUTSIDE_SLICE);
         set.setYValuePosition(PieDataSet.ValuePosition.OUTSIDE_SLICE);
         */

        let pieData = PieChartData(dataSet: set)
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 1
        formatter.multiplier = 1.0
        pieData.setValueFormatter(DefaultValueFormatter(formatter: formatter))

        pieData.setValueTextColor(UIColor.white)
        //pieData.setValueTextSize(10.0f);
        pieChartView.data = pieData

        let legend = pieChartView.legend
        //legend.setPosition(Legend.LegendPosition.LEFT_OF_CHART); //deprecated
        legend.verticalAlignment = .top
        legend.horizontalAlignment = .left
        legend.orientation = .vertical
        legend.drawInside = false
        legend.enabled = true
        //legend.setTextSize(11.0f);
        legend.xOffset = LTheme.Dimension.pie_chart_legend_offset
        legend.yOffset = LTheme.Dimension.pie_chart_legend_offset

        pieChartView.chartDescription?.text = ""
    }
}
