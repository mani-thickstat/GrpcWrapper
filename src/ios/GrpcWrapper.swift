

@objc(GrpcWrapper) class GrpcWrapper : CDVPlugin,VoiceManagerDelegate,ChatDelegate {
    func onOpenChatImage() {
        
    }
    
    func onShowChatText(data: String) {
        
    }
    
    func onMicTestResponse(text: String) {
        print("onMicTestResponse"+text)
        
        
        let  pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs:text);
        
        self.commandDelegate!.send(
            pluginResult,
            callbackId: self.rootCommand?.callbackId
        )
        
        //        print("onMicTestResponse \(pluginResult)")
        //
        //
        //        print("onMicTestResponse \()")
        
        
    }
    
    func onMicActive() {
        print("onMicActive")
    }
    
    func onMicSpeak() {
        print("onMicSpeak")
    }
    
    func onMicProcess() {
        print("onMicProcess")
    }
    
    func onMicListern() {
        print("onMicListern")
    }
    
    func onTest(text: String) {
        print("onTest")
    }
    
    
    
    var rootCommand: CDVInvokedUrlCommand? = nil;
    
    
    //On Tab
    @objc(onTap:)
    func onTap(command: CDVInvokedUrlCommand) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.voiceManager?.setVoiceDelegate(delegate: self,chatDelegate: self);
        appDelegate.voiceManager?.delegate = GrpcWrapper.self as? VoiceManagerDelegate;
        rootCommand = command;

        appDelegate.voiceManager?.onTabMic()
    }
    
    
    //On Release
    @objc(onRelease:)
    func onRelease(command: CDVInvokedUrlCommand) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.voiceManager?.setVoiceDelegate(delegate: self,chatDelegate: self);
        appDelegate.voiceManager?.delegate = GrpcWrapper.self as? VoiceManagerDelegate;
        rootCommand = command;

        appDelegate.voiceManager?.onHoldMic();
    }
    
    
    //On Release
    @objc(onHold:)
    func onHold(command: CDVInvokedUrlCommand) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.voiceManager?.setVoiceDelegate(delegate: self,chatDelegate: self);
        appDelegate.voiceManager?.delegate = GrpcWrapper.self as? VoiceManagerDelegate;
        rootCommand = command;
        
        appDelegate.voiceManager?.onReleaseMic()
    }
    
    
    @objc(echo:)
    func echo(command: CDVInvokedUrlCommand) {
        print("Echo Method");
        var pluginResult = CDVPluginResult(
            status: CDVCommandStatus_ERROR
        )
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.voiceManager?.setVoiceDelegate(delegate: self,chatDelegate: self);
        appDelegate.voiceManager?.onTabMic()
        appDelegate.voiceManager?.delegate = GrpcWrapper.self as? VoiceManagerDelegate;
        rootCommand = command;
        
        //   AppDelegate
        
        let msg = command.arguments[0] as? String ?? ""
        
        if msg.characters.count > 0 {
            /* UIAlertController is iOS 8 or newer only. */
            let toastController: UIAlertController =
                UIAlertController(
                    title: "",
                    message: msg,
                    preferredStyle: .alert
            )
            
            //        self.viewController?.present(
            //        toastController,
            //        animated: true,
            //        completion: nil
            //      )
            
            //      let duration = Double(NSEC_PER_SEC) * 3.0
            //
            //      dispatch_after(
            //        dispatch_time(
            //            dispatch_time_t(DISPATCH_TIME_NOW),
            //          Int64(duration)
            //        ),
            //        dispatch_get_main_queue(),
            //        {
            //          toastController.dismissViewControllerAnimated(
            //            true,
            //            completion: nil
            //          )
            //        }
            //      )
            
            
            
            //            pluginResult = CDVPluginResult(
            //                status: CDVCommandStatus_OK,
            //                messageAs: msg
            //            )
        }
        
        //        self.commandDelegate!.send(
        //            pluginResult,
        //            callbackId: command.callbackId
        //        )
    }
}
