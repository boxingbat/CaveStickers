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
    }

    struct ViewModel {
        let data: [Double]
        let ShowLegend: Bool
        let ShowAxis: Bool
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
