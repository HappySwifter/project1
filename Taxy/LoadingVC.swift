//
//  LoadingVC.swift
//  Taxy
//
//  Created by Artem Valiev on 16.12.15.
//  Copyright © 2015 ltd Elektronnie Tehnologii. All rights reserved.
//

import Foundation
import UIKit

class LoadingVC: UIViewController, CLLocationManagerDelegate {
    
    let manager =  CLLocationManager()
    @IBOutlet weak var reloadButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.evo_drawerController?.leftDrawerViewController = nil
    }
    
    deinit {
        manager.delegate = nil
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        reloadButton.layer.cornerRadius = 0.8
        checkStatus()
        
    }
    
    private func checkStatus() {
        switch CLLocationManager.authorizationStatus() {
        case .NotDetermined:
            manager.delegate = self
            manager.requestWhenInUseAuthorization()
        case .AuthorizedWhenInUse, .AuthorizedAlways:
            GeoSender.instanse.startSending()
            makeRequests()
        case .Restricted, .Denied:
            Popup.instanse.showError("Геолокация выключена", message: "Для работы приложения, вам необходимо включить геолокацию")
        }
    }
    
    
    private func makeRequests() {
        Helper().showLoading("Загрузка городов")
        Networking.instanse.getCities { [weak self] result in
            Helper().hideLoading()
            switch result {
            case .Error(let error):
                Popup.instanse.showError("", message: error)
                
            case .Response(let cities):
                LocalData.instanse.saveCities(cities)

                let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                if let _ = LocalData().getUserID  {
                    Helper().showLoading("Загрузка профиля")
                    Networking.instanse.getUserInfo { [weak self] result in
                        Helper().hideLoading()
                        switch result {
                        case .Error(let error):
                            Popup.instanse.showError("", message: error)
                            if error == errorDecription().getErrorName(404) { // handle if user not found
                                LocalData.instanse.deleteUserID()
                            }
                            self?.makeRequests()
                            
                        case .Response(_):
                            self?.activateMenu()
                            let centerViewController = storyBoard.instantiateViewControllerWithIdentifier(STID.MakeOrderSTID.rawValue)
                            let nav = NavigationContr(rootViewController: centerViewController)
                            self?.evo_drawerController?.setCenterViewController(nav, withCloseAnimation: true, completion: nil)
                        }
                        
                        
                    }
                } else {
                    self?.activateMenu()
                    let centerViewController = storyBoard.instantiateViewControllerWithIdentifier(STID.LoginSTID.rawValue)
                    let nav = NavigationContr(rootViewController: centerViewController)
                    self?.evo_drawerController?.setCenterViewController(nav, withCloseAnimation: true, completion: nil)
                }
            }
            
            
        }
    }
    
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .AuthorizedWhenInUse, .AuthorizedAlways:
            GeoSender.instanse.startSending()
            makeRequests()
        case .Restricted, .Denied:
            Popup.instanse.showError("Геолокация выключена", message: "Для работы приложения, вам необходимо включить геолокацию")

        case .NotDetermined:
            Popup.instanse.showInfo("Включите геолокацию", message: "Для работы приложения, вам необходимо включить геолокацию")
        }
    }
    
    private func activateMenu() {
        self.evo_drawerController?.leftDrawerViewController =  NavigationContr(rootViewController: MenuVC())
    }
    
    @IBAction func reloadTouched(control: UIControl) {
        checkStatus()
    }
    
}


class GeoSender: NSObject {
    
    static let instanse = GeoSender()
    var timer: NSTimer?
    
    func startSending() {
        switch CLLocationManager.authorizationStatus() {
        case .AuthorizedAlways, .AuthorizedWhenInUse:
            print("start sending coordinates")
            timer?.invalidate()
            timer = NSTimer.scheduledTimerWithTimeInterval(100, target: self, selector: "sendCoords", userInfo: nil, repeats: true)
            timer!.fire()
        default:
            debugPrint("Error \(__FUNCTION__) \(CLLocationManager.authorizationStatus())")
        }
    }
    
    func sendCoords() {
        Helper().getLocation { Networking.instanse.sendCoordinates($0.coordinate) }
    }
    
}