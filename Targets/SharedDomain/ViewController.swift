import UIKit
import SwiftUI

public class ViewController<Content: View>: UIHostingController<Content> {
    private var onDismissedAction: (() -> Void)?

    public func onDismissed(perform action: (() -> Void)? = nil) {
        self.onDismissedAction = action
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isBeingDismissed {
            onDismissedAction?()
        }
    }
}
