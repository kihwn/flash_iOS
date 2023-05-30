import UIKit
import AVFoundation

class testViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    var audioRecorder: AVAudioRecorder!
    var isRecording = false
    
    @IBOutlet weak var recordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getListOfRecordingFiles()
        let fileURL = getDocumentsDirectory().appendingPathComponent("test.m4a")
        removeFile(atURL: fileURL)
        // Request permission to access the microphone
        AVAudioSession.sharedInstance().requestRecordPermission { [unowned self] allowed in
            DispatchQueue.main.async {
                if allowed {
                    // Microphone access granted
                } else {
                    // Microphone access denied, show an alert to the user
                    self.showMicrophoneAccessAlert()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func showMicrophoneAccessAlert() {
        let alert = UIAlertController(title: "마이크 권한이 거부되었습니다.",
                                      message: "설정에서 마이크 권한을 허용해주세요.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel){ _ in
            self.navigationController?.popViewController(animated: true)
        })
        alert.addAction(UIAlertAction(title: "설정", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:])
            }
        })
        
        present(alert, animated: true)
    }
    
    
    @IBAction func recordButtonTapped(_ sender: Any) {
        if isRecording {
            finishRecording(success: true)
            isRecording = false
            recordButton.setTitle("녹음 시작", for: .normal)
            upload()
        } else {
            startRecording()
            isRecording = true
            recordButton.setTitle("녹음 종료", for: .normal)
            
        }
    }
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("test.m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
        } catch {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        
        if success {
            print("Recording succeeded.")
        } else {
            print("Recording failed.")
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    /// 앱 내에 저장된 녹음 파일 목록 출력
    private func getListOfRecordingFiles() {
        // Get the document directory url
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil)
            print(directoryContents)
            
            // if you want to filter the directory contents you can do like this:
            let m4aFiles = directoryContents.filter{ $0.pathExtension == "m4a" }
            print("m4a urls:", m4aFiles)
            let m4aFileNames = m4aFiles.map{ $0.deletingPathExtension().lastPathComponent }
            print("m4a list:", m4aFileNames)
            
        } catch {
            print(error)
        }
    }
    
    
    func upload(){
        let alertController = UIAlertController(title: "업로드 실패", message: "업로드에 실패했습니다. 다시 시도해주세요.", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "확인", style: .default) { (_) in
            alertController.dismiss(animated: true, completion: {
                self.navigationController?.popViewController(animated: true)
            })
        }
        
        alertController.addAction(okAction)
        
        let fileURL = getDocumentsDirectory().appendingPathComponent("test.m4a")
        
        let url = URL(string: "http://13.209.75.213:8080/dementia/upload")
        
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        if let storedCookies = HTTPCookieStorage.shared.cookies(for: url!) {
            // 쿠키를 요청에 추가
            let cookieHeaders = HTTPCookie.requestHeaderFields(with: storedCookies)
            request.allHTTPHeaderFields = cookieHeaders
        }
        
        var body = Data()
        
        let fileData = try? Data(contentsOf: fileURL)
        if fileData == nil {
            print("M4A 파일을 찾을 수 없습니다.")
            return
        }else{
            print("exists file")
        }
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"voice_file\"; filename=\"test.m4a\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: audio/mp4\r\n\r\n".data(using: .utf8)!)
       body.append(fileData!)
       body.append("\r\n".data(using: .utf8)!)
        
        // 바디 마지막 부분 추가
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse {
                print(response.statusCode)
            }
            
            guard let output = try? JSONDecoder().decode(TestRP.self, from: data!) else{
                DispatchQueue.main.async {
                    self.present(alertController, animated: true, completion: nil)
                }
                return
            }
            print(output)
            DispatchQueue.main.async {
                let modifyVC = self.storyboard?.instantiateViewController(withIdentifier: "modify") as! modifyViewController
                modifyVC.textData = output
                self.navigationController?.pushViewController(modifyVC, animated: true)
            }
        }
        task.resume()
    }
    
    
    func removeFile(atURL url: URL) {
        let fileManager = FileManager.default
        
        do {
            try fileManager.removeItem(at: url)
            print("파일이 성공적으로 삭제되었습니다.")
        } catch {
            print("파일 삭제 중 오류가 발생했습니다: \(error)")
        }
    }
    
    var audioPlayer: AVAudioPlayer!
    
    @IBAction func playButtonTapped(_ sender: Any) {
           playRecording()
       }

       func playRecording() {
           let audioFilename = getDocumentsDirectory().appendingPathComponent("test.m4a")
           do {
               try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
               try AVAudioSession.sharedInstance().setActive(true)
           } catch {
               print("Setting up audio session failed: \(error)")
           }
           
           let doesFileExist = FileManager.default.fileExists(atPath: audioFilename.path)
           print("Does file exist? - \(doesFileExist)")
           do {
               audioPlayer = try AVAudioPlayer(contentsOf: audioFilename)
               audioPlayer.delegate = self
               audioPlayer.play()
           } catch {
               print("Error occurred while trying to play recording: \(error)")
           }
       }
       
       // AVAudioPlayerDelegate
       func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
           if flag {
               print("Audio player finished playing.")
           } else {
               print("Audio player did not finish playing.")
           }
       }



}

// MARK: - TestRPElement
struct TestRPElement: Codable {
    let name: String
    let text: [String]
}

typealias TestRP = [TestRPElement]


