//
//  TGChatViewController.swift
//  NoChat-Swift-Example
//
//  Copyright (c) 2016-present, little2s.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import UIKit
import NoChat
import MultipeerConnectivity
import MobileCoreServices
import AVFoundation
import MessageUI
import GSImageViewerController
import CoreData

var control_resources = "0"

@available(iOS 10.0, *)
class TGChatViewController: NOCChatViewController, UINavigationControllerDelegate, TGChatInputTextPanelDelegate, TGTextMessageCellDelegate, MCBrowserViewControllerDelegate, MCSessionDelegate, UIImagePickerControllerDelegate, MFMailComposeViewControllerDelegate  {
    
    let serviceType = "LCOC-Chat"
    
    var global_flag = "0"
    
    var camera_control = 0
    
    let uuid = UUID().uuidString
    
    var images = [UIImage]()
    var browser : MCBrowserViewController!
    var assistant : MCAdvertiserAssistant!
    var session : MCSession!
    var peerID: MCPeerID!
    
    var message_content = ""
    
    var image_data_content = UIImage()
    var temp_image = UIImage()
    
    var data_video = Data()
    
    var sessao_enable = 0
    
    var control_browser = 0
    
    var flag_browser = 0
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        dismiss(animated: true, completion: nil)
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            let msg = Message()
            msg.text = "Conexão estabelecida com: \(peerID.displayName)"
            msg.msgType = "System"
            addMessages([msg], scrollToBottom: true, animated: true)
            self.coredata_insert(msg)
            
        case MCSessionState.connecting:
            let msg = Message()
            msg.text = "Obtendo conexão com: \(peerID.displayName)"
            msg.msgType = "System"
            addMessages([msg], scrollToBottom: true, animated: true)
            self.coredata_insert(msg)
            
        case MCSessionState.notConnected:
            let msg = Message()
            msg.text = "Informação: \(peerID.displayName) está offline"
            msg.msgType = "System"
            addMessages([msg], scrollToBottom: true, animated: true)
            self.coredata_insert(msg)
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            
            if self.global_flag == "1" {
                
                if let mensagem = String(data: data, encoding: String.Encoding.utf8) {
                
                    var senderID : String
                    var type : String
                    var chatType: String
                    
                    senderID = peerID.displayName
                    type = "Text"
                    chatType = "bot"
                    
                    control_resources = "1"
                    
                    if(self.message_content != mensagem){
                        
                        let msg = Message()
                        msg.senderId = senderID
                        msg.msgType = type
                        msg.text = "~" + peerID.displayName + "\n" + mensagem
                        msg.isOutgoing = false
                        
                        self.addMessages([msg], scrollToBottom: true, animated: true)
                        
                        self.coredata_insert(msg)
                        
                        SoundManager.manager.playSound(name: "notification.caf", vibrate: false)
                        
                    }
                }
                
                control_resources = "0"
                self.global_flag = "0"
                
            } else if self.global_flag == "2" {
        
                if let image = UIImage(data: data) {
                    
                    var senderID : String
                    var type : String
                    var chatType: String
                    
                    senderID = peerID.displayName
                    type = "Text"
                    chatType = "bot"
                    
                    control_resources = "2"
                    
                    if (self.image_data_content != image) {
                        
                        let msg = Message()
                        msg.senderId = senderID
                        msg.msgType = type
                        msg.text = "~" + peerID.displayName + " enviou uma foto para sua galeria"
                        msg.image = image
                        msg.isOutgoing = false
                        
                        self.temp_image = image
                        
                        UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                        
                        self.addMessages([msg], scrollToBottom: true, animated: true)
                        
                        /*
                        let msg_ok = Message()
                        msg_ok.text = "Foto recebida"
                        msg_ok.msgType = "System"
                        self.sendMessage_system(msg_ok)
                        */
                        
                        self.coredata_insert(msg)
                        
                        SoundManager.manager.playSound(name: "notification.caf", vibrate: false)
                    
                    }
                    
                }
                
                control_resources = "0"
                self.global_flag = "0"
             
            } else if self.global_flag == "3" {
                
                if let mensagem = String(data: data, encoding: String.Encoding.utf8) {
                    
                    var senderID : String
                    var type : String
                    var chatType: String
                    
                    senderID = peerID.displayName
                    type = "System"
                    chatType = "bot"
                    
                    control_resources = "1"
                    
                    if(self.message_content != mensagem){
                        let msg = Message()
                        msg.senderId = senderID
                        msg.msgType = type
                        msg.text = peerID.displayName + ": " + mensagem
                        msg.isOutgoing = false
                        
                        self.addMessages([msg], scrollToBottom: true, animated: true)
                        
                        self.coredata_insert(msg)
                        
                        SoundManager.manager.playSound(name: "notification.caf", vibrate: false)
                    }
                    
                }
                
                control_resources = "0"
                self.global_flag = "0"
                
            } else if self.global_flag == "0" {
                
                let type = String(data: data, encoding: String.Encoding.utf8)
                
                if type == "1" { self.global_flag = "1" }
                if type == "2" { self.global_flag = "2" }
                if type == "3" { self.global_flag = "3" }
        
            } else  {
                print("Erro ao receber dados")
            }
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
        var senderID : String
        var type : String
        var chatType: String
                
