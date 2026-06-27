//
//  ImagePickerView.swift
//  WhatInMyFridge
//
//  Created by Setianing Budi on 27/06/26.
//

import SwiftUI
import PhotosUI

struct ImagePickerView: View {
    @Binding var selectedImage: UIImage?
    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        // tidak perlu menambahkan permissin di info.plist, by default sudah bisa bypass untuk akses galeri
        PhotosPicker(
            selection: $selectedItem,
            matching: .images,
            photoLibrary: .shared()
        ) {
            Label("Pilih dari Galeri", systemImage: "photo.on.rectangle")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color("BrandBlue"))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .onChange(of: selectedItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    selectedImage = image
                }
            }
        }
    }
}
