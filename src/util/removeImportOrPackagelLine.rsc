module util::removeImportOrPackagelLine

public list[str] removeImportOrPackagelLine(list[str] text){
	list[str] result = [];
	for(str line <- text){
		if(!/^import|^package/ := line) result += line;;
	}
	return result;
}