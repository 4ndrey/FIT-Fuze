//
//  UIColor+Ext.swift
//  FIT Fuze
//
//  Created by Andrei Toropchin on 24.02.19.
//  Copyright © 2019 FIT. All rights reserved.
//

import UIKit

extension UIColor {

    static var main: UIColor {
        return UIColor(red: 54/255.0, green: 170/255.0, blue: 220/255.0, alpha: 1.0)
    }

    static var superset: UIColor {
        return main.withAlphaComponent(0.2)
    }

    static var edit: UIColor {
        return UIColor(red: 0/255.0, green: 213/255.0, blue: 127/255.0, alpha: 1.0)
    }

    static var mainTransparent: UIColor {
        return UIColor(red: 54/255.0, green: 170/255.0, blue: 220/255.0, alpha: 0.5)
    }

    static var failure: UIColor {
        return UIColor(red: 192/255.0, green: 57/255.0, blue: 43/255.0, alpha: 1)
    }

    static var workoutColors: [UIColor] {
        let zero = UIColor(red: 84/255.0, green: 194/255.0, blue: 1, alpha: 1)
        let first = UIColor(red: 216/255.0, green: 0, blue: 1, alpha: 1)
        let second = UIColor(red: 1, green: 90/255.0, blue: 0, alpha: 1)
        let third = UIColor(red: 1, green: 245/255.0, blue: 0, alpha: 1)
        let forth = UIColor(red: 0, green: 1, blue: 55/255.0, alpha: 1)
        let fifth = UIColor(red: 0, green: 1, blue: 235/255.0, alpha: 1)
        return [zero, first, second, third, forth, fifth]
    }

}
