M.Autocomplete.prototype._highlight = function(string, $el) {
  	//console.log("incoming string is:" + string);
  	var start_end_positions = {};
  	var arr = []
  	_.each(string.split(" "), function(st){
  		//console.log("searching for: " + st + "in string:" + $el.text());
  		if(_.isEmpty(st)){
  		}
  		else{
	  		let img = $el.find('img');
		  	let matchStart = $el
		      .text()
		      .toLowerCase()
		      .indexOf(st.toLowerCase())

		    if(matchStart !== -1){
		    	var matchEnd = matchStart + st.length
		    	arr.push([matchStart,matchEnd]);
			}
	    }
  	});

  	// knock of positive and negative
  	// fix the 

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


// the software will solve
// report typing
// interfacing
// printing -> scheduling of tasks
// cleaning schedules
// payment clarity 
// reminders for the status and schedules
// inventory management
// that will be the end of it
// payumoney (27th)
// balance and top up tests -> (31st)
// order accessibility and statment tests -> 10 november
// rates, packages, notifications -> 20 november
// status, inventory revamp -> 10 december.
// dr sneha joins from the 15th of december and maybe mundhada
// so we have the team, the software and the people in place
// hopefully nabl is moving substantially forward.
// 45 days -> i should be able to make 45 crucial tests pass.


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