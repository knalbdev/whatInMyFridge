//
//  FoodClassifierService.swift
//  WhatInMyFridge
//
//  Created by Setianing Budi on 27/06/26.
//

import Vision
import CoreML
import UIKit

final class FoodClassifierService {
    // memiliki variabel nil (null), kemungkinan variable ini tidak berisikan apapun (kosong)
    private var model: VNCoreMLModel?
    
    init() {
        setupModel()
    }
    
    private func setupModel() {
        do {
            let config = MLModelConfiguration()
#if targetEnvironment(simulator)
            config.computeUnits = .cpuOnly
#endif
            let coreMLModel = try FoodClassifier(configuration: config).model
            model = try VNCoreMLModel(for: coreMLModel)
        } catch {
            print("FoodClassifierService: gagal load model — \(error)")
        }
    }
    
    // untuk mengklasifikasi gambar
    func classify(image: UIImage, completion: @escaping ([FoodResult]) -> Void) {
        guard let model = model else {
            completion([])
            return
        }
        
        guard let cgImage = normalizedCGImage(from: image) else {
            completion([])
            return
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            guard error == nil,
                  let results = request.results as? [VNClassificationObservation] else {
                completion([])
                return
            }
            
            let topResults = results
                .sorted { $0.confidence > $1.confidence }
                .prefix(3)
                .map { FoodResult(label: $0.identifier, confidence: Double($0.confidence)) }
            
            // mengarahkan untuk menjalankan proses di thread lain, dan tidak di main thread
            DispatchQueue.main.async {
                completion(Array(topResults))
            }
        }
        
        // untuk melakukan crop pada gambar agar gambar hanya fokus kepada gambar yang di-inference
        request.imageCropAndScaleOption = .centerCrop
        
        configureRequestForSimulator(request)
        
        // untuk mengarahkan agar proses berjalan di background thread dan tidak di main thread
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("VNImageRequestHandler error: \(error)")
                DispatchQueue.main.async { completion([]) }
            }
        }
    }
    
    
    // untuk menormalisasikan gambar yang diambil dari galeri
    private func normalizedCGImage(from image: UIImage) -> CGImage? {
        UIGraphicsBeginImageContextWithOptions(image.size, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: image.size))
        let normalized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalized?.cgImage
    }
    
    private func configureRequestForSimulator(_ request: VNRequest) {
#if targetEnvironment(simulator)
        request.usesCPUOnly = true
#endif
    }
}
