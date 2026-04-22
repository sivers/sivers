// static HTML comments, by Derek Sivers. Article: https://sive.rs/shc


function showForm(uri) {
  document.getElementById('comments').innerHTML = `
<header><h1>Comments:</h1></header>
<form method="post" action="/comments">
<input type="hidden" name="uri" value="${uri}">
<label for="name">Your Name</label>
<input type="text" name="name" id="name" required>
<label for="email">Your Email</label>
<input type="email" name="email" id="email" required>
<label for="comment">Comment</label>
<textarea name="comment" id="comment" cols="80" rows="10" required></textarea>
<input type="submit" value="post comment">
</form>
<ol id="commentlist"></ol>`;
}

function getComments(uri) {
  try {
    const xhr = new XMLHttpRequest();
    xhr.open('get', '/commentcache/' + uri);
    xhr.send(null);
    xhr.onload = function() {
      if (xhr.status === 200) {
        document.getElementById('commentlist').innerHTML = xhr.responseText;
      }
    };
  } catch(e) { }
}

// /blog/topic/page.html uri = 'blog_topic_page.html' for filesystem
const uri = location.pathname.substring(1).replace(/\//g, '_');
showForm(uri);
getComments(uri);
