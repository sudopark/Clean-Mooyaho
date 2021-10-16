//
//  InnerWebViewView.swift
//  ViewerScene
//
//  Created by sudo.park on 2021/10/16.
//

import UIKit

import Prelude
import Optics

import CommonPresenting


// MARK: - InnerWebViewBottomToolBar


final class InnerWebViewBottomToolBar: BaseUIView {
    
    struct Metric {
        static let height: CGFloat = 104
        static let shrinkHeight: CGFloat = 30
        static let titleHorizontalPadding: CGFloat = 96
        static let titleLabelCenterOffset: CGFloat = 0
        static let titleLabelCenterOffsetShrink: CGFloat = 12
    }
    
    let lineView = UIView()
    
    let topContainerView = RoundShadowView()
    let titleLabel = UILabel()
    let editButton = UIButton()
    let refreshButton = UIButton()
    private var titleLabelWidthRatioConstraint: NSLayoutConstraint!
    private var progressLayer: CAShapeLayer?
    private var titleLabelCenterOffsetConstraint: NSLayoutConstraint!
    
    let stackView = UIStackView()
    let backButton = UIButton()
    let nextButton = UIButton()
    let memoButton = UIButton()
    let readMarkButton = UIButton()
    let safariButton = UIButton()
    
    weak var bottomOffsetConstraint: NSLayoutConstraint?
    
    
    func updateToolbarPosition(by scrollY: CGFloat) {
        
        let smallerThan1 = 1 |> CGFloat.init >>> curry(Swift.min)
        let biggerThan0 = 0 |> CGFloat.init >>> curry(Swift.max)
        
        let distance = Metric.height - Metric.shrinkHeight
        let percent = (scrollY / distance) |> smallerThan1 >>> biggerThan0
        
        self.udpateTopContainerVisibility(by: percent)
        self.updateToolbarBottomOffset(by: percent, distance: distance)
        self.updateTitleLabelTopConstraint(by: percent)
        self.updateTitleLabelRatio(by: percent)
        
    }
    
    private func udpateTopContainerVisibility(by percent: CGFloat) {
        let alpha = 1 - percent
        self.topContainerView.alpha = alpha
        self.stackView.alpha = alpha
    }
    
    private func updateToolbarBottomOffset(by percent: CGFloat, distance: CGFloat) {
        let dy = distance * percent
        let newOffset = Metric.height - dy
        self.bottomOffsetConstraint?.constant = -newOffset
    }
    
    private func updateTitleLabelRatio(by percent: CGFloat) {
        let newPadding = Metric.titleHorizontalPadding * (1 - percent)
        self.titleLabelWidthRatioConstraint.constant = -newPadding
    }
    
    private func updateTitleLabelTopConstraint(by percent: CGFloat) {
        let distance = Metric.titleLabelCenterOffsetShrink - Metric.titleLabelCenterOffset
        let dy = distance * percent
        self.titleLabelCenterOffsetConstraint.constant = -dy
    }
}

extension InnerWebViewBottomToolBar: Presenting {
    
    func setupLayout() {

        self.addSubview(lineView)
        lineView.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
            $0.topAnchor.constraint(equalTo: $1.topAnchor)
            $0.heightAnchor.constraint(equalToConstant: 1)
        }
        
        self.addSubview(topContainerView)
        topContainerView.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 16)
            $0.heightAnchor.constraint(equalToConstant: 36)
        }
        
        topContainerView.addSubview(editButton)
        editButton.autoLayout.active(with: topContainerView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 16)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.widthAnchor.constraint(equalToConstant: 22)
            $0.heightAnchor.constraint(equalToConstant: 22)
        }
        
        topContainerView.addSubview(refreshButton)
        refreshButton.autoLayout.active(with: topContainerView) {
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -16)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.widthAnchor.constraint(equalToConstant: 22)
            $0.heightAnchor.constraint(equalToConstant: 22)
        }
        
        self.addSubview(titleLabel)
        titleLabel.autoLayout.active(with: topContainerView) {
            $0.centerXAnchor.constraint(equalTo: $1.centerXAnchor)
        }
        self.titleLabelCenterOffsetConstraint = titleLabel.centerYAnchor
            .constraint(equalTo: topContainerView.centerYAnchor, constant: 0)
        self.titleLabelCenterOffsetConstraint.isActive = true
        self.titleLabelWidthRatioConstraint = titleLabel.widthAnchor
            .constraint(equalTo: self.topContainerView.widthAnchor, constant: -Metric.titleHorizontalPadding)
        self.titleLabelWidthRatioConstraint.isActive = true
        
        self.addSubview(stackView)
        stackView.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: -8)
        }
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        
        let buttons = [
            self.backButton, self.nextButton, self.readMarkButton, self.memoButton, self.safariButton
        ]
        
        buttons.forEach {
            stackView.addArrangedSubview($0)
            $0.autoLayout.active {
                $0.widthAnchor.constraint(equalToConstant: 40)
                $0.heightAnchor.constraint(equalToConstant: 40)
            }
            $0.contentMode = .scaleAspectFill
        }
    }
    
    func setupStyling() {
        
        self.lineView.backgroundColor = self.uiContext.colors.secondaryTitle.withAlphaComponent(0.1)
        
        _ = self.topContainerView
            |> \.cornerRadius .~ 15
            |> \.fillColor .~ self.uiContext.colors.appBackground
        self.topContainerView.updateLayer()
        
        self.editButton.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        self.editButton.tintColor = self.uiContext.colors.secondaryTitle
        
        let configure = UIImage.SymbolConfiguration(pointSize: 12)
        let closeImage = UIImage(systemName: "xmark", withConfiguration: configure)
        self.refreshButton.setImage(closeImage, for: .normal)
        self.refreshButton.tintColor = self.uiContext.colors.secondaryTitle
        
        _ = self.titleLabel
            |> \.numberOfLines .~ 1
            |> \.textColor .~ self.uiContext.colors.text.withAlphaComponent(0.8)
            |> \.font .~ self.uiContext.fonts.get(12, weight: .regular)
            |> \.textAlignment .~ .center
            |> \.text .~ "https://stackoverflow.com/questions/33922076/wkwebviewcontentinset-makes-content-size-wrong"
        
        self.backButton.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        self.backButton.isEnabled = false
        self.backButton.tintColor = self.uiContext.colors.raw.lightGray
        
        self.nextButton.setImage(UIImage(named: "chevron.right"), for: .normal)
        self.nextButton.isEnabled = false
        self.nextButton.tintColor = self.uiContext.colors.raw.lightGray
        
        self.memoButton.setImage(UIImage(systemName: "note.text"), for: .normal)
        
        self.readMarkButton.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        
        self.safariButton.setImage(UIImage(systemName: "safari"), for: .normal)
    }
}
