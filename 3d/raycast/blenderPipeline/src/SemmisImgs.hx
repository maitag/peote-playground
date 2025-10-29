package;

import peote.view.Load;

class SemmisImgs {

	static var indexREG = ~/<a href="(.+\.png|.+\.jpg)">.+?<td align="right">([\d\w-: ]+)<\/td><td align="right">(\d+\.?\d*)(K|M)<\/td>/;

	public static function get(urls:Array<String>, minSizeKB:Int=0, maxSizeKB:Int=2048, onLoad:Array<String>->Array<{name:String, date:String, size:Int}>->Void)
	{	
		var out_urls = new Array<String>();
		var out_imgs = new Array<{name:String, date:String, size:Int}>();

		Load.textArray(urls, false, function(texts:Array<String>) {
			for (i in 0...texts.length) {
				var t = texts[i];
				var url = urls[i];
				if (url.substr(url.length-1,1)!="/") url+="/";
				while (indexREG.match(t)) {
					var size = Std.parseFloat(indexREG.matched(3));
					if (indexREG.matched(4) == "M") size = Math.round(size*1024);
					if (size > minSizeKB && size < maxSizeKB) {
						out_urls.push(url+indexREG.matched(1));
						out_imgs.push( {name:indexREG.matched(1), date:indexREG.matched(2), size:Std.int(size)} );
					}
					t = indexREG.matchedRight();
				}
			}
			onLoad(out_urls, out_imgs);
		});
	}

	public static function pickRandom(urls:Array<String>, n:Int):Array<String>
	{
		var out = new Array<String>();
		var r:Int;
		for (i in 0...n) {
			r = Std.random(urls.length);
			out.push(urls[r]);
			urls.splice(r,1);
			if (urls.length==0) break;
		}
		return out;
	}

}