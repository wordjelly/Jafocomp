$(document).ready(function() {
  // Get all quote elements inside the article
  const articleBody = $('#article');
  const quotes = articleBody.find('quote, blockquote');
  let tweetableUrl = '';
  let clickToTweetBtn = null;
  
  // Get a url of the current page 
  const currentPageUrl = window.location.href;
    
  quotes.each(function (index, quote) {
    const q = $(quote);
    // Create a tweetable url
    tweetableUrl = makeTweetableUrl(
      q.text(), currentPageUrl
    );

    // Create a 'click to tweet' button with appropriate attributes
    clickToTweetBtn = $("<a>");
    clickToTweetBtn.text('Click to Tweet');

    clickToTweetBtn.attr('href', tweetableUrl);
    clickToTweetBtn.on('click', onClickToTweet);

    // Add button to every blockquote
    q.append(clickToTweetBtn);
            
  });

});


function makeTweetableUrl(text, pageUrl) {

  const tweetableText = "https://twitter.com/intent/tweet?url=" + pageUrl + "&text=" + encodeURIComponent(text);
  
  
  return tweetableText;
}

function onClickToTweet(e) {
  e.preventDefault();

  window.open(
    e.target.getAttribute('href'),
    "twitterwindow", 
    "height=450, width=550, toolbar=0, location=0, menubar=0, directories=0, scrollbars=0"
  );
}