test-ios:
	set -o pipefail && \
	xcodebuild test \
	-scheme ZPTooltip \
	-destination platform="iOS Simulator,name=iPhone 17 Pro Max,OS=26.0"
