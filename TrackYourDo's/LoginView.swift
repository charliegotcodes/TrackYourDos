//
//  ContentView.swift
//  TrackYourDo's
//
//  Created by Kevin Charles on 2024-12-16.
//

import SwiftUI

struct FallingWordsView: View {
    // Words to animate
    @State var words = ["Track", "Your", "Do's", "List", "Due", "Date", "Reminder", "Tasks", "Goals", "Priorities", "Notes", "Agenda", "Assignments"]
    
    @State private var TrackYourDos: [Task] = []
    
    // Tracks current positions of each word (CGSize) as we need both width and height
    @State private var wordPositions: [CGSize] = []
    
    // Tracks the velocity of each word as it travels down the screen
    @State private var wordVelocities: [CGFloat] = []
    
    // Used to store the screen dimensions which is calculated in GeometryReader
    @State private var screenWidth: CGFloat = 0
    @State private var screenHeight: CGFloat = 0

    private let gravity: CGFloat = 50// Speed of the words falling
    private let updateInterval: Double = 0.04 // How fast it will update

    var body: some View {
        // Gives us the size of the parent view in this case being LoginView
        GeometryReader { geometry in
            // ZStack controls the layering of the words
            ZStack {
                ForEach(0..<words.count, id: \.self) { index in
                    Text(words[index])
                        .font(.title)
                        .bold()
                        .foregroundColor(.blue)
                        // Randomizes the position of where the words spawn
                        .position(
                            x: wordPositions.indices.contains(index) ? wordPositions[index].width : geometry.size.width / 2,
                            y: wordPositions.indices.contains(index) ? wordPositions[index].height : -100
                        )
                    // sets a random delay of 1.5 to 5 when the word appears for it to drop
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 1.5...9)) {
                                startFalling(for: index, screenSize: geometry.size)
                            }
                        }
                }
            }
            //executes when this view appears on the screen
            .onAppear {
                screenWidth = geometry.size.width
                screenHeight = geometry.size.height
            //generates the word positions
                wordPositions = (0..<words.count).map { _ in
                    CGSize(width: CGFloat.random(in: -100...geometry.size.width - 50), height: -50)
                }
                wordVelocities = Array(repeating: 0, count: words.count)
            }
        }
    }

    private func startFalling(for index: Int, screenSize: CGSize) {
        // Timer to update the falling words positions at intervals
        Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { timer in
            DispatchQueue.main.async {
                // Gravity calculation for the word's velocity
                wordVelocities[index] += gravity * CGFloat(updateInterval)
                //Position updates on update interval
                wordPositions[index].height += wordVelocities[index] * CGFloat(updateInterval)
                
                // Prevent word from overlapping with others
                                for otherIndex in 0..<index {
                                    let wordWidth = words[index].size(withAttributes: [.font: UIFont.boldSystemFont(ofSize: 24)]).width
                                    let otherWordWidth = words[otherIndex].size(withAttributes: [.font: UIFont.boldSystemFont(ofSize: 24)]).width
                                    
                                    // Check if there is overlap
                                    if abs(wordPositions[index].width - wordPositions[otherIndex].width) < max(wordWidth, otherWordWidth) &&
                                        abs(wordPositions[index].height - wordPositions[otherIndex].height) < 50 {
                                        
                                        // Prevent overlap by adjusting the falling word's position
                                        wordPositions[index].height = wordPositions[otherIndex].height - 60
                                        wordVelocities[index] = 0  // Stop its velocity as it landed on another word
                                        break
                                    }
                                }

                // Reset word to top when it reaches the bottom
                if wordPositions[index].height >= screenSize.height {
                    wordPositions[index].height = -100 // Reset to above the screen
                    let rangeUpperBound = screenSize.width - 50

                    // Ensure that the upper bound is greater than the lower bound (50)
                    if rangeUpperBound > 50 {
                        wordPositions[index].width = CGFloat.random(in: 50...rangeUpperBound)
                    } else {
                        // Handle the case where the range is invalid (e.g., use a default value)
                        wordPositions[index].width = 50
                    } // Randomize the horizontal position
                    wordVelocities[index] = 0 // Reset velocity
                }
            }
        }
    }
}


// LoginView
struct LoginView: View {
    // Storing Necessary Variables
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoggedIn: Bool = false
    @State private var showingAlert: Bool = false
    @State private var TrackYourDos: [Task] = []

    var body: some View {
        //Layering of multiple views in this case FallingWordsView is placed behind all the other UI elements
        NavigationStack{
        ZStack {
            FallingWordsView().edgesIgnoringSafeArea(.all).preferredColorScheme(.dark)
            // Login UI
            
                VStack(spacing: 20) {
                    Text("TrackYourDo's")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom, 20)
                    
                    TextField("Email", text: $email)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(9)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(9)
                    
                    Button(action: {
                        if validateLogin() {
                            isLoggedIn = true
                        } else {
                            showingAlert = true
                        }
                    }) {
                        Text("Login")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(9)
                    }
                    .padding(.top, 10)
                    .alert(isPresented: $showingAlert) {
                        Alert(
                            title: Text("Invalid Credentials"),
                            message: Text("Please check your email or password."),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                    
                    HStack {
                        NavigationLink(destination: Text("Sign-Up View")) {
                            Text("Sign Up")
                                .foregroundColor(.blue)
                        }
                        Spacer()
                        NavigationLink(destination: Text("Forgot Password View")) {
                            Text("Forgot Password?")
                                .foregroundColor(.blue)
                        }
                    }
                    .font(.footnote)
                    .padding(.top, 10)
                }
                .padding()
                .navigationDestination(isPresented: $isLoggedIn) {
                    TrackYourDo(TrackYourDos: $TrackYourDos).preferredColorScheme(.dark)
                }
            }
        }
    }

    private func validateLogin() -> Bool {
        return email == "user@example.com" && password == "password123"
    }
}

//// TaskListView Placeholder
//struct TaskListView: View {
//    var body: some View {
//        Text("Welcome to your To-Do List!")
//            .font(.title)
//            .padding()
//    }
//}
//
//// Preview
//struct LoginView_Previews: PreviewProvider {
//    static var previews: some View {
//        LoginView().preferredColorScheme(.dark)
//    }
//}
