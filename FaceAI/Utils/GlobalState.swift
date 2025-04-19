import Foundation
import SwiftUI
import RevenueCat

final class GlobalState: ObservableObject {
    static let shared = GlobalState()
    
    private init() {}
    
    func loadPrefs() {
        Purchases.shared.getCustomerInfo { (customerInfo, error) in
            self.isProUser = customerInfo?.entitlements.all["Pro"]?.isActive == true
        }
        showOnboarding = !UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
    }
    
    @Published var credits: Int = 0
    
    @Published var isProUser: Bool = false
    
    @Published var navigationPath: [NavigationDestination] = []
    
    @Published var showOnboarding: Bool = false
    @Published var showSplashView: Bool = true
    @Published var showPresetPreview: Bool = false
    @Published var showImageFilter: Bool = false
    @Published var showFullscreenImage: Bool = false
    
    @Published var selectedImageId: String?
    @Published var selectedImage: UIImage?
    @Published var selectedFilterType: FilterType = .enhance
    @Published var selectedImageUrl: URL?
    
    @Published var showActionFigurePopup: Bool = false
    @Published var showMenu = false
    
    @Published var isLoading: Bool = false
    @Published var showQueuePopup: Bool = false
    
    @Published var selectedPreset: ImagePreset? = nil
    
    @Published var imagesToShow: [Any] = []
    @Published var isSharingImages: Bool = false
    
    @Published var alertTitle: String?
    @Published var alertMessage: String?
    @Published var showAlert: Bool = false
    
    @Published var historyJobs: [ImageJob] = []
    @Published var savedImages: [SavedImage] = []
    @Published var enhanceJobs: [EnhanceJob] = []
}
