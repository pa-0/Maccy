import AppKit
import Foundation
import Settings

@Observable
class AppState {
  static let shared = AppState()

  var popup: Popup
  var history: History
  var footer: Footer

  var appDelegate: AppDelegate? = nil

  var selection: UUID? = nil {
    didSet {
      history.selectedItem = nil
      footer.selectedItem = nil

      if let item = history.items.first { $0.id == selection } {
        history.selectedItem = item
      } else if var item = footer.items.first { $0.id == selection } {
        footer.selectedItem = item
      }
    }
  }

  private let about = About()

  init() {
    history = History.shared
    footer = Footer()
    popup = Popup()
  }

  func highlightFirst() {
    selection = history.items.first(where: \.isVisible)?.id
  }

  func highlightPrevious() {
    if let selectedItem = history.selectedItem {
      if let nextItem = history.items.filter(\.isVisible).item(before: selectedItem) {
        selection = nextItem.id
      }
    } else if let selectedItem = footer.selectedItem {
      if let nextItem = footer.items.filter(\.isVisible).item(before: selectedItem) {
        selection = nextItem.id
      } else if selectedItem == footer.items.first(where: \.isVisible) {
        selection = history.items.last(where: \.isVisible)?.id
      }
    }
  }

  func highlightNext() {
    if let selectedItem = history.selectedItem {
      if let nextItem = history.items.filter(\.isVisible).item(after: selectedItem) {
        selection = nextItem.id
      } else if selectedItem == history.items.filter(\.isVisible).last {
        selection = footer.items.first(where: \.isVisible)?.id
      }
    } else if let selectedItem = footer.selectedItem {
      if let nextItem = footer.items.filter(\.isVisible).item(after: selectedItem) {
        selection = nextItem.id
      }
    }
  }

  func highlightLast() {
    if let selectedItem = history.selectedItem {
      if selectedItem == history.items.filter(\.isVisible).last {
        selection = footer.items.first(where: \.isVisible)?.id
      } else {
        selection = history.items.last(where: \.isVisible)?.id
      }
    } else if footer.selectedItem != nil {
      selection = footer.items.last(where: \.isVisible)?.id
    }
  }

  func openAbout() {
    about.openAbout(nil)
  }

  func openPreferences() {
    let settingsWindowController = SettingsWindowController(
      panes: [
        Settings.Pane(
          identifier: Settings.PaneIdentifier.general,
          title: NSLocalizedString("Title", tableName: "GeneralSettings", comment: ""),
          toolbarIcon: NSImage.gearshape!
        ) {
          GeneralSettingsPane()
        },
        Settings.Pane(
          identifier: Settings.PaneIdentifier.storage,
          title: NSLocalizedString("Title", tableName: "StorageSettings", comment: ""),
          toolbarIcon: NSImage.externaldrive!
        ) {
          StorageSettingsPane()
        },
        Settings.Pane(
          identifier: Settings.PaneIdentifier.appearance,
          title: NSLocalizedString("Title", tableName: "AppearanceSettings", comment: ""),
          toolbarIcon: NSImage.paintpalette!
        ) {
          AppearanceSettingsPane()
        },
        Settings.Pane(
          identifier: Settings.PaneIdentifier.ignore,
          title: NSLocalizedString("Title", tableName: "IgnoreSettings", comment: ""),
          toolbarIcon: NSImage.nosign!
        ) {
          IgnoreSettingsPane()
        },
        Settings.Pane(
          identifier: Settings.PaneIdentifier.advanced,
          title: NSLocalizedString("Title", tableName: "AdvancedSettings", comment: ""),
          toolbarIcon: NSImage.gearshape2!
        ) {
          AdvancedSettingsPane()
        },
      ]
    )
    settingsWindowController.show()
  }

  func quit() {
    NSApp.terminate(self)
  }
}