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

M.Autocomplete.prototype.selectOption = function(el) {
  	let text = el.text().trim();
  	// comment this so that it does not fill the autocomplete totally.
  	//this.el.value = text;
  	this.$el.trigger('change');
  	this._resetAutocomplete();
  	this.close();

  	// Handle onAutocomplete callback.
  	if (typeof this.options.onAutocomplete === 'function') {
   	 this.options.onAutocomplete.call(this, text);
  	}
}

M.Autocomplete.prototype.updateData = function(data) {
  	let val = this.el.value.toLowerCase();
  	this.options.data = data;

  	//if (this.isOpen) {
    	this._renderDropdown(data, val);
  	//}
}

// patient consent sign.

M.Autocomplete.prototype._highlight = function(string, $el) {
 
  	var start_end_positions = {};
  	var arr = []


  	// even if we add the html here.
  	// and then get the positions.
  	// later on its going to take that text
  	// but for what take the string directly.
  	var el_text = $el.text();
  	// do the replacer shit here.
  	el_text = this._process_segments(el_text);

  	_.each(string.split(" "), function(st){
  		
  		if(_.isEmpty(st)){
  		}
  		else{
  			_.each(M.Autocomplete.prototype._getIndicesOf(st.toLowerCase(),el_text.toLowerCase()),function(index){
  				arr.push([index,index + st.length]);
  			});
  		
	    }
  	});

  	
  	arr = _.uniq(arr,function(el){
  		return el[0];
  	});

  	arr = _.uniq(arr,function(el){
  		return el[1];
  	});
  	
  	var sorted = _.sortBy(arr, function(item) { 
	   return item[0]; 
	});
	
  	var segments = [];

  	var prev_end = 0;
  	
	_.each(sorted, function(arr,key,list){
		if(key == 0){
			if(arr[0] == 0){
				segments.push('<span>');
				segments.push('<span class="highlight">');
			}	
			else{
				segments.push('<span>');
				segments.push(el_text.slice(0,arr[0]));
				segments.push('<span class="highlight">');
			}
			segments.push(el_text.slice(arr[0],arr[1]));
			segments.push('</span>');
		}
		else{
			prev_el = sorted[key - 1];
			segments.push(el_text.slice(prev_el[1],arr[0]));
			segments.push('<span class="highlight">');
			segments.push(el_text.slice(arr[0],arr[1]));
			segments.push('</span>');
		}
		if(key == (_.size(list) - 1)){
			segments.push(el_text.slice(arr[1],el_text.length));
			segments.push('</span>');
		}
	});
	
	/***
	segments = _.map(segments,function(val){
		return M.Autocomplete.prototype._process_segments(val);
	});
	***/
	
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
	

M.Autocomplete.prototype.replace_up_down = function(match,ud,offset,string){

	if(ud == "up"){
		if(match.indexOf("pattern") != -1){
			return "<i class='material-icons'>arrow_upward</i> pattern";
		}
		else{
			return "<i class='material-icons'>arrow_upward</i>";
		}
	}
	else{
		if(match.indexOf("pattern") != -1){
			return "<i class='material-icons'>arrow_downward</i> pattern";
		}
		else{
			return "<i class='material-icons'>arrow_downward</i>";
		}
	}
}


// so it already has the html tags.
// next step is further normalization of the UI.

M.Autocomplete.prototype.add_superscript_to_standard_deviation = function(setup){

	var pattern = new RegExp(/deviation\s(\d+)/);
	if(! _.isNull(pattern.exec(setup))){
		setup = setup.replace(pattern,function(match,ud,offset,string){
			
			return "deviation <sup>" + ud + "</sup>";
		});
	}
	return setup;
}


M.Autocomplete.prototype.summarize_sma_cross = function(setup){

	// pattern is deviation (number)
	// replace with deviation

	return setup;
}

M.Autocomplete.prototype.replace_pattern_with_icons = function(setup){
	
	// do we have something like 
	var end_pattern = new RegExp(/_(up|down)\s($|pattern)/g);
	var pattern = new RegExp(/(up|down)(?=_(down|up))/g);
	var newText = setup;
	if(!_.isNull(pattern.exec(setup))){
		newText = setup.replace(pattern,this.replace_up_down).replace(/>_</,'');
	}
	if(!_.isNull(end_pattern.exec(setup))){
		//console.log("check now ----------------------->");
		newText = newText.replace(/_(up|down)\s($|pattern)/g,this.replace_up_down).replace(/>_</,'');
		//console.log("check ends ------------------------>");
	}


	return newText;
}



M.Autocomplete.prototype._process_segments = function(segment){
	segment = this.replace_pattern_with_icons(segment);
	segment = this.add_superscript_to_standard_deviation(segment);
	segment = this.summarize_sma_cross(segment);
	return segment;
}