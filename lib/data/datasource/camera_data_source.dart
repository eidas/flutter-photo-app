// ファイル上部の既存のインポートはそのまま

class CameraDataSource {
  // 既存のコードはそのまま維持
  
  // エラーのあるメソッドを修正
  Stream<CameraImage> getPreviewStream() {
    // ストリームを開始して、ストリームオブジェクト自体を返す
    if (!_cameraController.value.isStreamingImages) {
      _cameraController.startImageStream((image) {});
    }
    
    // StreamController を使って新しいストリームを作成
    final streamController = StreamController<CameraImage>();
    
    // カメラからの画像を新しいストリームに転送
    _cameraController.startImageStream((CameraImage image) {
      if (!streamController.isClosed) {
        streamController.add(image);
      }
    });
    
    // ストリームが閉じられたときにリソースをクリーンアップ
    streamController.onCancel = () {
      if (_cameraController.value.isStreamingImages) {
        _cameraController.stopImageStream();
      }
    };
    
    return streamController.stream;
  }
  
  // 既存の他のメソッドはそのまま維持
}