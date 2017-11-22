//
//  ChatsViewController.swift
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
import CoreData

@available(iOS 10.0, *)
class ChatsViewController: UITableViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.backgroundColor = UIColor.white;
        
        /*
        var session_flag = 0
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let requisicao = NSFetchRequest<NSFetchRequestResult>(entityName: "Session")
        
        requisicao.returnsObjectsAsFaults = false
        
        do{
            let mensagens = try context.fetch(requisicao)
            
            if mensagens.count > 0 {
                for mensagem in mensagens as! [NSManagedObject] {
                    do{
                        try session_flag = mensagem.value(forKey: "state") as! Int
                        print(String(session_flag))
                    } catch {
                        session_flag = 0
                        print("Sesion falg definido como default")
                    }
                }
            } else {
                print("Nenhuma mensagem encontrada")
            }
            
        } catch {
            print("Nenhuma mensagem encontrada")
        }
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Session")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print ("Um erro ocorreu")
        }
        
        if (session_flag != 1 && session_flag != 2){
            let mensagem_db = NSEntityDescription.entity(forEntityName: "Session", in: context)
            let usuario = NSManagedObject(entity: mensagem_db!, insertInto: context)
            
            usuario.setValue(0, forKey: "state")
            print("set value 0")
            
            do{
                try context.save()
            } catch {
                print("Erro ao inserir no banco de dados")
            }
        }*/
    }
    
    var messageManager = MessageManager.manager
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath)
        if indexPath.row == 0 {
            cell.textLabel?.text = "Sala 213: TCC"
            cell.imageView?.image = UIImage(named: "logo-usf")
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let chat = ChatsViewController.botChat
        var chatVC: UIViewController?
        
        if #available(iOS 10.0, *) {
            if indexPath.row == 0 {
                chatVC = TGChatViewController(chat: chat)
            }
        } else {
            // Fallback on earlier versions
        }
        
        if let vc = chatVC {
            navigationController?.pushViewController(vc, animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    static let botChat: Chat = {
        let chat = Chat()
        chat.type = "bot"
        chat.targetId = "89757"
        chat.chatId = chat.type + "_" + chat.targetId
        chat.title = "Sala 213: TCC"
        chat.detail = "USF"
        return chat
    }()
    
}
