import AVFoundation
import SwiftUI

enum SoundEffect: String, CaseIterable {
    case correctAnswer = "correct_chime"
    case wrongAnswer = "wrong_buzz"
    case buttonTap = "button_tap"
    case gameComplete = "celebration"
}

class AudioManager: ObservableObject {
    static let shared = AudioManager()

    private var musicPlayer: AVAudioPlayer?
    private var soundPlayers: [SoundEffect: AVAudioPlayer] = [:]
    private var isMusicPlaying = false

    private init() {
        setupAudioSession()
        preloadSoundEffects()
    }

    // MARK: - Setup

    private func setupAudioSession() {
        do {
            // Use ambient category so music mixes with other audio and respects silent mode
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }

    private func preloadSoundEffects() {
        for effect in SoundEffect.allCases {
            if let url = Bundle.main.url(forResource: effect.rawValue, withExtension: "mp3") {
                do {
                    let player = try AVAudioPlayer(contentsOf: url)
                    player.prepareToPlay()
                    soundPlayers[effect] = player
                } catch {
                    print("Failed to preload \(effect.rawValue): \(error)")
                }
            }
        }
    }

    // MARK: - Background Music

    func playBackgroundMusic() {
        guard SettingsManager.shared.musicEnabled else { return }
        guard !isMusicPlaying else { return }

        // Try to load background music
        if let url = Bundle.main.url(forResource: "background_music", withExtension: "mp3") {
            do {
                musicPlayer = try AVAudioPlayer(contentsOf: url)
                musicPlayer?.numberOfLoops = -1 // Infinite loop
                musicPlayer?.volume = 0.3 // 30% volume
                musicPlayer?.play()
                isMusicPlaying = true
            } catch {
                print("Failed to play background music: \(error)")
            }
        }
    }

    func stopBackgroundMusic() {
        musicPlayer?.stop()
        musicPlayer?.currentTime = 0
        isMusicPlaying = false
    }

    func pauseBackgroundMusic() {
        musicPlayer?.pause()
    }

    func resumeBackgroundMusic() {
        guard SettingsManager.shared.musicEnabled else { return }
        guard isMusicPlaying else { return }
        musicPlayer?.play()
    }

    // MARK: - Sound Effects

    func playSoundEffect(_ effect: SoundEffect) {
        guard SettingsManager.shared.soundEffectsEnabled else { return }

        // Try preloaded player first
        if let player = soundPlayers[effect] {
            player.currentTime = 0
            player.play()
            return
        }

        // Fallback: create new player
        guard let url = Bundle.main.url(forResource: effect.rawValue, withExtension: "mp3") else {
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.play()
            soundPlayers[effect] = player
        } catch {
            print("Failed to play sound effect \(effect.rawValue): \(error)")
        }
    }

    // MARK: - Convenience Methods

    func playCorrectSound() {
        playSoundEffect(.correctAnswer)
    }

    func playWrongSound() {
        playSoundEffect(.wrongAnswer)
    }

    func playButtonTap() {
        playSoundEffect(.buttonTap)
    }

    func playGameComplete() {
        playSoundEffect(.gameComplete)
    }
}