        senderID = peerID.displayName
        type = "Text"
        chatType = "bot"
                
        control_resources = "2"
                
        if (peerID.displayName != "Você") {
            
            let msg = Message()
            msg.senderId = senderID
            msg.msgType = type
            msg.text = "~" + peerID.displayName + " enviou um video para sua galeria"
            msg.isOutgoing = false
            
            if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum((localURL?.relativePath)!) {
                UISaveVideoAtPathToSavedPhotosAlbum((localURL?.relativePath)!, nil, #selector(self.video_receive(videoPath:didFinishSavingWithError:contextInfo:)), nil)
            }else{
                print("Video não encontrado")
            }
                    
            self.addMessages([msg], scrollToBottom: true, animated: true)
                    
            self.coredata_insert(msg)
                    
            SoundManager.manager.playSound(name: "notification.caf", vibrate: false)
        }
            
        control_resources = "0"
        self.global_flag = "0"
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
        let msg = Message()
        msg.text = "Você entrou numa sessão remota"
        msg.msgType = "System"
        addMessages([msg], scrollToBottom: true, animated: true)
        self.coredata_insert(msg)
        
        /*
        let msg_ok = Message()
        msg_ok.text = "Sessão remota iniciada"
        msg_ok.msgType = "System"
        sendMessage_system(msg_ok)
        */
        
        sessao_enable = 2
        flag_browser = 1
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
        if (session.connectedPeers.count == 0){
            let msg = Message()
            msg.text = "Sessão remota offline"
            msg.msgType = "System"
            addMessages([msg], scrollToBottom: true, animated: true)
            self.coredata_insert(msg)
        }
    }
    
    var titleView = TGTitleView()
    var avatarButton = TGAvatarButton()
    
    var messageManager = MessageManager.manager
    var layoutQueue = DispatchQueue(label: "com.nlabs.nochat-example.tg.layout", qos: DispatchQoS(qosClass: .default, relativePriority: 0))
    
    let chat: Chat
    
    // MARK: Overrides
    
    override class func cellLayoutClass(forItemType type: String) -> Swift.AnyClass? {
        if type == "Text" {
            return TGTextMessageCellLayout.self
        } else if type == "Date" {
            return TGDateMessageCellLayout.self
        } else if type == "System" {
            return TGSystemMessageCellLayout.self
        } else {
            return nil
        }
    }
    
    override class func inputPanelClass() -> Swift.AnyClass? {
        return TGChatInputTextPanel.self
    }
    
    override func registerChatItemCells() {
        collectionView?.register(TGTextMessageCell.self, forCellWithReuseIdentifier: TGTextMessageCell.reuseIdentifier())
        collectionView?.register(TGDateMessageCell.self, forCellWithReuseIdentifier: TGDateMessageCell.reuseIdentifier())
        collectionView?.register(TGSystemMessageCell.self, forCellWithReuseIdentifier: TGSystemMessageCell.reuseIdentifier())
    }
    
