//
//  PieChartViewController.swift
//  LogAlong
//
//  Created by Frank Gao on 10/22/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import UIKit
import Charts

class PieChartViewController: UIViewController, ChartViewDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var pieChartView: PieChartView!

    var accounts = DBAccount.instance.getAll()
    var amounts: [Double] = []
    var entryView: UIView!
    let entryViewTop: CGFloat = 50
    let entryViewWidth: CGFloat = 140
    var entryViewHeight: NSLayoutConstraint!
    var entryViewMaxHeight: CGFloat!
    var headerLabel: UILabel!
    var headerValue: UILabel!
    var tableView: UITableView!

    let HEADER_H: CGFloat = 40
    let ENTRY_H: CGFloat = 40
    let FONT_SIZE: CGFloat = 12


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = LTheme.Color.base_bgd_color
        //pieChartView.backgroundColor = LTheme.Color.base_bgd_color
        pieChartView.delegate = self

        entryViewMaxHeight = UIScreen.main.bounds.width - 2 * entryViewTop //landscape
        createEntryView()

        let centerLabel = UILabel(frame: CGRect(x: UIScreen.main.bounds.height / 2 - 40, y: UIScreen.main.bounds.width / 2, width: 80, height: 30))
        centerLabel.textAlignment = .center
        centerLabel.textColor = UIColor.red
        centerLabel.font = UIFont.systemFont(ofSize: FONT_SIZE)
        centerLabel.text = "$9912345.67"
        view.addSubview(centerLabel)
    }

    private func createEntryView() {
        entryView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        entryView.layer.borderColor = UIColor.red.cgColor
        entryView.layer.borderWidth = 1
        entryView.layer.cornerRadius = 5
        entryView.clipsToBounds = true

        let vl = VerticalLayout(width: entryViewWidth)
        let hl = HorizontalLayout(height: HEADER_H)
        hl.backgroundColor = UIColor.red
        hl.layoutMargins.top = 0
        hl.layoutMargins.bottom = 0

        headerLabel = UILabel(frame: CGRect(x: 2, y: 0, width: 0, height: HEADER_H))
        headerLabel.text = "House"
        headerLabel.font = UIFont.systemFont(ofSize: FONT_SIZE)
        headerLabel.textColor = UIColor.white
        headerValue = UILabel(frame: CGRect(x: 3, y: 0, width: 0, height: HEADER_H))
        //headerValue.textAlignment = .right
        headerValue.text = "$53298.85"
        headerValue.font = UIFont.systemFont(ofSize: FONT_SIZE)
        headerValue.textColor = UIColor.white
        hl.addSubview(headerLabel)
        hl.addSubview(headerValue)
        vl.addSubview(hl)

        tableView = UITableView(frame: CGRect(x: 0, y: 1, width: entryViewWidth, height: 0))
        tableView.layoutMargins.top = 0
        tableView.layoutMargins.bottom = 0
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        vl.addSubview(tableView)

        entryView.addSubview(vl)
        view.addSubview(entryView)

        entryView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: entryView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal,
                           toItem: view, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: entryViewTop).isActive = true
        NSLayoutConstraint(item: entryView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal,
                           toItem: view, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: -8).isActive = true

        NSLayoutConstraint(item: entryView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal,
                           toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: entryViewWidth).isActive = true
        entryViewHeight = NSLayoutConstraint(item: entryView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal,
                           toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: entryViewMaxHeight)

        entryViewHeight.isActive = true
        entryView.isHidden = true
    }

    private func displayEntry() {
        let height = HEADER_H + 3 * ENTRY_H

        entryViewHeight.constant = height > entryViewMaxHeight ? entryViewMaxHeight : height
        entryView.isHidden = false
        tableView.reloadData()
    }

    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        entryView.isHidden = true
    }

    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {

        displayEntry()
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

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ENTRY_H
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(frame: CGRect(x: 0, y: 0, width: entryViewWidth, height: ENTRY_H))
        let hl = HorizontalLayout(height: ENTRY_H)
        headerLabel = UILabel(frame: CGRect(x: 2, y: 0, width: 0, height: ENTRY_H))
        headerLabel.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        headerLabel.text = "test"

        headerValue = UILabel(frame: CGRect(x: 3, y: 0, width: 0, height: ENTRY_H))
        headerValue.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        headerValue.text = "1234.56"
        hl.addSubview(headerLabel)
        hl.addSubview(headerValue)
        cell.addSubview(hl)

        return cell;
    }
}
