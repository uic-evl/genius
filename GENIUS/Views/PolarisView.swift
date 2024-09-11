//
//  PolarisView.swift
//  GENIUS
//
//  Created by Rick Massa on 6/6/24.
//

import SwiftUI

struct PolarisView: View {
    
    var updatingTextHolder = UpdatingTextHolder.shared
    @State private var recording = false
    @State private var directory = ""
    @State var outputs: [String] = []
    @State private var username = "fmassa"
    @State private var password = ""
    @State private var command = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Polaris")
                    .font(.system(size: 30, weight: .medium))
                
                ScrollView {
                    LazyVStack(alignment: .leading) {
                        ForEach(outputs, id: \.self) { line in
                            Text(line)
                                .font(.system(.body, design: .monospaced))
                                .padding(.horizontal)
                                .padding(.vertical, 2)
                                .foregroundColor(.green)
                                .cornerRadius(4)
                        }
                    }
                    .padding()
                }
                .frame(maxHeight: 300)
                .background(Color.black.opacity(0.9))
                .cornerRadius(8)
                .padding()
                
                //                HStack {
                //                    TextField("username", text: $username)
                //                        .textFieldStyle(RoundedBorderTextFieldStyle())
                //                    SecureField("password", text: $password)
                //                        .textFieldStyle(RoundedBorderTextFieldStyle())
                //                }
                //                .padding()
                //
                TextField("command", text: $command)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button("Submit") {
                    
                    sendPostRequest(command: command.components(separatedBy: " && "), directory: directory) { result in
                        print("Result: \(result)")
                        
                        for (input, output) in zip(result.inputs, result.outputs) {
                            if(output != "") {
                                outputs.append(username + "/" + directory + ": " + input + "\n" + output)
                            }
                            else {
                                outputs.append(username + "/" + directory + ": " + input)
                            }
                        }
                        self.directory = result.directory
                    }
                    
                    command = ""
                    password = ""
                }
                .padding()
                Button(action: {
                    if(recording) {
                        Task {
                            codeRequest(command: "Test") { results in
                                print(results)
                            }
                            //command = await handlePolarisCommand(updatingTextHolder: updatingTextHolder, command: command)
                            recording = false
                        }
                    }
                    else {
                        Recorder().startRecording()
                        recording = true
                    }
                }, label: {
                    Text("Ask GENIUS")
                })
            }
            .padding()
        }.background(Color(.systemGray6))
    }
}

#Preview {
    PolarisView()
}
