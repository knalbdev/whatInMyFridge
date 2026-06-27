//
//  HomeView.swift
//  WhatInMyFridge
//
//  Created by Setianing Budi on 26/06/26.
//

import SwiftUI
struct HomeView: View {
    @State private var selectedImage: UIImage?
    @State private var classificationResults: [FoodResult] = []
    @State private var isClassifying = false
    
    private let classifier = FoodClassifierService()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                // Isi ditambahkan bertahap di 6b–6d
                if selectedImage != nil {
                    imageSection
                } else {
                    headerSection
                }
                actionSection
                if !classificationResults.isEmpty {
                    ResultView(results: classificationResults)
                }
            }
            .padding()
            .navigationTitle("WhatInMyFridge")
            .navigationBarTitleDisplayMode(.large)
            .onChange(of: selectedImage) { _, newImage in
                guard let image = newImage else { return }
                classifyImage(image)
            }
        }
    }
    
    // mengatur gambar yang akan ditampilkan yang sudah dipilih dari galeri
    @ViewBuilder
    private var imageSection: some View {
        if let image = selectedImage {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 250)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    isClassifying ? ProgressView().tint(.white) : nil
                )
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "camera.viewfinder")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundStyle(Color("BrandBlue").gradient)
            
            Text("Deteksi Bahan Makanan")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Foto atau pindai bahan makanan\nuntuk mendapatkan rekomendasi resep")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 40)
    }
    
    private var actionSection: some View {
        VStack(spacing: 16) {
            ImagePickerView(selectedImage: $selectedImage)
            NavigationLink {
                LiveScannerView()
            } label: {
                Label("Live Scanner", systemImage: "livephoto")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("FreshGreen"))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
    
    private func classifyImage(_ image: UIImage) {
        isClassifying = true
        classificationResults = []
        classifier.classify(image: image) { results in
            classificationResults = results
            isClassifying = false
        }
    }
}

#Preview {
    HomeView()
}
