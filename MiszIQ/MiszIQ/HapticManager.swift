import UIKit

class HapticManager {
    static let shared = HapticManager()

    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let selectionGenerator = UISelectionFeedbackGenerator()

    private init() {
        prepare()
    }

    // MARK: - Preparation

    func prepare() {
        lightImpact.prepare()
        mediumImpact.prepare()
        heavyImpact.prepare()
        notificationGenerator.prepare()
        selectionGenerator.prepare()
    }

    // MARK: - Impact Feedback

    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard SettingsManager.shared.hapticFeedbackEnabled else { return }

        switch style {
        case .light:
            lightImpact.impactOccurred()
        case .medium:
            mediumImpact.impactOccurred()
        case .heavy:
            heavyImpact.impactOccurred()
        default:
            mediumImpact.impactOccurred()
        }
    }

    // MARK: - Notification Feedback

    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard SettingsManager.shared.hapticFeedbackEnabled else { return }
        notificationGenerator.notificationOccurred(type)
    }

    // MARK: - Selection Feedback

    func selection() {
        guard SettingsManager.shared.hapticFeedbackEnabled else { return }
        selectionGenerator.selectionChanged()
    }

    // MARK: - Game-Specific Feedback

    func buttonTap() {
        impact(.light)
    }

    func correctAnswer() {
        notification(.success)
    }

    func wrongAnswer() {
        notification(.error)
    }

    func gameComplete() {
        impact(.medium)
    }

    func levelUp() {
        notification(.success)
    }

    func badgeUnlocked() {
        impact(.heavy)
    }
}
