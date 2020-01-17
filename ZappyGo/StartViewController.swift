//
//  StartViewController.swift
//  ZappyGo
//
//  Created by Quentin Liardeaux on 6/25/19.
//  Copyright © 2019 Quentin Liardeaux. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {

    @IBOutlet weak var portTextField: UITextField!
    @IBOutlet weak var hostnameTextField: UITextField!

    override func viewDidLoad() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))

        super.viewDidLoad()
        view.addGestureRecognizer(tap)
        print("\(MemoryLayout<srv_map_size>.size)")
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let port = UInt32(portTextField.text ?? "6000") else { return }
        guard let hostname = hostnameTextField.text else { return }

        if (segue.destination is ViewController) {
            let vc = segue.destination as? ViewController
        
            vc?.serverCommunication = ServerCommunication(port: port,
                                                          hostname: hostname.count == 0 ? "hostname" : hostname)
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
