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