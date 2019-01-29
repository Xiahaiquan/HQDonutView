//
//  HQDonutView.swift
//  HQDonutView
//
//  Created by HaiQuan on 2019/1/22.
//  Copyright © 2019 HaiQuan. All rights reserved.
//

import UIKit

class HQDonutView: UIView {

    var fromColour = UIColor.white
    var toColour = UIColor.blue
    var baseColour = UIColor.gray

    var lineWidth: CGFloat = 20
    var duration: CGFloat = 2
    var fromPercentage: CGFloat = 0

    var maskLayer = CAShapeLayer()
    var rotateView = UIView()

    func layout() {


        //vars
        let dimension = self.frame.size.width;

        //1. layout views

        //1.1 layout base track
        let donut = UIBezierPath.init(ovalIn: CGRect.init(x: lineWidth / 2, y: lineWidth / 2, width: dimension - lineWidth, height: dimension - lineWidth))
        let baseTrack = CAShapeLayer()
        baseTrack.path = donut.cgPath
        baseTrack.lineWidth = lineWidth
        baseTrack.fillColor =  UIColor.clear.cgColor
        baseTrack.strokeStart = 0
        baseTrack.strokeEnd = 0
        baseTrack.strokeColor = baseColour.cgColor
        baseTrack.lineCap = CAShapeLayerLineCap.butt
        layer.addSublayer(baseTrack)


        //1.2 clipView has mask applied to it
        let clipView = UIView()
        clipView.frame = self.bounds
        self.addSubview(clipView)


        //1.3 rotateView transforms with strokeEnd
        rotateView.frame = self.bounds
        clipView.addSubview(rotateView)

        //1.4 radialGradient holds an image of the colours
        let radialGradient = UIImageView()
        radialGradient.frame = self.bounds
        rotateView.addSubview(radialGradient)

        //2. create colours fromColour --> toColour and add to an array

        //2.1 holds all colours between fromColour and toColour
        var spectrumColours = [UIColor]()


        //2.2 get RGB values for both colours
        //fromRed, fromGreen etc
        var fR: CGFloat = 0, fG: CGFloat = 0, fB: CGFloat = 0
        fromColour.getRed(&fR, green: &fG, blue: &fB, alpha: nil)

        //toRed, toGreen etc
        var tR: CGFloat = 0, tG: CGFloat = 0, tB: CGFloat = 0
        toColour.getRed(&tR, green: &tG, blue: &tB, alpha: nil)

        //2.3 determine increment between fromRed and toRed etc.
        let numberOfColours = 360;
        let dR = (tR-fR)/CGFloat(numberOfColours-1);
        let dG = (tG-fG)/CGFloat(numberOfColours-1);
        let dB = (tB-fB)/CGFloat(numberOfColours-1);

        //2.4 loop through adding incrementally different colours
        //this is a gradient fromColour --> toColour
        for n in 0 ..< numberOfColours {
            spectrumColours.append(UIColor.init(red: (fR+CGFloat(n)*dR), green: (fG+CGFloat(n)*dG), blue: (fB+CGFloat(n)*dB), alpha: 1))
        }


        //3. create a radial image using the spectrum colours
        //go through adding the next colour at an increasing angle

        //3.1 setup
        let radius = min(dimension, dimension) / 2
        let angle = Double(2) * Double.pi/Double(numberOfColours);
        var bezierPath = UIBezierPath()
        let center = CGPoint.init(x: dimension/2, y: dimension/2)

        UIGraphicsBeginImageContextWithOptions(CGSize.init(width: dimension, height: dimension), true, 0)
        UIRectFill(CGRect.init(x: 0, y: 0, width: dimension, height: dimension))

        //3.2 loop through pulling the colour and adding
        for n in 0 ..< numberOfColours {

            let colour = spectrumColours[n]
            colour.setFill()
            colour.setStroke()

            bezierPath = UIBezierPath.init(arcCenter: center, radius: radius, startAngle: CGFloat(Double(n) * angle), endAngle: CGFloat(Double(n + 1) * angle), clockwise: true)
            bezierPath.addLine(to: center)
            bezierPath.close()
            bezierPath.fill()
            bezierPath.stroke()
        }

        //3.3 create image, add to the radialGradient and end

        radialGradient.image = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        //4. create a dot to add to the rotating view
        //this covers the connecting line between the two colours

        //4.1 set up vars
        let containsDots = (Double.pi * Double( dimension)) /*circumference*/ / 10; //number of dots in circumference

        let colourIndex = roundf(Float((Double( numberOfColours) / containsDots) * (containsDots-0.5))); //the nearest colour for the dot
        //the closest colour
        let closestColour = spectrumColours[Int(colourIndex)]

        //4.2 create dot

        let dot = UIImageView()
        dot.frame = CGRect.init(x: dimension - lineWidth, y: (dimension - lineWidth) / 2, width: lineWidth, height: lineWidth)
        dot.layer.cornerRadius = lineWidth / 2
        dot.backgroundColor = closestColour
        rotateView.addSubview(dot)

        //5. create the mask
        maskLayer = CAShapeLayer()
        maskLayer.path = donut.cgPath
        maskLayer.lineWidth = lineWidth
        maskLayer.fillColor = UIColor.clear.cgColor
        maskLayer.strokeStart = 0
        maskLayer.strokeEnd = 1
        maskLayer.strokeColor = UIColor.black.cgColor
        maskLayer.lineCap = CAShapeLayerLineCap.round

        //5.1 apply the mask and rotate all by -90 (to move to the 12 position)
        clipView.layer.mask = maskLayer
        clipView.transform = CGAffineTransform.init(rotationAngle: CGFloat(rad(value:-90)))

    }


    func animateTo(percentage: CGFloat) {

        let difference = fabsf(Float(fromPercentage - percentage));
        let fixedDuration = CGFloat(difference) * duration;

        //1. animate stroke End
        let strokeEndAnimation = CABasicAnimation.init(keyPath: "strokeEnd")
        strokeEndAnimation.duration = CFTimeInterval(fixedDuration)
        strokeEndAnimation.fromValue = fromPercentage
        strokeEndAnimation.toValue = percentage
        strokeEndAnimation.fillMode = CAMediaTimingFillMode.forwards
        strokeEndAnimation.isRemovedOnCompletion = false
        strokeEndAnimation.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.linear)
        maskLayer.add(strokeEndAnimation, forKey: "strokeEndAnimation")

        //2. animate rotation of rotateView
        let viewRotationAnimation = CABasicAnimation.init(keyPath: "transform.rotation.z")
        viewRotationAnimation.duration = CFTimeInterval(fixedDuration)
        viewRotationAnimation.fromValue = rad(value: Double(360 * fromPercentage))
        viewRotationAnimation.toValue = rad(value: Double(360 * percentage))
        viewRotationAnimation.fillMode = CAMediaTimingFillMode.forwards
        viewRotationAnimation.isRemovedOnCompletion = false
        viewRotationAnimation.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.linear)
        rotateView.layer.add(viewRotationAnimation, forKey: "transform.rotation.z")

        //3. update from percentage
        fromPercentage = percentage;

    }

}

extension HQDonutView {
    fileprivate func rad (value:Double) -> Double {

        return value * Double.pi / 180.0

    }
}

