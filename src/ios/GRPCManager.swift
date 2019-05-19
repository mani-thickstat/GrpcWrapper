//
//  GRPCManager.swift
//  ThickstatLibrary
//
//  Created by Sathish on 22/06/18.
//  Copyright © 2018 thickstat. All rights reserved.
//

import UIKit
import googleapis
import AVFoundation

let SAMPLE_RATE = 16000

class GRPCManager: NSObject,AudioControllerDelegate,AVAudioPlayerDelegate {
    public var currentMicState = VoiceManager.MIC_STATE.FINISHED
    
    public var grpcProtocol : VoiceManagerDelegate? = nil;
    public var chatProtocol : ChatDelegate? = nil;

    //    @IBOutlet weak var textView: UITextView!
    var audioData: NSMutableData!
    var recordText = "";
    
    private var listenerTimer: Timer!
    private var processTimer: Timer!
    
    var voiceChatTask : URLSessionDataTask? = nil;
    var cloudeTTSTask : URLSessionDataTask? = nil;
    let  stopWords = ["stop", "good bye", "goodbye", "bye for now", "see you later"];
    
    //Status for set App Name Start
    var isMainMicFreshStart : Bool = false;

    //Sound Cues
    var playerSoundCuesSingleClickStart: AVAudioPlayer?
    var playerSoundCuesLongPressStart: AVAudioPlayer?
    var playerSoundCuesEnd: AVAudioPlayer?
    var playerMusicOnProcess: AVAudioPlayer?

    var fileNameForDownlaodTable = "";

    
    //Init
    func initDelegate() {
        AudioController.sharedInstance.delegate = self
    }
    
    
    func cancelAllMicProcess(){
        
        //Reset
        resetStartVoiceProperties();
        
        isAutoListern = false;
        isSessionEnds = true;
        
        //Set mic State
        currentMicState = VoiceManager.MIC_STATE.FINISHED;
        self.setMicView(micState: VoiceManager.MIC_STATE.FINISHED)

    }
    
    
    //Reset all properties
    
    func resetStartVoiceProperties()  {
        
        //Stop Background Task
        voiceChatTask?.cancel();
        cloudeTTSTask?.cancel();
        
        //Stop Timers
        processTimer?.invalidate();
        listenerTimer?.invalidate()
        
        //Stop audio if playing
        if(audioPlayer != nil && audioPlayer.isPlaying){
            audioPlayer.stop();
        }
        
        //Stop music on Play
        if(playerMusicOnProcess != nil && (playerMusicOnProcess?.isPlaying)!){
            playerMusicOnProcess?.stop();
        }
        
        //Stop Streaming
        if(AudioController.sharedInstance.remoteIOUnit != nil){
            _ = AudioController.sharedInstance.stop()
            SpeechRecognitionService.sharedInstance.stopStreaming()
        }

        //Reset Text
        recordText = "";
    }
    
    //Start Voice for text Chat
    func startTTSCloudTextChatVoice(text : String) {
        repromptString = "";
        isSessionEnds = true;
        charSenderText = "";
        
        resetStartVoiceProperties();
        
        startCloudeTTSService(voiceText: text);
        
    }
    
    
    
    //Start Recording by single tab
    func startRecordAudioSingleClick() {
        print("startRecordAudio")
        
        playMicOnSingleClick();
        
        /*isAutoListern = true;
        listenerTimerCount = 0;
        
        //Start Audio Listener
        startRecordAudio();
        
        //Start Timer for silent listener
        listenerTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(listenerTimerListener), userInfo: nil, repeats: true)*/
        
    }
    
