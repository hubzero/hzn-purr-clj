# How this Works

Q: Why is this complex? 
A: Because we have an overly complex CMS and no easy way to "integrate" things that are not "CMS" into it. Even CMS "thigns" are complicated to integrate.

## dev.purr && purr production

### systemd 

Use and install `pubs.service`:

```
cp pubs.service /etc/systemd/system/
systemctl enable pubs.service
systemctl start pubs
```

The script assumes the target run location of: `/opt/hubzero/pubs`.

This directory will contain:

```
drwx--S--- 2 apache   apache     4096 Feb 26 09:33 log
-rw-r--r-x 1 hubadmin apache 27693709 Jan  6 11:32 pubs-api.jar
-rw-rw---- 1 hubadmin apache       12 Feb 26 07:45 pubs.conf
-rw-rw---- 1 hubadmin apache      845 Jan 20 12:19 pubs.edn
-rw------- 1 hubadmin apache      345 Feb 26 09:37 pubs.service
```

`log` gets created on system startup and has the running application logs. They are set to rotate.
`pubs.conf` is a systemd ENVIRONMENT listing, which contains a `secret` for user Auth decoding.
`pubs.edn` is the application configuration used when starting the API.

## Pieces

- CMS
- com_pubs
- Clojure API
- Clojure SPA

In all existing systems, the users interact with our universe through the CMS.
In order to promote new systems while still maintaing this interface, some
_glue_ is created. This is `com_pubs`. 

`com_pubs` Is a simple CMS component that serves some inline SVG and complied
CLJS->JS code. That's it. "New Publications" has to be turned on in the 
`/administrator` console under _Projects - Publications_ plugin management.

`API` runs as a standalone JVM process and binds on a configured port. The
fronting webserver must be configured to proxy requests to this process. 
Ideally, this would be its own Docker container, but right now it is not.
Requests coming to `/p/` are routed here:

```
location ^~ /p/ {
```

In HZ Prod, this is an Apache ProxyPass statement. Here, it is bundled nginx 
configuration located in `hzcms-docker/docker/nginx/nginx.conf`.

`SPA` Is React.JS via ClojureScript that must be compiled. This compiled
asset is then sent along with `com_pubs` which is responsible for delivering
it to the end user. In this development environment, we are volume mounting
the compiled code into the correct location so the webserver can find it.