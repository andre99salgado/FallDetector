//
//  ContentView.swift
//  FallDetector
//
//  Created by André Salgado on 17/11/2022.
//

import SwiftUI
import CoreMotion
import CoreLocation
import CoreML

struct ContentView: View {
    
    @StateObject private var viewModel = MotionManager()
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            
            VStack {
                MapView()
                    .ignoresSafeArea(edges: .top)
                    .frame(height: 300)
                
                CircleImage()
                    .offset(y: -130)
                    .padding(.bottom, -130)
                
                VStack(alignment: .leading) {
                    Text(String(viewModel.texto))
                        .frame(maxWidth: .infinity, alignment: .center)
                    Spacer()
                    Divider()
                    Spacer()
                    
                    Text("André salgado")
                        .font(.title)
                        .foregroundColor(Color.black)
                    HStack {
                        Text("Computer Science Student")
                            .font(.subheadline)
                        Spacer()
                        Text("Lisbon")
                            .font(.subheadline)
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    
                    Divider()
                    
                    Text("23 years old.")
                    
                    Divider()
                    
                    Group {
                        Text("Gyroscope")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.horizontal, 85.0)
                            .padding(.vertical, 10.0)
                        
                        HStack {
                            Text("X: \(viewModel.x_gyro)")
                                .font(.subheadline)
                            Spacer()
                            Text("Y: \(viewModel.z_gyro)")
                                .font(.subheadline)
                            Spacer()
                            Text("Z: \(viewModel.z_gyro)")
                                .font(.subheadline)
                            
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        
                        Text("Accelerometer")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.horizontal, 85.0)
                            .padding(.vertical, 15.0)
                        
                        HStack {
                            Text("X: \(viewModel.x_acce)")
                                .font(.subheadline)
                            Spacer()
                            Text("Y: \(viewModel.z_acce)")
                                .font(.subheadline)
                            Spacer()
                            Text("Z: \(viewModel.z_acce)")
                                .font(.subheadline)
                            
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        
                        Text("Magnetometer")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.horizontal, 85.0)
                            .padding(.vertical, 15.0)
                        
                        HStack {
                            Text("X: \(viewModel.x_magnet)")
                                .font(.subheadline)
                            Spacer()
                            Text("Y: \(viewModel.z_magnet)")
                                .font(.subheadline)
                            Spacer()
                            Text("Z: \(viewModel.z_magnet)")
                                .font(.subheadline)
                            
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        
                        
                        Divider()
                        Spacer()
                        
                        HStack {
                                    Spacer()
                                        Button("Predict") {
                                            print("Button tapped!")
                                            
                                            print(viewModel.currentIndexInPredictionWindow)
                                            if (viewModel.currentIndexInPredictionWindow == 99) {
                                                viewModel.texto = viewModel.activityPrediction() ?? "teste"
                                                viewModel.currentIndexInPredictionWindow = 0
                                            }
                                            
                                        }
                                    Spacer()
                                }
                        
                        }
        
                }
                .padding()
                Spacer()
                
                
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        ContentView()
    }
    
}

final class MotionManager: ObservableObject {

    private var motionManager: CMMotionManager
    
    @Published
    var texto: String = "No prediction yet!"
    
    //Gyro variables
    @Published
    var x_gyro: Double = 0.0
    @Published
    var y_gyro: Double = 0.0
    @Published
    var z_gyro: Double = 0.0
    
    //Accelerometer data variables
    @Published
    var x_acce: Double = 0.0
    @Published
    var y_acce: Double = 0.0
    @Published
    var z_acce: Double = 0.0

    
    //Magnetometer data variables
    @Published
    var x_magnet: Double = 0.0
    @Published
    var y_magnet: Double = 0.0
    @Published
    var z_magnet: Double = 0.0
    
