//
//  StockChartView .swift
//  CaveTickers
//
//  Created by 1 on 2023/11/17.
//

import UIKit

class StockChartView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
//        addSubview(chartView)
    }

    struct ViewModel {
        let data: [Double]
        let showLegend: Bool
        let showAxis: Bool
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
    }

    func reset() {
        
    }

    func configure(with viewModel: ViewModel){
        
    }
}
