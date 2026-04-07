(function() {
  /* Putting form in separate-loaded js file hides it from bots */
  function showForm(uri) {
    return `<header><h2>Your thoughts?<br>Please leave a reply:</h2></header>
<form action="/comments/${uri.substring(1)}" method="post">
<label for="namef">Your Name</label>
<input type="text" name="name" id="namef" autocomplete="name" required>
<label for="emailf">Your Email &nbsp;
<span class="small">(private for my eyes only)</span></label>
<input type="email" name="email" id="emailf" autocomplete="email" required>
<label for="comment">Comment</label>
<textarea name="comment" id="comment" cols="80" rows="10" required></textarea><br>
<input name="submit" type="submit" class="submit" value="post comment">
</form>
<header><h2>Comments</h2></header>
<div id="commentlist"></div>`;
  }
  function getComments(uri) {
    try {
      var xhr = new XMLHttpRequest();
      xhr.onreadystatechange = function() {
        if (xhr.readyState === 4 && xhr.status === 200) {
          document.getElementById('commentlist').innerHTML = xhr.responseText;
        }
      };
      xhr.open('get', '/comments' + uri, true);
      xhr.send(null);
    } catch(e) { }
  }
  var isLoaded = false;
  function showComments() {
    if (isLoaded) { return; }
    document.getElementById('comments').innerHTML = showForm(location.pathname);
    getComments(location.pathname);
    isLoaded = true;
    window.onscroll = null;
  }
  function weHitBottom() {
    var contentHeight = document.getElementsByTagName('main')[0].offsetHeight;
    var y1 = (window.pageYOffset !== undefined) ? window.pageYOffset : (document.documentElement || document.body.parentNode || document.body).scrollTop;
    var y2 = (window.innerHeight !== undefined) ? window.innerHeight : document.documentElement.clientHeight;
    var y = y1 + y2;
    if (y >= contentHeight) { showComments(); }
  }
  weHitBottom();
  if (isLoaded === false) { window.onscroll = weHitBottom; }
  if (/comment-\d+/.test(location.hash)) { showComments(); }
})();