    // Define some ML Model constants for the recurrent network
      struct ModelConstants {
        static let numOfFeatures = 9
        // Must be the same value you used while training
        static let predictionWindowSize = 100
        // Must be the same value you used while training
        static let sensorsUpdateFrequency = 1.0 / 100.0
        static let stateInLength = 400
        static let hiddenInLength = 100
        static let hiddenCellInLength = 300
      }
    
    // Initialize the model, layers, and sensor data arrays
    private let classifier = modelo_final()
    private let modelName:String = "FallClassifier"
    var currentIndexInPredictionWindow = 0
    let accX = try? MLMultiArray(
        shape: [ModelConstants.predictionWindowSize] as [NSNumber],
        dataType: MLMultiArrayDataType.double)
    let accY = try? MLMultiArray(
        shape: [ModelConstants.predictionWindowSize] as [NSNumber],
        dataType: MLMultiArrayDataType.double)
    let accZ = try? MLMultiArray(
        shape: [ModelConstants.predictionWindowSize] as [NSNumber],
        dataType: MLMultiArrayDataType.double)
    
    let maX = try? MLMultiArray(
        shape: [ModelConstants.predictionWindowSize] as [NSNumber],
        dataType: MLMultiArrayDataType.double)
    let maY = try? MLMultiArray(
        shape: [ModelConstants.predictionWindowSize] as [NSNumber],
        dataType: MLMultiArrayDataType.double)
    let maZ = try? MLMultiArray(
        shape: [ModelConstants.predictionWindowSize] as [NSNumber],
        dataType: MLMultiArrayDataType.double)
    
    let gyX = try? MLMultiArray(
        shape: [ModelConstants.predictionWindowSize] as [NSNumber],
        dataType: MLMultiArrayDataType.double)
    let gyY = try? MLMultiArray(
        shape: [ModelConstants.predictionWindowSize] as [NSNumber],
        dataType: MLMultiArrayDataType.double)
    let gyZ = try? MLMultiArray(
        shape: [ModelConstants.predictionWindowSize] as [NSNumber],
        dataType: MLMultiArrayDataType.double)
    
    var stateOutput = try! MLMultiArray(shape:[ModelConstants.stateInLength as NSNumber], dataType: MLMultiArrayDataType.double)
    
    var currentState = try? MLMultiArray(
        shape: [(ModelConstants.hiddenInLength +
          ModelConstants.hiddenCellInLength) as NSNumber],
        dataType: MLMultiArrayDataType.double)

    init() {
        //Magnetometer Data
        self.motionManager = CMMotionManager()
        self.motionManager.magnetometerUpdateInterval = 1/20
        self.motionManager.startMagnetometerUpdates(to: .main) { (magnetometerData, error) in
            guard error == nil else {
                print(error!)
                return
            }

            if let magnetData = magnetometerData {
                self.x_magnet = magnetData.magneticField.x
                self.y_magnet = magnetData.magneticField.y
                self.z_magnet = magnetData.magneticField.z
                
                self.maX![self.currentIndexInPredictionWindow] = self.x_magnet as NSNumber
                self.maY![self.currentIndexInPredictionWindow] = self.y_magnet as NSNumber
                self.maZ![self.currentIndexInPredictionWindow] = self.z_magnet as NSNumber
            }

        }
        
        //Gyroscope Data
        self.motionManager.gyroUpdateInterval = 1/20
        self.motionManager.startGyroUpdates(to: .main) { (gyroscopeData, error) in
            guard error == nil else {
                print(error!)
                return
            }
            
            if let gyroData = gyroscopeData {
                self.x_gyro = gyroData.rotationRate.x
                self.y_gyro = gyroData.rotationRate.y
                self.z_gyro = gyroData.rotationRate.z
                
                self.gyX![self.currentIndexInPredictionWindow] = self.x_gyro as NSNumber
                self.gyY![self.currentIndexInPredictionWindow] = self.y_gyro as NSNumber
                self.gyZ![self.currentIndexInPredictionWindow] = self.z_gyro as NSNumber

            }
            
        }
        
        //Accelerometer Data
        self.motionManager.accelerometerUpdateInterval = 1/20
        self.motionManager.startAccelerometerUpdates(to: .main) { (accelerometerData, error)in
            guard error == nil else{
                print(error!)
                return
            }
            
            if let acclerData = accelerometerData {
                self.x_acce = acclerData.acceleration.x
                self.y_acce = acclerData.acceleration.y
                self.z_acce = acclerData.acceleration.z
                
                
                self.accX![self.currentIndexInPredictionWindow] = self.x_acce as NSNumber
                self.accY![self.currentIndexInPredictionWindow] = self.y_acce as NSNumber
                self.accZ![self.currentIndexInPredictionWindow] = self.z_acce as NSNumber
                
                self.currentIndexInPredictionWindow += 1
                     
                // If data array is full - execute a prediction
                if (self.currentIndexInPredictionWindow == 100) {
                    
                    if (self.texto != "Fall"){
                        self.texto = self.activityPrediction() ?? "N/A"
                    }
                        
                    for i in 0...98 {
                        self.accX![i] = self.accX![i+1]
                        self.accY![i] = self.accY![i+1]
                        self.accZ![i] = self.accZ![i+1]
                        self.gyX![i] = self.gyX![i+1]
                        self.gyY![i] = self.gyY![i+1]
                        self.gyZ![i] = self.gyZ![i+1]
                        self.maX![i] = self.maX![i+1]
                        self.maY![i] = self.maY![i+1]
                        self.maZ![i] = self.maZ![i+1]
                    }
                    
                  // Maintain the prediction window
                    
                  self.currentIndexInPredictionWindow -= 1
                
                print()
                 // Update prediction array index
                 }
            }
        }
        
    }
    
