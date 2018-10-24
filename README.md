# Kong
- need to create your own kong image because of nginx configurations and the custom middleman plugin 


# Build
```
docker build -t kong .
```

# Notes
- this change has to be made to the nginx.conf file because the request headers from keycloak are too big for the default configuration
- then the response containing the access token does not get forwared to the user
```
proxy_buffer_size   128k;
proxy_buffers   4 256k;
proxy_busy_buffers_size   256k;
```

- Kong versions > 0.10 need postgres 9.5 minimum

# Kong Import Export
- use https://github.com/mybuilder/kongfig
- make sure to setup kong admin on the load balancer and change the uri below

## Export
```
kongfig dump --host mykong:8099 > config.yml
```

## Import 
```
kongfig apply --path config.yml --host mykong:8099
````