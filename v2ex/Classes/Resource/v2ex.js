<script>
window.onload = function(){
    
    // 初始化样式
    initCss();
    
    // 初始化头像点击
    initAvatarOnclick();
    
    function initCss()
    {
        var topic_content = document.getElementsByClassName("topic_content")[0];
        var markdown_body = topic_content.getElementsByClassName("markdown_body");
        if (markdown_body.length == 0)
        {
            topic_content.style.padding = "10px";
        }
    }
    
    function initAvatarOnclick()
    {
        var avatars = document.getElementsByClassName("avatar");
        
        for (var i = 0; i < avatars.length; i++)
        {
            avatars[i].onclick = function(){
                
                var html = this.parentNode.parentNode.innerHTML;
                
                window.location.href= "userId://" + html.match(/member\/(\S*)"/)[1];
            }
        }
    }

    
    var topic_content_images = document.getElementsByClassName("topic_content")[0].getElementsByTagName("img");
//    
//    var reply_content_images = document.getElementsByClassName("reply_content").getElementsByTagName("img");
//    
    contentImageClick(topic_content_images);
//    contentImageClick(reply_content_images);
//    
    function contentImageClick(images)
    {
        for(var i = 0; i < images.length; i++)
        {
            images[i].index = i;
            images[i].onclick = function(){
                
                
                var imagesUrl = "";
                
                if (images.length == 1)
                {
                    window.location.href=("images://--" + this.src+"--");
                    return;
                }
                
                for(var j = 0; j < images.length; j++)
                {
                    if(this.index == j)
                    {
                        imagesUrl += "::--" + images[j].src + "--";
                    }
                    else
                    {
                        imagesUrl += "::" + images[j].src;
                    }
                    
                }
                window.location.href=("images://" + imagesUrl);
            }
        }
    }
    
    
}

</script>
