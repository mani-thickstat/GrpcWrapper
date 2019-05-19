//
//  VoiceManager.swift
//  ThickstatLibrary
//
//  Created by apple on 12/12/17.
//  Copyright © 2017 thickstat. All rights reserved.
//
import UIKit
import Foundation


public protocol VoiceManagerDelegate {
    func onMicActive()
    func onMicSpeak()
    func onMicProcess()
    func onMicListern()
    func onBottomLayerVisibility()
    func onBottomLayerOperation()
    func onTest(text : String)

}

public protocol ChatDelegate {
    func onOpenChatImage();
    func onShowChatText(data : String)
}




//    case SHOW_CHAT // Open Chat window on Image
//    case CHAT_AOI // Open Chat window on AOI
//    case CHAT_TEXT // Refresh chat if page is open


public class VoiceManager : NSObject{
    
    
    public enum MIC_STATE {
        case FINISHED
        case LISTENING
        case PROCESS
        case SPEAKING
    }
    
//    case SHOW_CHAT // Open Chat window on Image
//    case CHAT_AOI // Open Chat window on AOI
//    case CHAT_TEXT // Refresh chat if page is open
    
    public var delegate : VoiceManagerDelegate? = nil;
    public var chatDelegate : ChatDelegate? = nil;

    public enum VOICE_TYPE {
        case ALEXA
        case SIRI_VOICE
        case GRPC
    }
    
    var voiceType : VOICE_TYPE = VOICE_TYPE.GRPC
    var alexaVoiceMgr : AlexaVoiceManager? = nil;
    var siriVoiceManager : SiriVoiceManager? = nil;
    var grpcManager : GRPCManager? = nil;

    
    
    
    public func setVoiceDelegate(delegate : VoiceManagerDelegate, chatDelegate : ChatDelegate){
        
        self.chatDelegate = chatDelegate;
        
        if(voiceType == VOICE_TYPE.ALEXA){// Alexa
            
            if(alexaVoiceMgr == nil){
                alexaVoiceMgr = AlexaVoiceManager()
            }
            
            self.delegate =  delegate
            alexaVoiceMgr?.alexaProtocol =  delegate

        }else if(voiceType == VOICE_TYPE.SIRI_VOICE){ // Siri
            if(siriVoiceManager==nil){
                siriVoiceManager = SiriVoiceManager()
            }
            
            self.delegate =  delegate
            siriVoiceManager?.alexaProtocol =  delegate

        }else if(voiceType == VOICE_TYPE.GRPC){
            
            if(grpcManager == nil){
                grpcManager = GRPCManager()
            }
            
            grpcManager?.initDelegate();
            self.delegate = delegate;
            grpcManager?.grpcProtocol = delegate;
            grpcManager?.chatProtocol = chatDelegate;
        }
    }
    
    public func initalize(voiceType : VOICE_TYPE) {
        
        if(voiceType == VOICE_TYPE.ALEXA){// Alexa
            
            if(alexaVoiceMgr == nil){
                alexaVoiceMgr = AlexaVoiceManager()
                alexaVoiceMgr?.initAlexa()
            }
            
           alexaVoiceMgr?.alexaProtocol =  delegate
            
        }else if(voiceType == VOICE_TYPE.SIRI_VOICE){ // Siri
            if(siriVoiceManager==nil){
                siriVoiceManager = SiriVoiceManager()
            }
            
            siriVoiceManager?.alexaProtocol =  delegate

        }else if(voiceType == VOICE_TYPE.GRPC){
            if(grpcManager == nil){
                grpcManager = GRPCManager()
            }
            
            grpcManager?.initDelegate();
            grpcManager?.grpcProtocol = delegate;
            grpcManager?.chatProtocol = chatDelegate;

        }
        
        
    }
    
    public func onLoadTextChatVoiceResponse(text : String){
        
        
       if(voiceType == VOICE_TYPE.GRPC){
            
            if(grpcManager == nil){
                grpcManager = GRPCManager()
                grpcManager?.initDelegate();
                grpcManager?.grpcProtocol = delegate;
                grpcManager?.chatProtocol = chatDelegate;

                
            }
            
            grpcManager?.startTTSCloudTextChatVoice(text: text)
        }
    }
    
    public func onTabMic(){
        
        
        if(voiceType == VOICE_TYPE.ALEXA){// Alexa
            
            if(alexaVoiceMgr == nil){
                alexaVoiceMgr = AlexaVoiceManager()
                alexaVoiceMgr?.initAlexa()
            }
            alexaVoiceMgr?.onMicSingleTab()
            
            alexaVoiceMgr?.alexaProtocol =  delegate
            
        }else if(voiceType == VOICE_TYPE.SIRI_VOICE){ // Siri
           
        }else if(voiceType == VOICE_TYPE.GRPC){
            
            if(grpcManager == nil){
                grpcManager = GRPCManager()
                grpcManager?.initDelegate();
                grpcManager?.grpcProtocol = delegate;
                grpcManager?.chatProtocol = chatDelegate;

            }
            
            grpcManager?.startRecordAudioSingleClick()
        }
    }
   
