//
//  CertificateView.swift
//  PhishWise
//
//  Created by Siddharth Sehgal on 15/09/2025.
//

import SwiftUI
import UIKit
import Photos

// MARK: - Logo Helper
extension UIImage {
    static func loadAppLogo() -> UIImage? {
        // Try to load from images folder in bundle (primary location)
        if let logoURL = Bundle.main.url(forResource: "logo", withExtension: "png", subdirectory: "images"),
           let logoData = try? Data(contentsOf: logoURL),
           let logo = UIImage(data: logoData) {
            return logo
        }
        // Fallback: try from bundle root
        if let logoPath = Bundle.main.path(forResource: "logo", ofType: "png"),
           let logo = UIImage(contentsOfFile: logoPath) {
            return logo
        }
        // Fallback: try from Assets catalog
        if let logo = UIImage(named: "logo") {
            return logo
        }
        // Fallback: try direct path
        if let bundlePath = Bundle.main.resourcePath,
           let logo = UIImage(contentsOfFile: "\(bundlePath)/images/logo.png") {
            return logo
        }
        return nil
    }
}

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
                            Text(String(format: "your_score".localized, 
                                      appViewModel.quizScore, 
                                      appViewModel.totalQuestions))
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
    @State private var showingShareSheet = false
    @State private var certificateImage: UIImage?
    @State private var isGeneratingImage = false
    @State private var showSaveSuccessAlert = false
    @State private var showSaveErrorAlert = false
    @State private var saveError: String?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Certificate Header with Logo
                VStack(spacing: 16) {
                    // App Logo
                    if let logoImage = UIImage.loadAppLogo() {
                        Image(uiImage: logoImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 80)
                            .accessibilityLabel("PhishWise Logo")
                    } else {
                        Image(systemName: "shield.checkered")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                    }
                    
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
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.blue.opacity(0.05)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                
                // Certificate Content
                VStack(spacing: 20) {
                    // Decorative Line
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.3)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 3)
                        .cornerRadius(1.5)
                        .padding(.horizontal, 40)
                    
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
                            .foregroundColor(.blue)
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
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.blue.opacity(0.1)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
                
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
                        captureCertificateImage { image in
                            if let image = image {
                                certificateImage = image
                                showingShareSheet = true
                            }
                        }
                    }) {
                        HStack {
                            if isGeneratingImage {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.title2)
                            }
                            Text("share_certificate".localized)
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isGeneratingImage ? Color.gray : Color.blue)
                        .cornerRadius(12)
                    }
                    .disabled(isGeneratingImage)
                    .accessibilityLabel("share_certificate".localized)
                    .sheet(isPresented: $showingShareSheet) {
                        if let image = certificateImage {
                            ShareSheet(activityItems: [image])
                        }
                    }
                    
                    Button(action: {
                        captureCertificateImage { image in
                            if let image = image {
                                saveCertificateToPhotos(image: image)
                            }
                        }
                    }) {
                        HStack {
                            if isGeneratingImage {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                            } else {
                                Image(systemName: "photo.on.rectangle")
                                    .font(.title2)
                            }
                            Text("save_to_photos".localized)
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .disabled(isGeneratingImage)
                    .accessibilityLabel("save_to_photos".localized)
                    
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
                .alert("saved_to_photos".localized, isPresented: $showSaveSuccessAlert) {
                    Button("ok".localized, role: .cancel) { }
                } message: {
                    Text("certificate_saved_successfully".localized)
                }
                .alert("error_saving".localized, isPresented: $showSaveErrorAlert) {
                    Button("ok".localized, role: .cancel) { }
                } message: {
                    if let error = saveError {
                        Text(error)
                    }
                }
                
                Spacer(minLength: 50)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Helper Methods
    private func captureCertificateImage(completion: @escaping (UIImage?) -> Void) {
        isGeneratingImage = true
        
        // Use async rendering to properly capture the SwiftUI view
        DispatchQueue.main.async {
            let snapshotView = CertificateSnapshotView(certificate: certificate, language: language)
            let hostingController = UIHostingController(rootView: snapshotView)
            
            let targetSize = CGSize(width: 800, height: 1200)
            hostingController.view.frame = CGRect(origin: .zero, size: targetSize)
            hostingController.view.backgroundColor = .white
            
            // Create a window to ensure proper rendering
            let window = UIWindow(frame: CGRect(origin: .zero, size: targetSize))
            window.rootViewController = hostingController
            window.windowLevel = UIWindow.Level.alert + 1
            window.isHidden = false
            window.makeKeyAndVisible()
            
            // Force the view to layout and render multiple times to ensure everything is ready
            hostingController.view.setNeedsLayout()
            hostingController.view.layoutIfNeeded()
            
            // Wait for the view to fully render - give it more time
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                // Get the main view from the hosting controller
                guard let view = hostingController.view else {
                    window.isHidden = true
                    window.rootViewController = nil
                    isGeneratingImage = false
                    completion(nil)
                    return
                }
                
                // Ensure the view is still properly sized
                view.frame = CGRect(origin: .zero, size: targetSize)
                view.setNeedsLayout()
                view.layoutIfNeeded()
                
                // Render to image using snapshot with afterScreenUpdates
                let renderer = UIGraphicsImageRenderer(size: targetSize)
                let image = renderer.image { context in
                    view.drawHierarchy(in: CGRect(origin: .zero, size: targetSize), afterScreenUpdates: true)
                }
                
                // Clean up the window
                window.isHidden = true
                window.rootViewController = nil
                
                isGeneratingImage = false
                completion(image)
            }
        }
    }
    
    private func saveCertificateToPhotos(image: UIImage) {
        // Request photo library access
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            DispatchQueue.main.async {
                if status == .authorized || status == .limited {
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAsset(from: image)
                    }) { success, error in
                        DispatchQueue.main.async {
                            if success {
                                showSaveSuccessAlert = true
                            } else {
                                saveError = error?.localizedDescription ?? "photo_library_permission_denied".localized
                                showSaveErrorAlert = true
                            }
                        }
                    }
                } else {
                    saveError = "photo_library_permission_denied".localized
                    showSaveErrorAlert = true
                }
            }
        }
    }
}

