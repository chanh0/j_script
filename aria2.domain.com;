#redirect aria rpc/rpcjson to host/LAN ip
# http://aria2.domain.com/ serve AriaNG allinone html

server {
    listen 80;
    #listen 443;
    root /config/www/webui; #save AriaNg-1.3.6-AllInOne\index.html #https://github.com/mayswind/AriaNg/releases
    index index.html; 
    server_name aria2.domain.com;

    location /jsonrpc {
        proxy_pass http://0.0.0.0:6800/jsonrpc;
        proxy_http_version 1.1;
        #The following code supports WebSocket
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_read_timeout 86400;
    }
    location /rpc {
        proxy_pass http://0.0.0.0:6800/rpc;
        proxy_http_version 1.1;
       	#The following code supports WebSocket
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_read_timeout 86400;
    }
}
