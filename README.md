# README #

# README #
Example usage NSOperation for concurrency in swift 2.0 to find the following patterns in a string  and compose a JSON.

1, EmotIcons - Emoticons which are alphanumeric strings, no longer than 15 characters, contained in parenthesis eg (success)

2, Mentions - Always starts with an '@' and ends when hitting a non-word character e.g. @saiserf

3, URLs - Detect urls in the chat plus the title of that url.

Eg input,  hello @tonku see the (funny) news www.cnn.com 

the output is {"links" : [ {"title" : "CNN - Breaking News, U.S., World, Weather, Entertainment & Video News","url" : "http:\\www.cnn.com" }  ],  "emoticons" : ["funny"],"mentions" : ["@tonku","@daigdn"  ]}

The flow diagram of the app is given below

![HipChatFlow.png](https://bitbucket.org/repo/z4LEBd/images/2950891983-HipChatFlow.png)