// MARK: - Certificate Snapshot View
/// A simplified view for generating certificate images for sharing
struct CertificateSnapshotView: View {
    let certificate: Certificate
    let language: Language
    @State private var logoImage: UIImage?
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 30) {
                    // Logo and Header
                    VStack(spacing: 16) {
                        if let logo = logoImage {
                            Image(uiImage: logo)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                                .frame(maxWidth: .infinity)
                        } else {
                            Image(systemName: "shield.checkered")
                                .font(.system(size: 60))
                                .foregroundColor(.blue)
                        }
                        
                        Text("certificate_completion".localized)
                            .font(.system(size: 32, weight: .bold))
                            .multilineTextAlignment(.center)
                        
                        Text("phishing_awareness_course".localized)
                            .font(.system(size: 20))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 40)
                    
                    // Content
                    VStack(spacing: 20) {
                        Rectangle()
                            .fill(Color.blue)
                            .frame(height: 3)
                            .frame(maxWidth: 600)
                        
                        VStack(spacing: 8) {
                            Text("awarded_to".localized)
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                            
                            Text(certificate.userName)
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.blue)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        
                        VStack(spacing: 12) {
                            Text("has_successfully_completed".localized)
                                .font(.system(size: 16))
                                .multilineTextAlignment(.center)
                            
                            Text("phishing_awareness_training".localized)
                                .font(.system(size: 24, weight: .semibold))
                                .multilineTextAlignment(.center)
                            
                            Text("with_score".localized)
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                            
                            Text("\(certificate.score) / \(certificate.totalQuestions) (\(Int(certificate.scorePercentage))%)")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.blue)
                        }
                        .frame(maxWidth: .infinity)
                        
                        VStack(spacing: 8) {
                            Text("completion_date".localized)
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                            
                            Text(certificate.formattedDate)
                                .font(.system(size: 18, weight: .semibold))
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: 600)
                    .padding(.horizontal, 40)
                    
                    // QR Code
                    VStack(spacing: 16) {
                        Text("verification_code".localized)
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                        
                        if let qrImage = QRCodeGenerator.generateQRCode(from: certificate.qrCodeString) {
                            Image(uiImage: qrImage)
                                .interpolation(.none)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150, height: 150)
                        }
                        
                        Text("scan_to_verify".localized)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 60)
                .padding(.horizontal, 40)
                
                Spacer()
            }
        }
        .frame(width: 800, height: 1200)
        .onAppear {
            // Load logo on appear
            logoImage = UIImage.loadAppLogo()
        }
    }
}

// MARK: - UIView Extension for Snapshot
extension UIView {
    func snapshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        return renderer.image { context in
            layer.render(in: context.cgContext)
        }
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview
#Preview {
    CertificateView(appViewModel: AppViewModel())
}
