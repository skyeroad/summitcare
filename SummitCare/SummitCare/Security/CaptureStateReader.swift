// SummitCare/Security/CaptureStateReader.swift (Solution 12)
import SwiftUI
import UIKit

final class CaptureStateView: UIView {
    var onChange: ((Bool) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        registerForTraitChanges([UITraitSceneCaptureState.self]) { (view: CaptureStateView, _: UITraitCollection) in
            view.onChange?(view.traitCollection.sceneCaptureState == .active)
        }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        onChange?(traitCollection.sceneCaptureState == .active)
    }
}

struct CaptureStateReader: UIViewRepresentable {
    let onChange: (Bool) -> Void

    func makeUIView(context: Context) -> CaptureStateView {
        let view = CaptureStateView()
        view.onChange = onChange
        return view
    }

    func updateUIView(_ view: CaptureStateView, context: Context) {
        view.onChange = onChange
    }
}
