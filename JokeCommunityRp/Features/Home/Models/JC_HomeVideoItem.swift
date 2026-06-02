//
//  JC_HomeVideoItem.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/2.
//

import Foundation

struct JC_HomeVideoItem {
    let videoURL: URL
    let jokeText: String
    let likeCount: String
    let commentCount: String
}

enum JC_HomeVideoProvider {

    static func loadItems() -> [JC_HomeVideoItem] {
        let videoURLs = loadVideoURLs()

        let jokes = [
            """
            A doctor asked a patient how he got his fracture.
            Patient: I felt sand inside my shoe, so I held a pole to shake it off.
            Doctor: How could that hurt you?
            Patient: A passer-by thought I got an electric shock, and knocked me down with a stick.
            """,
            """
            Why don't scientists trust atoms?
            Because they make up everything.
            """,
            """
            I told my wife she was drawing her eyebrows too high.
            She looked surprised.
            """
        ]

        let likeCounts = ["100W", "56W", "32W"]
        let commentCounts = ["884", "612", "430"]

        if videoURLs.isEmpty {
            return []
        }

        return videoURLs.enumerated().map { index, url in
            JC_HomeVideoItem(
                videoURL: url,
                jokeText: jokes[index % jokes.count],
                likeCount: likeCounts[index % likeCounts.count],
                commentCount: commentCounts[index % commentCounts.count]
            )
        }
    }

    private static func loadVideoURLs() -> [URL] {
        let sources: [[URL]?] = [
            Bundle.main.urls(forResourcesWithExtension: "mp4", subdirectory: "Videos"),
            Bundle.main.urls(forResourcesWithExtension: "mp4", subdirectory: nil)
        ]

        for urls in sources {
            if let urls, !urls.isEmpty {
                return urls.sorted { $0.lastPathComponent < $1.lastPathComponent }
            }
        }

        if let url = Bundle.main.url(forResource: "video_01", withExtension: "mp4") {
            return [url]
        }

        return []
    }
}
