package;

import ecs.System;

import peote.view.Buffer;
import Sprite;


class RenderSystem extends System
{
    @:fullFamily var sprites : {
        requires : { sprite : Sprite },
		resources: { buffer : Buffer<Sprite> }
    };

	override function onEnabled()
    {
		trace("RenderSystem: onEnabled");
	
		sprites.onEntityAdded.subscribe(entity -> {
            setup(sprites, {
                fetch(sprites, entity, {
                    trace("RenderSystem: onEntityAdded");
                    buffer.addElement(sprite);
                });
            });
        });

        sprites.onEntityRemoved.subscribe(entity -> {
            setup(sprites, {
                fetch(sprites, entity, {
					trace("RenderSystem: onEntityRemoved");
                    buffer.removeElement(sprite);
                });
            });
        });
		
    }

    override function update(_dt : Float)
    {
		setup(sprites, {
			
            iterate(sprites, {
				
				buffer.updateElement(sprite);
				
            });
			
			
        });
    }

}