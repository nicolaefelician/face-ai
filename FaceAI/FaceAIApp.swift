import SwiftUI
import Firebase
import FirebaseMessaging
import RevenueCat
import SuperwallKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        Consts.shared.loadConfig()
        
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: Consts.shared.revenueCatApiKey, appUserID: Consts.shared.userId?.uuidString)
        
        Superwall.configure(apiKey: Consts.shared.superwallApiKey, purchaseController: purchaseController)
        purchaseController.syncSubscriptionStatus()
        
        UNUserNotificationCenter.current().delegate = self
        
        Task {
            await handleNotificationPermissions(application: application)
        }
        
        GlobalState.shared.loadPrefs()
        
        configureAppearance()
        
        return true
    }
    
    private func configureAppearance() {
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = UIColor(Color.white)
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Colors.shared.primaryColor)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(Colors.shared.primaryColor)]
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        
        let navigationBarStyle = UINavigationBarAppearance()
        
        navigationBarStyle.backgroundColor = UIColor(Color.white)
        navigationBarStyle.shadowColor = nil
        
        UINavigationBar.appearance().standardAppearance = navigationBarStyle
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarStyle
        UINavigationBar.appearance().compactAppearance = navigationBarStyle
    }
    
    @MainActor
    private func handleNotificationPermissions(application: UIApplication) async {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: authOptions)
            print("Notification authorization granted: \(granted)")
        } catch {
            print("Notification authorization error: \(error.localizedDescription)")
        }
        
        application.registerForRemoteNotifications()
        
        Messaging.messaging().delegate = self
    }
}

@main
struct FaceAIApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @ObservedObject private var globalState = GlobalState.shared
    
    var body: some Scene {
        WindowGroup {
            if globalState.showSplashView {
                SplashView()
                    .preferredColorScheme(.light)
            } else if globalState.showOnboarding {
                OnboardingView()
                    .preferredColorScheme(.light)
            } else {
                ContentView()
                    .preferredColorScheme(.light)
            }
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async
    -> UNNotificationPresentationOptions {
        return [[.badge, .sound]]
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo
        
        guard let jobId = userInfo["jobId"] as? String,
              let stringType = userInfo["type"] as? String,
              let type = GenerationType(rawValue: stringType.lowercased()) else {
            print("❌ Invalid or missing data in notification payload.")
            return
        }
        
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        GlobalState.shared.navigationPath.append(.imageFilter(jobId: jobId, type: type))
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else {
            print("No FCM token received")
            return
        }
        
        Consts.shared.setFcmToken(fcmToken)
        
        let dataDict: [String: String] = ["token": fcmToken]
        
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
}
