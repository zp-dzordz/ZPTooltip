test-ios:
	set -o pipefail && \
	xcodebuild test \
	-scheme ZPTooltip \
	-destination platform="iOS Simulator,name=iPhone 17 Pro Max,OS=26.0"

# CI-specific target for GitHub Actions (uses compatible simulator)
test-ci:
	set -o pipefail && \
	xcodebuild test \
	-scheme ZPTooltip \
	-destination platform="iOS Simulator,name=iPhone 15 Pro,OS=18.1"
