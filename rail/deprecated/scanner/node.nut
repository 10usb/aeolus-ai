class RailScannerNode {
	index   = null;
	towards = null;
	value   = 0;
}

function RailScannerNode::Sign(text){
    AISign.BuildSign(index, text);
}