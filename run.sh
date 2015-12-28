
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
38
39
40
41
42
43
44
45
46
47
48
49
50
51
52
53
54
55
56
57
58
59
60
61
62
63
64
65
66
67
68
69
70
71
72
73
74
75
76
77
78
79
80
81
82
83
84
85
86
87
88
89
90
91
92
93
94
95
96
97
98
99
100
101
102
103
104
105
106
107
108
109
110
111
112
113
114
115
116
117
118
119
120
121
122
123
124
125
126
127
128
129
130
131
132
133
134
135
136
137
138
139
140
141
142
143
144
145
146
147
148
149
150
#!/bin/sh
#########################################################################
# File Name: run.sh
# Author: LookBack
# Email: admin#dwhd.org
# Version:
# Created Time: 2015年11月18日 星期三 02时49分12秒
#########################################################################
PATH=/bin:/sbin:$PATH
 
set -e
 
if [ "${1:0:1}" = '-' ]; then
    set -- python "$@"
fi
 
if [ -n "$MANYUSER" ]; then
        if [ -z "$MYSQL_PASSWORD" ]; then
                echo >&2 'error:  missing MYSQL_PASSWORD'
                echo >&2 '  Did you forget to add -e MYSQL_PASSWORD=... ?'
                exit 1
        fi
 
        if [ -z "$MYSQL_USER" ]; then
                echo >&2 'error:  missing MYSQL_USER'
                echo >&2 '  Did you forget to add -e MYSQL_USER=... ?'
                exit 1
        fi
 
        if [ -z "$MYSQL_PORT" ]; then
                echo >&2 'error:  missing MYSQL_PORT'
                echo >&2 '  Did you forget to add -e MYSQL_PORT=... ?'
                exit 1
        fi
 
        if [ -z "$MYSQL_HOST" ]; then
                echo >&2 'error:  missing MYSQL_HOST'
                echo >&2 '  Did you forget to add -e MYSQL_HOST=... ?'
                exit 1
        fi
 
        if [ -z "$MYSQL_DBNAME" ]; then
                echo >&2 'error:  missing MYSQL_DBNAME'
                echo >&2 '  Did you forget to add -e MYSQL_DBNAME=... ?'
                exit 1
        fi
 
        for i in $MYSQL_USER $MYSQL_PORT $MYSQL_HOST $MYSQL_DBNAME $MYSQL_PASSWORD; do
                if grep '@' <<<"$i" >/dev/null 2>&1; then
                        echo >&2 "error:  missing -e $i"
                        echo >&2 "  You can't special characters '@'"
                        exit 1
                fi
        done
  
        sed -ri "s@^(MYSQL_HOST = ).*@\1'$MYSQL_HOST'@" /shadowsocks/Config.py
        sed -ri "s@^(MYSQL_PORT = ).*@\1$MYSQL_PORT@" /shadowsocks/Config.py
        sed -ri "s@^(MYSQL_USER = ).*@\1'$MYSQL_USER'@" /shadowsocks/Config.py
        sed -ri "s@^(MYSQL_PASS = ).*@\1'$MYSQL_PASSWORD'@" /shadowsocks/Config.py
        sed -ri "s@^(MYSQL_DB = ).*@\1'$MYSQL_DBNAME'@" /shadowsocks/Config.py
else
        echo >&2 'error:  missing MANYUSER'
        echo >&2 '  Did you forget to add -e MANYUSER=... ?'
        exit 1
fi
 
