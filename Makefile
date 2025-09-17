test-ios:
	set -o pipefail && \
	xcodebuild test \
	-scheme ZPTooltip \
	-destination platform="iOS Simulator,name=iPhone 16 Pro Max,OS=18.6"

# CI-specific target for GitHub Actions (uses compatible simulator)
test-ci:
	set -o pipefail && \
	xcodebuild test \
	-scheme ZPTooltip \
	-destination platform="iOS Simulator,name=iPhone 16 Pro Max,OS=18.6"
