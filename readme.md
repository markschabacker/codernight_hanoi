# CoderNight - June 2014

## Problem

Solve the [Tower of Hanoi](http://en.wikipedia.org/wiki/Tower_of_Hanoi).

## Goal

The Xcode 6 Playground demo shown during the WWDC 2014 keynote was very impressive.  I would like to solve the this month's assignment while exploring:

- [Swift](https://developer.apple.com/swift/)
- [Xcode 6 Playgrounds](https://developer.apple.com/library/prerelease/ios/recipes/xcode_help-source_editor/ExploringandEvaluatingSwiftCodeinaPlayground/ExploringandEvaluatingSwiftCodeinaPlayground.html)

## Solution

Code located at:

    swift/hanoi.playground/section-1.swift

This was a fun experiment.  As someone who has written a fair amount of Objective C, I felt that Swift was pretty easy to pick up.  Beta 1 of Xcode 6 is still a bit crashy but that's to be expected.  After writing the puzzle solver code I concentrated on exposing solution progress through the Xcode Playground's graphical debugging tools.  I was able to implement text, NSView, and SceneKit based "quick looks":

Text:  
![Text Quick Look](screenshot_text_quicklook.png?raw=true)

NSView:  
![NSView Quick Look](screenshot_nsview_quicklook.png?raw=true)

SceneKit:  ([movie](hanoi_playground_scenekit.mp4?raw=true))
![SceneKit Quick Look](screenshot_scenekit_quicklook.png?raw=true)

Overall this was an exciting and different way to work through a problem.  However, I did become frustrated with the messiness of the solution and look forward to Playgrounds consisting of multiple files.
