M.Autocomplete.prototype._getIndicesOf = function(searchStr, str, caseSensitive){

	var searchStrLen = searchStr.length;
    if (searchStrLen == 0) {
        return [];
    }
    var startIndex = 0, index, indices = [];
    if (!caseSensitive) {
        str = str.toLowerCase();
        searchStr = searchStr.toLowerCase();
    }
    while ((index = str.indexOf(searchStr, startIndex)) > -1) {
        indices.push(index);
        startIndex = index + searchStrLen;
    }
    return indices;

}

// patient consent sign.

M.Autocomplete.prototype._highlight = function(string, $el) {
  	console.log("incoming string is:" + string);
 
  	var start_end_positions = {};
  	var arr = []
  	_.each(string.split(" "), function(st){
  		//console.log("searching for: " + st + "in string:" + $el.text());
  		if(_.isEmpty(st)){
  		}
  		else{
  			_.each(M.Autocomplete.prototype._getIndicesOf(st.toLowerCase(),$el.text().toLowerCase()),function(index){
  				arr.push([index,index + st.length]);
  			});
  			/****
	  		let img = $el.find('img');
		  	let matchStart = $el
		      .text()
		      .toLowerCase()
		      .indexOf(st.toLowerCase())

		    if(matchStart !== -1){
		    	var matchEnd = matchStart + st.length
		    	arr.push([matchStart,matchEnd]);
			}
			*****/
	    }
  	});

  	// sometimes its getting multiple matches on the same word
  	// so we use only one match starting on the same begin position.
  	arr = _.uniq(arr,function(el){
  		return el[0];
  	});

  	
  	var sorted = _.sortBy(arr, function(item) { 
	   return item[0]; 
	});

  	
  	var segments = [];
  	var prev_end = 0;
  	//console.log("string is: " + string);
  	//console.log("sorted is:");
  	//console.log(sorted);
	_.each(sorted, function(arr,key,list){
		if(key == 0){
			if(arr[0] == 0){
				segments.push('<span>');
				segments.push('<span class="highlight">');
			}	
			else{
				segments.push('<span>');
				segments.push($el.text().slice(0,arr[0]));
				segments.push('<span class="highlight">');
			}
			segments.push($el.text().slice(arr[0],arr[1]));
			segments.push('</span>');
		}
		else{
			prev_el = sorted[key - 1];
			segments.push($el.text().slice(prev_el[1],arr[0]));
			segments.push('<span class="highlight">');
			segments.push($el.text().slice(arr[0],arr[1]));
			segments.push('</span>');
		}
		if(key == (_.size(list) - 1)){
			segments.push($el.text().slice(arr[1],$el.text().length));
			segments.push('</span>');
		}
	});
		
	//console.log(segments);
	$el.html(segments.join(''));


}


M.Autocomplete.prototype._renderDropdown = function(data,val){

	this._resetAutocomplete();

  	let matchingData = [];

  	//console.log("data is:");
  	//console.log(data);

  	// Gather all matching data
  	for (let key in data) {
	    if (data.hasOwnProperty(key)) {
	      let entry = {
	        data: data[key],
	        key: key
	      };
	      matchingData.push(entry);

	      this.count++;
	    }
  	}

  	// Sort
  	if (this.options.sortFunction) {
	    let sortFunctionBound = (a, b) => {
	      return this.options.sortFunction(
	        a.key.toLowerCase(),
	        b.key.toLowerCase(),
	        val.toLowerCase()
	      );
	    };
	    matchingData.sort(sortFunctionBound);
  	}

  	// Limit
  	matchingData = matchingData.slice(0, this.options.limit);

  	// Render
	for (let i = 0; i < matchingData.length; i++) {
	    let entry = matchingData[i];
	    let $autocompleteOption = $('<li></li>');
	    if (!!entry.data) {
	      $autocompleteOption.append(
	        `<img src="${entry.data}" class="right circle"><span>${entry.key}</span>`
	      );
	    } else {
	      $autocompleteOption.append('<span>' + entry.key + '</span>');
	    }

	    $(this.container).append($autocompleteOption);
	    this._highlight(val, $autocompleteOption);
	}

};