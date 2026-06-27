//
//  FoodResult.swift
//  WhatInMyFridge
//
//  Created by Setianing Budi on 27/06/26.
//

import Foundation

struct FoodResult: Identifiable {
    let id = UUID()
    let label: String
    let confidence: Double

    // di dalam confidence sebetulnay bertipe persentase, namun dikonvert menjadi string
    var confidencePercentage: String {
        String(format: "%.1f%%", confidence * 100)
    }
}