    func setupStartSingleClickMic(){
        isAutoListern = true;
        listenerTimerCount = 0;
        
        //Start Audio Listener
        startRecordAudio();
        
        //Start Timer for silent listener
        listenerTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(listenerTimerListener), userInfo: nil, repeats: true)
    }
    
    
    //Start Recording
    func startRecordAudio() {
        print("startRecordAudio")
        
        //Reset All Properties
        resetStartVoiceProperties();
        
        self.setMicView(micState: VoiceManager.MIC_STATE.LISTENING)
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
           // try audioSession.setCategory(AVAudioSessionCategoryRecord)
//            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord, mode: AVAudioSessionModeDefault)
//            try AVAudioSession.sharedInstance().setActive(true)
            if #available(iOS 10.0, *) {
                try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with:[AVAudioSessionCategoryOptions.allowBluetooth, AVAudioSessionCategoryOptions.allowBluetoothA2DP,AVAudioSessionCategoryOptions.defaultToSpeaker])
            } else {
                try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with:[AVAudioSessionCategoryOptions.allowBluetooth,AVAudioSessionCategoryOptions.defaultToSpeaker])
                
            }
        } catch {
            
        }
        audioData = NSMutableData()
        _ = AudioController.sharedInstance.prepare(specifiedSampleRate: SAMPLE_RATE)
        SpeechRecognitionService.sharedInstance.sampleRate = SAMPLE_RATE
        _ = AudioController.sharedInstance.start()
    }
    
    
    //Start Recording
    func startRecordAudioLongClick() {
        print("startRecordAudio")
        playMicOnLongPress();
    }
    
    func setupStartLongPressMic(){
        
        isAutoListern = false;
        isMainMicFreshStart = true;
        
        
        //Reset All Properties
        resetStartVoiceProperties();
        
        self.setMicView(micState: VoiceManager.MIC_STATE.LISTENING)
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
          //  try audioSession.setCategory(AVAudioSessionCategoryRecord)
//            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord, mode: AVAudioSessionModeDefault)
//            try AVAudioSession.sharedInstance().setActive(true)
            
            if #available(iOS 10.0, *) {
                try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with:[AVAudioSessionCategoryOptions.allowBluetooth, AVAudioSessionCategoryOptions.allowBluetoothA2DP,AVAudioSessionCategoryOptions.defaultToSpeaker])
            } else {
                try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with:[AVAudioSessionCategoryOptions.allowBluetooth,AVAudioSessionCategoryOptions.defaultToSpeaker])
                
            }
        } catch {
            
        }
        audioData = NSMutableData()
        _ = AudioController.sharedInstance.prepare(specifiedSampleRate: SAMPLE_RATE)
        SpeechRecognitionService.sharedInstance.sampleRate = SAMPLE_RATE
        _ = AudioController.sharedInstance.start()
    }
    
    //Stop Recording
    func stopRecordAudio() {
        
        //Stop Timers
        processTimer?.invalidate();
        listenerTimer?.invalidate()
        
        
        _ = AudioController.sharedInstance.stop()
        SpeechRecognitionService.sharedInstance.stopStreaming()
        
        processTimerCount = 0;
        self.setMicView(micState: VoiceManager.MIC_STATE.PROCESS)

        processTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(processTimerListener), userInfo: nil, repeats: true)

        
        
        
    }
    
    
    
    //Process Record Voice Response
    func processSampleData(_ data: Data) -> Void {
        audioData.append(data)
        
        // We recommend sending samples in 100ms chunks
        let chunkSize : Int /* bytes/chunk */ = Int(0.1 /* seconds/chunk */
            * Double(SAMPLE_RATE) /* samples/second */
            * 2 /* bytes/sample */);
        
        if (audioData.length > chunkSize) {
            SpeechRecognitionService.sharedInstance.streamAudioData(audioData,
                                                                    completion:
                { [weak self] (response, error) in
                    guard let strongSelf = self else {
                        return
                    }
                    
                    if let error = error {
                        strongSelf.recordText = error.localizedDescription
                    } else if let response = response {
                        var finished = false
                        var confident : Float = 0.0;
                       // print(response)
                        for result in response.resultsArray! {
                            
                            
                            if let result = result as? StreamingRecognitionResult {
                                if result.isFinal {
                                    finished = true
                                }
                                
                                

                                for alternative in result.alternativesArray! {
                                    
                                    if let resultAlter = alternative as? SpeechRecognitionAlternative {
                                       // print("GRPC=>" + resultAlter.transcript + ", Confident = \(resultAlter.confidence)");
                                        
                                        print("\(confident), \(resultAlter.confidence) , \(confident < resultAlter.confidence), "+resultAlter.transcript);
                                        if(confident < resultAlter.confidence){
                                            strongSelf.recordText = resultAlter.transcript;

                                            confident = resultAlter.confidence;
                                        }
                                        
                                    }
                                    
                                }
                                
                            }
                            
                            
                            //Auto Listener Start Fresh listening speech
                            if (strongSelf.isAutoListern) {
                                
                                //Set Listening time
                                
                                let repromptSec = AppContant.getRepromptSec();
                                let listenerSec = AppContant.getListenerSec();

                                print("repromptSec = \(repromptSec)")
                                print("listenerSec = \(listenerSec)")

                                //strongSelf.listenerTimerCount = sharedPreference.getRepromptSec() - sharedPreference.getListenerSec();
                                strongSelf.listenerTimerCount = repromptSec - listenerSec;
                                print("strongSelf.listenerTimerCount = \(strongSelf.listenerTimerCount)")

                                
                                //End the listening if stop word present
                                for word : String in strongSelf.stopWords{
                                    if(word.caseInsensitiveCompare(strongSelf.recordText) == ComparisonResult.orderedSame){

                                        print("equal")

                                        strongSelf.listenerTimerCount = repromptSec + 1;
                                        break;
                                    }
                                }
                                
                                print("strongSelf.listenerTimerCount = \(strongSelf.listenerTimerCount)")

                                
                               
                                
                                
                            }
                            
                        }
                        
                        print("Output => " + strongSelf.recordText );

                        
                        // strongSelf.recordText = response.description
                        //print("description=>"+response.description);

                        if finished {
                            //strongSelf.stopRecordAudio()
                        }
                    }
            })
            self.audioData = NSMutableData()
        }
    }
    
    //Set the Mic State
    private func setMicView(micState : VoiceManager.MIC_STATE){
        
        
        //Stop music on Play
        if(playerMusicOnProcess != nil && (playerMusicOnProcess?.isPlaying)!){
            playerMusicOnProcess?.stop();
        }
        
        currentMicState = micState;
        
        if(micState == .PROCESS){
            playMicOff()
        }
        
        print(micState)
        
        if let alxProto = grpcProtocol{
            switch micState {
            case .FINISHED:
                alxProto.onMicActive()
            case .LISTENING:
                alxProto.onMicListern()
            case .PROCESS:
                alxProto.onMicProcess()
            case .SPEAKING:
                alxProto.onMicSpeak()
            }
        }
        
    }
    
    func jsonToString(json: [String : Any]) -> String{
        do {
            let data1 =  try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted) // first of all convert json to the data
            let convertedString = String(data: data1, encoding: String.Encoding.utf8) // the data will be converted to the string
            
            print(convertedString ?? "defaultvalue")
            
            return convertedString ?? "";
            
        } catch let myJSONError {
            print(myJSONError)
        }
        return "";

    }

    func jsonArrayToString(json: [String]) -> String{
        do {
            let data1 =  try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted) // first of all convert json to the data
            let convertedString = String(data: data1, encoding: String.Encoding.utf8) // the data will be converted to the string
            
            print(convertedString ?? "defaultvalue")
            
            return convertedString ?? "";
            
        } catch let myJSONError {
            print(myJSONError)
        }
        return "";
        
    }
    
    // Start Service after Speach to text
    private func startVocieChatService(text:String){
        
        if let alxProto = grpcProtocol{
            alxProto.onTest(text: "Request = \"" + text + "\"");
        }
        
        let domainStr : String = UserDefaults.standard.string(forKey: AppContant.UD_DOMAIN) ?? ""
       let orgIDStr : String = UserDefaults.standard.string(forKey: AppContant.UD_ORG_ID) ?? ""
       let dataSetNameStr : String = UserDefaults.standard.string(forKey: AppContant.UD_DATASET_NAME) ?? ""
      let dataSetStr : String =  UserDefaults.standard.string(forKey: AppContant.UD_DATASET) ?? ""
       // let appID : String =  UserDefaults.standard.string(forKey: AppContant.UD_APP_ID) ?? AppContant.DEFAULT_APP_ID
        let appID : String =  AppContant.getAppId();

        
        fileNameForDownlaodTable = text + "_" + domainStr;


//        domainStr = (domainStr == nil ? "" : domainStr);
//        orgIDStr = (orgIDStr == nil ? "" : orgIDStr);
//        dataSetNameStr = (dataSetNameStr == nil ? "" : dataSetNameStr);
//        dataSetStr = (dataSetStr == nil ? "" : dataSetStr);

        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
        let dateTime = formatter.string(from: date)
        
        let genData = Util.generateInputTextForAPI(query: text);

        let messageObj : [String : Any] = ["text": genData,"domain": domainStr ,"dataSet": dataSetStr ,"dataSetName": dataSetNameStr ]

//        let messageObj : [String : Any] = ["text": text,"domain": domainStr ,"dataSet": dataSetStr ,"dataSetName": dataSetNameStr ]
        
        let optionObj  : [String : Any]  = ["transform": true,"channel": "voice","source": "mobile"]
        let sessionObj  : [String : Any] = ["sessionId": sessionId,"orgId":orgIDStr,"message":messageObj,"options" : optionObj]
        
        let rootObj  : [String : Any] = ["session": sessionObj, "dateTime":dateTime,"appId":appID]
        
        
        var token = UserDefaults.standard.string(forKey: AppContant.UD_TOKEN)!
        
        token = token.replacingOccurrences(of: " ", with: "%20")
        
        let url = AppContant.getAPI_URLVoiceChat() + token;
        
        var request = URLRequest(url: URL(string: url)!)
        request.addValue("application/json",forHTTPHeaderField: "Content-Type")

        request.httpMethod = "POST"
        
        
        let postString =  jsonToString(json: rootObj);
        
        request.httpBody = postString.data(using: .utf8)
        
         voiceChatTask = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }
            
            do{
                let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: AnyObject];
                
                if let alxProto = self.grpcProtocol{
                    alxProto.onTest(text: "Response = \(json)");
                }
                
                self.loadVoiceChatResponse(json: json);
                
               
                
                
            }catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
        }
        voiceChatTask?.resume()
    }
    
    
    //Store Messge in DB for Chat Window
    func setChatMessage(message:String,imageURL:String,msgType : ChatViewController.MSG_TYPE, msgFrom : ChatViewController.MSG_FROM, isStoreDB:Bool ) {
        
        
        //chatData = ChatDBModel.getInstance().GetAllData()
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy hh:mm a"
        
        let item:Chat = Chat()
        
        item.Message = message
        item.ImageUrl = imageURL
        item.IsSender = (msgFrom == ChatViewController.MSG_FROM.SENDER ? 1:0)
        item.Date =  formatter.string(from: date)
        item.formatedDate = date
        item.MessageType = msgType.rawValue
        item.userID = UserDefaults.standard.string(forKey: AppContant.UD_UID) ?? "";
        
        if(isStoreDB){
            _ =  ChatManager.getInstance().saveChat(chat: item)
        }
    }
    
    var isSessionEnds = true;
    var isTable = false;
    var repromptString = "";
    var sessionId = "";
    var orgId = "";
    var dataSet = "";
    var dataSetName = "";
    var domain = "";
    
    var processTimerCount = 0;
    var listenerTimerCount = 0;
    var isAutoListern = false;
    private var audioPlayer: AVAudioPlayer!
    
    //Load Voice Chat Service Response
    private func loadVoiceChatResponse ( json : [String : AnyObject]){
        
        var isSpeaking = false;
        self.isSessionEnds = true;
        self.repromptString = "";
        // String reply = "";
        var chatText = "";
        var voiceText = "";
        
        do{
            
            
            
            
            
            
            if let ct = json["chatText"] as? String {
                chatText = ct;
            }
            
            if let vt = json["voiceText"] as? String {
                voiceText = vt;
            }
            
            if let sid = json["sessionId"] as? String {
                self.sessionId = sid;
            }
            
            if let oid = json["orgId"] as? String {
                self.orgId = oid;
            }
            
            if let dSet = json["dataSet"] as? String {
                self.dataSet = dSet;
            }
            
            if let dSetName = json["dataSetName"] as? String {
                self.dataSetName = dSetName;
            }
            
            if let reprompt = json["reprompt"] as? String {
                
                
                if (AppContant.isReprompt()) { //Check for Reprompt and set for one time
                    
                    self.repromptString = reprompt;
                }else{
                    self.repromptString = "";
                    
                }
            }
            
            if let dom = json["domain"] as? String {
                self.domain = dom;
            }
            
            
            
            var deviceAction : String = "";
            
            if let dA = json["deviceAction"] as? String {
                deviceAction = dA;
            }
            
            self.isSessionEnds = true;
            
            
            if let sessionEnd = json["sessionEnd"] as? Bool {
                self.isSessionEnds = sessionEnd;
                if (sessionEnd) {
                    self.sessionId = "";
                }
            }
            
            
            var imageURL : String = "";
            
            if let attachmentUrl = json["attachmentUrl"] as? String {
                imageURL = attachmentUrl;
            }
            
            if let isTbl = json["isTable"] as? Bool {
                
                isTable = isTbl;
            }
            
            
            
            
            if let displayChat = json["displayChat"] as? Bool {
                
                var isChatWindowOpen = false;
                
                if(displayChat){
                    
                    //Store Message for Sender
                    self.setChatMessage(message: recordText,imageURL: "",msgType: ChatViewController.MSG_TYPE.TEXT, msgFrom: ChatViewController.MSG_FROM.SENDER, isStoreDB: true)
                    
                    if (isTable && imageURL != "") {//Table Download Excel File
                        
                        
                        //Open Chat window if not opened in foreground
                        if let delegate = self.chatProtocol{
                            delegate.onOpenChatImage()
                        }
                        
                        isChatWindowOpen = true;
                        
                        let urlObj = "{\"url\": \"\(imageURL)\",\"filename\": \"\(self.fileNameForDownlaodTable)\"}";

                        self.setChatMessage(message: chatText,imageURL: urlObj,msgType: ChatViewController.MSG_TYPE.TABLE, msgFrom: ChatViewController.MSG_FROM.RECEIVE, isStoreDB: true)

                        
                    }else if (deviceAction == "1" || deviceAction == "2") { // AOI
                        
                        //sendReply(VoiceService.STATE_CHAT_AOI);
                    

                        self.setChatMessage(message: "Areas of Insights",imageURL: "",msgType: ChatViewController.MSG_TYPE.AREA_OF_INSIGHT, msgFrom: ChatViewController.MSG_FROM.RECEIVE, isStoreDB: true)

                        
                    }else if (deviceAction == "3") { // Did you mean
                        
                       
                        if let clarificationJSON = json["clarification"] as? [String: Any]{
                            
                            if let text = clarificationJSON["text"] as? String{
                                
                                if let clarifyArr = clarificationJSON["clarify"] as? [String]{
                                    
                                    
                                    if(text != nil && text != "" && clarifyArr != nil && clarifyArr.count != 0){
                                        
                                        
                                        //Open Chat window if not opened in foreground
                                        if let delegate = self.chatProtocol{
                                            delegate.onOpenChatImage()
                                        }
                                        
                                        isChatWindowOpen = true;
                                        
                                        self.setChatMessage(message: self.jsonToString(json: clarificationJSON),imageURL: "",msgType:  ChatViewController.MSG_TYPE.DID_YOU_MEAN, msgFrom: ChatViewController.MSG_FROM.RECEIVE, isStoreDB: true)
                                        
                                    }
                                    
                                }
                                
                            }
                            
                            
                            
                        }
                        
                        
                    } else if (chatText != "") { // Text & Iamge
                        
                        if(imageURL != ""){
                            //Open Chat window if not opened in foreground
                            if let delegate = self.chatProtocol{
                                delegate.onOpenChatImage()
                            }
                            isChatWindowOpen = true;
                        }
                        
                        //Store Message for Receiver (Both Text and Image)
                        
                        self.setChatMessage(message: chatText,imageURL: imageURL,msgType: (imageURL == "" ? ChatViewController.MSG_TYPE.TEXT : ChatViewController.MSG_TYPE.IMAGE), msgFrom: ChatViewController.MSG_FROM.RECEIVE, isStoreDB: true)
                        
                    }
                }
                
                //Follow UP
                var isFollowUp = false;
                if let fu = json["isFollowUp"] as? Bool {
                    isFollowUp = fu;
                }
                
                if (isFollowUp) {
                    if let followUpArr = json["followUp"] as? [String]{
                        
                        if(followUpArr.count != 0){
                            
                            DispatchQueue.main.async() {
                                if(!isChatWindowOpen){
                                    //Open Chat window if not opened in foreground
                                    if let delegate = self.chatProtocol{
                                        delegate.onOpenChatImage()
                                    }
                                    
                                }
                                self.setChatMessage(message: self.jsonArrayToString(json: json["followUp"] as! [String]), imageURL: "", msgType: ChatViewController.MSG_TYPE.FOLLOW_UP, msgFrom: ChatViewController.MSG_FROM.RECEIVE, isStoreDB: true)
                            }
                        }
                    }
                }
            }
            
            
            if (!isSessionEnds && dataSet != nil && dataSet != "") {
                UserDefaults.standard.set(domain, forKey: AppContant.UD_DOMAIN)
                UserDefaults.standard.set(orgId, forKey: AppContant.UD_ORG_ID)
                UserDefaults.standard.set(dataSetName, forKey: AppContant.UD_DATASET_NAME)
                UserDefaults.standard.set(dataSet, forKey: AppContant.UD_DATASET)
                
                //Set user based data set
                let userId = UserDefaults.standard.string(forKey: AppContant.UD_UID)!
                UserDefaults.standard.set(dataSet, forKey: userId)
            }
            
            
        }catch let error as NSError {
            print("Failed to load: \(error.localizedDescription)")
            
        }
        isSpeaking = true;
        
        if (!isSpeaking) {
            
            self.setMicView(micState: VoiceManager.MIC_STATE.FINISHED)
            
        } else {
            
            if (voiceText != "") {
                
                if let alxProto = self.grpcProtocol{
                    alxProto.onTest(text: "Response = "+voiceText);
                }
                startCloudeTTSService(voiceText: voiceText);
                
                
                
            } else {
                self.setMicView(micState: VoiceManager.MIC_STATE.FINISHED)
                
            }
            
        }
        
        
    }
    
    
    // Start TTS Cloude Service
    private func startCloudeTTSService(voiceText:String){
        
        if let alxProto = self.grpcProtocol{
            alxProto.onTest(text: "Request for TTS Speak = " + voiceText);
        }
        
        
        //        var cloudTTS  = UserDefaults.standard.string(forKey: AppContant.UD_SELECTED_CLOUD_TTS);
        //
        //        cloudTTS = cloudTTS == "" ? AppContant.DEFAULT_CLOUD_TTS : cloudTTS;
        
        let input = "{\"audioConfig\": {\"audioEncoding\": \"MP3\", \"pitch\": \"0.00\", \"speakingRate\": \"1.00\"},\"input\": {\"text\": \"" + voiceText + "\"}"
        
        let input2 = ",\"voice\": {\"languageCode\": \"en-US\", \"name\": \"" + AppContant.getCloudTTS() + "\"}}";
        
        var postString = input+input2;
        
        // let data = postString.data(using: .utf8)!
        //        do {
        //            if let jsonObj = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as?  [String: AnyObject]
        //            {
        //
        //                postString = "\(jsonObj)";
        //
        //            } else {
        //                print("bad json")
        //            }
        //        } catch let error as NSError {
        //            print(error)
        //        }
        
        
        let urlStr : String = AppContant.API_URL_CLOUD_TTS+AppContant.CLOUD_TTS_API_KEY;
        
        var request = URLRequest(url: URL(string: urlStr)!)
        request.addValue("application/json",forHTTPHeaderField: "Content-Type")
        
        request.httpMethod = "POST"
        
        
        
        
        //        let postString = input+input2;
        
        request.httpBody = postString.data(using: .utf8)
        
        cloudeTTSTask = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }
            
            do{
                let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: AnyObject];
                
                if let alxProto = self.grpcProtocol{
                    alxProto.onTest(text: "Response from TTS Speak = " + voiceText);
                }
                self.loadCloudTTS(json: json);
                
                
                
            }catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
        }
        cloudeTTSTask?.resume()
    }
    
    //Play Base64 Audio
    private func playMp3(base64Str : String){
        if let data = Data(base64Encoded: base64Str) {
            audioPlayer = try? AVAudioPlayer(data: data)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            DispatchQueue.main.async { () -> Void in
                self.setMicView(micState: VoiceManager.MIC_STATE.SPEAKING)
            }
        }else{
            DispatchQueue.main.async { () -> Void in
                
                self.setMicView(micState: VoiceManager.MIC_STATE.FINISHED)
            }
        }
    }
    
    // On Finish Audio Listener
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        if(player == audioPlayer){ // TTS Cloude Audio
            DispatchQueue.main.async { () -> Void in
                
                self.loadAfterMediaplayerComplete();
                
            }
        }else if(player == playerSoundCuesSingleClickStart){ // Single Click Sound Cue
            
                setupStartSingleClickMic();
            
        }else if(player == playerSoundCuesLongPressStart){ // Long Press Sound Cue
            
          //  setupStartLongPressMic();
        }else if(player == playerSoundCuesEnd){
            if(currentMicState == .PROCESS){
                playMusicOnProcess();
            }
        }
       
    }
    
    
    //Method for process after audio player finish
    func  loadAfterMediaplayerComplete () {
        if (isSessionEnds) { // Finish if session ends
            
            self.setMicView(micState: VoiceManager.MIC_STATE.FINISHED)
            
        } else { // Start again if session not ends
            
            //Start again if session not ends
            setupStartSingleClickMic();
            
            
            /* //Stats for auto listen
            isAutoListern = true;
            listenerTimerCount = 0;
            
            //Start Audio Listener
            startRecordAudio();
            
            //Start Timer for silent listener
            listenerTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(listenerTimerListener), userInfo: nil, repeats: true) */
            
            
            
        }
    }
    var charSenderText : String = "";

    
    //Process Timer
    @objc func processTimerListener(){
        
        
        
            if (processTimerCount >= 1) { // just remove call backs
                processTimer.invalidate()
                isGoogleResponseThreadRunning = false;
                
               
                
                if (recordText != nil && recordText != "") {
                    
                    
                    charSenderText = recordText;
                    
                    
                   // sendReply(VoiceService.STATE_CHAT_TEXT);
                    
                    if let delegate = chatProtocol{
                        delegate.onShowChatText(data: charSenderText) // Test need to change
                    }
                    
                    startVocieChatService(text: recordText)
                    
                    
                } else {
                    
                    if (isMainMicFreshStart) { // Main Mic Instance Start
                        
                        isMainMicFreshStart = false;
                        
                        let appName :String = UserDefaults.standard.string(forKey: AppContant.UD_APP_NAME) ?? "";
                        
                        if (appName == "" ) { // Start appName
                            
                            repromptString = "";
                            isSessionEnds = true;
                            charSenderText = "";
                            
                            startCloudeTTSService(voiceText: "You don't have any available apps to access. Contact administrator");
                            
                            
                        } else {
                            
                            charSenderText = "Hey " + appName;
                            
                            
                            //Send text to chat on Request
                         //   sendReply(VoiceService.STATE_CHAT_TEXT);
                            
                            if let delegate = chatProtocol{
                                delegate.onShowChatText(data: charSenderText) // Test need to change
                            }
                            
                            startVocieChatService(text: "Hey " + appName);
                            
                        }
                        
                    } else { // Finish Mic
                    
                        setMicView(micState: VoiceManager.MIC_STATE.FINISHED);
                        
                    }

                    
                }
                
            } else { // post again
                processTimerCount = processTimerCount + 1 ;
            }
    }
    
    
    var isListenerThreadRunning = false;
    var isGoogleResponseThreadRunning = false;
    
    //Timer for Listening State
    @objc func listenerTimerListener(){
        
        
        print("listenerTimerCount >= AppContant.getRepromptSec() \(listenerTimerCount) , \(AppContant.getRepromptSec())")
        
        if (listenerTimerCount >= AppContant.getRepromptSec()) { // just remove call backs
            listenerTimer.invalidate();
            
            isListenerThreadRunning = false;
            
            if (recordText != nil && recordText != "") {
                
                stopRecordAudio();
                
            } else {
                
                //Stop Voice engine
                processTimerCount = 5;
                isGoogleResponseThreadRunning = false;
                processTimer?.invalidate();
                setMicView(micState: VoiceManager.MIC_STATE.PROCESS);
                
                //Stop Streaming
                if(AudioController.sharedInstance.remoteIOUnit != nil){
                    _ = AudioController.sharedInstance.stop()
                    SpeechRecognitionService.sharedInstance.stopStreaming()
                }
                
                if (self.repromptString == "") {
                    
                    setMicView(micState: VoiceManager.MIC_STATE.FINISHED);
                } else {
                    
                   
                    
                    setMicView(micState: VoiceManager.MIC_STATE.PROCESS);
                    
                    
                    startCloudeTTSService(voiceText: self.repromptString);
                    
                    repromptString = "";
                }
                
                
            }
            
        } else { // post again
            listenerTimerCount  = listenerTimerCount + 1;
        }
    }
    
    //Load Cloude Service Response
    private func loadCloudTTS (json : [String: AnyObject]){
        
        
        
        
        var base64String = "";
        
        
        if let audioContent = json["audioContent"] as? String {
            base64String = audioContent;
        }
        
        if (base64String == "") {
            
            self.setMicView(micState: VoiceManager.MIC_STATE.FINISHED)
            
        } else {
            playMp3(base64Str: base64String);
            
        }
    }
    
    
    //Sound Cues for Mic On Single Click
    func playMicOnSingleClick() {
        
        if(UserDefaults.standard.bool(forKey: AppContant.UD_IS_SOUND_CUES)){
            
            let url = Bundle.main.url(forResource: "mic_on", withExtension: "wav")!
            
            do {
                playerSoundCuesSingleClickStart = try AVAudioPlayer(contentsOf: url)
                guard let player = playerSoundCuesSingleClickStart else { return }
                playerSoundCuesSingleClickStart?.delegate = self
                
                player.prepareToPlay()
                player.play()
            } catch let error as NSError {
                print(error.description)
            }
        }else{
            setupStartSingleClickMic();
        }
    }
    
    //Sound Cues for Mic On Long Press
    func playMicOnLongPress() {
        
        setupStartLongPressMic(); // Added Listener before sound cues cause instance listenr issue (Hay ...)

        if(UserDefaults.standard.bool(forKey: AppContant.UD_IS_SOUND_CUES)){
            
            let url = Bundle.main.url(forResource: "mic_on", withExtension: "wav")!
            
            do {
                playerSoundCuesLongPressStart = try AVAudioPlayer(contentsOf: url)
                guard let player = playerSoundCuesLongPressStart else { return }
                playerSoundCuesLongPressStart?.delegate = self
                
                player.prepareToPlay()
                player.play()
            } catch let error as NSError {
                print(error.description)
            }
            if let alxProto = grpcProtocol{
                alxProto.onTest(text: "Sound Cues ON")
            }
        }else{
            if let alxProto = grpcProtocol{
                alxProto.onTest(text: "Sound Cues OFF")
            }

        //    setupStartLongPressMic();
        }
    }
    
    //Sound Cues for Mic OFF
    func playMicOff() {
        if(UserDefaults.standard.bool(forKey: AppContant.UD_IS_SOUND_CUES)){
            
            let url = Bundle.main.url(forResource: "mic_off", withExtension: "wav")!
            
            do {
                
                playerSoundCuesEnd = try AVAudioPlayer(contentsOf: url)
                guard let player = playerSoundCuesEnd else { return }
                playerSoundCuesEnd?.delegate = self

                player.prepareToPlay()
                player.play()
            } catch let error as NSError {
                print(error.description)
            }
        }else{
            
            if(currentMicState == .PROCESS){
                playMusicOnProcess();
            }
        }
    }
    
    //
    func playMusicOnProcess() {
        if(AppContant.isMusicOnProcess()){
            
            let url = Bundle.main.url(forResource: "process", withExtension: "mp3")!
            
            do {
                
                playerMusicOnProcess = try AVAudioPlayer(contentsOf: url)
                guard let player = playerMusicOnProcess else { return }
                
                player.prepareToPlay()
                player.play()
            } catch let error as NSError {
                print(error.description)
            }
        }
    }
}




