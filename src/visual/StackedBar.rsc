module visual::StackedBar

import vis::Figure;
import vis::Render;
import util::Math;
import IO;

@doc{
  function that generate a bar diagram for the unit size and complexity metrics
}
public void drawGraphic(str method, real simplePercentage, real moderatePercentage, real highPercentage, real veryHighPercentage ){
	list[Figure] boxes=[];
	int width=200;
	real other=100-simplePercentage-moderatePercentage-highPercentage-veryHighPercentage; 
	
	boxes+=box(text(method+" simple"), fillColor("green"), popup("<simplePercentage>%"), resizable(false), size(width, toInt(simplePercentage*3) ));
	boxes+=box(text(method+" mod"), fillColor("yellow"), popup("<moderatePercentage>%"), resizable(false), size(width, toInt(moderatePercentage*3) ));
	boxes+=box(text(method+" high"), fillColor("orange"), popup("<highPercentage>%"),resizable(false), size(width, toInt(highPercentage*3) ));
	boxes+=box(text(method+" very high"), fillColor("red"), popup("<veryHighPercentage>%"),resizable(false), size(width, toInt(veryHighPercentage*3) ));
	if(other > 0.1) boxes+=box(text("Other"), fillColor("white"), popup("<other>%"),resizable(false), size(width, toInt(other*3) ));
	render(method, pack(boxes, gap(0)));
}

private FProperty popup(str message) {
	return mouseOver(box(text(message), resizable(false)));
}
