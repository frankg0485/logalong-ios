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

    private var isVisible = false
    private var isRefreshPending = false
    private var hasData = false

    var year: Int = 2018
    var expenseCategories = Dictionary<String, Double>()

    var pieEntries = [PieChartDataEntry]()
    var extraPieEntries = [PieChartDataEntry]()
    var subEntries = [(key: String, value: Double)]()
    var lastPieEntry = 0

    var entryView: UIView!
    var headerView: UIView!
    let entryViewTop: CGFloat = 50
    let entryViewWidth: CGFloat = 140
    var entryViewHeight: NSLayoutConstraint!
    var entryViewMaxHeight: CGFloat!
    var headerLabel: UILabel!
    var headerValue: UILabel!
    var tableView: UITableView!
    var centerLabel: UILabel!

    let HEADER_H: CGFloat = 40
    let ENTRY_H: CGFloat = 40
    let FONT_SIZE: CGFloat = 12
    let MAX_PIE_CHART_ITEMS = 12

    let colors: [UIColor] = [
        UIColor(hex: 0xffcc0000),
        UIColor(hex: 0xff9933cc),
        UIColor(hex: 0xffff8a00),
        UIColor(hex: 0xff669900),
        UIColor(hex: 0xff0099cc),

        UIColor(hex: 0xffe21d1d),
        UIColor(hex: 0xffac59d6),
        UIColor(hex: 0xffffa00e),
        UIColor(hex: 0xff7caf00),
        UIColor(hex: 0xff16a5d7),

        UIColor(hex: 0xfff83a3a),
        UIColor(hex: 0xffc182e0),
        UIColor(hex: 0xffffb61c),
        UIColor(hex: 0xff92c500),
        UIColor(hex: 0xff2cb1e1),

        UIColor(hex: 0xffff7979),
        UIColor(hex: 0xffcf9fe7),
        UIColor(hex: 0xffffd060),
        UIColor(hex: 0xffb6db49),
        UIColor(hex: 0xff6dcaec)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = LTheme.Color.base_bgd_color
        //pieChartView.backgroundColor = LTheme.Color.base_bgd_color
        pieChartView.delegate = self

        entryViewMaxHeight = UIScreen.main.bounds.width - 2 * entryViewTop //landscape
        createEntryView()

        centerLabel = UILabel(frame: CGRect(x: UIScreen.main.bounds.height / 2 - 40, y: UIScreen.main.bounds.width / 2, width: 80, height: 30))
        centerLabel.textAlignment = .center
        centerLabel.textColor = UIColor.red
        centerLabel.font = UIFont.systemFont(ofSize: FONT_SIZE)
        view.addSubview(centerLabel)

        createPieChart()
    }

    override func viewDidAppear(_ animated: Bool) {
        let value = UIInterfaceOrientation.landscapeRight.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        tabBarController?.tabBar.isHidden = true

        isVisible = true
        if isRefreshPending {
            createPieChart()
        }
        super.viewDidAppear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        isVisible = false
        super.viewDidDisappear(animated)
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
        headerLabel.layoutMargins.right = 0
        headerLabel.font = UIFont.systemFont(ofSize: FONT_SIZE)
        headerLabel.textColor = UIColor.white
        headerValue = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: HEADER_H))
        headerValue.layoutMargins.left = 3
        headerValue.textAlignment = .right
        headerValue.font = UIFont.systemFont(ofSize: FONT_SIZE)
        headerValue.textColor = UIColor.white
        hl.addSubview(headerLabel)
        hl.addSubview(headerValue)
        vl.addSubview(hl)
        headerView = hl

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

    private func displayEntry(_ color: UIColor) {
        entryView.layer.borderColor = color.cgColor
        headerView.backgroundColor = color

        var height = HEADER_H
        if subEntries.count > 1 {
            height += CGFloat(subEntries.count) * ENTRY_H
        }

        entryViewHeight.constant = height > entryViewMaxHeight ? entryViewMaxHeight : height
        entryView.isHidden = false
        tableView.reloadData()
    }

    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        entryView.isHidden = true
    }

    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {

        let pe: PieChartDataEntry = entry as! PieChartDataEntry
        let index = pieEntries.index(of: pe)

        subEntries.removeAll()

        headerLabel.text = pe.label
        headerValue.text = LA.valueAsCurrency(pe.value)
        headerValue.sizeToFit()
        for kv in getExpenseSubCatsAt(mainCat: pe.label!, index: index!).sorted(by: {$0.value > $1.value}) {
            subEntries.append((key: kv.key, value: kv.value))
        }

        displayEntry(colors[index!])
    }

    private func getExpenseSubCats(_ mainCat: String) -> Dictionary<String, Double> {
        var map = Dictionary<String, Double>()

        for key in expenseCategories.keys {
            let cats = key.components(separatedBy: ":")
            if cats[0] == mainCat {
                map[(cats.count > 1) ? cats[1] : key] = expenseCategories[key]
            }
        }
        return map
    }

    private func getExpenseSubCatsAt(mainCat: String, index: Int) -> Dictionary<String, Double> {
        var map: Dictionary<String, Double>

        if (index == lastPieEntry && extraPieEntries.count > 0) {
            map = Dictionary<String, Double>()
            for entry in extraPieEntries {
                map[entry.label!] = entry.value
            }
        } else {
            map = getExpenseSubCats(mainCat)
        }
        return map
    }

    func createPieChart() {
        pieChartView.centerText = NSLocalizedString("Expense", comment: "") + " - " + String(year)
        pieChartView.drawSlicesUnderHoleEnabled = true
        pieChartView.usePercentValuesEnabled = true

        // group all sub-categories
        var currentExpenseCats =  Dictionary<String, Double>();
        var sum: Double = 0
        for key in expenseCategories.keys {
            sum += expenseCategories[key]!
            let mainCat = key.components(separatedBy: ":")[0]
            if var v = currentExpenseCats[mainCat] {
                v += expenseCategories[key]!
                currentExpenseCats[mainCat] = v
            } else {
                currentExpenseCats[mainCat] = expenseCategories[key]!
            }
        }

        centerLabel.text = LA.valueAsCurrency(sum)

        // group tiny entries
        pieEntries = [PieChartDataEntry]()
        extraPieEntries = [PieChartDataEntry]()

        lastPieEntry = currentExpenseCats.count - 1
        var count = 0
        var lastGroup: String? = nil
        var lastGroupValue: Double = 0

        var list = [String]()
        let threshold = sum * 0.005;
        var lastKey = "";
        var lastValue: Double = 0.0

        for kv in currentExpenseCats.sorted(by: {$0.value > $1.value}) {
            if (count < MAX_PIE_CHART_ITEMS && kv.value > threshold) {
                list.append(kv.key)
            } else {
                if (nil == lastGroup) {
                    if list.count > 0 { list.removeLast() }
                    extraPieEntries.append(PieChartDataEntry(value: lastValue, label: lastKey))

                    lastGroup = lastKey + " ..."
                    lastGroupValue = lastValue
                    lastPieEntry = count - 1;
                }

                extraPieEntries.append(PieChartDataEntry(value: kv.value, label: kv.key))
                lastGroupValue += kv.value
            }

            lastKey = kv.key
            lastValue = kv.value
            count += 1
        }

        if currentExpenseCats.count <= list.count {
            for kv in currentExpenseCats {
                pieEntries.append(PieChartDataEntry(value: kv.value, label: kv.key))
            }
        } else {
            for key in list {
                pieEntries.append(PieChartDataEntry(value: currentExpenseCats[key]!, label: key))
            }
            pieEntries.append(PieChartDataEntry(value: lastGroupValue, label: lastGroup))
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
        pieData.setValueFont(UIFont.systemFont(ofSize: FONT_SIZE - 1))
        pieChartView.data = pieData

        let legend = pieChartView.legend
        //legend.setPosition(Legend.LegendPosition.LEFT_OF_CHART); //deprecated
        legend.verticalAlignment = .top
        legend.horizontalAlignment = .left
        legend.orientation = .vertical
        legend.drawInside = false
        legend.enabled = true
        //legend.setTextSize(11.0f);
        legend.font = UIFont.systemFont(ofSize: FONT_SIZE)
        legend.xOffset = LTheme.Dimension.pie_chart_legend_offset
        legend.yOffset = LTheme.Dimension.pie_chart_legend_offset
        //legend.textWidthMax = 50
        //legend.maxSizePercent = 10
        //legend.wordWrapEnabled = true

        pieChartView.chartDescription?.text = ""

        pieChartView.isHidden = !hasData
        centerLabel.isHidden = !hasData
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subEntries.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ENTRY_H
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(frame: CGRect(x: 0, y: 0, width: entryViewWidth, height: ENTRY_H))
        let hl = HorizontalLayout(height: ENTRY_H)
        let headerLabel = UILabel(frame: CGRect(x: 2, y: 0, width: 0, height: ENTRY_H))
        headerLabel.layoutMargins.right = 5
        headerLabel.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        headerLabel.text = subEntries[indexPath.row].key

        let headerValue = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: ENTRY_H))
        headerValue.layoutMargins.left = 0
        headerValue.textAlignment = .right
        headerValue.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        headerValue.text = LA.valueAsCurrency(subEntries[indexPath.row].value)
        headerValue.sizeToFit()
        hl.addSubview(headerLabel)
        hl.addSubview(headerValue)
        cell.addSubview(hl)

        return cell;
    }

    func refresh(year: Int, data: Dictionary<String, Double>?) {
        hasData = false
        if data != nil {
            if data!.count > 0 {
                pieChartView.isHidden = false
                centerLabel.isHidden = false
                expenseCategories = data!
                self.year = year
                hasData = true
            }
        }

        if isVisible {
            isRefreshPending = false
            createPieChart()
        } else {
            isRefreshPending = true
        }
    }
}
