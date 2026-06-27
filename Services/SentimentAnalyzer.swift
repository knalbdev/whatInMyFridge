//
//  SentimentAnalyzer.swift
//  WhatInMyFridge
//
//  Created by Setianing Budi on 27/06/26.
//

import NaturalLanguage

enum SentimentLevel {
    case positive, neutral, negative

    var emoji: String {
        switch self {
        case .positive: return "😍"
        case .neutral:  return "😐"
        case .negative: return "😡"
        }
    }

    var label: String {
        switch self {
        case .positive: return "Positif"
        case .neutral:  return "Netral"
        case .negative: return "Negatif"
        }
    }

    var color: String {
        switch self {
        case .positive: return "green"
        case .neutral:  return "orange"
        case .negative: return "red"
        }
    }
}

// untuk mengidentifikasi level mana dan skornya apa
struct SentimentResult {
    let score: Double
    let level: SentimentLevel

    var displayText: String { "\(level.emoji) \(level.label)" }
}

final class SentimentAnalyzer {
    private let tagger = NLTagger(tagSchemes: [.sentimentScore])

    func analyze(text: String) -> SentimentResult {
        //  untuk mengamankan jika nilainya kosong, jadi akan menjadi nilai default atau status netral
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return SentimentResult(score: 0, level: .neutral)
        }

        // output akan menghasilkan nilai yang sudah displit (default -1 sampai 1, namun bisa disesuaikan menjadi 1-5)
        tagger.string = text
        let (tag, _) = tagger.tag(
            at: text.startIndex,
            unit: .paragraph,
            scheme: .sentimentScore
        )

        let score = Double(tag?.rawValue ?? "0") ?? 0.0
        let level = sentimentLevel(for: score)
        return SentimentResult(score: score, level: level)
    }

    private func sentimentLevel(for score: Double) -> SentimentLevel {
        switch score {
        case 0.3...:    return .positive
        case ..<(-0.3): return .negative
        default:        return .neutral
        }
    }
}
