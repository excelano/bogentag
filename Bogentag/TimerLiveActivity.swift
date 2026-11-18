// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import ActivityKit
import Foundation

enum TimerLiveActivity {
    static func show(_ timer: SpanTimer?) {
        let now = Date.now
        Task.detached { await apply(timer, at: now) }
    }

    static func tidy(_ timer: SpanTimer?) {
        let now = Date.now
        guard timer.map({ $0.isDone(at: now) }) ?? true else { return }
        Task.detached { await apply(nil, at: now) }
    }

    private static func apply(_ timer: SpanTimer?, at now: Date) async {
        let activities = Activity<TimerAttributes>.activities
        guard let timer, !timer.isDone(at: now) else {
            for activity in activities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
            return
        }
        let attributes = TimerAttributes(unit: timer.unit, amount: timer.amount, place: timer.place)
        let content = ActivityContent(state: state(timer, at: now), staleDate: timer.end)
        let current = activities.first { $0.attributes == attributes }
        for activity in activities where activity.id != current?.id {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
        if let current {
            await current.update(content)
        } else {
            _ = try? Activity.request(attributes: attributes, content: content)
        }
    }

    private static func state(_ timer: SpanTimer, at now: Date) -> TimerAttributes.ContentState {
        guard let end = timer.end, timer.left > 0 else {
            return TimerAttributes.ContentState(run: nil, left: timer.left)
        }
        let ran = (timer.amount - timer.left) / timer.left
        let start = now.addingTimeInterval(-ran * end.timeIntervalSince(now))
        return TimerAttributes.ContentState(run: start...end, left: timer.left)
    }
}
