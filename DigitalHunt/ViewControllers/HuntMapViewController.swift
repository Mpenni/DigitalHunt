//
//  HuntMapViewController.swift
//  DigitalHunt
//
//  Created by Dave Stops on 19/10/23.
//

import UIKit

class HuntMapViewController: UIViewController {
    
    var track = Track()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = track.name
        setupBackButton()

        // Do any additional setup after loading the view.
    }
    
    func setupBackButton(){
        let newBackButton = UIBarButtonItem(title: "Annulla", style: .plain, target: self, action: #selector(back(_:)))
        navigationItem.leftBarButtonItem = newBackButton

    }

    @objc func back(_ sender: UIBarButtonItem?) {
        navigationItem.hidesBackButton = true
        let ac = UIAlertController(title: "Annullare la gara in corso?", message: nil, preferredStyle: .alert)
        let yes = UIAlertAction(title: "Si", style: .destructive, handler: { action in
            self.navigationController?.popViewController(animated: true)
        })
        let no = UIAlertAction(title: "No", style: .default, handler: nil)
        ac.addAction(yes)
        ac.addAction(no)
        self.present(ac, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
