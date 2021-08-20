//
//  ContentView.swift
//  TimerThang
//
//  Created by Stuart Davison on 8/16/21.
//

import SwiftUI

struct ContentView: View {

    var body: some View {
		VStack(spacing:0) {
			FancyTimer(seconds: 30)
				.frame(width: 25, height: 25)
			FancyTimer(seconds: 30)
				.frame(width: 50, height: 50)
			ScrollView(.horizontal) {
				HStack(spacing:2) {
					FancyTimer(seconds: 60)
						.frame(width: 100, height: 100)
					FancyTimer(seconds: 70)
						.frame(width: 100, height: 100)
					FancyTimer(seconds: 80)
						.frame(width: 100, height: 100)
					FancyTimer(seconds: 90)
						.frame(width: 100, height: 100)
					FancyTimer(seconds: 120)
						.frame(width: 100, height: 100)
				}
			}
			FancyTimer(seconds: 360)
				.frame(width: 200, height: 200)
			FancyTimer(seconds: 25)
				.frame(width: 300, height: 300)
		}
    }
}

struct FancyTimer: View {
	@ObservedObject var timer: CountdownTimer
	var isRunning: Bool {timer.state == .running}
	var trimVal: CGFloat {
		CGFloat(timer.timeRemaining.percentRemaining / 100)
	}
	var ring1Color: Color {
		guard isRunning else {return .clear}
		return timer.timeRemaining.percentRemaining <= 10.0 ? .red : .blue
	}
	var ring2Color: Color {
		Color.white.opacity(0.2)
	}
	var circleColor: Color {
		isRunning ? Color(white: 0.2) : .black
	}
	var timeRemainingStr: String {
		let mins = String(format: "%02d", timer.timeRemaining.minutes)
		let secs = String(format: "%02d", timer.timeRemaining.seconds)
		return "\(mins):\(secs)"
	}
	var fontSize: CGFloat {height / 5}
	var strokeWidth: CGFloat {height / 10}
	var inset: CGFloat {strokeWidth / 2}
	@State private var size: CGSize = CGSize.zero
	var height: CGFloat {size.height}
	
	@State private var progress: CGFloat = 1.0

	init(minutes: Int = 0, seconds: Int = 0) {
		timer = CountdownTimer(mins: minutes, secs: seconds)
	}
	
	var body: some View {
		GeometryReader { geo in
			ZStack {
				ZStack {
					Circle()
						.trim(from: 0.0, to: progress)
						.fill(circleColor)
					Circle()
						.inset(by: inset)
						.stroke(ring2Color, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
					Circle()
						.inset(by: inset)
						.trim(from: 0.0, to: trimVal)
						.stroke(ring1Color, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
				}
				.rotationEffect(Angle(degrees: -90))
				Text(timeRemainingStr)
					.foregroundColor(.white)
					.font(Font.custom("AvenirNext-Bold", size: fontSize))
				if timer.state == .paused || timer.state == .complete {
					Button {} label: {
						Text(timer.state == .paused ? "Continue" : "Restart")
							.font(Font.custom("AvenirNext-Bold", size: fontSize / 2))
					}
					.offset(y: height / 6)
				}
			}
			.onAppear {
				size = geo.size
			}
			.onTapGesture {
				isRunning ? timer.pause() : timer.start()
			}
		}
	}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
