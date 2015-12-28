# docker-shadowsocks-manyuser



|变量名      	|默认参数   	|说明   |
| ------------- |:-------------:| :---|
|MANYUSER       |	            |	可用参数有：R/On 当参数是R的时候则使用ShadowSocksR模式的多用户版本，否则用ShadowSocks原版的多用户模式。|
|MYSQL_HOST |	|当MANYUSER变量有参数时，才会启用。|
|MYSQL_PORT	|	|当MANYUSER变量有参数时，才会启用。|
|MYSQL_USER	||	当MANYUSER变量有参数时，才会启用。|
|MYSQL_DBNAME	| |	当MANYUSER变量有参数时，才会启用。|
|MYSQL_PASSWORD	| |	当MANYUSER变量有参数时，才会启用。|
|METHOD|	aes-256-cfb|	可用选项有:aes-256-cfb aes-192-cfb aes-128-cfb chacha20 salsa20 rc4-md5|
|PROTOCOL|	origin|	可用参数有:origin verify_simple verify_deflate auth_simple|
|OBFS	|http_simple_compatible|	可用参数有：plain http_simple http_simple_compatible tls_simple tls_simple_compatible random_head random_head_compatible OBFS_PARAM|		
|DNS_IPV6|	false|	可用参数有：false true|