    public func onHoldMic(){
        print("VOICE_TYPE.GRPC")

        
        if(voiceType == VOICE_TYPE.ALEXA){// Alexa
            
            if(alexaVoiceMgr == nil){
                alexaVoiceMgr = AlexaVoiceManager()
                alexaVoiceMgr?.initAlexa()
            }
            alexaVoiceMgr?.onMicPressed()
            
            alexaVoiceMgr?.alexaProtocol =  delegate

        }else if(voiceType == VOICE_TYPE.SIRI_VOICE){ // Siri
            if(siriVoiceManager==nil){
                siriVoiceManager = SiriVoiceManager()
            }
            
            siriVoiceManager?.holdMic()
            siriVoiceManager?.alexaProtocol =  delegate
        }else if(voiceType == VOICE_TYPE.GRPC){
            print("VOICE_TYPE.GRPC")

            if(grpcManager == nil){
                grpcManager = GRPCManager()
                grpcManager?.initDelegate();
                grpcManager?.grpcProtocol = delegate;
                grpcManager?.chatProtocol = chatDelegate;

            }
            
            grpcManager?.startRecordAudioLongClick();

        }
    }
 
    public func onReleaseMic(){
        if(voiceType == VOICE_TYPE.ALEXA){ // Alexa

            if(alexaVoiceMgr == nil){
                    alexaVoiceMgr = AlexaVoiceManager()
                    alexaVoiceMgr?.initAlexa()
            }
            alexaVoiceMgr?.onMicReleased()
            alexaVoiceMgr?.alexaProtocol =  delegate
        }else if(voiceType == VOICE_TYPE.SIRI_VOICE){// Siri

            if(siriVoiceManager==nil){
                siriVoiceManager = SiriVoiceManager()
            }
            siriVoiceManager?.releaseMic()
            siriVoiceManager?.alexaProtocol =  delegate
        }else if(voiceType == VOICE_TYPE.GRPC){
            if(grpcManager == nil){
                grpcManager = GRPCManager()
                grpcManager?.initDelegate();
                grpcManager?.grpcProtocol = delegate;
                grpcManager?.chatProtocol = chatDelegate;

            }
            
            grpcManager?.stopRecordAudio();
            
        }
    }
    
    
    public func setVoice(voiceType : VOICE_TYPE){
        self.voiceType = voiceType;
    }
    
   public func getCurrentMicState() -> MIC_STATE{
        if(voiceType == VOICE_TYPE.ALEXA){ // Alexa
    
            return (alexaVoiceMgr?.currentMicState) ?? MIC_STATE.FINISHED;
            
        }else if(voiceType == VOICE_TYPE.SIRI_VOICE){// Siri
            return (siriVoiceManager?.currentMicState) ?? MIC_STATE.FINISHED
        }else if(voiceType == VOICE_TYPE.GRPC){
            return (grpcManager?.currentMicState) ?? MIC_STATE.FINISHED
        
        }
    
        return MIC_STATE.FINISHED
    }
    
    //GRPC Stop all mic process
    public func cancelAllMicProcess(){
       if(voiceType == VOICE_TYPE.GRPC){
        grpcManager?.cancelAllMicProcess();
            
        }
        
    }
    
    public func isBottomLayerOpen()-> Bool{
        if(voiceType == VOICE_TYPE.ALEXA){ // Alexa
            
            return (alexaVoiceMgr?.isBottomLayerOpen)!;
            
        }
        
        return false;
    }
  
    public func isBottomLayerPlaying()-> Bool{
        if(voiceType == VOICE_TYPE.ALEXA){ // Alexa            
            return (alexaVoiceMgr?.isBottomLayerPlaying)!;
            
        }
        return false;
    }
    
    public func audioNext(){
        if(voiceType == VOICE_TYPE.ALEXA){ // Alexa
            alexaVoiceMgr?.onClickNext();
        }
    }
    
    public func audioPrevious(){
        if(voiceType == VOICE_TYPE.ALEXA){ // Alexa
            alexaVoiceMgr?.onClickPrevious();
        }
    }
    
    public func audioPause(){
        if(voiceType == VOICE_TYPE.ALEXA){ // Alexa
            alexaVoiceMgr?.onClickPlayPause()
        }
    }
    
    public func audioPlay(){
        if(voiceType == VOICE_TYPE.ALEXA){ // Alexa
            alexaVoiceMgr?.onClickPlayPause()
        }
    }
    
    public func audioClose(){
        if(voiceType == VOICE_TYPE.ALEXA){ // Alexa
            alexaVoiceMgr?.onClickClose();
        }
    }
    
    public func signOutAlexa(){
        alexaVoiceMgr?.logoutAlexa()
    }
    
    public func isLoggedIn() -> Bool{
        
        if(voiceType == VOICE_TYPE.ALEXA){ // Alexa
        let status =  (alexaVoiceMgr?.isLogin)! || (LoginWithAmazonToken.sharedInstance.loginWithAmazonToken != nil);
        
        if(!status){
            if(alexaVoiceMgr == nil){
                alexaVoiceMgr = AlexaVoiceManager()
            }
            alexaVoiceMgr?.initAlexa()

        }
        
        return status;
        }else{
            return true
        }
    }
}
