//
//  ViewController.swift
//  HQDonutView
//
//  Created by HaiQuan on 2019/1/22.
//  Copyright © 2019 HaiQuan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let donut = HQDonutView.init(frame: CGRect.init(x: 20, y: 74, width: 200, height: 200))
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        donut.layout()
        view.addSubview(donut)
        
        let slider = UISlider.init(frame: CGRect.init(x: 40, y: self.view.frame.height - 40, width: self.view.frame.width - 80, height: 30))
        view.addSubview(slider)
        slider.addTarget(self, action: #selector(ViewController.change(slider:)), for: UIControl.Event.valueChanged)
        
    }
    
    @objc func change(slider:UISlider) {
        
        donut.animateTo(percentage: CGFloat(slider.value))
        
    }
    
}




