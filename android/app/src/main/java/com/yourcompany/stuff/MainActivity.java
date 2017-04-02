package com.yourcompany.stuff;

import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.provider.MediaStore;
import android.support.v4.content.FileProvider;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.FlutterMethodChannel;
import io.flutter.plugin.common.MethodCall;

public class MainActivity extends FlutterActivity {

	FlutterMethodChannel.Response response;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

		new FlutterMethodChannel(getFlutterView(), "samples.flutter.io/battery").setMethodCallHandler(new FlutterMethodChannel.MethodCallHandler() {
			@Override
			public void onMethodCall(MethodCall call, FlutterMethodChannel.Response response) {
				MainActivity.this.response = response;
				if (call.method.equals("takePicture")) {
					Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
					if (intent.resolveActivity(getPackageManager()) != null) {
						File file = null;
						try {
							file = createImageFile();
							filePath = file.getAbsolutePath();
						} catch (IOException ex) {
							ex.printStackTrace();
						}
						if (file != null) {
							// Uri uri = FileProvider.getUriForFile(MainActivity.this, "com.yourcompany.stuff", file);
							Uri uri = Uri.fromFile(file);
							intent.putExtra(MediaStore.EXTRA_OUTPUT, uri);
							// intent.putExtra(MediaStore.EXTRA_OUTPUT, Uri.parse("file://" + file.getAbsolutePath()));
							startActivityForResult(intent, 1);
						}
					}
					// response.success("well hello there");
				} else {
					response.notImplemented();
				}
			}
		});
    }

	String filePath;

	private File createImageFile() throws IOException {
		String timestamp = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
		String fileName = "image" + timestamp;
		File dir = getExternalFilesDir(Environment.DIRECTORY_PICTURES);
		File image = File.createTempFile(fileName, ".jpg", dir);
		return image;
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		if (requestCode == 1) {
			// Bundle extras = data.getExtras();
			// Bitmap image = (Bitmap) extras.get("data");
            //
			// try {
			// 	// String otherPath = filePath.substring(0, filePath.length() - 4) + "-stuff" + filePath.substring(filePath.length() - 4);
			// 	File file = createImageFile();
			// 	FileOutputStream stream = new FileOutputStream(file, false);
            //
			// 	image.compress(Bitmap.CompressFormat.JPEG, 50, stream);
            //
			// 	stream.flush();
			// 	stream.close();
            //
			// } catch (Exception ex) {
			// 	ex.printStackTrace();
			// }

			response.success(filePath);
		}
	}

}
