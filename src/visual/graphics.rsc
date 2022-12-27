module visual::graphics

import vis::Figure;
import vis::Render;
import vis::KeySym;

public void drawGraphic(str method, int simplePercentage, int moderatePercentage, int highPercentage, int veryHighPercentage ){
	list[Figure] boxes=[];
	int width=120;
	int other=100-simplePercentage-moderatePercentage-highPercentage-veryHighPercentage; 
	
	boxes+=box(text(method+" simple"), fillColor("green"), popup("<simplePercentage>%"), resizable(false), size(width, simplePercentage*2));
	boxes+=box(text(method+" mod"), fillColor("orange"), popup("<moderatePercentage>%"), resizable(false), size(width, moderatePercentage*2));
	boxes+=box(text(method+" high"), fillColor("red"), popup("<highPercentage>%"),resizable(false), size(width, highPercentage*2));
	boxes+=box(text(method+" very high"), fillColor("blue"), popup("<veryHighPercentage>%"),resizable(false), size(width, veryHighPercentage*2));
	boxes+=box(text("Other"), fillColor("white"), popup("<other>%"),resizable(false), size(width, other*2));
	render(pack(boxes, gap(0)));
}

private FProperty popup(str message) {
	return mouseOver(box(text(message), resizable(false)));
}
