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
                            
                            Text("congratulations".localized)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                                .accessibilityAddTraits(.isHeader)
                                .accessibilityHeading(.h1)
                            
                            Text("course_completed".localized)
                                .font(.title2)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                        }
                        
                        // Score Display
                        VStack(spacing: 12) {
                            Text("your_score".localized)
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text("\(appViewModel.quizScore) / \(appViewModel.totalQuestions)")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                            
                            Text(String(format: "percentage".localized, 
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
                            Text("enter_name_certificate".localized)
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            TextField("your_name".localized, text: $userName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.title3)
                                .accessibilityLabel("your_name".localized)
                        }
                        
                        // Generate Certificate Button
                        Button(action: {
                            generateCertificate()
                        }) {
                            HStack {
                                Image(systemName: "doc.text.fill")
                                    .font(.title2)
                                Text("generate_certificate".localized)
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
                        .accessibilityLabel("generate_certificate".localized)
                        
                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationTitle("certificate".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !showingCertificate {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("back".localized) {
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
                    
                    Text("certificate_completion".localized)
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityHeading(.h1)
                    
                    Text("phishing_awareness_course".localized)
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
                        Text("awarded_to".localized)
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
                        Text("has_successfully_completed".localized)
                            .font(.body)
                            .multilineTextAlignment(.center)
                        
                        Text("phishing_awareness_training".localized)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                        
                        Text("with_score".localized)
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        Text("\(certificate.score) / \(certificate.totalQuestions) (\(Int(certificate.scorePercentage))%)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    
                    // Date
                    VStack(spacing: 8) {
                        Text("completion_date".localized)
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
                    Text("verification_code".localized)
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
                    
                    Text("scan_to_verify".localized)
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
                            Text("share_certificate".localized)
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    .accessibilityLabel("share_certificate".localized)
                    
                    Button(action: onNewCertificate) {
                        HStack {
                            Image(systemName: "plus.circle")
                                .font(.title2)
                            Text("new_certificate".localized)
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .accessibilityLabel("new_certificate".localized)
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