if [ "$MANYUSER" = "R" ]; then
        if [ -z "$PROTOCOL" ]; then
                echo >&2 'error:  missing PROTOCOL'
                echo >&2 '  Did you forget to add -e PROTOCOL=... ?'
                exit 1
        elif [[ ! "$PROTOCOL" =~ ^(origin|verify_simple|verify_deflate|auth_simple)$ ]]; then
                echo >&2 'error : missing PROTOCOL'
                echo >&2 '  You must be used -e PROTOCOL=[origin|verify_simple|verify_deflate|auth_simple]'
                exit 1
        fi
 
        if [ -z "$OBFS" ]; then
                echo >&2 'error:  missing OBFS'
                echo >&2 '  Did you forget to add -e OBFS=... ?'
                exit 1
        elif [[ ! "$OBFS" =~ ^(plain|http_simple|http_simple_compatible|tls_simple|tls_simple_compatible|random_head|random_head_compatible)$ ]]; then
                echo >&2 'error:  missing OBFS'
                echo >&2 '  You must be used -e OBFS=[http_simple|plain|http_simple_compatible|tls_simple|tls_simple_compatible|random_head|random_head_compatible]'
                exit 1
        fi
 
        if [ -z "$OBFS_PARAM" ]; then
                echo >&2 'error:  missing OBFS_PARAM'
                echo >&2 '  Did you forget to add -e OBFS_PARAM=... ?'
                exit 1
        fi
 
        if [ -n "$METHOD" ]; then
                if [[ ! "$METHOD" =~ ^(aes-(256|192|128)-cfb|(chacha|salsa)20|rc4-md5)$ ]]; then
                        echo >&2 'error:  missing METHOD'
                        echo >&2 '  You must be used -e METHOD=[aes-256-cfb|aes-192-cfb|aes-128-cfb|chacha20|salsa20|rc4-md5]'
                        exit 1
                else
                        sed -ri "s@^(.*\"method\": ).*@\1\"$METHOD\",@" /shadowsocks/config.json
                fi
        fi
 
        if [ -n "$DNS_IPV6" ]; then
                if [[ ! "$DNS_IPV6" =~ ^(false|true)$ ]]; then
                        echo >&2 'error:  missing DNS_IPV6'
                        echo >&2 '  You must be used -e DNS_IPV6=[false|true]'
                        exit 1
                else
                        sed -ri "s@^(.*\"dns_ipv6\": ).*@\1\"$DNS_IPV6\",@" /shadowsocks/config.json
                fi
        fi
 
        sed -ri "s@^(.*\"protocol\": ).*@\1\"$PROTOCOL\",@" /shadowsocks/config.json
        sed -ri "s@^(.*\"obfs\": ).*@\1\"$OBFS\",@" /shadowsocks/config.json
        sed -ri "s@^(.*\"obfs_param\": ).*@\1\"$OBFS_PARAM\",@" /shadowsocks/config.json
 
fi
 
if [ -n "$SPAM" ]; then
        if [ "$SPAM" = "On" ]; then
                iptables -t mangle -A OUTPUT -m string --string "Subject" --algo bm --to 65535 -j DROP
                iptables -t mangle -A OUTPUT -m string --string "HELO" --algo bm --to 65535 -j DROP
                iptables -t mangle -A OUTPUT -m string --string "SMTP" --algo bm --to 65535 -j DROP
                iptables -t mangle -A OUTPUT -m string --string "torrent" --algo bm --to 65535 -j DROP
                iptables -t mangle -A OUTPUT -m string --string ".torrent" --algo bm --to 65535 -j DROP
                iptables -t mangle -A OUTPUT -m string --string "peer_id=" --algo bm --to 65535 -j DROP
                iptables -t mangle -A OUTPUT -m string --string "announce" --algo bm --to 65535 -j DROP
                iptables -t mangle -A OUTPUT -m string --string "info_hash" --algo bm --to 65535 -j DROP
                iptables -t mangle -A OUTPUT -m string --string "get_peers" --algo bm --to 65535 -j DROP
                iptables -t mangle -A OUTPUT -m string --string "find_node" --algo bm --to 65535 -j DROP
                iptables -t mangle -A OUTPUT -m string --string "BitTorrent" --algo bm --to 65535 -j DROP
                iptables -t mangle -A OUTPUT -m string --string "announce_peer" --algo bm --to 65535 -j DROP
                iptables -t mangle -A OUTPUT -m string --string "BitTorrent" --algo bm --to 65535 -j DROP
                iptables -t mangle -A OUTPUT -m string --string "protocol" --algo bm --to 65535 -j DROP
                iptables -t mangle -A OUTPUT -m string --string "announce.php?passkey=" --algo bm --to 65535 -j DROP
                iptables -t filter -A OUTPUT -p tcp -m multiport --dports 25,26,465 -m state --state NEW,ESTABLISHED -j REJECT --reject-with icmp-port-unreachable
                iptables -t filter -A OUTPUT -p tcp -m multiport --dports 109,110,995 -m state --state NEW,ESTABLISHED -j REJECT --reject-with icmp-port-unreachable
                iptables -t filter -A OUTPUT -p tcp -m multiport --dports 143,218,220,993 -m state --state NEW,ESTABLISHED -j REJECT --reject-with icmp-port-unreachable
                iptables -t filter -A OUTPUT -p tcp -m multiport --dports 24,50,57,105,106,158,209,587,1109,24554,60177,60179 -m state --state NEW,ESTABLISHED -j REJECT --reject-with icmp-port-unreachable
                iptables -t mangle -L -nvx --lin
                iptables -t filter -L -nvx --lin
        fi
else
        echo >&2 'error:  missing SPAM'
        echo >&2 '  You must be used -e SPAM=[On|Off]'
fi
 
exec python /shadowsocks/server.py
