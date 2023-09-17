enum MediaType {
  text,
  image,
  video,
  audio,
  deleted,
}

extension MediaTypeExtension on MediaType {
  String get str {
    switch (this) {
      case MediaType.text:
        return "text";
      case MediaType.image:
        return "image";
      case MediaType.video:
        return "video";
      case MediaType.audio:
        return "audio";
      case MediaType.deleted:
        return "deleted";
    }
  }
}

class MediaTypeUtils {
  static MediaType from(String str) {
    switch (str.toLowerCase()) {
      case "text":
      case "texts":
        return MediaType.text;
      case "image":
      case "images":
        return MediaType.image;
      case "audio":
      case "audios":
        return MediaType.audio;
      case "video":
      case "videos":
        return MediaType.video;
      case "delete":
      case "deleted":
      case "remove":
      case "removed":
        return MediaType.deleted;
      default:
        throw UnimplementedError("No media type assigned to $str");
    }
  }
}
