import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver/gallery_saver.dart';

void main() => runApp(MaterialApp(home: HDREditor(), theme: ThemeData.dark()));

class HDREditor extends StatefulWidget {
  @override
  _HDREditorState createState() => _HDREditorState();
}

class _HDREditorState extends State<HDREditor> {
  bool isProcessing = false;
  String status = "Video Select Karen";

  Future<void> processVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result != null) {
      setState(() { isProcessing = true; status = "Applying 8K HDR Quality..."; });
      String input = result.files.single.path!;
      final dir = await getTemporaryDirectory();
      final output = '${dir.path}/edit_${DateTime.now().millisecondsSinceEpoch}.mp4';

      // Red, White, Blue Trending Tone Command
      String cmd = "-i $input -vf unsharp=5:5:1.5,eq=contrast=1.5:saturation=1.8,colorbalance=rh=0.5:bh=0.4 -c:v libx264 $output";

      await FFmpegKit.execute(cmd).then((session) async {
        await GallerySaver.saveVideo(output);
        setState(() { isProcessing = false; status = "Done! Video Saved in Gallery"; });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("8K HDR AUTO EDIT")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isProcessing) CircularProgressIndicator(),
            Text(status),
            ElevatedButton(onPressed: processVideo, child: Text("Pick & Edit Video")),
          ],
        ),
      ),
    );
  }
}
