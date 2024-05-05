import WidgetKit
import SwiftUI
import Network
import DesignSystem
import Models
import Timeline

struct LatestPostWidgetEntry: TimelineEntry {
  let date: Date
  let timeline: TimelineFilter
  let statuses: [Status]
  let images: [URL: UIImage]
}

struct LatestPostsWidgetView : View {
  var entry: LatestPostsWidgetProvider.Entry
  
  @Environment(\.widgetFamily) var family
  @Environment(\.redactionReasons) var redacted
  
  var contentLineLimit: Int {
    switch family {
    case .systemSmall, .systemMedium:
      return 4
    default:
      return 2
    }
  }
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      headerView
      VStack(alignment: .leading, spacing: 16) {
        ForEach(entry.statuses) { status in
          makeStatusView(status)
        }
      }
      Spacer()
    }
    .frame(maxWidth: .infinity)
  }
  
  private var headerView: some View {
    HStack {
      Text(entry.timeline.title)
      Spacer()
      Image(systemName: "cube")
    }
    .font(.subheadline)
    .fontWeight(.bold)
    .foregroundStyle(Color("AccentColor"))
  }
  
  @ViewBuilder
  private func makeStatusView(_ status: Status) -> some View {
    if let url = URL(string: status.url ?? "") {
      Link(destination: url, label: {
        VStack(alignment: .leading, spacing: 2) {
          makeStatusHeaderView(status)
          Text(status.content.asSafeMarkdownAttributedString)
            .font(.body)
            .lineLimit(contentLineLimit)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.leading, 20)
        }
      })
    }
  }
  
  private func makeStatusHeaderView(_ status: Status) -> some View {
    HStack(alignment: .center, spacing: 4) {
      if let image = entry.images[status.account.avatar] {
        Image(uiImage: image)
          .resizable()
          .frame(width: 16, height: 16)
          .clipShape(Circle())
      } else {
        Circle()
          .foregroundStyle(.secondary)
          .frame(width: 16, height: 16)
      }
      HStack(spacing: 0) {
        Text(status.account.safeDisplayName)
          .foregroundStyle(.primary)
        if family != .systemSmall {
          Text(" @")
            .foregroundStyle(.tertiary)
          Text(status.account.username)
            .foregroundStyle(.tertiary)
        }
        Spacer()
      }
      .font(.subheadline)
      .fontWeight(.semibold)
      .lineLimit(1)
    }
  }
}
