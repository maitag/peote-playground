function makeWavFile(data:haxe.io.Bytes, samplingRate:Int):format.wav.Data.WAVE {
	var bitsPerSample = 8;
	var channels = 1;

	return {
		header: {
			format: WF_PCM,
			channels: channels,
			samplingRate: samplingRate,
			byteRate: Std.int(samplingRate * channels * bitsPerSample / 8),
			blockAlign: Std.int(channels * bitsPerSample / 8),
			bitsPerSample: bitsPerSample
		},
		data: data,
		cuePoints: []
	}
}

#if web
function saveWavFile(wave:format.wav.Data.WAVE, fileName:String) {
	var output = new haxe.io.BytesOutput();
	var writer = new format.wav.Writer(output);
	writer.write(wave);

	var blob = new js.html.Blob([output.getBytes().getData()], {type: "audio/wave"});
	var url = js.html.URL.createObjectURL(blob);
	var anchor = js.Browser.document.createAnchorElement();
	anchor.href = url;
	anchor.download = fileName + ".wav";
	anchor.click();
	js.html.URL.revokeObjectURL(url);
}
#else
function saveWavFile(wave:format.wav.Data.WAVE, fileName:String) {
	var output = sys.io.File.write(fileName + '.wav', true);
	var writer = new format.wav.Writer(output);
	writer.write(wave);
}
#end
