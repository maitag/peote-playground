# Simple chat prototype that can be build into 3 modes:

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


## TODO

- [x] wordwrapping in clientViews chat-output textpage
- [x] glitch: chat output page scrolls back if there something is "selected" ?
- [x] give the username into chat-output a more fresh green color
- [x] ctrl-a to select all into input-textline have a glitch (thx to logo to find!)
- [x] automatic input focus if chat starts
- [x] prevent double spaces and take care on min/max-length for the nickname (also while editing!)
- [x] a simple "enter" button while login and "send" button beside the chat input TextLine
- [x] let the log-field for the client easy en/disable by compilerdefine
- [x] let the client re-connect on error and keep the nickname-input on top of chat-output area
- [x] fixing bug in peote-socket lib where after closing the websocket it send events after closeTimeout
- [x] servercheck that new nickname not already exists -> have to call a client remote function into this case
- [x] copy into clipboard by simple select inside the chat-output textpage
- [x] simple "/who" command in client to show who is logged on
- [x] another Client/Server Constellation where the server is opened on demand (if the "channel" is free, otherwise it only "enters" the client)
- [x] for web-clients the "channel" name have to be fetched from url/param
- [ ] fix glitches on mobile browsers and softkeyboard (resizing/input focus!)
- [ ] make compatible for limes android target