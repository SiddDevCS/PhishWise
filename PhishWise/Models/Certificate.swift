//
//  Certificate.swift
//  PhishWise
//
//  Created by Siddharth Sehgal on 15/09/2025.
//

import Foundation
import SwiftUI

// MARK: - Certificate Model
// Dit is het certificate model, dus hoe het qr-code/pdf/img na het quiz er uit gaat zien
/// course completion certificate
struct Certificate: Identifiable {
    let id = UUID()
    let userName: String
    let completionDate: Date
    let score: Int
    let totalQuestions: Int
    
    /// qr-code generatie
    var qrCodeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "Phishing Course Completed - \(userName) - \(formatter.string(from: completionDate))"
    }
    
    /// percentage van score
    var scorePercentage: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(score) / Double(totalQuestions) * 100
    }
    
    /// datum
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: completionDate)
    }
}

// MARK: - QR Code Generator
import CoreImage.CIFilterBuiltins

struct QRCodeGenerator {
    /// Generates a QR code image from a string
    static func generateQRCode(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        let data = string.data(using: String.Encoding.ascii)
        filter.setValue(data, forKey: "inputMessage")
        
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        
        if let outputImage = filter.outputImage?.transformed(by: transform) {
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        
        return nil
    }
}
