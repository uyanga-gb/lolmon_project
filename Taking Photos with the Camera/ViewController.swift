
import UIKit
import MobileCoreServices
import AVFoundation
import CoreMotion

class ViewController: UIViewController, UITextFieldDelegate,
UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    let socket = SocketIOClient(socketURL: "10.0.0.4:6789")
//    var player = [""]
//    var player_id = 1
    var beenHereBefore = false
    var controller: UIImagePickerController?
    var name = ""
    var song_intro = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("110-pokemon-center", ofType: "mp3")!)
    var song = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("111-pokemon-recovery", ofType: "mp3")!)
    var songAudio = AVAudioPlayer()
    var songAudio2 = AVAudioPlayer()
    
    @IBOutlet weak var snapShot: UIImageView!
    @IBOutlet weak var enterNameText: UITextField!
    @IBOutlet weak var txtTest: UITextField! = nil
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var healthLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    
    @IBAction func enterName(sender: UIButton) {
        nameLabel.text = "Name: \(enterNameText.text)"
        sender.hidden = true
        enterNameText.hidden = true
       txtTest.delegate=self
        name = enterNameText.text
//        player.append(name)
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
     override func viewDidLoad() {
        songAudio = AVAudioPlayer(contentsOfURL: song, error: nil)
        songAudio2 = AVAudioPlayer(contentsOfURL: song_intro, error: nil)
        songAudio.prepareToPlay()
        songAudio2.prepareToPlay()
        super.viewDidLoad()
        socket.connect()
    }
    @IBAction func playPressed(sender: UIButton) {
        songAudio.play()
        songAudio2.play()
    }
    
  func imagePickerController(picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [NSObject : AnyObject]){
      let mediaType:AnyObject? = info[UIImagePickerControllerMediaType]
      
      if let type:AnyObject = mediaType{
        
        if type is String{
          let stringType = type as! String
          
          if stringType == kUTTypeMovie as! String{
            let urlOfVideo = info[UIImagePickerControllerMediaURL] as? NSURL
            if let url = urlOfVideo{
              println("Video URL = \(url)")
            }
          }
            
          else if stringType == kUTTypeImage as! String{
            let metadata = info[UIImagePickerControllerMediaMetadata]
              as? NSDictionary
            if let theMetaData = metadata{
              let image = info[UIImagePickerControllerOriginalImage]
                as? UIImage
              if let theImage = image{
                var imageData = UIImagePNGRepresentation(theImage)
                var base64String = imageData.base64EncodedStringWithOptions(.allZeros)
//                println(base64String)
                snapShot.image = theImage
//              player_id = 1
//                player_id+=1
//                player.append(base64String)
//                player.append(String(player_id))
//                println(player)
                socket.emit("photo", base64String)
                socket.on("connect") { data, ack in
                    println("iOS::WE ARE USING SOCKETS!")
                }
              }
            }
          }
          
        }
      }
      
      picker.dismissViewControllerAnimated(true, completion: nil)
  }
  
    @IBAction func sendPhoto(sender: UIButton) {

    }
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    println("Picker was cancelled")
    picker.dismissViewControllerAnimated(true, completion: nil)
  }

  func isCameraAvailable() -> Bool{
    return UIImagePickerController.isSourceTypeAvailable(.Camera)
  }
  
  func cameraSupportsMedia(mediaType: String,
    sourceType: UIImagePickerControllerSourceType) -> Bool{
      
      let availableMediaTypes =
      UIImagePickerController.availableMediaTypesForSourceType(sourceType) as!
        [String]?
      
      if let types = availableMediaTypes{
        for type in types{
          if type == mediaType{
            return true
          }
        }
      }
      return false
  }

  func doesCameraSupportTakingPhotos() -> Bool{
    return cameraSupportsMedia(kUTTypeImage as! String, sourceType: .Camera)
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    if beenHereBefore{
      return;
    } else {
      beenHereBefore = true
    }
    
    if isCameraAvailable() && doesCameraSupportTakingPhotos(){
      controller = UIImagePickerController()
      if let theController = controller{
        theController.sourceType = .Camera
        theController.mediaTypes = [kUTTypeImage as! String]
        theController.allowsEditing = true
        theController.delegate = self
        
        presentViewController(theController, animated: true, completion: nil)
      }
      
    } else {
      println("Camera is not available")
    }
    
  }
  
}

