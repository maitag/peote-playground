import lime.ui.Window;
import peote.ui.PeoteUIDisplay;
import peote.ui.event.PointerEvent;
import peote.ui.interactive.UIElement;
import peote.ui.style.BoxStyle;
import peote.ui.style.RoundBorderStyle;
import peote.ui.style.interfaces.Style;
import peote.view.Color;
import peote.view.Display;
import peote.view.PeoteView;
import peote.view.text.Text;
import peote.view.text.TextProgram;

class Menu {
    public static function init(peoteView:PeoteView, window:Window, gameDisplay:Display) {
        var uiDisplay = new PeoteUIDisplay(0, 0, window.width, window.height, Color.BLACK);
		peoteView.addDisplay(uiDisplay);

        var boxStyle = new BoxStyle();

        var normalStyle = boxStyle.copy(); 
		normalStyle.color = Color.GREY4;

        var clickedStyle = boxStyle.copy();
        clickedStyle.color = Color.GREY1;

        var button:UIElement = new UIElement(Std.int((window.width - 200) / 2), Std.int((window.height - 100) / 2) + 60, 200, 100, normalStyle);
        uiDisplay.add(button);

        var textProgram = new TextProgram();
        var buttonScale = 20;
        var buttonText = new Text(0, 0, "Play", {letterWidth: buttonScale, letterHeight: buttonScale});
        buttonText.x = Std.int(button.x + ((button.width - (buttonScale * buttonText.text.length)) / 2));
        buttonText.y = Std.int(button.y + (button.height - buttonScale) / 2);
        textProgram.add(buttonText);

        var titleScale = 50;
        var titleText = new Text(0, button.y - 150, "Peong", {letterWidth: titleScale, letterHeight: titleScale});
        titleText.x = Std.int((gameDisplay.width - (titleScale * titleText.text.length)) / 2);
        textProgram.add(titleText);

        uiDisplay.addProgram(textProgram);
        
		// button2.onPointerOver = (e) -> trace("hello");
		button.onPointerClick = (uiElement:UIElement, e:PointerEvent) -> {
            uiDisplay.hide();
            gameDisplay.show();
        }

        button.onPointerOver = (_, _) -> {
      
            button.style = clickedStyle;
            button.updateStyle();
        }

        button.onPointerOut = (_, _) -> {
            button.style = normalStyle;
            button.updateStyle();
        }
		

        PeoteUIDisplay.registerEvents(window);
    }
}