# Treasure Data Social Grader

This is a handy tool to get quick stats on content popularity.

## Using it as a bookmarklet

Save this bookmarklet in your bookmark toolbar.

```js
javascript:td_social_grader=function(d){var msg=[];msg.push("Tweets:"+d.twitter); msg.push("FB Likes:"+d.facebook);msg.push("LinkedIn:"+d.linkedin);msg.push("Hatebu:"+d.hatebu);alert(msg.join("\n"))};var td_aoiyu=document.createElement("script");td_aoiyu.src=window.location.protocol+"//td-social-grader.herokuapp.com/jsonp?u="+window.location;document.body.appendChild(td_aoiyu);void(0);
```

When you click on it, it shows you how many people have Liked/Tweeted/LinkedIn shared/Hatena bookmarked the entry.
