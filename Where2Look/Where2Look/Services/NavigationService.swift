import Foundation
import CoreLocation
import Combine

final class NavigationService: ObservableObject {
    
    // MARK: - Public State
    
    @Published var selectedFeature: GISFeature?
    @Published var lockedFeature: GISFeature?
    @Published var direction: Double = 0   // -180...180
    
    // MARK: - Private
    
    private var cancellables = Set<AnyCancellable>()
    private var smoothedHeading: Double?
    private var lastBeepTime: Date = .distantPast
    
    // No beeping unless you're within this many degrees of the target
    private let beepWindow: Double = 5
    
    // MARK: - Lifecycle
    
    func start(locationService: LocationService) {
        locationService.$heading
            .sink { [weak self] heading in
                self?.handleHeadingUpdate(heading)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Heading Handling
    
    private func handleHeadingUpdate(_ rawHeading: Double) {
        print("Heading:", rawHeading)
        print("selected:", selectedFeature?.location ?? "nil",
              "locked:", lockedFeature?.location ?? "nil")
        
        guard rawHeading >= 0 else {
            print("No target or heading")
            return
        }
        
        // Audio guidance only for locked target
        guard let target = lockedFeature else {
            direction = 0
            return
        }
        
        let heading = normalizeHeading(smoothHeading(new: rawHeading))
        
        let delta = headingDelta(
            current: heading,
            target: target.bearingDegrees
        )
        
        let direction = headingDirection(
            current: heading,
            target: target.bearingDegrees
        )
        
        self.direction = direction
        
        // ✅ No sound unless we are close to the target heading
        guard delta <= beepWindow else {
            return
        }
        
        let now = Date()
        let interval = beepInterval(for: delta)
        
        guard now.timeIntervalSince(lastBeepTime) >= interval else {
            return
        }
        
        lastBeepTime = now
        SoundManager.shared.update(delta: delta, direction: direction)
    }
    
    // MARK: - Locking
    
    func lockSelected() {
        guard let selected = selectedFeature else {
            print("No selection to lock")
            return
        }
        
        lockedFeature = selected
        print("LOCKED:", selected.location)
    }
    
    func unlock() {
        print("UNLOCKED")
        lockedFeature = nil
        direction = 0
    }
    
    // MARK: - Smoothing
    
    private func smoothHeading(new: Double) -> Double {
        let alpha = 0.2
        
        if let previous = smoothedHeading {
            let delta = headingDirection(current: previous, target: new)
            let result = previous + delta * alpha
            smoothedHeading = normalizeHeading(result)
        } else {
            smoothedHeading = new
        }
        
        return smoothedHeading!
    }
    
    private func normalizeHeading(_ value: Double) -> Double {
        var v = value
        while v < 0 { v += 360 }
        while v >= 360 { v -= 360 }
        return v
    }
    
    // MARK: - Beep Timing
    
    private func beepInterval(for delta: Double) -> TimeInterval {
        switch delta {
        case 0..<1:
            return 0.08   // fastest when directly on heading
        case 1..<2:
            return 0.12
        case 2..<3:
            return 0.18
        case 3..<4:
            return 0.26
        default:
            return 0.36   // slowest near edge of ±5°
        }
    }
    
    // MARK: - Helpers
    
    private func headingDelta(current: Double, target: Double) -> Double {
        let diff = abs(current - target)
        return diff > 180 ? 360 - diff : diff
    }
    
    private func headingDirection(current: Double, target: Double) -> Double {
        var diff = target - current
        
        while diff > 180 { diff -= 360 }
        while diff < -180 { diff += 360 }
        
        return diff
    }
}
