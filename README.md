# ZPTooltip
*Tooltip implementation attempting to mimic Apple Podcast's app tooltip:*
<br><br>
<img width="277" height="600" alt="tooltip_apple_podcast" src="https://github.com/user-attachments/assets/ca584df0-35f1-4dab-be09-8630f0a3f483" />
<br><br><br>
Behaviors to be implemented:
-	Tapping on the trigger (a user-defined item) displays the tooltip. The tooltip should not be clipped by any view—its full content must be visible and properly positioned within the view.<br>
-	Tapping on a tooltip action closes the tooltip and executes the corresponding action.<br>
-	Long-pressing the tooltip allows the user to pan over available options. When the finger moves over an option, that option is highlighted, and haptic feedback is triggered.<br>
-	When the user is panning over the tooltip and moves their finger outside the tooltip area, the tooltip scales down.<br>
-	If the user taps outside the displayed tooltip area, the tooltip closes.<br>
-	If the tooltip is displayed over a scroll view, the scroll view should still receive pan gestures when the user pans outside the tooltip area. The expected behavior is that the scroll view continues to scroll while the tooltip is dismissed, reducing the number of taps required for the user to resume scrolling.<br>


