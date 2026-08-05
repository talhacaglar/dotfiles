function discord --wraps='env http_proxy=http://127.0.0.1:8118 https_proxy=http://127.0.0.1:8118 /usr/bin/discord --proxy-server="http://127.0.0.1:8118"' --description 'alias discord=env http_proxy=http://127.0.0.1:8118 https_proxy=http://127.0.0.1:8118 /usr/bin/discord --proxy-server="http://127.0.0.1:8118"'
    env http_proxy=http://127.0.0.1:8118 https_proxy=http://127.0.0.1:8118 /usr/bin/discord --proxy-server="http://127.0.0.1:8118" $argv
end
