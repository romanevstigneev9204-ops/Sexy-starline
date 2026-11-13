import SwiftUI
import WidgetKit

/// App Group shared with Runner — must match Flutter `kIosAppGroupId`.
private let widgetGroupId = "group.ru.sexystarline.app"

/// WidgetKit kind — must match Flutter `kIosArmStatusWidgetName`.
private let widgetKind = "ArmStatusWidget"

// MARK: - Night Drive palette

private enum NightDrive {
  static let graphite = Color(red: 0.043, green: 0.055, blue: 0.071) // #0B0E12
  static let elevated = Color(red: 0.071, green: 0.086, blue: 0.114) // #12161D
  static let card = Color(red: 0.102, green: 0.122, blue: 0.157) // #1A1F28
  static let cyan = Color(red: 0.239, green: 0.859, blue: 0.851) // #3DDBD9
  static let amber = Color(red: 0.941, green: 0.627, blue: 0.294) // #F0A04B
  static let danger = Color(red: 0.878, green: 0.439, blue: 0.376) // #E07060
  static let textPrimary = Color.white
  static let textSecondary = Color(red: 0.604, green: 0.639, blue: 0.698) // #9AA3B2
  static let stroke = Color(red: 0.165, green: 0.192, blue: 0.251) // #2A3140
}

// MARK: - Snapshot from App Group UserDefaults (no StarLine poll)

private struct ArmStatusSnapshot {
  let deviceName: String
  let statusLabel: String
  let subtitle: String
  let actionLabel: String
  let armed: Bool
  let online: Bool
  let hasSession: Bool

  static func load(from defaults: UserDefaults?) -> ArmStatusSnapshot {
    ArmStatusSnapshot(
      deviceName: defaults?.string(forKey: "device_name") ?? "Sexy Starline",
      statusLabel: defaults?.string(forKey: "status_label") ?? "Нет данных",
      subtitle: defaults?.string(forKey: "subtitle") ?? "Откройте приложение",
      actionLabel: defaults?.string(forKey: "action_label") ?? "Открыть",
      armed: defaults?.bool(forKey: "armed") ?? false,
      online: defaults?.bool(forKey: "online") ?? false,
      hasSession: defaults?.bool(forKey: "has_session") ?? false
    )
  }

  var statusColor: Color {
    if armed && online { return NightDrive.cyan }
    if !online { return NightDrive.danger }
    return NightDrive.amber
  }

  /// Deep-link for the primary CTA. `homeWidget` query is required by home_widget on iOS.
  var primaryURI: URL {
    if !hasSession || !online {
      return URL(string: "sexystarline://widget/open?homeWidget")!
    }
    if armed {
      return URL(string: "sexystarline://widget/disarm?homeWidget")!
    }
    return URL(string: "sexystarline://widget/arm?homeWidget")!
  }

  static let openURI = URL(string: "sexystarline://widget/open?homeWidget")!
  static let armURI = URL(string: "sexystarline://widget/arm?homeWidget")!
  static let disarmURI = URL(string: "sexystarline://widget/disarm?homeWidget")!
}

struct ArmStatusEntry: TimelineEntry {
  let date: Date
  let snapshot: ArmStatusSnapshot
}

struct Provider: TimelineProvider {
  func placeholder(in context: Context) -> ArmStatusEntry {
    ArmStatusEntry(
      date: Date(),
      snapshot: ArmStatusSnapshot(
        deviceName: "Sexy Starline",
        statusLabel: "Нет данных",
        subtitle: "Откройте приложение",
        actionLabel: "Открыть",
        armed: false,
        online: false,
        hasSession: false
      )
    )
  }

  func getSnapshot(in context: Context, completion: @escaping (ArmStatusEntry) -> Void) {
    let defaults = UserDefaults(suiteName: widgetGroupId)
    let entry = ArmStatusEntry(date: Date(), snapshot: .load(from: defaults))
    completion(entry)
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<ArmStatusEntry>) -> Void) {
    getSnapshot(in: context) { entry in
      // `.never` — system does not poll; Flutter pushes via HomeWidget.updateWidget.
      let timeline = Timeline(entries: [entry], policy: .never)
      completion(timeline)
    }
  }
}

// MARK: - Views

struct ArmStatusWidgetEntryView: View {
  @Environment(\.widgetFamily) var family
  var entry: Provider.Entry

  var body: some View {
    let snap = entry.snapshot

    Group {
      if family == .systemMedium {
        mediumBody(snap)
      } else {
        smallBody(snap)
      }
    }
    .padding(14)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .widgetURL(ArmStatusSnapshot.openURI)
    .modifier(NightDriveBackground())
  }

