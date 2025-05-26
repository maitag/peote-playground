Simple chat prototype that can be build into 3 modes:

- offline mode what include the server and two clients for developing
- a gui server (`-D server`)
- a gui client (`-D client`)

other available compiler defines are:  

`-D host=127.0.0.1` for the host (can also be a domain name)  

`-D port=1234` for the port number  

`-D channel=mychat` name of the peote-net channel  

or look into Config.hx for the defaults!

Example build command:
`lime test neko -D server -D host=chat.myhost-where-peote-s3rv3r.run -D port=3210 -D channel=testingChan`
  

You can also create a dedicated server as commandline tool,  
use the scripts into server-cli/ folder to build it.


##TODO

- [x] wordwrapping in clientViews chat-output textpage
- [ ] servercheck that new nickname not already exists -> have to call a client remote function into this case
- [ ] copy paste and other keyboard events for the chat-output textpage
- [x] glitch: chat output page scrolls back if there something is "selected" ?
- [x] give the username into chat-output a more fresh green color
- [ ] ctrl-a to select all into input-textline have a glitch (thx to logo to find!)
- [ ] automatic input focus if chat starts
- [ ] for web-clients the "channel" name have to be fetched from url/param
- [ ] let Client automatic try to connect again (after little timeout) if the connection gets lost
- [ ] another Client/Server Constellation where the server is opened on demand (if the "channel" is free, otherwise it only "enters" the client)
- [ ] a simple "enter" button while login and "send" button beside the chat input TextLine
- [ ] if a new user enters there should be transmitted the informations about the haxe-version and target
- [ ] one simple `/who` command to let the server transmit who is logged on