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
    private let progressView = UIView()
    private var titleLabelCenterOffsetConstraint: NSLayoutConstraint!
    private var progressPercentWidthConstraint: NSLayoutConstraint!
    
    let stackView = UIStackView()
    let backButton = UIButton()
    let nextButton = UIButton()
    let memoButton = UIButton()
    let readMarkButton = UIButton()
    let jumpFolderButton = UIButton()
    let safariButton = UIButton()
    
    weak var bottomOffsetConstraint: NSLayoutConstraint?
    
    func hideEditingViews() {
        let buttons = [self.memoButton, self.readMarkButton, self.editButton]
        buttons.forEach {
            $0.alpha = 0
            $0.isEnabled = false
        }
    }
    
    func hideJumping() {
        self.jumpFolderButton.isHidden = true
    }
}


// MARK: - udpate view position

extension InnerWebViewBottomToolBar {
    
    func hideOrShowToolbarWithAnimation(_ hide: Bool) {
     
        let percent: CGFloat = hide ? 1 : 0
        
        self.updateToolbarBottomOffset(by: percent)
        self.updateTitleLabelTopConstraint(by: percent)
        
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.udpateTopContainerVisibility(by: percent)
            self?.layoutIfNeeded()
            self?.superview?.layoutIfNeeded()
        })
    }
    
    private func udpateTopContainerVisibility(by percent: CGFloat) {
        let alpha = 1 - percent
        self.topContainerView.alpha = alpha
        self.stackView.alpha = alpha
    }
    
    private func updateToolbarBottomOffset(by percent: CGFloat) {
        let distance = Metric.height - Metric.shrinkHeight
        let dy = distance * percent
        let newOffset = Metric.height - dy
        self.bottomOffsetConstraint?.constant = -newOffset
    }
    
    private func updateTitleLabelTopConstraint(by percent: CGFloat) {
        let distance = Metric.titleLabelCenterOffsetShrink - Metric.titleLabelCenterOffset
        let dy = distance * percent
        self.titleLabelCenterOffsetConstraint.constant = -dy
    }
}


// MARK: - update view loading status

extension InnerWebViewBottomToolBar {
    
    func updateLoadingStatus(_ percent: Double) {
        self.udpateLoadingPercentLayer(percent)
    }
    
    private func udpateLoadingPercentLayer(_ percent: Double) {
        let newWidth = (self.topContainerView.frame.width - 30.0) * percent
        self.progressPercentWidthConstraint.constant = newWidth
        self.progressView.isHidden = percent >= 1.0
    }
    
    func updateNavigationButton(isBack: Bool, enable: Bool) {
        let button = isBack ? self.backButton : self.nextButton
        let color = enable ? self.uiContext.colors.buttonBlue : self.uiContext.colors.raw.lightGray
        button.isEnabled = enable
        button.tintColor = color
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
        
        topContainerView.addSubview(progressView)
        progressView.autoLayout.active(with: self.topContainerView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 15)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor)
            $0.heightAnchor.constraint(equalToConstant: 2)
        }
        self.progressPercentWidthConstraint = progressView.widthAnchor
            .constraint(equalToConstant: 0)
        self.progressPercentWidthConstraint.isActive = true
        
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
            $0.widthAnchor.constraint(equalTo: $1.widthAnchor, constant: -Metric.titleHorizontalPadding)
        }
        self.titleLabelCenterOffsetConstraint = titleLabel.centerYAnchor
            .constraint(equalTo: topContainerView.centerYAnchor, constant: 0)
        self.titleLabelCenterOffsetConstraint.isActive = true
        
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
            self.backButton, self.nextButton, self.readMarkButton, self.memoButton, self.jumpFolderButton, self.safariButton
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
        
        self.refreshButton.setImage(UIImage(systemName: "arrow.clockwise.circle.fill"), for: .normal)
        self.refreshButton.tintColor = self.uiContext.colors.secondaryTitle
        
        _ = self.titleLabel
            |> \.numberOfLines .~ 1
            |> \.textColor .~ self.uiContext.colors.text.withAlphaComponent(0.8)
            |> \.font .~ self.uiContext.fonts.get(12, weight: .regular)
            |> \.textAlignment .~ .center
        
        self.backButton.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        self.backButton.isEnabled = false
        self.backButton.tintColor = self.uiContext.colors.raw.lightGray
        
        self.nextButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        self.nextButton.isEnabled = false
        self.nextButton.tintColor = self.uiContext.colors.raw.lightGray
        
        self.memoButton.setImage(UIImage(systemName: "note.text.badge.plus"), for: .normal)
        
        self.readMarkButton.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        
        self.jumpFolderButton.setImage(UIImage(systemName: "folder"), for: .normal)
        self.jumpFolderButton.isHidden = true
        
        self.safariButton.setImage(UIImage(systemName: "safari"), for: .normal)
        
        self.progressView.backgroundColor = self.uiContext.colors.buttonBlue
    }
}
