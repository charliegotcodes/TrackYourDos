//
//  ContentView.swift
//  TrackYourDo's
//
//  Created by Kevin Charles on 2024-12-16.
//

import SwiftUI

//Structure for the Task Itself
struct Task: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var description: String
    var IsCompleted: Bool = false
}

struct AddYourTask: View {
    
    @Binding var TrackYourDos: [Task]
    @State private var newTaskTitle: String = ""
    @State private var newTaskDescription: String = ""
    
    private let titleCharacterLimit = 35
    private let descriptionCharacterLimit = 100
    
    @State private var shouldNavigate = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
            VStack (spacing:50){
                Spacer()
                Text("Task Name")
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
                TextField("Enter Here ", text: $newTaskTitle).foregroundColor(.white).font(.system(size: 24)).bold().multilineTextAlignment(.center).frame(maxWidth: 350).onChange(of:newTaskTitle){
                    if newTaskTitle.count > titleCharacterLimit {
                        newTaskTitle = String(newTaskTitle.prefix(titleCharacterLimit))
                    }
                }
                Text("Task Description")
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
                TextEditor(text: $newTaskDescription)
                    .foregroundColor(.white)
                    .font(.system(size: 18))
                    .frame(maxWidth: .infinity, minHeight: 100)
                    .background(Color.clear)
                    .cornerRadius(12).overlay(Text("Enter here").opacity(0.6) .foregroundColor(.gray).bold()
                            .font(.system(size: 24))
                            .opacity(newTaskDescription.isEmpty ? 1 : 0)).padding(.top, -10)
                    .onChange(of: newTaskDescription) {
                        if newTaskDescription.count > descriptionCharacterLimit {
                            newTaskDescription = String(newTaskDescription.prefix(descriptionCharacterLimit))
                        }
                    }
                Spacer()
                Button(action: {
                    addNewTask()
                }) {
                    Text("Create Task").foregroundColor(.blue).font(.system(size: 24)).bold()
                }
            }.navigationDestination(isPresented: $shouldNavigate) {TrackYourDo(TrackYourDos: $TrackYourDos)}
    }
     func addNewTask(){
         // ensures that neither components are empty otherwise returns till the user inputs valid values
         
        guard !newTaskTitle.isEmpty && !newTaskDescription.isEmpty else { return }
        let newTask = Task(title: newTaskTitle, description: newTaskDescription)
         // appends the new task to TrackYourDos Array
        TrackYourDos.append(newTask)
        
        // resets the strings
        newTaskTitle = ""
        newTaskDescription = ""
        print(TrackYourDos)
         saveTrackYourDos()
        
         // exits the AddYourTask view and returns to TrackYourDo view
         shouldNavigate = true
        
    }
    // Saves the TrackYourDos to UserDefaults
    private func saveTrackYourDos() {
        if let encoded = try? JSONEncoder().encode(TrackYourDos) {
            UserDefaults.standard.set(encoded, forKey: "savedTrackYourDos")
        }
    }
}

struct IndividualTask: View {
    var onDelete: () -> Void
    var task: Task
    var body: some View {
        // Alignment of how the Task will appear in the bubble on screen once created
        VStack(alignment: .leading, spacing: 5){
            Text(task.title).font(.headline).bold().foregroundStyle(Color.white).padding(.top, 5).multilineTextAlignment(.leading)
                .lineLimit(3).frame(width: 325, height: 15).multilineTextAlignment(.leading).padding(.top, 10)
            
            Text(task.description).font(.subheadline).foregroundColor(Color.white).padding(.top, 5).multilineTextAlignment(.leading)
                .lineLimit(4).frame(width: 325, height: 50).padding(.bottom, 10)
        }.background(Color.blue).cornerRadius(20).padding(.bottom, 10)
            .padding([.leading, .trailing], 5)
            .contextMenu{
                // The button will initiate the removal of the task to mean it has been completed
                Button(role: .destructive){
                    onDelete()
                }label: {
                    Label("Completed", systemImage: "checkmark.circle.fill")
                }
            }
    }
        
    
}

struct TrackYourDo: View {
    @Binding var TrackYourDos: [Task]
    
    // Used to track when we are adding a new task
    @State private var navigateToAddTask: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    // Running in the background of the app
                    FallingWordsView()
                        .edgesIgnoringSafeArea(.all)
                        .preferredColorScheme(.dark)
                }
                // Shown when TrackYourDos is empty
                if TrackYourDos.isEmpty {
                    VStack(spacing: 20) {
                        Text("No Do's To Track Yet")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        // responsible for switching the variable to true to activate the transition to AddYourTask View
                        Button(action: {
                            navigateToAddTask = true
                        }) {
                            Text("Add Task")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: 250)
                                .background(Color.blue.opacity(1))
                                .cornerRadius(8)
                        }
                    }
                }
                // Shown when TrackYourDos is not empty
                else {
                    NavigationStack{
                        VStack{
                            HStack{
                                Spacer()
                                // displays the plus icon in the top right corner using HStack VStack and Spacer()
                                PlusIcon {
                                        navigateToAddTask = true
                                        print("navigateToAddTask set to \(navigateToAddTask)")
                                        }.padding(.trailing, 34).padding(.top, -20)
                            }.navigationBarHidden(true)
                            HStack{
                                // Title display for this view of the Your To Do List
                                Text("Track Your Dos").fontWeight(.bold).foregroundColor(.white).font(.system(size: 20))
                                Spacer()
                            }.padding(.top, -28).padding(.leading, 6)
                            ScrollView {
                                // Displays each of the tasks in TrackYourDos
                                ForEach(TrackYourDos) { task in
                                    IndividualTask(onDelete: {deleteTask(task)}, task: task)
                                }
                            }.padding(.top, 20).padding(.bottom, 20)
                        }.navigationBarHidden(true)
                    }
                    
                }
            }.navigationBarBackButtonHidden(false)
            // Navigation destination when the plus icon is clicked
            .navigationDestination(isPresented: $navigateToAddTask) {
                AddYourTask(TrackYourDos: $TrackYourDos).preferredColorScheme(.dark)
            }
        }.onAppear {
            // Load tasks when the view appears
            loadTrackYourDos()
        }

    }
    // Deletes the task when its completed
    private func deleteTask(_ task: Task) {
                if let index = TrackYourDos.firstIndex(where: { $0.id == task.id }) {
                    TrackYourDos.remove(at: index)
                }
            }

    // Attempts to load saved tasks from UserDefaults
    private func loadTrackYourDos() {
        if let savedData = UserDefaults.standard.data(forKey: "savedTrackYourDos"),
           let decodedTasks = try? JSONDecoder().decode([Task].self, from: savedData) {
            TrackYourDos = decodedTasks
        }
    }
}

struct PlusIcon: View{
    var action: () -> Void
    // Creating the Plus Icon
    var body: some View{
            Button(action: {
                print("PlusIcon tapped")
                action()
            }){
                // Finds Image for Plus and designs it
                Image(systemName: "plus")
                    .font(.system(size: 35))
                    .foregroundColor(.white)
                    .background(Circle().fill(Color.gray))
            }
    }
}
    
