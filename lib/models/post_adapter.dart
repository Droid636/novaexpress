import 'package:hive/hive.dart';
import '../models/post.dart';

class PostAdapter extends TypeAdapter<Post> {
  @override
  final int typeId = 0;

  @override
  Post read(BinaryReader reader) {
    return Post(
      id: reader.readInt(),
      title: reader.readString(),
      content: reader.readString(),
      link: reader.readString(),
      excerpt: reader.readString(),
      featuredImage: reader.readString(),
      categories: reader.readList().cast<int>(),
      date: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Post obj) {
    writer.writeInt(obj.id);
    writer.writeString(obj.title);
    writer.writeString(obj.content);
    writer.writeString(obj.link);
    writer.writeString(obj.excerpt);
    writer.writeString(obj.featuredImage);
    writer.writeList(obj.categories);
    writer.writeString(obj.date);
  }
}