    init(chat: Chat) {
        self.chat = chat
        super.init(nibName: nil, bundle: nil)
        registerContentSizeCategoryDidChangeNotification()
        setupNavigationItems()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        unregisterContentSizeCategoryDidChangeNotification()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView?.image = UIImage(named: "TGWallpaper")!
        navigationController?.delegate = self
        self.peerID = MCPeerID(displayName: UIDevice.current.name)
        self.session = MCSession(peer: peerID)
        self.session.delegate = self
        self.assistant = MCAdvertiserAssistant(serviceType:serviceType, discoveryInfo:nil, session:self.session)
        navigationController?.updateViewConstraints()
        showConnectionPrompt()
        coredata_list()
        /*
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let requisicao = NSFetchRequest<NSFetchRequestResult>(entityName: "Session")
        var session_flag = 0
        
        requisicao.returnsObjectsAsFaults = false
        
        do{
            let mensagens = try context.fetch(requisicao)
            
            if mensagens.count > 0 {
                for mensagem in mensagens as! [NSManagedObject] {
                    do{
                        try session_flag = mensagem.value(forKey: "state") as! Int
                        print(String(session_flag))
                    } catch {
                        print("Sesion falg definido como default")
                    }
                }
            } else {
                print("Nenhuma mensagem encontrada")
            }
            
        } catch {
            print("Nenhuma mensagem encontrada")
        }
        
        if (session_flag == 1){
            let alertController = UIAlertController(title: "Informação", message: "Sua sessão foi perdida ao voltar a tela, deseja reiniciar sessão?", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                self.startHosting_reconect()
                
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                let fetchRequest: NSFetchRequest<Session> = Session.fetchRequest()
                
                do {
                    let array_users = try context.fetch(fetchRequest)
                    let user = array_users[0]
                    
                    user.setValue(0, forKey: "state")
                    
                    try context.save()
                    
                } catch {
                    print("Erro ao requisitar dados: \(error)")
                }
            }
            alertController.addAction(OKAction)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
                print("Cancel button tapped");
            }
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion:nil)
        } else if (session_flag == 2) {
            let alertController = UIAlertController(title: "Informação", message: "Sua sessão remota foi perdida ao voltar a tela, deseja reconectar?", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                self.joinSession_reconect()
                
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                let fetchRequest: NSFetchRequest<Session> = Session.fetchRequest()
                
                do {
                    let array_users = try context.fetch(fetchRequest)
                    let user = array_users[0]
                    
                    user.setValue(0, forKey: "state")
                    
                    try context.save()
                    
                } catch {
                    print("Erro ao requisitar dados: \(error)")
                }
            }
            alertController.addAction(OKAction)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
                print("Cancel button tapped");
            }
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion:nil)
        }*/
        
        micButton.addTarget(self, action: #selector(camera_library_access), for: .allTouchEvents)
        attachButton.addTarget(self, action: #selector(showConnectionPrompt_before), for: .allTouchEvents)
    }
    
    // MARK: TGChatInputTextPanelDelegate
    
    func inputTextPanel(_ inputTextPanel: TGChatInputTextPanel, requestSendText text: String) {
        let msg = Message()
        msg.text = text
        sendMessage(msg)
    }
    
    // MARK: TGTextMessageCellDelegate
    
    func didTapLink(cell: TGTextMessageCell, linkInfo: [AnyHashable: Any]) {
        inputPanel?.endInputting(true)
        
        guard let command = linkInfo["command"] as? String else { return }
        let msg = Message()
        msg.text = command
        sendMessage(msg)
    }
    
    // MARK: UINavigationControllerDelegate
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard viewController is ChatsViewController else {
            return
        }
        
        if viewController.isKind(of: ChatsViewController.self) {
            if (sessao_enable == 1){
                let alertController = UIAlertController(title: "Informação", message: "Ao voltar a tela de seleção de salas sua sessão anterior foi perdida, portanto, entre na sala desejada e inicie uma sessão novamente", preferredStyle: .alert)
                
                let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                    navigationController.popToRootViewController(animated: animated)
                    do{
                        try self.assistant.session.disconnect()
                        print("Sessão desconectada")
                    } catch {
                        print("Problema ao finalizar sessao")
                    }
                    print("Sessão finalizada");
                }
                alertController.addAction(OKAction)
                
                viewController.present(alertController, animated: true, completion:nil)
            }else if(sessao_enable == 2){
                let alertController = UIAlertController(title: "Informação", message: "Ao voltar a tela de seleção de salas sua sessão remota anterior foi perdida, portanto, entre na sala desejada e conecte-se novamente com os outros", preferredStyle: .alert)
                
                let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                    navigationController.popToRootViewController(animated: animated)
                    do{
                        try self.assistant.session.disconnect()
                        print("Sessão desconectada")
                    } catch {
                        print("Problema ao finalizar sessao")
                    }
                    print("Sessão offline");
                }
                alertController.addAction(OKAction)
                
                viewController.present(alertController, animated: true, completion:nil)
            }
        }
        
        isInControllerTransition = true
        
