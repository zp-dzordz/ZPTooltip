# ZPTooltip

*A SwiftUI tooltip implementation attempting to mimic the Apple Podcasts app tooltip behavior.*

<div align="center">

https://github.com/user-attachments/assets/5634dad6-df5c-4cc8-a1f2-df6e4e86be9a

</div>

---

## 🎯 Features

This tooltip implementation provides the following behaviors:

- **Tap to Display**: Tapping on the trigger (a user-defined item) displays the tooltip. The tooltip is intelligently positioned to ensure its full content is visible within the view bounds.

- **Tap Actions**: Tapping on any tooltip action closes the tooltip and executes the corresponding action.

- **Long-Press Interaction**: Long-pressing the tooltip allows users to pan over available options. When a finger moves over an option, that option becomes highlighted and haptic feedback is triggered.

- **Scale Animation**: When panning over the tooltip and moving outside the tooltip area, the tooltip smoothly scales down to provide visual feedback.

- **Dismiss on Outside Tap**: Tapping outside the displayed tooltip area closes the tooltip.

- **Scroll View Compatibility**: When the tooltip is displayed over a scroll view, the scroll view continues to receive pan gestures when the user pans outside the tooltip area. This ensures smooth scrolling behavior while the tooltip is dismissed, reducing the number of taps required to resume scrolling.

---

## 📋 TODO

### High Priority
- [ ] Move logic contained in `@State` variables of `TooltipHelper` view modifier to `TooltipState` model
- [ ] Suppress errors related to tapping tooltip trigger in rapid succession

### Documentation
- [ ] Better documentation and code examples
- [ ] Add inline code documentation
- [ ] Create usage guide


