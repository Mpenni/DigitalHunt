//
//  QRCodeController.swift
//  DigitalHunt
//
//  Created by Dave Stops on 23/10/23.
//

import UIKit
import AVFoundation

class QRCodeController: UIViewController, UITextFieldDelegate, AVCaptureMetadataOutputObjectsDelegate {
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var track = Track()
 
    @IBOutlet weak var inputCode: UITextField!
    
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var cameraView: UIView!
    
    @IBAction func deleteCodeField(_ sender: Any) {
        inputCode.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputCode.delegate = self
        setupBackButton()
        self.title = "QRCode per tappa \(track.currentNodeIndex + 1)"
        infoLabel.text = "Inserisci o inquadra codice di sblocco"
        setupCamera()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopRunning()
    }
    
    private func checkCode(insertedCode: String) {

        if insertedCode == track.getCurrentNode().code {
            infoLabel.textColor = UIColor.green
            infoLabel.text = "Codice corretto"
            print("Codice corretto")
            self.navigationController?.popViewController(animated: true)
        } else {
            infoLabel.textColor = UIColor.red
            infoLabel.text = "Codice errato, riprova!"
            startRunning()
        }
        
    }
    
    func setupBackButton(){
        let newBackButton = UIBarButtonItem(title: "Annulla", style: .plain, target: self, action: #selector(back(_:)))
        navigationItem.leftBarButtonItem = newBackButton

    }

    @objc func back(_ sender: UIBarButtonItem?) {
        navigationItem.hidesBackButton = true
        let ac = UIAlertController(title: "Questa azione ti farà uscire dall'applicazione", message: nil, preferredStyle: .alert)
        let yes = UIAlertAction(title: "Si", style: .destructive, handler: { action in
            UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
        })
        let no = UIAlertAction(title: "No", style: .default, handler: nil)
        ac.addAction(yes)
        ac.addAction(no)
        self.present(ac, animated: true, completion: nil)
    }

    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Testo prima della modifica
        let previousText = textField.text ?? ""
        
        // Calcola il nuovo testo dopo la modifica
        let newText = (previousText as NSString).replacingCharacters(in: range, with: string)
        
        // Esegui il tuo controllo o azione in base al testo inserito
        if newText.isEmpty {
            // Nessun testo inserito
            // Esegui il tuo controllo o azione qui
        } else {
            // Del testo è stato inserito o modificato
            // Esegui il tuo controllo o azione qui
            checkCode(insertedCode: newText)
        }
        
        return true // Ritorna true per consentire la modifica del testo, false per impedirla
    }

    //MARK:  AVCaptureMetadataOutputObjectsDelegate
    
    private func setupCamera() {
        cameraView.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            failed()
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = cameraView.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        cameraView.layer.addSublayer(previewLayer)

        DispatchQueue.main.async {
            self.captureSession.startRunning()
        }
    }
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    /*
     Thread Performance Checker: -[AVCaptureSession startRunning] should be called from background thread. Calling it on the main thread can lead to UI unresponsiveness
     */
    
    private func startRunning() {
        if (captureSession?.isRunning == false) {
            DispatchQueue.global(qos: .background).async {
                self.captureSession.startRunning()
            }
        }
    }
    
    private func stopRunning() {
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }

        dismiss(animated: true)
    }

    func found(code: String) {
        print("Codice: \(code)")
        checkCode(insertedCode: code)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
}


