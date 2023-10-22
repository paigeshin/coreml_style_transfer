//
//  ContentView.swift
//  ImageClassificationSwiftUI
//
//  Created by Mohammad Azam on 2/3/20.
//  Copyright © 2020 Mohammad Azam. All rights reserved.
//

import SwiftUI
import CoreML

struct ContentView: View {
    
    let photos = ["banana","tiger","bottle"]
    @State private var currentIndex: Int = 0
    @State private var classificationLabel: String = ""
    
    @State private var styledImage: UIImage?
    let placeholderImage = UIImage(named: "banana")!

    private var styleTransfer: MyCustomStyleTransfer? {
        try? MyCustomStyleTransfer(configuration: MLModelConfiguration())
    }
    
    private func performStyleTransfer() {
        let currentImageName = self.photos[self.currentIndex]
        guard
            let img = UIImage(named: currentImageName),
            let resized = img.resizeTo(size: CGSize(width: 256, height: 256)),
            let buffer = resized.toBuffer(),
            let model = self.styleTransfer,
            let styleArray = try? MLMultiArray(
                shape: [1] as [NSNumber],
                dataType: .double
            )
        else {
            return
        }
        styleArray[0] = 1.0
        guard let output = try? model.prediction(image: buffer, index: styleArray) else { return }
        let stylizdBuffer = output.stylizedImage
        self.styledImage = UIImage.imageFromCVPixelBuffer(pixelBuffer: stylizdBuffer)
    }
    
    var body: some View {
        VStack(alignment: .center) {
            
            HStack {
                Text("Original Image")
                    .font(.title)
                Spacer()
                Image(photos[currentIndex])
                .resizable()
                    .frame(width: 150, height: 150)
            }.padding()
           
            
            HStack {
                Text("Style")
                    .font(.title)
                Spacer()
                Image("style1")
                    .resizable()
                    .frame(width:150, height: 150)
            }.padding()
            
            HStack {
                Text("Styled Image")
                    .font(.title)
                Spacer()
                
                if styledImage != nil {
                   Image(uiImage: styledImage!)
                    .resizable()
                    .frame(width: 150, height: 150)
                }
               
                
            }.padding()
            
            HStack {
                Button("Previous") {
                    
                    if self.currentIndex >= self.photos.count {
                        self.currentIndex = self.currentIndex - 1
                    } else {
                        self.currentIndex = 0
                    }
                    
                    }.padding()
                    .foregroundColor(Color.white)
                    .background(Color.gray)
                    .cornerRadius(10)
                    .frame(width: 100)
                
                Button("Next") {
                    if self.currentIndex < self.photos.count - 1 {
                        self.currentIndex = self.currentIndex + 1
                    } else {
                        self.currentIndex = 0
                    }
                }
                .padding()
                .foregroundColor(Color.white)
                .frame(width: 100)
                .background(Color.gray)
                .cornerRadius(10)
            
               
                
                
            }.padding()
            
            Button("Classify") {
                // style transfer here
                self.performStyleTransfer()
                
            }.padding()
            .foregroundColor(Color.white)
            .background(Color.green)
            .cornerRadius(8)
            
            Text(classificationLabel)
                .font(.largeTitle)
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
