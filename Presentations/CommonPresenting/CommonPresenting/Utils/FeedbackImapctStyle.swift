//
//  FeedbackImapctStyle.swift
//  CommonPresenting
//
//  Created by sudo.park on 2022/01/11.
//

import UIKit


public enum FeedbackImapctStyle {
    
    case soft
}


extension FeedbackImapctStyle {
    
    var uiImpactStyle: UIImpactFeedbackGenerator.FeedbackStyle {
        switch self {
        case .soft: return .soft
        }
    }
}
