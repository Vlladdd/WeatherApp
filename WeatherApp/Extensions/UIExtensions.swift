//
//  UIExtensions.swift
//  WeatherApp
//
//  Created by Vlad Nechyporenko on 08.04.2022.
//

import SwiftUI
import SDWebImageSwiftUI
import MapKit

//MARK: - Some useful UI extensions

extension View {
    
    //changes color of placeholder of textField
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
    
    //I am using big images as background, but instead of scaleToFit, which makes image small,
    //i just crop it to fit the screen and this looks great. I didnt find a good way to do it
    //on gif images, so for that i am using AnimatedImage instead
    private func cropImageToFitScreen(sourceImage: UIImage, height: CGFloat, width: CGFloat) -> Image {
        let sourceSize = sourceImage.size
        let xOffset = (sourceSize.width - width) / 2.0
        let yOffset = (sourceSize.height - height) / 2.0
        let cropRect = CGRect(
            x: xOffset,
            y: yOffset,
            width: width,
            height: height
        ).integral
        let sourceCGImage = sourceImage.cgImage!
        let croppedCGImage = sourceCGImage.cropping(
            to: cropRect
        )
        if let croppedCGImage = croppedCGImage {
            let croppedImage = UIImage(
                cgImage: croppedCGImage,
                scale: sourceImage.imageRendererFormat.scale,
                orientation: sourceImage.imageOrientation
            )
            let image = Image(uiImage: croppedImage)
            return image
        }
        else {
            return Image(uiImage: sourceImage)
        }
    }
    
    func removeStandardColors() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.5)
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = UITabBar.appearance().standardAppearance
        }
        UITableView.appearance().backgroundColor = .clear
        UITableViewCell.appearance().backgroundColor = .clear
        UIPageControl.appearance().backgroundColor = UIColor.systemBackground.withAlphaComponent(0.1)
        UIPageControl.appearance().currentPageIndicatorTintColor = .red
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.systemBackground.inverseColor()
        UIStepper.appearance().setDecrementImage(UIImage(systemName: "minus"), for: .normal)
        UIStepper.appearance().setIncrementImage(UIImage(systemName: "plus"), for: .normal)
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithTransparentBackground()
        coloredAppearance.backgroundColor =  UIColor.systemBackground.withAlphaComponent(0.5)
        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().compactAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
    }
    
    func delayedAnimation(delay: Double = 1.0, animation: Animation = .default) -> some View {
      self.modifier(DelayedAnimation(delay: delay, animation: animation))
    }
    
    //MARK: - Background
    
    @ViewBuilder
    func makeBackground(image: UIImage?) -> some View {
        GeometryReader{geometry in
            if let image = image {
                let newImage = cropImageToFitScreen(sourceImage: image, height: geometry.size.height, width: geometry.size.width)
                Color.clear
                    .background(
                        newImage
                    )
            }
            else {
                Color.gray
                    .overlay(
                        Text("No image")
                            .font(.largeTitle)
                    )
            }
        }
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    func makeAnimatedBackground(imageName: String) -> some View {
        GeometryReader{geometry in
            Color.clear
                .background(
                    AnimatedImage(name: imageName)
                )
        }
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    func makeTextBackground(text: String) -> some View {
        GeometryReader{geometry in
            Color.gray
                .overlay(
                    Text(text)
                        .font(.largeTitle)
                )
        }
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    func makeMapBackground(lat: Double, lon: Double) -> some View {
        GeometryReader { _ in
            Map(coordinateRegion: .constant(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: lon), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))), interactionModes: [])
        }
        .ignoresSafeArea()
    }
    
}

extension UIColor {
    
    func inverseColor() -> UIColor {
        var alpha: CGFloat = 1.0

        var red: CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: 1.0 - red, green: 1.0 - green, blue: 1.0 - blue, alpha: alpha)
        }

        var hue: CGFloat = 0.0, saturation: CGFloat = 0.0, brightness: CGFloat = 0.0
        if self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            return UIColor(hue: 1.0 - hue, saturation: 1.0 - saturation, brightness: 1.0 - brightness, alpha: alpha)
        }

        var white: CGFloat = 0.0
        if self.getWhite(&white, alpha: &alpha) {
            return UIColor(white: 1.0 - white, alpha: alpha)
        }

        return self
    }
}

//I had a bug: edit button not working, if list have .animation
//By delaying animation, this fixes the problem
struct DelayedAnimation: ViewModifier {
    var delay: Double
    var animation: Animation
    
    @State private var animating = false
    
    func delayAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.animating = true
        }
    }
    
    func body(content: Content) -> some View {
        content
            .animation(animating ? animation : nil)
            .onAppear(perform: delayAnimation)
    }
}