    func stopDeviceMotion() {
      guard motionManager.isDeviceMotionAvailable else {
        debugPrint("Core Motion Data Unavailable!")
        return
      }
    // Stop streaming device data
      motionManager.stopDeviceMotionUpdates()
    // Reset some parameters
      currentIndexInPredictionWindow = 0
      currentState = try? MLMultiArray(
        shape: [(ModelConstants.hiddenInLength +
          ModelConstants.hiddenCellInLength) as NSNumber],
        dataType: MLMultiArrayDataType.double)
    }
    
    
    func addMotionDataSampleToArray() {
      // Using global queue for building prediction array
          self.accX![self.currentIndexInPredictionWindow] = 0.1 as NSNumber
          self.accY![self.currentIndexInPredictionWindow] = 0.23 as NSNumber
          self.accZ![self.currentIndexInPredictionWindow] = 0.45 as NSNumber

           // Update prediction array index
           self.currentIndexInPredictionWindow += 1
                
           // If data array is full - execute a prediction
           if (self.currentIndexInPredictionWindow == 1) {
             self.texto = self.activityPrediction() ?? "N/A"
             // Move to main thread to update the UI
             
             // Start a new prediction window from scratch
             self.currentIndexInPredictionWindow = 0
           }
       }
    
    func activityPrediction() -> String? {
        print(self.accX![0])
        print(self.accY![0])
        print(self.accZ![0])
        
        print(self.gyX![0])
        print(self.gyY![0])
        print(self.gyZ![0])
        
        print(self.maX![0])
        print(self.maY![0])
        print(self.maZ![0])
    
      // Perform prediction
        for i in 0...399 {
            currentState?[i] = NSNumber(value: 0)
        }
        
      let modelPrediction = try! classifier.prediction(
        x_ac: accX!,
        x_gyro: gyX!,
        x_mag: maX!,
        y_ac: accX!,
        y_gyro: gyY!,
        y_mag: maY!,
        z_ac: accX!,
        z_gyro: gyZ!,
        z_mag: maY!,
        stateIn: currentState!)
    // Update the state vector
      currentState = modelPrediction.stateOut
    // Return the predicted activity
        print("--------------------------------------")
        print(modelPrediction.label)
        print(modelPrediction.labelProbability)
        print("--------------------------------------")
      return modelPrediction.label
    }
}
