//
//  ColorScheme.swift
//  DaFoVo1
//
//  Galaxy Finance Quest Color Scheme
//

import SwiftUI

extension Color {
    static let galaxyBackground = Color(red: 0.114, green: 0.122, blue: 0.188) // #1D1F30
    static let galaxyAccent = Color(red: 0.996, green: 0.157, blue: 0.290) // #FE284A
    static let galaxySecondary = Color(red: 0.2, green: 0.25, blue: 0.4) // Secondary blue
    static let galaxyText = Color.white
    static let galaxyTextSecondary = Color(red: 0.8, green: 0.8, blue: 0.9)
    static let galaxySuccess = Color(red: 0.2, green: 0.8, blue: 0.4)
    static let galaxyWarning = Color(red: 1.0, green: 0.6, blue: 0.0)
    static let galaxyCard = Color(red: 0.15, green: 0.17, blue: 0.25)
}

struct GalaxyTheme {
    static let cornerRadius: CGFloat = 12
    static let shadowRadius: CGFloat = 8
    static let buttonHeight: CGFloat = 50
    static let cardPadding: CGFloat = 16
    
    // Typography
    static let titleFont = Font.system(size: 28, weight: .bold, design: .rounded)
    static let headlineFont = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let bodyFont = Font.system(size: 16, weight: .regular, design: .rounded)
    static let captionFont = Font.system(size: 14, weight: .medium, design: .rounded)
}

