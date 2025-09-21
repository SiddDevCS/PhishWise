//
//  CertificateView.swift
//  PhishWise
//
//  Created by Siddharth Sehgal on 15/09/2025.
//

import SwiftUI

// MARK: - Certificate View
/// Displays a course completion certificate with QR code
struct CertificateView: View {
    @ObservedObject var appViewModel: AppViewModel
    @State private var userName = ""
    @State private var showingCertificate = false
    @State private var certificate: Certificate?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                if showingCertificate, let cert = certificate {
                    // Certificate Display
                    CertificateDisplayView(
                        certificate: cert,
                        language: appViewModel.currentLanguage,
                        onNewCertificate: {
                            showingCertificate = false
                            userName = ""
                        }
                    )
                } else {
                    // Name Input Form
                    VStack(spacing: 24) {
                        Spacer()
                        
                        // Header
                        VStack(spacing: 16) {
                            Image(systemName: "trophy.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.yellow)
                                .accessibilityLabel("Certificate Icon")
                            
                            Text(NSLocalizedString("congratulations", comment: "Congratulations"))
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                                .accessibilityAddTraits(.isHeader)
                                .accessibilityHeading(.h1)
                            
                            Text(NSLocalizedString("course_completed", comment: "Course completed"))
                                .font(.title2)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                        }
                        
                        // Score Display
                        VStack(spacing: 12) {
                            Text(NSLocalizedString("your_score", comment: "Your score"))
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text("\(appViewModel.quizScore) / \(appViewModel.totalQuestions)")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                            
                            Text(String(format: NSLocalizedString("percentage", comment: "Percentage"), 
                                      appViewModel.totalQuestions > 0 ? 
                                      Double(appViewModel.quizScore) / Double(appViewModel.totalQuestions) * 100 : 0))
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        // Name Input
                        VStack(alignment: .leading, spacing: 12) {
                            Text(NSLocalizedString("enter_name_certificate", comment: "Enter name for certificate"))
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            TextField(NSLocalizedString("your_name", comment: "Your name"), text: $userName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.title3)
                                .accessibilityLabel(NSLocalizedString("your_name", comment: "Your name"))
                        }
                        
                        // Generate Certificate Button
                        Button(action: {
                            generateCertificate()
                        }) {
                            HStack {
                                Image(systemName: "doc.text.fill")
                                    .font(.title2)
                                Text(NSLocalizedString("generate_certificate", comment: "Generate certificate"))
                                    .font(.title2)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(userName.isEmpty ? Color.gray : Color.blue)
                            .cornerRadius(12)
                        }
                        .disabled(userName.isEmpty)
                        .accessibilityLabel(NSLocalizedString("generate_certificate", comment: "Generate certificate"))
                        
                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationTitle(NSLocalizedString("certificate", comment: "Certificate"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !showingCertificate {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(NSLocalizedString("back", comment: "Back")) {
                            appViewModel.navigateTo(.welcome)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Methods
    private func generateCertificate() {
        guard !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        certificate = Certificate(
            userName: userName.trimmingCharacters(in: .whitespacesAndNewlines),
            completionDate: Date(),
            score: appViewModel.quizScore,
            totalQuestions: appViewModel.totalQuestions
        )
        
        withAnimation(.easeInOut(duration: 0.5)) {
            showingCertificate = true
        }
    }
}

// MARK: - Certificate Display View
struct CertificateDisplayView: View {
    let certificate: Certificate
    let language: Language
    let onNewCertificate: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Certificate Header
                VStack(spacing: 16) {
                    Image(systemName: "shield.checkered")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text(NSLocalizedString("certificate_completion", comment: "Certificate of completion"))
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityHeading(.h1)
                    
                    Text(NSLocalizedString("phishing_awareness_course", comment: "Phishing Awareness Course"))
                        .font(.title2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
                
                // Certificate Content
                VStack(spacing: 20) {
                    // Recipient Name
                    VStack(spacing: 8) {
                        Text(NSLocalizedString("awarded_to", comment: "Awarded to"))
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(certificate.userName)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .accessibilityAddTraits(.isHeader)
                    }
                    
                    // Completion Details
                    VStack(spacing: 12) {
                        Text(NSLocalizedString("has_successfully_completed", comment: "Has successfully completed"))
                            .font(.body)
                            .multilineTextAlignment(.center)
                        
                        Text(NSLocalizedString("phishing_awareness_training", comment: "Phishing Awareness Training"))
                            .font(.title2)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                        
                        Text(NSLocalizedString("with_score", comment: "With a score of"))
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        Text("\(certificate.score) / \(certificate.totalQuestions) (\(Int(certificate.scorePercentage))%)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    
                    // Date
                    VStack(spacing: 8) {
                        Text(NSLocalizedString("completion_date", comment: "Completion date"))
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(certificate.formattedDate)
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                // QR Code
                VStack(spacing: 16) {
                    Text(NSLocalizedString("verification_code", comment: "Verification code"))
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    if let qrImage = QRCodeGenerator.generateQRCode(from: certificate.qrCodeString) {
                        Image(uiImage: qrImage)
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 150, height: 150)
                            .overlay(
                                Text("QR Code")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            )
                    }
                    
                    Text(NSLocalizedString("scan_to_verify", comment: "Scan to verify"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
                
                // Action Buttons
                VStack(spacing: 16) {
                    Button(action: {
                        // Share functionality could be added here
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .font(.title2)
                            Text(NSLocalizedString("share_certificate", comment: "Share certificate"))
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    .accessibilityLabel(NSLocalizedString("share_certificate", comment: "Share certificate"))
                    
                    Button(action: onNewCertificate) {
                        HStack {
                            Image(systemName: "plus.circle")
                                .font(.title2)
                            Text(NSLocalizedString("new_certificate", comment: "New certificate"))
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .accessibilityLabel(NSLocalizedString("new_certificate", comment: "New certificate"))
                }
                
                Spacer(minLength: 50)
            }
            .padding()
        }
    }
}

// MARK: - Preview
#Preview {
    CertificateView(appViewModel: AppViewModel())
}
