
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});

Parse.Cloud.define("top", function(request, response) {
	var WTF = Parse.Object.extend("WTF");
	var query = new Parse.Query(WTF);
	query.limit(10);
	query.descending("severity");
	query.find({
	  success: function(results) {
	    alert("Successfully retrieved " + results.length + " scores.");
	    // Do something with the returned Parse.Object values
	    for (var i = 0; i < results.length; i++) { 
	      var object = results[i];
	      alert(object.id + ' - ' + object.get('fileName'));
	    }
	    response.success(results);
	  },
	  error: function(error) {
	    alert("Error: " + error.code + " " + error.message);
	    response.error(error);
	  }
	});
});