module visual::graphics

import vis::Figure;
import vis::Render;
import vis::KeySym;
import util::Math;

public void drawGraphic(str method, real simplePercentage, real moderatePercentage, real highPercentage, real veryHighPercentage ){
	list[Figure] boxes=[];
	int width=150;
	real other=100-simplePercentage-moderatePercentage-highPercentage-veryHighPercentage; 
	
	boxes+=box(text(method+" simple"), fillColor("green"), popup("<simplePercentage>%"), resizable(false), size(width, toInt(simplePercentage)));
	boxes+=box(text(method+" mod"), fillColor("orange"), popup("<moderatePercentage>%"), resizable(false), size(width, toInt(moderatePercentage)));
	boxes+=box(text(method+" high"), fillColor("red"), popup("<highPercentage>%"),resizable(false), size(width, toInt(highPercentage)));
	boxes+=box(text(method+" very high"), fillColor("blue"), popup("<veryHighPercentage>%"),resizable(false), size(width, toInt(veryHighPercentage)));
	boxes+=box(text("Other"), fillColor("white"), popup("<other>%"),resizable(false), size(width, toInt(other)));
	render(pack(boxes, gap(0)));
}

private FProperty popup(str message) {
	return mouseOver(box(text(message), resizable(false)));
}
