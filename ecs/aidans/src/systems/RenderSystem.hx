package systems;

import ecs.System;

//import peote.view.Buffer;
import resources.SpriteLayer;
import components.Sprite;


class RenderSystem extends System
{
    @:fullFamily var sprites : {
        requires : { sprite : Sprite },
		//resources: { buffer : Buffer<Sprite> }
		resources: { spriteLayer : SpriteLayer }
    };

	// this did not work yet:
    override function onAdded()
    {
		trace("onAdded");
	
		sprites.onEntityAdded.subscribe(entity -> {
            setup(sprites, {
                fetch(sprites, entity, {
                    //buffer.addElement(sprite);
                    spriteLayer.buffer.addElement(sprite);
					trace("buffer.addElement(sprite)");
                });
            });
        });

        sprites.onEntityRemoved.subscribe(entity -> {
            setup(sprites, {
                fetch(sprites, entity, {
                    //buffer.removeElement(sprite);
                    spriteLayer.buffer.removeElement(sprite);
					trace("buffer.removeElement(sprite)");
                });
            });
        });
    }

    override function update(_dt : Float)
    {
		setup(sprites, {
			
            iterate(sprites, {
                // do stuff with the components and resources.
				trace("buffer.updateElement(sprite)");
				
				//buffer.updateElement(sprite);
				spriteLayer.buffer.updateElement(sprite);
            });
			
			
        });
    }

}