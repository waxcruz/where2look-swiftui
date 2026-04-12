import Foundation
import AVFoundation
import SwiftUI

final class SoundManager {
    
    static let shared = SoundManager()
    
    private var player: AVAudioPlayer?
    
    @AppStorage("volume") private var volume: Double = 0.5
    
    private init() {
        setupPlayer()
    }
    
    private func setupPlayer() {
        guard let url = Bundle.main.url(forResource: "beep", withExtension: "wav") else {
            print("Missing beep.wav")
            return
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
        } catch {
            print("Sound error: \(error)")
        }
    }
    
    private func playBeep(volumeMultiplier: Float, pan: Float) {
        guard let player else { return }
        
        player.stop()
        player.currentTime = 0
        player.volume = Float(volume) * volumeMultiplier
        player.pan = pan
        player.play()
    }
    
    func update(delta: Double, direction: Double) {
        // This function is only called when delta <= 5
        let clampedDelta = max(0, min(delta, 5))
        
        // 0° = strongest, 5° = weakest
        let closeness = Float((5.0 - clampedDelta) / 5.0)
        
        // Keep it audible near the edge, strongest at center
        let volumeMultiplier = 0.35 + (closeness * 0.65)
        
        // Stereo cue: left if negative, right if positive
        let pan = Float(max(-1.0, min(1.0, direction / 20.0)))
        
        playBeep(volumeMultiplier: volumeMultiplier, pan: pan)
    }
}
