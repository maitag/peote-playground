package render;

import lime.graphics.Image;
import peote.view.PeoteView;
import peote.view.Buffer;
import peote.view.Program;
import peote.view.Texture;
import peote.view.TextureFormat;
import peote.view.Color;
import peote.view.Load;

import render.fb_light.*;

class Render {

	var peoteView:PeoteView;

 	public function new(peoteView:PeoteView)
	{
		this.peoteView = peoteView;

		var normalDepthTexture = new Texture(128, 128, 1, {format:TextureFormat.RGBA, smoothExpand: true, smoothShrink: true});
		var uvAoAlphaTexture = new Texture(128, 128, 1, {format:TextureFormat.RGBA, smoothExpand: true, smoothShrink: true});
		normalDepthTexture.tilesX = uvAoAlphaTexture.tilesX = 4;
		normalDepthTexture.tilesY = uvAoAlphaTexture.tilesY = 4;
		
		var haxeUVTexture = new Texture(256, 256, {format:TextureFormat.RGBA, smoothExpand: true, smoothShrink: true});

		Load.imageArray([
			"assets/test_normal_depth.png",
			"assets/test_uv_ao_alpha.png",
			"assets/haxe.png"
			],
			true,
			function (image:Array<Image>) {
				normalDepthTexture.setData(image[0]);
				uvAoAlphaTexture.setData(image[1]);
				haxeUVTexture.setData(image[2]);
			}
		);


		
		//----------------------------------------------------
		// ----- create Buffers for Tentacles and Lights -----
		//----------------------------------------------------
		var bufferLight:Buffer<ElementLight>;
	
		var bufferTest = new Buffer<ElementTest>(1024, 512);
		bufferLight = new Buffer<ElementLight>(1024, 512);
		

		//-------------------------------------------------
		//           Framebuffer chain  
		//-------------------------------------------------

		// --- render all uv-mapped, ao-prelightned with alpha and in depth ---
		var uvAoAlphaDepthFB = new UvAoAlphaDepthFB(512, 512, bufferTest, normalDepthTexture, uvAoAlphaTexture, haxeUVTexture);
		uvAoAlphaDepthFB.addToPeoteView(peoteView);
		
		// ------ render all normals together to use for lightning -------
		var normalDepthFB = new NormalDepthFB(512, 512, bufferTest, normalDepthTexture);
		normalDepthFB.addToPeoteView(peoteView);

		// ------ render all lights while using normalDepthFB texture -----
		var lightFB = new LightFB(512, 512, bufferLight, normalDepthFB.fbTexture);
		lightFB.addToPeoteView(peoteView);
		
		// -------- combine both fb-textures (add dynamic lights to the pre-lighted) --------- 
		var combineDisplay = new CombineDisplay(0, 0, 512, 512, uvAoAlphaDepthFB.fbTexture, lightFB.fbTexture);
		peoteView.addDisplay(combineDisplay);

					
		// ----------------------------------------
		// ---------- add some tentacles ----------
		// ----------------------------------------

		var e0 = new ElementTest(1, 0);
		bufferTest.addElement(e0);
		var e1 = new ElementTest(1, 128);
		bufferTest.addElement(e1);
	
	
		// --------------------------------------
		// ---------- add some lights -----------
		// --------------------------------------


		var light1 = new ElementLight(64, 0, 256, Color.GREEN);
		light1.depth = 0.5;
		bufferLight.addElement(light1);
		
		var light2 = new ElementLight(200, 0, 512, Color.RED);
		// bufferLight.addElement(light2);

		

	}


}