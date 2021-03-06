//
//  CountdownTimer.swift
//  TimerThang
//
//  Created by Stuart Davison on 8/16/21.
//

import Foundation
import Combine

struct TimeRemaining {
	private var startingSeconds: Int
	
	var minutes: Int { secondsRemaining / 60 }
	var seconds: Int { secondsRemaining % 60 }

	var secondsRemaining: Int = 0
	var secondsPassed: Int { startingSeconds - secondsRemaining }
	
	var percentPassed: Double { 100.0 / Double(startingSeconds) * Double(secondsPassed) }
	var percentRemaining: Double { 100 - percentPassed }
	
	init(minutes: Int, seconds: Int) {
		startingSeconds = minutes * 60 + seconds
		secondsRemaining = startingSeconds
	}
	
	mutating func reset() {
		secondsRemaining = startingSeconds
	}
	
	mutating func add(minutes: Int = 0, seconds: Int = 0) {
		let newValue = secondsRemaining + (minutes * 60 + seconds)
		guard newValue >= 0 else {return}
		secondsRemaining = newValue
	}
}

enum TimerState {
	case reset
	case running
	case paused
	case complete
}

class CountdownTimer: ObservableObject {
	@Published var timeRemaining = TimeRemaining(minutes: 0, seconds: 0)
	@Published var state: TimerState = .reset
	
	private var timer: Timer?
	
	init(mins: Int = 0, secs: Int = 0, autostart: Bool = false) {
		set(mins: mins, secs: secs, autostart: autostart)
	}
	
	func set(mins: Int = 0, secs: Int = 0, autostart: Bool = false) {
		timeRemaining = TimeRemaining(minutes: mins, seconds: secs)
		if autostart {
			start()
		}
	}
	
	func checkStatus() {
		if timeRemaining.secondsRemaining == 0 {
			stop()
		}
	}
	
	func start() {
		guard timer == nil else {return}
		if state == .complete {
			timeRemaining.reset()
		}
		timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
			self.timeRemaining.add(seconds: -1)
			self.checkStatus()
		}
		state = .running
	}
	
	func pause() {
		stop(paused: true)
	}
	
	func stop(paused: Bool = false) {
		timer?.invalidate()
		timer = nil
		state = paused ? .paused : .complete
	}
}