        guard let tc = navigationController.topViewController?.transitionCoordinator else { return }
        tc.notifyWhenInteractionEnds { [weak self] (context) in
            guard let strongSelf = self else { return }
            if context.isCancelled {
                strongSelf.isInControllerTransition = false
            }
        }
    }
    
    // MARK: Private
    
    private func setupNavigationItems() {
        titleView.title = chat.title
        titleView.detail = chat.detail
        navigationItem.titleView = titleView
        
        let spacerItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spacerItem.width = -12
        
        avatarButton.addTarget(self, action: #selector(showConnectionPrompt_before), for: .allTouchEvents)
        //let rightItem = UIBarButtonItem(customView: avatarButton)
            
        navigationItem.rightBarButtonItems = [spacerItem]
    }
    
    //Mecanica @ON
    
    func startHosting(action: UIAlertAction!) {
        if (flag_browser == 1){
            let ac = UIAlertController(title: "Informação", message: "Você não pode iniciar ou reiniciar uma sessão, já que não iniciou uma sessão local e possui sessões remotas conectadas", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }else{
            if (control_browser == 0){
                if (sessao_enable == 0) {
                    self.assistant.start()
                    let msg = Message()
                    msg.text = "Sessão local iniciada"
                    msg.msgType = "System"
                    addMessages([msg], scrollToBottom: true, animated: true)
                    self.coredata_insert(msg)
                    navigationController?.updateViewConstraints()
                    sessao_enable = 1
                } else {
                    self.assistant.session.disconnect()
                    self.assistant = MCAdvertiserAssistant(serviceType:serviceType, discoveryInfo:nil, session:self.session)
                    self.assistant.start()
                    let msg = Message()
                    msg.text = "Sessão local reiniciada"
                    msg.msgType = "System"
                    addMessages([msg], scrollToBottom: true, animated: true)
                    self.coredata_insert(msg)
                    navigationController?.updateViewConstraints()
                    sessao_enable = 1
                }
                control_browser = 1
            }else{
                let ac = UIAlertController(title: "Informação", message: "Você já iniciou uma sessão, espere que alguem se conecte a você ou volte a tela para forçar reinicio da sessão", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac, animated: true)
            }
        }
    }
    
    func joinSession(action: UIAlertAction!) {
        if (control_browser == 1){
            let ac = UIAlertController(title: "Informação", message: "Você já iniciou uma sessão, portanto deve esperar alguem se conectar a você", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }else{
            self.browser = MCBrowserViewController(serviceType:serviceType, session:self.session)
            self.browser.delegate = self
            self.present(browser, animated: true)
            navigationController?.updateViewConstraints()
        }
    }
    
    /*
    func startHosting_reconect() {
        if (sessao_enable == 0) {
            self.assistant.start()
            let msg = Message()
            msg.text = "Sessão local iniciada"
            msg.msgType = "System"
            addMessages([msg], scrollToBottom: true, animated: true)
            self.coredata_insert(msg)
            navigationController?.updateViewConstraints()
            sessao_enable = 1
        } else {
            self.assistant.session.disconnect()
            self.assistant = MCAdvertiserAssistant(serviceType:serviceType, discoveryInfo:nil, session:self.session)
            self.assistant.start()
            let msg = Message()
            msg.text = "Sessão local reiniciada"
            msg.msgType = "System"
            addMessages([msg], scrollToBottom: true, animated: true)
            self.coredata_insert(msg)
            navigationController?.updateViewConstraints()
            sessao_enable = 1
        }
        control_browser = 1
    }
    
    func joinSession_reconect() {
        if (control_browser == 0){
            self.browser = MCBrowserViewController(serviceType:serviceType, session:self.session)
            self.browser.delegate = self
            self.present(browser, animated: true)
            navigationController?.updateViewConstraints()
        }else{
            let ac = UIAlertController(title: "Informação", message: "Você já iniciou uma sessão, espere que alguem se conecte a você", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }*/
    
    private func loadMessages() {
        layouts.removeAllObjects()
        
        messageManager.fetchMessages(withChatId: chat.chatId) { [weak self] (msgs) in
            if let strongSelf = self {
                strongSelf.addMessages(msgs, scrollToBottom: true, animated: false)
            }
        }
    }
    
    //mecanica envio on
    
    private func sendMessage(_ message: Message) {
        message.isOutgoing = true
        message.senderId = User.currentUser.userId
        message.deliveryStatus = .Read
        
        let dict = message.text
        
        message_content = dict
        
        let global_flag_msg = "1"
        
        var msg = global_flag_msg.data(using: String.Encoding.utf8, allowLossyConversion: false)
        
        do {
            try self.session.send(msg!, toPeers: self.session.connectedPeers, with: MCSessionSendDataMode.unreliable)
        }catch {
            let ac = UIAlertController(title: "Informação", message: "Você não está conectado com alguém", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
        
        msg = dict.data(using: String.Encoding.utf8, allowLossyConversion: false)
        
        control_resources = "1"
        
        do {
            try self.session.send(msg!, toPeers: self.session.connectedPeers, with: MCSessionSendDataMode.unreliable)
            
            addMessages([message], scrollToBottom: true, animated: true)
            
            self.coredata_insert(message)
            
            SoundManager.manager.playSound(name: "sent.caf", vibrate: false)
            
             control_resources = "0"
        }catch {
            
            let ac = UIAlertController(title: "Erro ao enviar mensagem", message: "Você não está conectado com alguém", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    private func sendImage(_ message: Message) {
        message.isOutgoing = true
        message.senderId = User.currentUser.userId
        message.deliveryStatus = .Read
        
        let global_flag_msg = "2"
        
        var msg = global_flag_msg.data(using: String.Encoding.utf8, allowLossyConversion: false)
        
        do {
            try self.session.send(msg!, toPeers: self.session.connectedPeers, with: MCSessionSendDataMode.unreliable)
        }catch {
            let ac = UIAlertController(title: "Informação", message: "Você não está conectado com alguém", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
        
        message.text = "~Você enviou uma foto"
        control_resources = "2"
        
        if let imageData = UIImagePNGRepresentation(message.image) {
            
            do {
                try session.send(imageData, toPeers: session.connectedPeers, with: .reliable)
                
                addMessages([message], scrollToBottom: true, animated: true)
                
                self.coredata_insert(message)
                
                SoundManager.manager.playSound(name: "sent.caf", vibrate: false)
                
                control_resources = "0"
            } catch {
                let ac = UIAlertController(title: "Erro ao enviar imagem", message: "Você não está conectado com alguém", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac, animated: true)
            }
            
        }
    }
    
    private func sendMessage_system(_ message: Message) {
        message.isOutgoing = true
        message.senderId = User.currentUser.userId
        message.deliveryStatus = .Read
        message.msgType = "System"
        
        let dict = message.text
        
        message_content = dict
        
        let global_flag_msg = "3"
        
        var msg = global_flag_msg.data(using: String.Encoding.utf8, allowLossyConversion: false)
        
        do {
            try self.session.send(msg!, toPeers: self.session.connectedPeers, with: MCSessionSendDataMode.unreliable)
        }catch {
            let ac = UIAlertController(title: "Informação", message: "Você não está conectado com alguém", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
        
        msg = dict.data(using: String.Encoding.utf8, allowLossyConversion: false)
        
        control_resources = "1"
        
        do {
            try self.session.send(msg!, toPeers: self.session.connectedPeers, with: MCSessionSendDataMode.unreliable)
            
            self.coredata_insert(message)
            
            control_resources = "0"
        }catch {
            let ac = UIAlertController(title: "Erro ao enviar mensagem", message: "Você não está conectado com alguém", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    // mecanica envio off
    
    //mecanica principal on
    
    private func addMessages(_ messages: [Message], scrollToBottom: Bool, animated: Bool) {
        layoutQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            let indexes = IndexSet(integersIn: 0..<messages.count)
            
            var layouts = [NOCChatItemCellLayout]()
            
            for message in messages {
                let layout = strongSelf.createLayout(with: message)!
                layouts.insert(layout, at: 0)
            }
            
            DispatchQueue.main.async {
                strongSelf.insertLayouts(layouts, at: indexes, animated: animated)
                if scrollToBottom {
                    strongSelf.scrollToBottom(animated: animated)
                }
            }
        }
    }
  
    //mecanica principal off
    
    func coredata_insert(_ messages: Message){
         print("Indicador do app delegate")
         let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
         let mensagem_db = NSEntityDescription.entity(forEntityName: "Mensagens", in: context)
         let usuario = NSManagedObject(entity: mensagem_db!, insertInto: context)
         
         var msgId = messages.msgId
         var msgType = messages.msgType
         var senderId = messages.senderId
         var date = messages.date
         var text = messages.text
         var isOutgoing = messages.isOutgoing
        
         usuario.setValue(uuid, forKey: "session_id")
         usuario.setValue(msgId, forKey: "msgId")
         usuario.setValue(msgType, forKey: "msgType")
         usuario.setValue(senderId, forKey: "senderId")
         usuario.setValue(date, forKey: "date")
         usuario.setValue(text , forKey: "text")
         usuario.setValue(isOutgoing, forKey: "isOutgoing")
         
         do{
            try context.save()
         } catch {
            print("Erro ao inserir no banco de dados")
         }
    }
    
    func coredata_list(){
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let requisicao = NSFetchRequest<NSFetchRequestResult>(entityName: "Mensagens")
        
        requisicao.returnsObjectsAsFaults = false
        
        do{
            let mensagens = try context.fetch(requisicao)
            
            if mensagens.count > 0 {
                for mensagem in mensagens as! [NSManagedObject] {
                    var msg = Message()
                    
                    msg.msgId = mensagem.value(forKey: "msgId") as! String
                    msg.msgType = mensagem.value(forKey: "msgType") as! String
                    msg.senderId = mensagem.value(forKey: "senderId") as! String
                    msg.date = mensagem.value(forKey: "date") as! Date
                    msg.text = mensagem.value(forKey: "text") as! String
                    msg.isOutgoing = mensagem.value(forKey: "isOutgoing") as! Bool
                    
                    addMessages([msg], scrollToBottom: true, animated: true)
                }

            } else {
                print("Nenhuma mensagem encontrada")
            }
            
            var msg = Message()
            msg.msgType = "Date"
            addMessages([msg], scrollToBottom: true, animated: true)
            self.coredata_insert(msg)
            
            var msg_system = Message()
            msg_system.msgType = "System"
            msg_system.text = "Seja bem vindo a sala de aula! Interaja com os outros participantes no campo logo abaixo."
            addMessages([msg_system], scrollToBottom: true, animated: true)
            
            var msg_system2 = Message()
            msg_system2.msgType = "System"
            msg_system2.text = "Inicie uma sessão ou adicione membros que iniciaram uma sessão remota para conversar."
            addMessages([msg_system2], scrollToBottom: true, animated: true)
        } catch {
            print("Nenhuma mensagem encontrada")
        }
    }
    
    func deleteAllRecords() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Mensagens")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print ("Um erro ocorreu")
        }
    }
    
    func image_camera(action: UIAlertAction!)
    {
        if session.connectedPeers.count > 0 {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                var imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera;
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
                camera_control = 1
            }
        } else {
            let ac = UIAlertController(title: "Informação", message: "Você não está conectado com alguém", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    func image_library(action: UIAlertAction!)
    {
        if session.connectedPeers.count > 0 {
            let image = UIImagePickerController()
            image.delegate = self
            image.sourceType = UIImagePickerControllerSourceType.photoLibrary
            image.allowsEditing = false
            self.present(image, animated: true)
        } else {
            let ac = UIAlertController(title: "Informação", message: "Você não está conectado com alguém", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    func record_video_action (viewController: UIViewController, withDelegate delegate: UIImagePickerControllerDelegate){
        if session.connectedPeers.count > 0 {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                var imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera;
                imagePicker.mediaTypes = [kUTTypeMovie as NSString as String]
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
                camera_control = 1
            }
        } else {
            let ac = UIAlertController(title: "Informação", message: "Você não está conectado com alguém", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    func record_video(action: UIAlertAction!) {
        record_video_action(viewController: self, withDelegate: self)
    }
    
    func GaleriaVideo(action: UIAlertAction!) {
        if session.connectedPeers.count > 0 {
            var imagePicker = UIImagePickerController()
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum){
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
                imagePicker.mediaTypes = [kUTTypeMovie as NSString as String]
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            }
        } else {
            let ac = UIAlertController(title: "Informação", message: "Você não está conectado com alguém", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    func GaleriaImage(action: UIAlertAction!) {
        if session.connectedPeers.count > 0 {
            var imagePicker = UIImagePickerController()
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum){
                print("Galeria Video")
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
                imagePicker.mediaTypes = [kUTTypeImage as String]
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            }
        } else {
            let ac = UIAlertController(title: "Informação", message: "Você não está conectado com alguém", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    func preview_image(action: UIAlertAction!) {
        let imageInfo   = GSImageInfo(image: self.temp_image, imageMode: .aspectFit)
        let imageViewer = GSImageViewerController(imageInfo: imageInfo)
        navigationController?.pushViewController(imageViewer, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        let mediaType = info[UIImagePickerControllerMediaType] as! String
        
        if mediaType == kUTTypeMovie as String {
                
                do {
                    var block_message = 0
                    
                    let message = Message()
                    message.isOutgoing = true
                    message.senderId = User.currentUser.userId
                    message.deliveryStatus = .Read
                    message.text = "~Você enviou um vídeo"
                    control_resources = "2"
                    
                    if block_message == 0 {
                        addMessages([message], scrollToBottom: true, animated: true)
                        
                        self.coredata_insert(message)
                        
                        SoundManager.manager.playSound(name: "sent.caf", vibrate: false)
                        
                        try session.sendResource(at: info[UIImagePickerControllerMediaURL] as! URL, withName: "video.mp4", toPeer: session.connectedPeers[0], withCompletionHandler: nil)
                        
                        if (camera_control == 1) {
                            UISaveVideoAtPathToSavedPhotosAlbum((info[UIImagePickerControllerMediaURL] as! URL).relativePath, self, #selector(self.video(videoPath:didFinishSavingWithError:contextInfo:)), nil)
                            camera_control = 0
                        }
                    }
                    
                    control_resources = "0"
                    
                } catch {
                    let ac = UIAlertController(title: "Erro ao enviar vídeo", message: "Você não está conectado com alguém", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    present(ac, animated: true)
                }
        
        }
        else
        {
            
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
            {
                self.image_data_content = image
    
                if (camera_control == 1) {
                    UIImageWriteToSavedPhotosAlbum(image, self, #selector(image_gallery(_:didFinishSavingWithError:contextInfo:)), nil)
                    camera_control = 0
                }
                
                let msg = Message()
                msg.image = image
                sendImage(msg)

            }
            else
            {
                print("Erro ao abrir imagem")
            }
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func video(videoPath: String, didFinishSavingWithError error: Error?, contextInfo info: AnyObject) {
        var title = "Video salvo!"
        var message = "Seu vídeo foi salvo na biblioteca"
        if let error = error {
            title = "Erro"
            message = "Falha ao salvar Vídeo"
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func video_receive(videoPath: String, didFinishSavingWithError error: Error?, contextInfo info: AnyObject) {
        var title = "Video salvo!"
        var message = "Seu vídeo recebido foi salvo na biblioteca"
        if let error = error {
            title = "Erro"
            message = "Problema ao salvar vídeo recebido"
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: "Erro ao salvar imagem recebida", message: "Você não está conectado com alguém", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Imagem recebida salva!", message: "Sua imagem recebida foi salva na galeria", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Pré-visualizar imagem", style: .default, handler: preview_image))
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    func image_gallery(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: "Erro ao salvar imagem", message: "Você não está conectado com alguém", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Imagem salva!", message: "Sua foto foi salva na galeria", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    func deletar_mensagens(action: UIAlertAction!) {
        deleteAllRecords()
        let ac = UIAlertController(title: "Volte à tela anterior", message: "Volte à tela anterior para limpar mensagens", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func backup_full(action: UIAlertAction!) {
        var email = ""
        
        let alertController = UIAlertController(title: "Digite o email para backup", message: "", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Salvar", style: .default, handler: {
            alert -> Void in
            
            let firstTextField = alertController.textFields![0] as UITextField
            
            email = firstTextField.text!
            
            self.envia_email_full(email)
        
        })
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
            
        })
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Para"
        }
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func backup_session(action: UIAlertAction!) {
        var email = ""
        
        let alertController = UIAlertController(title: "Digite o email para backup", message: "", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Salvar", style: .default, handler: {
            alert -> Void in
            
            let firstTextField = alertController.textFields![0] as UITextField
            
            email = firstTextField.text!
            
            self.envia_email_session(email)
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
            
        })
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Para"
        }
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func envia_email_full(_ email: String){
        if MFMailComposeViewController.canSendMail() {
            let emailVC = MFMailComposeViewController()
            emailVC.mailComposeDelegate = self
            emailVC.setToRecipients([email])
            
            var mensagem_title = "Mensagens - Backup completo"
            
            var mensagem_send = ""
            
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let requisicao = NSFetchRequest<NSFetchRequestResult>(entityName: "Mensagens")
            
            requisicao.returnsObjectsAsFaults = false
            
            do{
                let mensagens = try context.fetch(requisicao)
                
                if mensagens.count > 0 {
                    for mensagem in mensagens as! [NSManagedObject] {
                        var temp_mensagem = ""
                        
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        let myString = formatter.string(from: mensagem.value(forKey: "date") as! Date)
                        let yourDate = formatter.date(from: myString)
                        formatter.dateFormat = "dd-MM HH:mm"
                        let myStringafd = formatter.string(from: yourDate!)
                        
                        if (mensagem.value(forKey: "text") as! String != ""){
                            temp_mensagem = "[" + myStringafd + "] - " + (mensagem.value(forKey: "text") as! String)
                            temp_mensagem = temp_mensagem.replacingOccurrences(of: "\n", with: ": ", options: .literal, range: nil)
                            mensagem_send = mensagem_send + "\n\n" + temp_mensagem
                        }
                    }
                    
                    if (mensagem_send != ""){
                        mensagem_send = mensagem_title + mensagem_send
                        
                        emailVC.setMessageBody(mensagem_send, isHTML:  false)
                        
                        let date = Date()
                        let formatter = DateFormatter()
                        formatter.dateFormat = "dd.MM.yyyy"
                        let result = formatter.string(from: date)
                        
                        emailVC.setSubject("Backup completo: Feito em " + result)
                        present(emailVC, animated: true)
                    }else{
                        let ac = UIAlertController(title: "Informação", message: "Não há mensagens para backup", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(ac, animated: true)
                    }
                    
                } else {
                    print("Nenhuma mensagem encontrada")
                    let ac = UIAlertController(title: "Backup - Informação", message: "Não há mensagens para backup", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(ac, animated: true)
                }
            } catch {
                print("Nenhuma mensagem encontrada")
            }
        } else {
            let ac = UIAlertController(title: "Não foi possivel enviar email", message: "Email não configurado no iphone ou indisponivel", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true)
        }
    }
    
    func envia_email_session(_ email: String){
        if MFMailComposeViewController.canSendMail() {
            let emailVC = MFMailComposeViewController()
            emailVC.mailComposeDelegate = self
            emailVC.setToRecipients([email])
            
            var mensagem_title = "Mensagens - Backup da sessão"
            
            var mensagem_send = ""
            
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let requisicao = NSFetchRequest<NSFetchRequestResult>(entityName: "Mensagens")
            
            requisicao.returnsObjectsAsFaults = false
            
            do{
                let mensagens = try context.fetch(requisicao)
                
                if mensagens.count > 0 {
                    for mensagem in mensagens as! [NSManagedObject] {
                        if (mensagem.value(forKey: "session_id") as! String == uuid){
                            var temp_mensagem = ""
                            
                            let formatter = DateFormatter()
                            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                            let myString = formatter.string(from: mensagem.value(forKey: "date") as! Date)
                            let yourDate = formatter.date(from: myString)
                            formatter.dateFormat = "dd-MM HH:mm"
                            let myStringafd = formatter.string(from: yourDate!)
                            
                            if (mensagem.value(forKey: "text") as! String != ""){
                                temp_mensagem = "[" + myStringafd + "] - " + (mensagem.value(forKey: "text") as! String)
                                temp_mensagem = temp_mensagem.replacingOccurrences(of: "\n", with: ": ", options: .literal, range: nil)
                                mensagem_send = mensagem_send + "\n\n" + temp_mensagem
                            }
                        }
                    }
                    
                    if (mensagem_send != ""){
                        mensagem_send = mensagem_title + mensagem_send
                        
                        emailVC.setMessageBody(mensagem_send, isHTML:  false)
                        
                        let date = Date()
                        let formatter = DateFormatter()
                        formatter.dateFormat = "dd.MM.yyyy"
                        let result = formatter.string(from: date)
                        
                        emailVC.setSubject("Backup: Sessao do dia " + result)
                        present(emailVC, animated: true)
                    }else{
                        let ac = UIAlertController(title: "Informação", message: "Não há mensagens para backup durante essa sessão", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(ac, animated: true)
                    }
                } else {
                    print("Nenhuma mensagem encontrada")
                }
            } catch {
                print("Nenhuma mensagem encontrada")
            }
        } else {
            let ac = UIAlertController(title: "Não foi possivel enviar email", message: "Email não configurado no iphone ou indisponivel", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        switch result.rawValue {
        case MFMailComposeResult.cancelled.rawValue:
            let ac = UIAlertController(title: "Backup", message: "Email cancelado", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true)
        case MFMailComposeResult.saved.rawValue:
            let ac = UIAlertController(title: "Backup", message: "Email salvo nos raschunhos", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true)
        case MFMailComposeResult.sent.rawValue:
            let ac = UIAlertController(title: "Backup", message: "Email enviado para o gerenciador com sucesso", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true)
        case MFMailComposeResult.failed.rawValue:
            let ac = UIAlertController(title: "Erro", message: error!.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true)
        default:
            break
        }
    }

    //MecanicaOFF
    
    //MenusON
    
    func file_library_access() {
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Gravar vídeo", style: .default, handler: record_video))
        ac.addAction(UIAlertAction(title: "Biblioteca", style: .default, handler: GaleriaVideo))
        ac.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        present(ac, animated: true)
    }
    
    func showConnectionPrompt_before() {
        let ac = UIAlertController(title: "Configurações da sessão", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Reiniciar sessão", style: .default, handler: startHosting))
        ac.addAction(UIAlertAction(title: "Adicionar membros", style: .default, handler: joinSession))
        ac.addAction(UIAlertAction(title: "Backup da sessão", style: .default, handler: backup_session))
        ac.addAction(UIAlertAction(title: "Backup completo", style: .default, handler: backup_full))
        ac.addAction(UIAlertAction(title: "Limpar mensagens", style: .default, handler: deletar_mensagens))
        ac.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        present(ac, animated: true)
    }
    
    func showConnectionPrompt() {
        let ac = UIAlertController(title: "Conectando-se aos outros...", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Iniciar uma sessão", style: .default, handler: startHosting))
        ac.addAction(UIAlertAction(title: "Adicionar membros", style: .default, handler: joinSession))
        ac.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        present(ac, animated: true)
    }
    
    func camera_library_access() {
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Camera", style: .default, handler: image_camera))
        ac.addAction(UIAlertAction(title: "Álbuns", style: .default, handler: image_library))
        ac.addAction(UIAlertAction(title: "Galeria", style: .default, handler: GaleriaImage))
        ac.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        present(ac, animated: true)
    }
    
    //MenusOFF
    
    // MARK: Dynamic font support
    
    private func registerContentSizeCategoryDidChangeNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleContentSizeCategoryDidChanged(notification:)), name: .UIContentSizeCategoryDidChange, object: nil)
    }
    
    private func unregisterContentSizeCategoryDidChangeNotification() {
        NotificationCenter.default.removeObserver(self, name: .UIContentSizeCategoryDidChange, object: nil)
    }
    
    //Layout Configuration
    @objc private func handleContentSizeCategoryDidChanged(notification: Notification) {
        if isViewLoaded == false {
            return
        }
        
        if layouts.count == 0 {
            return
        }
        
        // ajust collection display
        
        let collectionViewSize = containerView!.bounds.size
        
        let anchorItem = calculateAnchorItem()
        
        for layout in layouts {
            (layout as! NOCChatItemCellLayout).calculate()
        }
        
        collectionLayout!.invalidateLayout()
        
        let cellLayouts = layouts.map { $0 as! NOCChatItemCellLayout }
        
        var newContentHeight = CGFloat(0)
        let newLayoutAttributes = collectionLayout!.layoutAttributes(for: cellLayouts, containerWidth: collectionViewSize.width, maxHeight: CGFloat.greatestFiniteMagnitude, contentHeight: &newContentHeight)
        
        var newContentOffset = CGPoint.zero
        newContentOffset.y = -collectionView!.contentInset.top
        if anchorItem.index >= 0 && anchorItem.index < newLayoutAttributes.count {
            let attributes = newLayoutAttributes[anchorItem.index]
            newContentOffset.y += attributes.frame.origin.y - floor(anchorItem.offset * attributes.frame.height)
        }
        newContentOffset.y = min(newContentOffset.y, newContentHeight + collectionView!.contentInset.bottom - collectionView!.frame.height)
        newContentOffset.y = max(newContentOffset.y, -collectionView!.contentInset.top)
        
        collectionView!.reloadData()
        
        collectionView!.contentOffset = newContentOffset
        
        // fix navigation items display
        setupNavigationItems()
    }
    
    //Layout configuration
    typealias AnchorItem = (index: Int, originY: CGFloat, offset: CGFloat, height: CGFloat)
    private func calculateAnchorItem() -> AnchorItem {
        let maxOriginY = collectionView!.contentOffset.y + collectionView!.contentInset.top
        let previousCollectionFrame = collectionView!.frame
        
        var itemIndex = Int(-1)
        var itemOriginY = CGFloat(0)
        var itemOffset = CGFloat(0)
        var itemHeight = CGFloat(0)
        
        let cellLayouts = layouts.map { $0 as! NOCChatItemCellLayout }

        let previousLayoutAttributes = collectionLayout!.layoutAttributes(for: cellLayouts, containerWidth: previousCollectionFrame.width, maxHeight: CGFloat.greatestFiniteMagnitude, contentHeight: nil)
        
        for i in 0..<layouts.count {
            let attributes = previousLayoutAttributes[i]
            let itemFrame = attributes.frame
            
            if itemFrame.origin.y < maxOriginY {
                itemHeight = itemFrame.height
                itemIndex = i
                itemOriginY = itemFrame.origin.y
            }
        }
        
        if itemIndex != -1 {
            if itemHeight > 1 {
                itemOffset = (itemOriginY - maxOriginY) / itemHeight
            }
        }
        
        return (itemIndex, itemOriginY, itemOffset, itemHeight)
    }
    
}
