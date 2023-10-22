### Style Transfer

1. Take an image

2. Mixing it up with the actual style you want to apply

### Python Code

```python
import turicreate as tc

tc.config.set_num_gpus(0)

styles = tc.load_images('style/')
content = tc.load_images('content/')

model = tc.style_transfer.create(styles, content, max_iterations=6000)

test_images = tc.load_images('test/')

stylized_images = model.stylize(test_images, max_size=1024)

stylized_images.explore()

model.export_coreml('MyCustomStyleTransfer.mlmodel')
```

### Swift Code

```swift
import Foundation
import UIKit
import VideoToolbox

extension UIImage {

    static func imageFromCVPixelBuffer(pixelBuffer: CVPixelBuffer) -> UIImage? {
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)

        guard let img = cgImage else {
            return nil
        }

        return UIImage(cgImage: img)
    }


    func resizeTo(size :CGSize) -> UIImage? {

        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(origin: CGPoint.zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resizedImage
    }

    func toBuffer() -> CVPixelBuffer? {

        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(self.size.width), Int(self.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }

        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)

        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)

        UIGraphicsPushContext(context!)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

        return pixelBuffer
    }

}

```

```swift

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

```
