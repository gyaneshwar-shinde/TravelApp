import UIKit

final class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let explore = HeroNavigationController(rootViewController: ExploreViewController())
        explore.tabBarItem = UITabBarItem(
            title: "Explore",
            image: UIImage(systemName: "safari"),
            selectedImage: UIImage(systemName: "safari.fill")
        )
        
        let map = HeroNavigationController(rootViewController: MapViewController())
        map.tabBarItem = UITabBarItem(
            title: "Map",
            image: UIImage(systemName: "map"),
            selectedImage: UIImage(systemName: "map.fill")
        )
        
        let profile = HeroNavigationController(rootViewController: ProfileViewController())
        profile.tabBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )
        
        viewControllers = [explore, map, profile]
    }
}
