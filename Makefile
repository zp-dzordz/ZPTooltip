test-ios:
	set -o pipefail && \
	xcodebuild test \
	-scheme ZPTooltip \
	-destination platform="iOS Simulator,name=iPhone 15 Pro Max,OS=17.0.1"