  @ViewBuilder
  private func smallBody(_ snap: ArmStatusSnapshot) -> some View {
    VStack(alignment: .leading, spacing: 4) {
      brandLabel
      Text(snap.deviceName)
        .font(.system(size: 15, weight: .bold))
        .foregroundColor(NightDrive.textPrimary)
        .lineLimit(1)
      statusRow(snap)
      Text(snap.subtitle)
        .font(.system(size: 11))
        .foregroundColor(NightDrive.textSecondary)
        .lineLimit(1)
      Spacer(minLength: 4)
      Link(destination: snap.primaryURI) {
        Text(snap.actionLabel)
          .font(.system(size: 13, weight: .bold))
          .foregroundColor(NightDrive.graphite)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 8)
          .background(NightDrive.cyan)
          .cornerRadius(10)
      }
    }
  }

  @ViewBuilder
  private func mediumBody(_ snap: ArmStatusSnapshot) -> some View {
    VStack(alignment: .leading, spacing: 4) {
      brandLabel
      Text(snap.deviceName)
        .font(.system(size: 16, weight: .bold))
        .foregroundColor(NightDrive.textPrimary)
        .lineLimit(1)
      statusRow(snap)
      Text(snap.subtitle)
        .font(.system(size: 12))
        .foregroundColor(NightDrive.textSecondary)
        .lineLimit(1)
      Spacer(minLength: 6)
      Link(destination: snap.primaryURI) {
        Text(snap.actionLabel)
          .font(.system(size: 14, weight: .bold))
          .foregroundColor(NightDrive.graphite)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 10)
          .background(NightDrive.cyan)
          .cornerRadius(10)
      }
      if snap.hasSession && snap.online {
        HStack(spacing: 8) {
          Link(destination: ArmStatusSnapshot.armURI) {
            Text("Поставить")
              .font(.system(size: 12, weight: .bold))
              .foregroundColor(NightDrive.cyan)
              .frame(maxWidth: .infinity)
              .padding(.vertical, 8)
              .background(NightDrive.card)
              .overlay(
                RoundedRectangle(cornerRadius: 8)
                  .stroke(NightDrive.stroke, lineWidth: 1)
              )
              .cornerRadius(8)
          }
          Link(destination: ArmStatusSnapshot.disarmURI) {
            Text("Снять")
              .font(.system(size: 12, weight: .bold))
              .foregroundColor(NightDrive.amber)
              .frame(maxWidth: .infinity)
              .padding(.vertical, 8)
              .background(NightDrive.card)
              .overlay(
                RoundedRectangle(cornerRadius: 8)
                  .stroke(NightDrive.stroke, lineWidth: 1)
              )
              .cornerRadius(8)
          }
        }
      }
    }
  }

  private var brandLabel: some View {
    Text("SEXY STARLINE")
      .font(.system(size: 10, weight: .bold))
      .tracking(1.2)
      .foregroundColor(NightDrive.cyan)
  }

  private func statusRow(_ snap: ArmStatusSnapshot) -> some View {
    HStack(spacing: 8) {
      Circle()
        .fill(snap.statusColor)
        .frame(width: 8, height: 8)
      Text(snap.statusLabel)
        .font(.system(size: 17, weight: .bold))
        .foregroundColor(snap.statusColor)
        .lineLimit(1)
    }
    .padding(.top, 6)
  }
}

private struct NightDriveBackground: ViewModifier {
  @ViewBuilder
  func body(content: Content) -> some View {
    if #available(iOSApplicationExtension 17.0, *) {
      content
        .containerBackground(for: .widget) {
          RoundedRectangle(cornerRadius: 16)
            .fill(NightDrive.elevated)
            .overlay(
              RoundedRectangle(cornerRadius: 16)
                .stroke(NightDrive.stroke, lineWidth: 1)
            )
        }
    } else {
      content
        .background(
          RoundedRectangle(cornerRadius: 16)
            .fill(NightDrive.elevated)
            .overlay(
              RoundedRectangle(cornerRadius: 16)
                .stroke(NightDrive.stroke, lineWidth: 1)
            )
        )
    }
  }
}

@main
struct ArmStatusWidget: Widget {
  let kind: String = widgetKind

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: Provider()) { entry in
      ArmStatusWidgetEntryView(entry: entry)
    }
    .configurationDisplayName("Sexy Starline")
    .description("Статус охраны и быстрый переход к постановке / снятию")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}

struct ArmStatusWidget_Previews: PreviewProvider {
  static var previews: some View {
    ArmStatusWidgetEntryView(
      entry: ArmStatusEntry(
        date: Date(),
        snapshot: ArmStatusSnapshot(
          deviceName: "Camry",
          statusLabel: "Под охраной",
          subtitle: "только что",
          actionLabel: "Снять",
          armed: true,
          online: true,
          hasSession: true
        )
      )
    )
    .previewContext(WidgetPreviewContext(family: .systemSmall))
  }
}
